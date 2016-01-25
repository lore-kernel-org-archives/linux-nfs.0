Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:50737 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933261AbcAYT7y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2016 14:59:54 -0500
Message-ID: <56A67C6E.1090903@cs.wisc.edu>
Date: Mon, 25 Jan 2016 13:50:06 -0600
From: Mike Christie <michaelc@cs.wisc.edu>
MIME-Version: 1.0
To: device-mapper development <dm-devel@redhat.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        linux-wireless@vger.kernel.org, linux-cifs@vger.kernel.org,
        ecryptfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org,
        keyrings@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-wpan@vger.kernel.org,
        linux-afs@lists.infradead.org, drbd-dev@lists.linbit.com,
        open-iscsi@googlegroups.com
Subject: Re: [dm-devel] [PATCH 22/26] iscsi_tcp: Use ahash
References: <20160124131021.GA31153@gondor.apana.org.au> <E1aNKZy-0008Fl-01@gondolin.me.apana.org.au>
In-Reply-To: <E1aNKZy-0008Fl-01@gondolin.me.apana.org.au>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/24/2016 07:19 AM, Herbert Xu wrote:
> This patch replaces uses of the long obsolete hash interface with
> ahash.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  drivers/scsi/iscsi_tcp.c    |   54 ++++++++++++++++++++++++++------------------
>  drivers/scsi/iscsi_tcp.h    |    4 +--
>  drivers/scsi/libiscsi_tcp.c |   29 +++++++++++++----------
>  include/scsi/libiscsi_tcp.h |   13 +++++-----
>  4 files changed, 58 insertions(+), 42 deletions(-)
> 

iSCSI parts look ok.

Reviewed-by: Mike Christie <michaelc@cs.wisc.edu>

