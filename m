Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:52945 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbcAXUAV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 15:00:21 -0500
Date: Sun, 24 Jan 2016 12:00:19 -0800
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
Subject: Re: [PATCH 3/26] staging: rtl8192e: Replace uses of obsolete
 blkcipher and hash
Message-ID: <20160124200019.GA17868@kroah.com>
References: <20160124131021.GA31153@gondor.apana.org.au>
 <E1aNKWo-0008AS-PG@gondolin.me.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E1aNKWo-0008AS-PG@gondolin.me.apana.org.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 24, 2016 at 09:16:26PM +0800, Herbert Xu wrote:
> The interfaces blkcipher and hash are obsolete.  This patch replaces
> them with skcipher and ahash respectively.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  drivers/staging/rtl8192e/rtllib_crypt_tkip.c |   99 ++++++++++++++-------------
>  drivers/staging/rtl8192e/rtllib_crypt_wep.c  |   48 +++++++------
>  2 files changed, 82 insertions(+), 65 deletions(-)

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
