Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:38473 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbcA2RWp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jan 2016 12:22:45 -0500
Date: Fri, 29 Jan 2016 11:22:30 -0600
From: Tyler Hicks <tyhicks@canonical.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Julia Lawall <julia.lawall@lip6.fr>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        dm-devel@redhat.com, linux-wireless@vger.kernel.org,
        linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
        linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
        drbd-dev@lists.linbit.com, open-iscsi@googlegroups.com,
        kbuild-all@01.org
Subject: Re: [v2 PATCH 9/26] eCryptfs: Use skcipher and shash
Message-ID: <20160129172229.GA4818@boyd>
References: <201601250207.1gdHywwq%fengguang.wu@intel.com>
 <alpine.DEB.2.10.1601241909430.2498@hadrien>
 <20160125022933.GA4345@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="huq684BweRXVnRxX"
In-Reply-To: <20160125022933.GA4345@gondor.apana.org.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2016-01-25 10:29:33, Herbert Xu wrote:
> On Sun, Jan 24, 2016 at 07:10:50PM +0100, Julia Lawall wrote:
> > Maybe the goto on line 1726 needs a preceding mutex_unlock?
>=20
> Good catch! Thanks.
>=20
> ---8<---
> This patch replaces uses of ablkcipher and blkcipher with skcipher,
> and the long obsolete hash interface with shash.
>=20
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Tyler Hicks <tyhicks@canonical.com>

I have no problem with you taking this through the cryptodev tree.
Thanks!

Tyler

>=20
> diff --git a/fs/ecryptfs/crypto.c b/fs/ecryptfs/crypto.c
> index 80d6901..11255cb 100644
> --- a/fs/ecryptfs/crypto.c
> +++ b/fs/ecryptfs/crypto.c
> @@ -23,6 +23,8 @@
>   * 02111-1307, USA.
>   */
> =20
> +#include <crypto/hash.h>
> +#include <crypto/skcipher.h>
>  #include <linux/fs.h>
>  #include <linux/mount.h>
>  #include <linux/pagemap.h>
> @@ -30,7 +32,6 @@
>  #include <linux/compiler.h>
>  #include <linux/key.h>
>  #include <linux/namei.h>
> -#include <linux/crypto.h>
>  #include <linux/file.h>
>  #include <linux/scatterlist.h>
>  #include <linux/slab.h>
> @@ -74,6 +75,19 @@ void ecryptfs_from_hex(char *dst, char *src, int dst_s=
ize)
>  	}
>  }
> =20
> +static int ecryptfs_hash_digest(struct crypto_shash *tfm,
> +				char *src, int len, char *dst)
> +{
> +	SHASH_DESC_ON_STACK(desc, tfm);
> +	int err;
> +
> +	desc->tfm =3D tfm;
> +	desc->flags =3D CRYPTO_TFM_REQ_MAY_SLEEP;
> +	err =3D crypto_shash_digest(desc, src, len, dst);
> +	shash_desc_zero(desc);
> +	return err;
> +}
> +
>  /**
>   * ecryptfs_calculate_md5 - calculates the md5 of @src
>   * @dst: Pointer to 16 bytes of allocated memory
> @@ -88,45 +102,26 @@ static int ecryptfs_calculate_md5(char *dst,
>  				  struct ecryptfs_crypt_stat *crypt_stat,
>  				  char *src, int len)
>  {
> -	struct scatterlist sg;
> -	struct hash_desc desc =3D {
> -		.tfm =3D crypt_stat->hash_tfm,
> -		.flags =3D CRYPTO_TFM_REQ_MAY_SLEEP
> -	};
> +	struct crypto_shash *tfm;
>  	int rc =3D 0;
> =20
>  	mutex_lock(&crypt_stat->cs_hash_tfm_mutex);
> -	sg_init_one(&sg, (u8 *)src, len);
> -	if (!desc.tfm) {
> -		desc.tfm =3D crypto_alloc_hash(ECRYPTFS_DEFAULT_HASH, 0,
> -					     CRYPTO_ALG_ASYNC);
> -		if (IS_ERR(desc.tfm)) {
> -			rc =3D PTR_ERR(desc.tfm);
> +	tfm =3D crypt_stat->hash_tfm;
> +	if (!tfm) {
> +		tfm =3D crypto_alloc_shash(ECRYPTFS_DEFAULT_HASH, 0, 0);
> +		if (IS_ERR(tfm)) {
> +			rc =3D PTR_ERR(tfm);
>  			ecryptfs_printk(KERN_ERR, "Error attempting to "
>  					"allocate crypto context; rc =3D [%d]\n",
>  					rc);
>  			goto out;
>  		}
> -		crypt_stat->hash_tfm =3D desc.tfm;
> -	}
> -	rc =3D crypto_hash_init(&desc);
> -	if (rc) {
> -		printk(KERN_ERR
> -		       "%s: Error initializing crypto hash; rc =3D [%d]\n",
> -		       __func__, rc);
> -		goto out;
> +		crypt_stat->hash_tfm =3D tfm;
>  	}
> -	rc =3D crypto_hash_update(&desc, &sg, len);
> +	rc =3D ecryptfs_hash_digest(tfm, src, len, dst);
>  	if (rc) {
>  		printk(KERN_ERR
> -		       "%s: Error updating crypto hash; rc =3D [%d]\n",
> -		       __func__, rc);
> -		goto out;
> -	}
> -	rc =3D crypto_hash_final(&desc, dst);
> -	if (rc) {
> -		printk(KERN_ERR
> -		       "%s: Error finalizing crypto hash; rc =3D [%d]\n",
> +		       "%s: Error computing crypto hash; rc =3D [%d]\n",
>  		       __func__, rc);
>  		goto out;
>  	}
> @@ -234,10 +229,8 @@ void ecryptfs_destroy_crypt_stat(struct ecryptfs_cry=
pt_stat *crypt_stat)
>  {
>  	struct ecryptfs_key_sig *key_sig, *key_sig_tmp;
> =20
> -	if (crypt_stat->tfm)
> -		crypto_free_ablkcipher(crypt_stat->tfm);
> -	if (crypt_stat->hash_tfm)
> -		crypto_free_hash(crypt_stat->hash_tfm);
> +	crypto_free_skcipher(crypt_stat->tfm);
> +	crypto_free_shash(crypt_stat->hash_tfm);
>  	list_for_each_entry_safe(key_sig, key_sig_tmp,
>  				 &crypt_stat->keysig_list, crypt_stat_list) {
>  		list_del(&key_sig->crypt_stat_list);
> @@ -342,7 +335,7 @@ static int crypt_scatterlist(struct ecryptfs_crypt_st=
at *crypt_stat,
>  			     struct scatterlist *src_sg, int size,
>  			     unsigned char *iv, int op)
>  {
> -	struct ablkcipher_request *req =3D NULL;
> +	struct skcipher_request *req =3D NULL;
>  	struct extent_crypt_result ecr;
>  	int rc =3D 0;
> =20
> @@ -358,20 +351,20 @@ static int crypt_scatterlist(struct ecryptfs_crypt_=
stat *crypt_stat,
>  	init_completion(&ecr.completion);
> =20
>  	mutex_lock(&crypt_stat->cs_tfm_mutex);
> -	req =3D ablkcipher_request_alloc(crypt_stat->tfm, GFP_NOFS);
> +	req =3D skcipher_request_alloc(crypt_stat->tfm, GFP_NOFS);
>  	if (!req) {
>  		mutex_unlock(&crypt_stat->cs_tfm_mutex);
>  		rc =3D -ENOMEM;
>  		goto out;
>  	}
> =20
> -	ablkcipher_request_set_callback(req,
> +	skcipher_request_set_callback(req,
>  			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
>  			extent_crypt_complete, &ecr);
>  	/* Consider doing this once, when the file is opened */
>  	if (!(crypt_stat->flags & ECRYPTFS_KEY_SET)) {
> -		rc =3D crypto_ablkcipher_setkey(crypt_stat->tfm, crypt_stat->key,
> -					      crypt_stat->key_size);
> +		rc =3D crypto_skcipher_setkey(crypt_stat->tfm, crypt_stat->key,
> +					    crypt_stat->key_size);
>  		if (rc) {
>  			ecryptfs_printk(KERN_ERR,
>  					"Error setting key; rc =3D [%d]\n",
> @@ -383,9 +376,9 @@ static int crypt_scatterlist(struct ecryptfs_crypt_st=
at *crypt_stat,
>  		crypt_stat->flags |=3D ECRYPTFS_KEY_SET;
>  	}
>  	mutex_unlock(&crypt_stat->cs_tfm_mutex);
> -	ablkcipher_request_set_crypt(req, src_sg, dst_sg, size, iv);
> -	rc =3D op =3D=3D ENCRYPT ? crypto_ablkcipher_encrypt(req) :
> -			     crypto_ablkcipher_decrypt(req);
> +	skcipher_request_set_crypt(req, src_sg, dst_sg, size, iv);
> +	rc =3D op =3D=3D ENCRYPT ? crypto_skcipher_encrypt(req) :
> +			     crypto_skcipher_decrypt(req);
>  	if (rc =3D=3D -EINPROGRESS || rc =3D=3D -EBUSY) {
>  		struct extent_crypt_result *ecr =3D req->base.data;
> =20
> @@ -394,7 +387,7 @@ static int crypt_scatterlist(struct ecryptfs_crypt_st=
at *crypt_stat,
>  		reinit_completion(&ecr->completion);
>  	}
>  out:
> -	ablkcipher_request_free(req);
> +	skcipher_request_free(req);
>  	return rc;
>  }
> =20
> @@ -622,7 +615,7 @@ int ecryptfs_init_crypt_ctx(struct ecryptfs_crypt_sta=
t *crypt_stat)
>  						    crypt_stat->cipher, "cbc");
>  	if (rc)
>  		goto out_unlock;
> -	crypt_stat->tfm =3D crypto_alloc_ablkcipher(full_alg_name, 0, 0);
> +	crypt_stat->tfm =3D crypto_alloc_skcipher(full_alg_name, 0, 0);
>  	if (IS_ERR(crypt_stat->tfm)) {
>  		rc =3D PTR_ERR(crypt_stat->tfm);
>  		crypt_stat->tfm =3D NULL;
> @@ -631,7 +624,7 @@ int ecryptfs_init_crypt_ctx(struct ecryptfs_crypt_sta=
t *crypt_stat)
>  				full_alg_name);
>  		goto out_free;
>  	}
> -	crypto_ablkcipher_set_flags(crypt_stat->tfm, CRYPTO_TFM_REQ_WEAK_KEY);
> +	crypto_skcipher_set_flags(crypt_stat->tfm, CRYPTO_TFM_REQ_WEAK_KEY);
>  	rc =3D 0;
>  out_free:
>  	kfree(full_alg_name);
> @@ -1591,7 +1584,7 @@ out:
>   * event, regardless of whether this function succeeds for fails.
>   */
>  static int
> -ecryptfs_process_key_cipher(struct crypto_blkcipher **key_tfm,
> +ecryptfs_process_key_cipher(struct crypto_skcipher **key_tfm,
>  			    char *cipher_name, size_t *key_size)
>  {
>  	char dummy_key[ECRYPTFS_MAX_KEY_BYTES];
> @@ -1609,21 +1602,18 @@ ecryptfs_process_key_cipher(struct crypto_blkciph=
er **key_tfm,
>  						    "ecb");
>  	if (rc)
>  		goto out;
> -	*key_tfm =3D crypto_alloc_blkcipher(full_alg_name, 0, CRYPTO_ALG_ASYNC);
> +	*key_tfm =3D crypto_alloc_skcipher(full_alg_name, 0, CRYPTO_ALG_ASYNC);
>  	if (IS_ERR(*key_tfm)) {
>  		rc =3D PTR_ERR(*key_tfm);
>  		printk(KERN_ERR "Unable to allocate crypto cipher with name "
>  		       "[%s]; rc =3D [%d]\n", full_alg_name, rc);
>  		goto out;
>  	}
> -	crypto_blkcipher_set_flags(*key_tfm, CRYPTO_TFM_REQ_WEAK_KEY);
> -	if (*key_size =3D=3D 0) {
> -		struct blkcipher_alg *alg =3D crypto_blkcipher_alg(*key_tfm);
> -
> -		*key_size =3D alg->max_keysize;
> -	}
> +	crypto_skcipher_set_flags(*key_tfm, CRYPTO_TFM_REQ_WEAK_KEY);
> +	if (*key_size =3D=3D 0)
> +		*key_size =3D crypto_skcipher_default_keysize(*key_tfm);
>  	get_random_bytes(dummy_key, *key_size);
> -	rc =3D crypto_blkcipher_setkey(*key_tfm, dummy_key, *key_size);
> +	rc =3D crypto_skcipher_setkey(*key_tfm, dummy_key, *key_size);
>  	if (rc) {
>  		printk(KERN_ERR "Error attempting to set key of size [%zd] for "
>  		       "cipher [%s]; rc =3D [%d]\n", *key_size, full_alg_name,
> @@ -1660,8 +1650,7 @@ int ecryptfs_destroy_crypto(void)
>  	list_for_each_entry_safe(key_tfm, key_tfm_tmp, &key_tfm_list,
>  				 key_tfm_list) {
>  		list_del(&key_tfm->key_tfm_list);
> -		if (key_tfm->key_tfm)
> -			crypto_free_blkcipher(key_tfm->key_tfm);
> +		crypto_free_skcipher(key_tfm->key_tfm);
>  		kmem_cache_free(ecryptfs_key_tfm_cache, key_tfm);
>  	}
>  	mutex_unlock(&key_tfm_list_mutex);
> @@ -1747,7 +1736,7 @@ int ecryptfs_tfm_exists(char *cipher_name, struct e=
cryptfs_key_tfm **key_tfm)
>   * Searches for cached item first, and creates new if not found.
>   * Returns 0 on success, non-zero if adding new cipher failed
>   */
> -int ecryptfs_get_tfm_and_mutex_for_cipher_name(struct crypto_blkcipher *=
*tfm,
> +int ecryptfs_get_tfm_and_mutex_for_cipher_name(struct crypto_skcipher **=
tfm,
>  					       struct mutex **tfm_mutex,
>  					       char *cipher_name)
>  {
> @@ -2120,7 +2109,7 @@ out:
>  int ecryptfs_set_f_namelen(long *namelen, long lower_namelen,
>  			   struct ecryptfs_mount_crypt_stat *mount_crypt_stat)
>  {
> -	struct blkcipher_desc desc;
> +	struct crypto_skcipher *tfm;
>  	struct mutex *tfm_mutex;
>  	size_t cipher_blocksize;
>  	int rc;
> @@ -2130,7 +2119,7 @@ int ecryptfs_set_f_namelen(long *namelen, long lowe=
r_namelen,
>  		return 0;
>  	}
> =20
> -	rc =3D ecryptfs_get_tfm_and_mutex_for_cipher_name(&desc.tfm, &tfm_mutex,
> +	rc =3D ecryptfs_get_tfm_and_mutex_for_cipher_name(&tfm, &tfm_mutex,
>  			mount_crypt_stat->global_default_fn_cipher_name);
>  	if (unlikely(rc)) {
>  		(*namelen) =3D 0;
> @@ -2138,7 +2127,7 @@ int ecryptfs_set_f_namelen(long *namelen, long lowe=
r_namelen,
>  	}
> =20
>  	mutex_lock(tfm_mutex);
> -	cipher_blocksize =3D crypto_blkcipher_blocksize(desc.tfm);
> +	cipher_blocksize =3D crypto_skcipher_blocksize(tfm);
>  	mutex_unlock(tfm_mutex);
> =20
>  	/* Return an exact amount for the common cases */
> diff --git a/fs/ecryptfs/ecryptfs_kernel.h b/fs/ecryptfs/ecryptfs_kernel.h
> index 7b39260..b7f8128 100644
> --- a/fs/ecryptfs/ecryptfs_kernel.h
> +++ b/fs/ecryptfs/ecryptfs_kernel.h
> @@ -28,6 +28,7 @@
>  #ifndef ECRYPTFS_KERNEL_H
>  #define ECRYPTFS_KERNEL_H
> =20
> +#include <crypto/skcipher.h>
>  #include <keys/user-type.h>
>  #include <keys/encrypted-type.h>
>  #include <linux/fs.h>
> @@ -38,7 +39,6 @@
>  #include <linux/nsproxy.h>
>  #include <linux/backing-dev.h>
>  #include <linux/ecryptfs.h>
> -#include <linux/crypto.h>
> =20
>  #define ECRYPTFS_DEFAULT_IV_BYTES 16
>  #define ECRYPTFS_DEFAULT_EXTENT_SIZE 4096
> @@ -233,9 +233,9 @@ struct ecryptfs_crypt_stat {
>  	size_t extent_shift;
>  	unsigned int extent_mask;
>  	struct ecryptfs_mount_crypt_stat *mount_crypt_stat;
> -	struct crypto_ablkcipher *tfm;
> -	struct crypto_hash *hash_tfm; /* Crypto context for generating
> -				       * the initialization vectors */
> +	struct crypto_skcipher *tfm;
> +	struct crypto_shash *hash_tfm; /* Crypto context for generating
> +					* the initialization vectors */
>  	unsigned char cipher[ECRYPTFS_MAX_CIPHER_NAME_SIZE + 1];
>  	unsigned char key[ECRYPTFS_MAX_KEY_BYTES];
>  	unsigned char root_iv[ECRYPTFS_MAX_IV_BYTES];
> @@ -309,7 +309,7 @@ struct ecryptfs_global_auth_tok {
>   * keeps a list of crypto API contexts around to use when needed.
>   */
>  struct ecryptfs_key_tfm {
> -	struct crypto_blkcipher *key_tfm;
> +	struct crypto_skcipher *key_tfm;
>  	size_t key_size;
>  	struct mutex key_tfm_mutex;
>  	struct list_head key_tfm_list;
> @@ -659,7 +659,7 @@ ecryptfs_add_new_key_tfm(struct ecryptfs_key_tfm **ke=
y_tfm, char *cipher_name,
>  int ecryptfs_init_crypto(void);
>  int ecryptfs_destroy_crypto(void);
>  int ecryptfs_tfm_exists(char *cipher_name, struct ecryptfs_key_tfm **key=
_tfm);
> -int ecryptfs_get_tfm_and_mutex_for_cipher_name(struct crypto_blkcipher *=
*tfm,
> +int ecryptfs_get_tfm_and_mutex_for_cipher_name(struct crypto_skcipher **=
tfm,
>  					       struct mutex **tfm_mutex,
>  					       char *cipher_name);
>  int ecryptfs_keyring_auth_tok_for_sig(struct key **auth_tok_key,
> diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
> index 040aa87..ed74d80 100644
> --- a/fs/ecryptfs/inode.c
> +++ b/fs/ecryptfs/inode.c
> @@ -29,7 +29,6 @@
>  #include <linux/dcache.h>
>  #include <linux/namei.h>
>  #include <linux/mount.h>
> -#include <linux/crypto.h>
>  #include <linux/fs_stack.h>
>  #include <linux/slab.h>
>  #include <linux/xattr.h>
> diff --git a/fs/ecryptfs/keystore.c b/fs/ecryptfs/keystore.c
> index 6bd67e2..c5c84df 100644
> --- a/fs/ecryptfs/keystore.c
> +++ b/fs/ecryptfs/keystore.c
> @@ -25,11 +25,12 @@
>   * 02111-1307, USA.
>   */
> =20
> +#include <crypto/hash.h>
> +#include <crypto/skcipher.h>
>  #include <linux/string.h>
>  #include <linux/pagemap.h>
>  #include <linux/key.h>
>  #include <linux/random.h>
> -#include <linux/crypto.h>
>  #include <linux/scatterlist.h>
>  #include <linux/slab.h>
>  #include "ecryptfs_kernel.h"
> @@ -601,12 +602,13 @@ struct ecryptfs_write_tag_70_packet_silly_stack {
>  	struct ecryptfs_auth_tok *auth_tok;
>  	struct scatterlist src_sg[2];
>  	struct scatterlist dst_sg[2];
> -	struct blkcipher_desc desc;
> +	struct crypto_skcipher *skcipher_tfm;
> +	struct skcipher_request *skcipher_req;
>  	char iv[ECRYPTFS_MAX_IV_BYTES];
>  	char hash[ECRYPTFS_TAG_70_DIGEST_SIZE];
>  	char tmp_hash[ECRYPTFS_TAG_70_DIGEST_SIZE];
> -	struct hash_desc hash_desc;
> -	struct scatterlist hash_sg;
> +	struct crypto_shash *hash_tfm;
> +	struct shash_desc *hash_desc;
>  };
> =20
>  /**
> @@ -629,14 +631,13 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *re=
maining_bytes,
>  	struct key *auth_tok_key =3D NULL;
>  	int rc =3D 0;
> =20
> -	s =3D kmalloc(sizeof(*s), GFP_KERNEL);
> +	s =3D kzalloc(sizeof(*s), GFP_KERNEL);
>  	if (!s) {
>  		printk(KERN_ERR "%s: Out of memory whilst trying to kmalloc "
>  		       "[%zd] bytes of kernel memory\n", __func__, sizeof(*s));
>  		rc =3D -ENOMEM;
>  		goto out;
>  	}
> -	s->desc.flags =3D CRYPTO_TFM_REQ_MAY_SLEEP;
>  	(*packet_size) =3D 0;
>  	rc =3D ecryptfs_find_auth_tok_for_sig(
>  		&auth_tok_key,
> @@ -649,7 +650,7 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *rema=
ining_bytes,
>  		goto out;
>  	}
>  	rc =3D ecryptfs_get_tfm_and_mutex_for_cipher_name(
> -		&s->desc.tfm,
> +		&s->skcipher_tfm,
>  		&s->tfm_mutex, mount_crypt_stat->global_default_fn_cipher_name);
>  	if (unlikely(rc)) {
>  		printk(KERN_ERR "Internal error whilst attempting to get "
> @@ -658,7 +659,7 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *rema=
ining_bytes,
>  		goto out;
>  	}
>  	mutex_lock(s->tfm_mutex);
> -	s->block_size =3D crypto_blkcipher_blocksize(s->desc.tfm);
> +	s->block_size =3D crypto_skcipher_blocksize(s->skcipher_tfm);
>  	/* Plus one for the \0 separator between the random prefix
>  	 * and the plaintext filename */
>  	s->num_rand_bytes =3D (ECRYPTFS_FILENAME_MIN_RANDOM_PREPEND_BYTES + 1);
> @@ -691,6 +692,19 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *rem=
aining_bytes,
>  		rc =3D -EINVAL;
>  		goto out_unlock;
>  	}
> +
> +	s->skcipher_req =3D skcipher_request_alloc(s->skcipher_tfm, GFP_KERNEL);
> +	if (!s->skcipher_req) {
> +		printk(KERN_ERR "%s: Out of kernel memory whilst attempting to "
> +		       "skcipher_request_alloc for %s\n", __func__,
> +		       crypto_skcipher_driver_name(s->skcipher_tfm));
> +		rc =3D -ENOMEM;
> +		goto out_unlock;
> +	}
> +
> +	skcipher_request_set_callback(s->skcipher_req,
> +				      CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
> +
>  	s->block_aligned_filename =3D kzalloc(s->block_aligned_filename_size,
>  					    GFP_KERNEL);
>  	if (!s->block_aligned_filename) {
> @@ -700,7 +714,6 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *rema=
ining_bytes,
>  		rc =3D -ENOMEM;
>  		goto out_unlock;
>  	}
> -	s->i =3D 0;
>  	dest[s->i++] =3D ECRYPTFS_TAG_70_PACKET_TYPE;
>  	rc =3D ecryptfs_write_packet_length(&dest[s->i],
>  					  (ECRYPTFS_SIG_SIZE
> @@ -738,40 +751,36 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *re=
maining_bytes,
>  		       "password tokens\n", __func__);
>  		goto out_free_unlock;
>  	}
> -	sg_init_one(
> -		&s->hash_sg,
> -		(u8 *)s->auth_tok->token.password.session_key_encryption_key,
> -		s->auth_tok->token.password.session_key_encryption_key_bytes);
> -	s->hash_desc.flags =3D CRYPTO_TFM_REQ_MAY_SLEEP;
> -	s->hash_desc.tfm =3D crypto_alloc_hash(ECRYPTFS_TAG_70_DIGEST, 0,
> -					     CRYPTO_ALG_ASYNC);
> -	if (IS_ERR(s->hash_desc.tfm)) {
> -			rc =3D PTR_ERR(s->hash_desc.tfm);
> +	s->hash_tfm =3D crypto_alloc_shash(ECRYPTFS_TAG_70_DIGEST, 0, 0);
> +	if (IS_ERR(s->hash_tfm)) {
> +			rc =3D PTR_ERR(s->hash_tfm);
>  			printk(KERN_ERR "%s: Error attempting to "
>  			       "allocate hash crypto context; rc =3D [%d]\n",
>  			       __func__, rc);
>  			goto out_free_unlock;
>  	}
> -	rc =3D crypto_hash_init(&s->hash_desc);
> -	if (rc) {
> -		printk(KERN_ERR
> -		       "%s: Error initializing crypto hash; rc =3D [%d]\n",
> -		       __func__, rc);
> -		goto out_release_free_unlock;
> -	}
> -	rc =3D crypto_hash_update(
> -		&s->hash_desc, &s->hash_sg,
> -		s->auth_tok->token.password.session_key_encryption_key_bytes);
> -	if (rc) {
> -		printk(KERN_ERR
> -		       "%s: Error updating crypto hash; rc =3D [%d]\n",
> -		       __func__, rc);
> +
> +	s->hash_desc =3D kmalloc(sizeof(*s->hash_desc) +
> +			       crypto_shash_descsize(s->hash_tfm), GFP_KERNEL);
> +	if (!s->hash_desc) {
> +		printk(KERN_ERR "%s: Out of kernel memory whilst attempting to "
> +		       "kmalloc [%zd] bytes\n", __func__,
> +		       sizeof(*s->hash_desc) +
> +		       crypto_shash_descsize(s->hash_tfm));
> +		rc =3D -ENOMEM;
>  		goto out_release_free_unlock;
>  	}
> -	rc =3D crypto_hash_final(&s->hash_desc, s->hash);
> +
> +	s->hash_desc->tfm =3D s->hash_tfm;
> +	s->hash_desc->flags =3D CRYPTO_TFM_REQ_MAY_SLEEP;
> +
> +	rc =3D crypto_shash_digest(s->hash_desc,
> +				 (u8 *)s->auth_tok->token.password.session_key_encryption_key,
> +				 s->auth_tok->token.password.session_key_encryption_key_bytes,
> +				 s->hash);
>  	if (rc) {
>  		printk(KERN_ERR
> -		       "%s: Error finalizing crypto hash; rc =3D [%d]\n",
> +		       "%s: Error computing crypto hash; rc =3D [%d]\n",
>  		       __func__, rc);
>  		goto out_release_free_unlock;
>  	}
> @@ -780,27 +789,12 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *re=
maining_bytes,
>  			s->hash[(s->j % ECRYPTFS_TAG_70_DIGEST_SIZE)];
>  		if ((s->j % ECRYPTFS_TAG_70_DIGEST_SIZE)
>  		    =3D=3D (ECRYPTFS_TAG_70_DIGEST_SIZE - 1)) {
> -			sg_init_one(&s->hash_sg, (u8 *)s->hash,
> -				    ECRYPTFS_TAG_70_DIGEST_SIZE);
> -			rc =3D crypto_hash_init(&s->hash_desc);
> -			if (rc) {
> -				printk(KERN_ERR
> -				       "%s: Error initializing crypto hash; "
> -				       "rc =3D [%d]\n", __func__, rc);
> -				goto out_release_free_unlock;
> -			}
> -			rc =3D crypto_hash_update(&s->hash_desc, &s->hash_sg,
> -						ECRYPTFS_TAG_70_DIGEST_SIZE);
> +			rc =3D crypto_shash_digest(s->hash_desc, (u8 *)s->hash,
> +						ECRYPTFS_TAG_70_DIGEST_SIZE,
> +						s->tmp_hash);
>  			if (rc) {
>  				printk(KERN_ERR
> -				       "%s: Error updating crypto hash; "
> -				       "rc =3D [%d]\n", __func__, rc);
> -				goto out_release_free_unlock;
> -			}
> -			rc =3D crypto_hash_final(&s->hash_desc, s->tmp_hash);
> -			if (rc) {
> -				printk(KERN_ERR
> -				       "%s: Error finalizing crypto hash; "
> +				       "%s: Error computing crypto hash; "
>  				       "rc =3D [%d]\n", __func__, rc);
>  				goto out_release_free_unlock;
>  			}
> @@ -834,10 +828,8 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *rem=
aining_bytes,
>  	 * of the IV here, so we just use 0's for the IV. Note the
>  	 * constraint that ECRYPTFS_FILENAME_MIN_RANDOM_PREPEND_BYTES
>  	 * >=3D ECRYPTFS_MAX_IV_BYTES. */
> -	memset(s->iv, 0, ECRYPTFS_MAX_IV_BYTES);
> -	s->desc.info =3D s->iv;
> -	rc =3D crypto_blkcipher_setkey(
> -		s->desc.tfm,
> +	rc =3D crypto_skcipher_setkey(
> +		s->skcipher_tfm,
>  		s->auth_tok->token.password.session_key_encryption_key,
>  		mount_crypt_stat->global_default_fn_cipher_key_bytes);
>  	if (rc < 0) {
> @@ -850,8 +842,9 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *rema=
ining_bytes,
>  		       mount_crypt_stat->global_default_fn_cipher_key_bytes);
>  		goto out_release_free_unlock;
>  	}
> -	rc =3D crypto_blkcipher_encrypt_iv(&s->desc, s->dst_sg, s->src_sg,
> -					 s->block_aligned_filename_size);
> +	skcipher_request_set_crypt(s->skcipher_req, s->src_sg, s->dst_sg,
> +				   s->block_aligned_filename_size, s->iv);
> +	rc =3D crypto_skcipher_encrypt(s->skcipher_req);
>  	if (rc) {
>  		printk(KERN_ERR "%s: Error attempting to encrypt filename; "
>  		       "rc =3D [%d]\n", __func__, rc);
> @@ -861,7 +854,7 @@ ecryptfs_write_tag_70_packet(char *dest, size_t *rema=
ining_bytes,
>  	(*packet_size) =3D s->i;
>  	(*remaining_bytes) -=3D (*packet_size);
>  out_release_free_unlock:
> -	crypto_free_hash(s->hash_desc.tfm);
> +	crypto_free_shash(s->hash_tfm);
>  out_free_unlock:
>  	kzfree(s->block_aligned_filename);
>  out_unlock:
> @@ -871,6 +864,8 @@ out:
>  		up_write(&(auth_tok_key->sem));
>  		key_put(auth_tok_key);
>  	}
> +	skcipher_request_free(s->skcipher_req);
> +	kzfree(s->hash_desc);
>  	kfree(s);
>  	return rc;
>  }
> @@ -888,7 +883,8 @@ struct ecryptfs_parse_tag_70_packet_silly_stack {
>  	struct ecryptfs_auth_tok *auth_tok;
>  	struct scatterlist src_sg[2];
>  	struct scatterlist dst_sg[2];
> -	struct blkcipher_desc desc;
> +	struct crypto_skcipher *skcipher_tfm;
> +	struct skcipher_request *skcipher_req;
>  	char fnek_sig_hex[ECRYPTFS_SIG_SIZE_HEX + 1];
>  	char iv[ECRYPTFS_MAX_IV_BYTES];
>  	char cipher_string[ECRYPTFS_MAX_CIPHER_NAME_SIZE + 1];
> @@ -922,14 +918,13 @@ ecryptfs_parse_tag_70_packet(char **filename, size_=
t *filename_size,
>  	(*packet_size) =3D 0;
>  	(*filename_size) =3D 0;
>  	(*filename) =3D NULL;
> -	s =3D kmalloc(sizeof(*s), GFP_KERNEL);
> +	s =3D kzalloc(sizeof(*s), GFP_KERNEL);
>  	if (!s) {
>  		printk(KERN_ERR "%s: Out of memory whilst trying to kmalloc "
>  		       "[%zd] bytes of kernel memory\n", __func__, sizeof(*s));
>  		rc =3D -ENOMEM;
>  		goto out;
>  	}
> -	s->desc.flags =3D CRYPTO_TFM_REQ_MAY_SLEEP;
>  	if (max_packet_size < ECRYPTFS_TAG_70_MIN_METADATA_SIZE) {
>  		printk(KERN_WARNING "%s: max_packet_size is [%zd]; it must be "
>  		       "at least [%d]\n", __func__, max_packet_size,
> @@ -992,7 +987,7 @@ ecryptfs_parse_tag_70_packet(char **filename, size_t =
*filename_size,
>  		       rc);
>  		goto out;
>  	}
> -	rc =3D ecryptfs_get_tfm_and_mutex_for_cipher_name(&s->desc.tfm,
> +	rc =3D ecryptfs_get_tfm_and_mutex_for_cipher_name(&s->skcipher_tfm,
>  							&s->tfm_mutex,
>  							s->cipher_string);
>  	if (unlikely(rc)) {
> @@ -1030,12 +1025,23 @@ ecryptfs_parse_tag_70_packet(char **filename, siz=
e_t *filename_size,
>  		       __func__, rc, s->block_aligned_filename_size);
>  		goto out_free_unlock;
>  	}
> +
> +	s->skcipher_req =3D skcipher_request_alloc(s->skcipher_tfm, GFP_KERNEL);
> +	if (!s->skcipher_req) {
> +		printk(KERN_ERR "%s: Out of kernel memory whilst attempting to "
> +		       "skcipher_request_alloc for %s\n", __func__,
> +		       crypto_skcipher_driver_name(s->skcipher_tfm));
> +		rc =3D -ENOMEM;
> +		goto out_free_unlock;
> +	}
> +
> +	skcipher_request_set_callback(s->skcipher_req,
> +				      CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
> +
>  	/* The characters in the first block effectively do the job of
>  	 * the IV here, so we just use 0's for the IV. Note the
>  	 * constraint that ECRYPTFS_FILENAME_MIN_RANDOM_PREPEND_BYTES
>  	 * >=3D ECRYPTFS_MAX_IV_BYTES. */
> -	memset(s->iv, 0, ECRYPTFS_MAX_IV_BYTES);
> -	s->desc.info =3D s->iv;
>  	/* TODO: Support other key modules than passphrase for
>  	 * filename encryption */
>  	if (s->auth_tok->token_type !=3D ECRYPTFS_PASSWORD) {
> @@ -1044,8 +1050,8 @@ ecryptfs_parse_tag_70_packet(char **filename, size_=
t *filename_size,
>  		       "password tokens\n", __func__);
>  		goto out_free_unlock;
>  	}
> -	rc =3D crypto_blkcipher_setkey(
> -		s->desc.tfm,
> +	rc =3D crypto_skcipher_setkey(
> +		s->skcipher_tfm,
>  		s->auth_tok->token.password.session_key_encryption_key,
>  		mount_crypt_stat->global_default_fn_cipher_key_bytes);
>  	if (rc < 0) {
> @@ -1058,14 +1064,14 @@ ecryptfs_parse_tag_70_packet(char **filename, siz=
e_t *filename_size,
>  		       mount_crypt_stat->global_default_fn_cipher_key_bytes);
>  		goto out_free_unlock;
>  	}
> -	rc =3D crypto_blkcipher_decrypt_iv(&s->desc, s->dst_sg, s->src_sg,
> -					 s->block_aligned_filename_size);
> +	skcipher_request_set_crypt(s->skcipher_req, s->src_sg, s->dst_sg,
> +				   s->block_aligned_filename_size, s->iv);
> +	rc =3D crypto_skcipher_decrypt(s->skcipher_req);
>  	if (rc) {
>  		printk(KERN_ERR "%s: Error attempting to decrypt filename; "
>  		       "rc =3D [%d]\n", __func__, rc);
>  		goto out_free_unlock;
>  	}
> -	s->i =3D 0;
>  	while (s->decrypted_filename[s->i] !=3D '\0'
>  	       && s->i < s->block_aligned_filename_size)
>  		s->i++;
> @@ -1108,6 +1114,7 @@ out:
>  		up_write(&(auth_tok_key->sem));
>  		key_put(auth_tok_key);
>  	}
> +	skcipher_request_free(s->skcipher_req);
>  	kfree(s);
>  	return rc;
>  }
> @@ -1667,9 +1674,8 @@ decrypt_passphrase_encrypted_session_key(struct ecr=
yptfs_auth_tok *auth_tok,
>  	struct scatterlist dst_sg[2];
>  	struct scatterlist src_sg[2];
>  	struct mutex *tfm_mutex;
> -	struct blkcipher_desc desc =3D {
> -		.flags =3D CRYPTO_TFM_REQ_MAY_SLEEP
> -	};
> +	struct crypto_skcipher *tfm;
> +	struct skcipher_request *req =3D NULL;
>  	int rc =3D 0;
> =20
>  	if (unlikely(ecryptfs_verbosity > 0)) {
> @@ -1680,7 +1686,7 @@ decrypt_passphrase_encrypted_session_key(struct ecr=
yptfs_auth_tok *auth_tok,
>  			auth_tok->token.password.session_key_encryption_key,
>  			auth_tok->token.password.session_key_encryption_key_bytes);
>  	}
> -	rc =3D ecryptfs_get_tfm_and_mutex_for_cipher_name(&desc.tfm, &tfm_mutex,
> +	rc =3D ecryptfs_get_tfm_and_mutex_for_cipher_name(&tfm, &tfm_mutex,
>  							crypt_stat->cipher);
>  	if (unlikely(rc)) {
>  		printk(KERN_ERR "Internal error whilst attempting to get "
> @@ -1711,8 +1717,20 @@ decrypt_passphrase_encrypted_session_key(struct ec=
ryptfs_auth_tok *auth_tok,
>  		goto out;
>  	}
>  	mutex_lock(tfm_mutex);
> -	rc =3D crypto_blkcipher_setkey(
> -		desc.tfm, auth_tok->token.password.session_key_encryption_key,
> +	req =3D skcipher_request_alloc(tfm, GFP_KERNEL);
> +	if (!req) {
> +		mutex_unlock(tfm_mutex);
> +		printk(KERN_ERR "%s: Out of kernel memory whilst attempting to "
> +		       "skcipher_request_alloc for %s\n", __func__,
> +		       crypto_skcipher_driver_name(tfm));
> +		rc =3D -ENOMEM;
> +		goto out;
> +	}
> +
> +	skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP,
> +				      NULL, NULL);
> +	rc =3D crypto_skcipher_setkey(
> +		tfm, auth_tok->token.password.session_key_encryption_key,
>  		crypt_stat->key_size);
>  	if (unlikely(rc < 0)) {
>  		mutex_unlock(tfm_mutex);
> @@ -1720,8 +1738,10 @@ decrypt_passphrase_encrypted_session_key(struct ec=
ryptfs_auth_tok *auth_tok,
>  		rc =3D -EINVAL;
>  		goto out;
>  	}
> -	rc =3D crypto_blkcipher_decrypt(&desc, dst_sg, src_sg,
> -				      auth_tok->session_key.encrypted_key_size);
> +	skcipher_request_set_crypt(req, src_sg, dst_sg,
> +				   auth_tok->session_key.encrypted_key_size,
> +				   NULL);
> +	rc =3D crypto_skcipher_decrypt(req);
>  	mutex_unlock(tfm_mutex);
>  	if (unlikely(rc)) {
>  		printk(KERN_ERR "Error decrypting; rc =3D [%d]\n", rc);
> @@ -1738,6 +1758,7 @@ decrypt_passphrase_encrypted_session_key(struct ecr=
yptfs_auth_tok *auth_tok,
>  				  crypt_stat->key_size);
>  	}
>  out:
> +	skcipher_request_free(req);
>  	return rc;
>  }
> =20
> @@ -2191,16 +2212,14 @@ write_tag_3_packet(char *dest, size_t *remaining_=
bytes,
>  	size_t max_packet_size;
>  	struct ecryptfs_mount_crypt_stat *mount_crypt_stat =3D
>  		crypt_stat->mount_crypt_stat;
> -	struct blkcipher_desc desc =3D {
> -		.tfm =3D NULL,
> -		.flags =3D CRYPTO_TFM_REQ_MAY_SLEEP
> -	};
> +	struct crypto_skcipher *tfm;
> +	struct skcipher_request *req;
>  	int rc =3D 0;
> =20
>  	(*packet_size) =3D 0;
>  	ecryptfs_from_hex(key_rec->sig, auth_tok->token.password.signature,
>  			  ECRYPTFS_SIG_SIZE);
> -	rc =3D ecryptfs_get_tfm_and_mutex_for_cipher_name(&desc.tfm, &tfm_mutex,
> +	rc =3D ecryptfs_get_tfm_and_mutex_for_cipher_name(&tfm, &tfm_mutex,
>  							crypt_stat->cipher);
>  	if (unlikely(rc)) {
>  		printk(KERN_ERR "Internal error whilst attempting to get "
> @@ -2209,12 +2228,11 @@ write_tag_3_packet(char *dest, size_t *remaining_=
bytes,
>  		goto out;
>  	}
>  	if (mount_crypt_stat->global_default_cipher_key_size =3D=3D 0) {
> -		struct blkcipher_alg *alg =3D crypto_blkcipher_alg(desc.tfm);
> -
>  		printk(KERN_WARNING "No key size specified at mount; "
> -		       "defaulting to [%d]\n", alg->max_keysize);
> +		       "defaulting to [%d]\n",
> +		       crypto_skcipher_default_keysize(tfm));
>  		mount_crypt_stat->global_default_cipher_key_size =3D
> -			alg->max_keysize;
> +			crypto_skcipher_default_keysize(tfm);
>  	}
>  	if (crypt_stat->key_size =3D=3D 0)
>  		crypt_stat->key_size =3D
> @@ -2284,20 +2302,36 @@ write_tag_3_packet(char *dest, size_t *remaining_=
bytes,
>  		goto out;
>  	}
>  	mutex_lock(tfm_mutex);
> -	rc =3D crypto_blkcipher_setkey(desc.tfm, session_key_encryption_key,
> -				     crypt_stat->key_size);
> +	rc =3D crypto_skcipher_setkey(tfm, session_key_encryption_key,
> +				    crypt_stat->key_size);
>  	if (rc < 0) {
>  		mutex_unlock(tfm_mutex);
>  		ecryptfs_printk(KERN_ERR, "Error setting key for crypto "
>  				"context; rc =3D [%d]\n", rc);
>  		goto out;
>  	}
> +
> +	req =3D skcipher_request_alloc(tfm, GFP_KERNEL);
> +	if (!req) {
> +		mutex_unlock(tfm_mutex);
> +		ecryptfs_printk(KERN_ERR, "Out of kernel memory whilst "
> +				"attempting to skcipher_request_alloc for "
> +				"%s\n", crypto_skcipher_driver_name(tfm));
> +		rc =3D -ENOMEM;
> +		goto out;
> +	}
> +
> +	skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP,
> +				      NULL, NULL);
> +
>  	rc =3D 0;
>  	ecryptfs_printk(KERN_DEBUG, "Encrypting [%zd] bytes of the key\n",
>  			crypt_stat->key_size);
> -	rc =3D crypto_blkcipher_encrypt(&desc, dst_sg, src_sg,
> -				      (*key_rec).enc_key_size);
> +	skcipher_request_set_crypt(req, src_sg, dst_sg,
> +				   (*key_rec).enc_key_size, NULL);
> +	rc =3D crypto_skcipher_encrypt(req);
>  	mutex_unlock(tfm_mutex);
> +	skcipher_request_free(req);
>  	if (rc) {
>  		printk(KERN_ERR "Error encrypting; rc =3D [%d]\n", rc);
>  		goto out;
> diff --git a/fs/ecryptfs/main.c b/fs/ecryptfs/main.c
> index e25b6b0..8b0b4a7 100644
> --- a/fs/ecryptfs/main.c
> +++ b/fs/ecryptfs/main.c
> @@ -29,7 +29,6 @@
>  #include <linux/module.h>
>  #include <linux/namei.h>
>  #include <linux/skbuff.h>
> -#include <linux/crypto.h>
>  #include <linux/mount.h>
>  #include <linux/pagemap.h>
>  #include <linux/key.h>
> diff --git a/fs/ecryptfs/mmap.c b/fs/ecryptfs/mmap.c
> index caba848..36c8b08 100644
> --- a/fs/ecryptfs/mmap.c
> +++ b/fs/ecryptfs/mmap.c
> @@ -30,7 +30,6 @@
>  #include <linux/page-flags.h>
>  #include <linux/mount.h>
>  #include <linux/file.h>
> -#include <linux/crypto.h>
>  #include <linux/scatterlist.h>
>  #include <linux/slab.h>
>  #include <asm/unaligned.h>
> diff --git a/fs/ecryptfs/super.c b/fs/ecryptfs/super.c
> index afa1b81..77a486d 100644
> --- a/fs/ecryptfs/super.c
> +++ b/fs/ecryptfs/super.c
> @@ -29,7 +29,6 @@
>  #include <linux/slab.h>
>  #include <linux/seq_file.h>
>  #include <linux/file.h>
> -#include <linux/crypto.h>
>  #include <linux/statfs.h>
>  #include <linux/magic.h>
>  #include "ecryptfs_kernel.h"
> --=20
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe ecryptfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--huq684BweRXVnRxX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJWq5/VAAoJENaSAD2qAscKwIsP/02h/lCxddKjKbf5cBCcT6tr
H/a0so21Cn5y4wUEHAL56V4Bhvp3cjf6h4Xoojwn1k1SLxX2Y8FVy9ObYYDWNRIi
9BWyS0TfTKQSk2bqhqFzhBIpIim9zZ4y4Lycja5MiTQ4pRMHS1aX8Vyp/YLE3iCm
JDZEuJozqlM4SeCX7tHoLhwzPGD6tnaihMsOCMSfim2OrO0FS/N8nGSqMOaLWU9/
JQulqJh+lSuHq7bwRmUlVk4KM4xfsV2hKG0FLivIAJOR0Q+T4PShmFuJQaDiKGnX
Kt/9YKLk55ORzZ+vhnMaSNz5/QpzpgXWv8JklDSNN/2KA8Laa5ALcxQZFbmMSKJb
HUPkuYwd8/KJtr/E8Q9R7fiXDfSRA7kq1hood+je49wWL4+jM1fw2n8gqpY6S67p
cvtABmesP1yi9yoWteSf3iJZqvyXrp4Knzuw/mQs7LAacMCw2w+KuK0fjPsNpa2m
Yan7xBGJZINzwWo6fTkWmEFfFRcCHOCtltMFnGHl6HzCQHfh3DlNiuasijZwPSwb
gTmtu/80Wgx4PSyVu39U+Cr0+QLWlBpjmPxBC0q1edW+s6NmiHVJE0jPBzxcha73
jiiZ0edw5/6OHlmQzx5myy/jXLHtJCZtMmAcHiyQpG6Fqls41xQbI5bXN+gbFDEv
Tt/yHC6iOQIuIuBS1bS3
=tGLb
-----END PGP SIGNATURE-----

--huq684BweRXVnRxX--
