Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45730 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933978Ab3D3Xmz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Apr 2013 19:42:55 -0400
Date: Tue, 30 Apr 2013 19:42:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Three short NFSD subjects
Message-ID: <20130430234255.GB32031@fieldses.org>
References: <20130430224730.21406.27294.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130430224730.21406.27294.stgit@seurat.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 30, 2013 at 06:48:37PM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> Two clean up patches, and a fix for a SECINFO corner case.

The first two look good, thanks.--b.

> 
> ---
> 
> Chuck Lever (3):
>       NFSD: Kill some mixed sign comparisons in fs/nfsd/nfs4xdr.c
>       NFSD: SECINFO doesn't handle unsupported pseudoflavors correctly
>       NFSD: Simplify GSS flavor encoding in nfsd4_do_encode_secinfo()
> 
> 
>  fs/nfsd/nfs4xdr.c |   43 +++++++++++++++++++++++++------------------
>  fs/nfsd/xdr4.h    |    2 +-
>  2 files changed, 26 insertions(+), 19 deletions(-)
> 
> -- 
> Chuck Lever
