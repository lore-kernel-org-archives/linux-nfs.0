Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:37648 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbcAXNLZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:11:25 -0500
Date: Sun, 24 Jan 2016 21:10:21 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        dm-devel@redhat.com, linux-wireless@vger.kernel.org,
        linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
        linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
        drbd-dev@lists.linbit.com, linux-nfc@ml01.01.org,
        open-iscsi@googlegroups.com
Subject: [PATCH 0/26] crypto: Use skcipher and ahash/shash where possible
Message-ID: <20160124131021.GA31153@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi:

The crypto hash interface has been obsolete for many years and
this series converts all remaining users to shash and ahash as
appropriate.  Despite the name ahash can be used synchronously
and is the preferred interface for those dealing with SGs.

The blkcipher and ablkcipher interfaces are also being phased out
and is being replaced with the merged skcipher interface which
is essentially the same as ablkcipher but without the implicit
IV generators.  This series converts all users of blkcipher and
ablkcipher over to skcipher.

If you have any objections please shout.  Otherwise I would like
to take these patches through the cryptodev tree so we can proceed
with phasing out the obsolete interfaces.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
