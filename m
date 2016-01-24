Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:55774 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752042AbcAXSLR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 13:11:17 -0500
Date: Sun, 24 Jan 2016 19:10:50 +0100 (CET)
From: Julia Lawall <julia.lawall@lip6.fr>
To: Herbert Xu <herbert@gondor.apana.org.au>
cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
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
Subject: Re: [PATCH 9/26] eCryptfs: Use skcipher and shash
In-Reply-To: <201601250207.1gdHywwq%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.10.1601241909430.2498@hadrien>
References: <201601250207.1gdHywwq%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Maybe the goto on line 1726 needs a preceding mutex_unlock?

julia

On Mon, 25 Jan 2016, kbuild test robot wrote:

> Hi Herbert,
>
> [auto build test WARNING on net/master]
> [also build test WARNING on v4.4 next-20160122]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
>
> url:    https://github.com/0day-ci/linux/commits/Herbert-Xu/crypto-Use-skcipher-and-ahash-shash-where-possible/20160124-212323
> :::::: branch date: 5 hours ago
> :::::: commit date: 5 hours ago
>
> >> fs/ecryptfs/keystore.c:1761:1-7: preceding lock on line 1719
>
> git remote add linux-review https://github.com/0day-ci/linux
> git remote update linux-review
> git checkout 0186bf144c1f96606f491be0e7ed47b79ea0d285
> vim +1761 fs/ecryptfs/keystore.c
>
> ac97b9f9 Michael Halcrow 2008-11-19  1713  	if (rc < 1 || rc > 2) {
> f4aad16a Michael Halcrow 2007-10-16  1714  		printk(KERN_ERR "Internal error whilst attempting to convert "
> f4aad16a Michael Halcrow 2007-10-16  1715  			"auth_tok->session_key.decrypted_key to scatterlist; "
> f4aad16a Michael Halcrow 2007-10-16  1716  			"expected rc = 1; got rc = [%d]\n", rc);
> f4aad16a Michael Halcrow 2007-10-16  1717  		goto out;
> 237fead6 Michael Halcrow 2006-10-04  1718  	}
> 237fead6 Michael Halcrow 2006-10-04 @1719  	mutex_lock(tfm_mutex);
> 0186bf14 Herbert Xu      2016-01-24  1720  	req = skcipher_request_alloc(tfm, GFP_KERNEL);
> 0186bf14 Herbert Xu      2016-01-24  1721  	if (!req) {
> 0186bf14 Herbert Xu      2016-01-24  1722  		printk(KERN_ERR "%s: Out of kernel memory whilst attempting to "
> 0186bf14 Herbert Xu      2016-01-24  1723  		       "skcipher_request_alloc for %s\n", __func__,
> 0186bf14 Herbert Xu      2016-01-24  1724  		       crypto_skcipher_driver_name(tfm));
> 0186bf14 Herbert Xu      2016-01-24  1725  		rc = -ENOMEM;
> 0186bf14 Herbert Xu      2016-01-24  1726  		goto out;
> 0186bf14 Herbert Xu      2016-01-24  1727  	}
> 0186bf14 Herbert Xu      2016-01-24  1728
> 0186bf14 Herbert Xu      2016-01-24  1729  	skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP,
> 0186bf14 Herbert Xu      2016-01-24  1730  				      NULL, NULL);
> 0186bf14 Herbert Xu      2016-01-24  1731  	rc = crypto_skcipher_setkey(
> 0186bf14 Herbert Xu      2016-01-24  1732  		tfm, auth_tok->token.password.session_key_encryption_key,
> 237fead6 Michael Halcrow 2006-10-04  1733  		crypt_stat->key_size);
> f4aad16a Michael Halcrow 2007-10-16  1734  	if (unlikely(rc < 0)) {
> f4aad16a Michael Halcrow 2007-10-16  1735  		mutex_unlock(tfm_mutex);
> e5d9cbde Michael Halcrow 2006-10-30  1736  		printk(KERN_ERR "Error setting key for crypto context\n");
> e5d9cbde Michael Halcrow 2006-10-30  1737  		rc = -EINVAL;
> f4aad16a Michael Halcrow 2007-10-16  1738  		goto out;
> 237fead6 Michael Halcrow 2006-10-04  1739  	}
> 0186bf14 Herbert Xu      2016-01-24  1740  	skcipher_request_set_crypt(req, src_sg, dst_sg,
> 0186bf14 Herbert Xu      2016-01-24  1741  				   auth_tok->session_key.encrypted_key_size,
> 0186bf14 Herbert Xu      2016-01-24  1742  				   NULL);
> 0186bf14 Herbert Xu      2016-01-24  1743  	rc = crypto_skcipher_decrypt(req);
> f4aad16a Michael Halcrow 2007-10-16  1744  	mutex_unlock(tfm_mutex);
> f4aad16a Michael Halcrow 2007-10-16  1745  	if (unlikely(rc)) {
> 8bba066f Michael Halcrow 2006-10-30  1746  		printk(KERN_ERR "Error decrypting; rc = [%d]\n", rc);
> f4aad16a Michael Halcrow 2007-10-16  1747  		goto out;
> 8bba066f Michael Halcrow 2006-10-30  1748  	}
> 237fead6 Michael Halcrow 2006-10-04  1749  	auth_tok->session_key.flags |= ECRYPTFS_CONTAINS_DECRYPTED_KEY;
> 237fead6 Michael Halcrow 2006-10-04  1750  	memcpy(crypt_stat->key, auth_tok->session_key.decrypted_key,
> 237fead6 Michael Halcrow 2006-10-04  1751  	       auth_tok->session_key.decrypted_key_size);
> e2bd99ec Michael Halcrow 2007-02-12  1752  	crypt_stat->flags |= ECRYPTFS_KEY_VALID;
> f4aad16a Michael Halcrow 2007-10-16  1753  	if (unlikely(ecryptfs_verbosity > 0)) {
> f24b3887 Tyler Hicks     2010-11-15  1754  		ecryptfs_printk(KERN_DEBUG, "FEK of size [%zd]:\n",
> f4aad16a Michael Halcrow 2007-10-16  1755  				crypt_stat->key_size);
> 237fead6 Michael Halcrow 2006-10-04  1756  		ecryptfs_dump_hex(crypt_stat->key,
> 237fead6 Michael Halcrow 2006-10-04  1757  				  crypt_stat->key_size);
> f4aad16a Michael Halcrow 2007-10-16  1758  	}
> 237fead6 Michael Halcrow 2006-10-04  1759  out:
> 0186bf14 Herbert Xu      2016-01-24  1760  	skcipher_request_free(req);
> 237fead6 Michael Halcrow 2006-10-04 @1761  	return rc;
> 237fead6 Michael Halcrow 2006-10-04  1762  }
> 237fead6 Michael Halcrow 2006-10-04  1763
> 237fead6 Michael Halcrow 2006-10-04  1764  /**
>
> :::::: The code at line 1761 was first introduced by commit
> :::::: 237fead619984cc48818fe12ee0ceada3f55b012 [PATCH] ecryptfs: fs/Makefile and fs/Kconfig
>
> :::::: TO: Michael Halcrow <mhalcrow@us.ibm.com>
> :::::: CC: Linus Torvalds <torvalds@g5.osdl.org>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>
