# frozen_string_literal: true

require "cose/key/base"

module COSE
  module Key
    class RSA < Base
      LABEL_N = -1
      LABEL_E = -2
      LABEL_D = -3
      LABEL_P = -4
      LABEL_Q = -5
      LABEL_D_P = -6
      LABEL_D_Q = -7
      LABEL_Q_INV = -8

      KTY_RSA = 3

      def self.from_pkey(pkey)
        params = pkey.params

        attributes = {
          modulus_n: params["n"].to_s(2),
          public_exponent_e: params["e"].to_s(2)
        }

        if pkey.private?
          attributes.merge!(
            private_exponent_d: params["d"].to_s(2),
            prime_factor_p: params["p"].to_s(2),
            prime_factor_q: params["q"].to_s(2),
            d_p: params["dmp1"].to_s(2),
            d_q: params["dmq1"].to_s(2),
            q_inv: params["iqmp"].to_s(2)
          )
        end

        new(attributes)
      end

      attr_reader :modulus_n, :public_exponent_e, :private_exponent_d, :prime_factor_p, :prime_factor_q, :d_p, :d_q, :q_inv

      def initialize(modulus_n:, public_exponent_e:, private_exponent_d: nil, prime_factor_p: nil, prime_factor_q: nil, d_p: nil, d_q: nil, q_inv: nil)
        if !modulus_n
          raise ArgumentError, "Required modulus_n is missing"
        elsif !public_exponent_e
          raise ArgumentError, "Required public_exponent_e is missing"
        else
          @modulus_n = modulus_n
          @public_exponent_e = public_exponent_e
          @private_exponent_d = private_exponent_d
          @prime_factor_p = prime_factor_p
          @prime_factor_q = prime_factor_q
          @d_p = d_p
          @d_q = d_q
          @q_inv = q_inv
        end
      end

      def serialize
        CBOR.encode(
          Base::LABEL_KTY => KTY_RSA,
          LABEL_N => modulus_n,
          LABEL_E => public_exponent_e,
          LABEL_D => private_exponent_d,
          LABEL_P => prime_factor_p,
          LABEL_Q => prime_factor_q,
          LABEL_D_P => d_p,
          LABEL_D_Q => d_q,
          LABEL_Q_INV => q_inv
        )
      end

      def self.from_map(map)
        enforce_type(map, KTY_RSA, "Not an RSA key")

        new(modulus_n: map[LABEL_N], public_exponent_e: map[LABEL_E])
      end
    end
  end
end
