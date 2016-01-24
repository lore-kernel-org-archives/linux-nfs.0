Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:52964 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbcAXUAy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 15:00:54 -0500
Date: Sun, 24 Jan 2016 12:00:52 -0800
From: Greg KH <greg@kroah.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        dm-devel@redhat.com, linux-wireless@vger.kernel.org,
        linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
        linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
        drbd-dev@lists.linbit.com, open-iscsi@googlegroups.com
Subject: Re: [PATCH 6/26] staging: rtl8192u: Use skcipher and ahash
Message-ID: <20160124200052.GB17868@kroah.com>
References: <20160124131021.GA31153@gondor.apana.org.au>
 <E1aNKXJ-0008BG-BI@gondolin.me.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E1aNKXJ-0008BG-BI@gondolin.me.apana.org.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 24, 2016 at 09:16:57PM +0800, Herbert Xu wrote:
> This patch replaces uses of blkcipher with skcipher, and the long
> obsolete hash interface with ahash.
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_tkip.c |   92 +++++++-------
>  drivers/staging/rtl8192u/ieee80211/ieee80211_crypt_wep.c  |   46 ++++---
>  2 files changed, 81 insertions(+), 57 deletions(-)

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
