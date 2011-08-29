Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:35356 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768Ab1H2Szb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 14:55:31 -0400
Subject: Re: [PATCH 0/3] NFSD support for FedFS junctions
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110829184608.3305.93648.stgit@matisse.1015granger.net>
Date: Mon, 29 Aug 2011 14:55:14 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <3C9663C8-A619-4490-83A8-2645EA78F444@oracle.com>
References: <20110829184608.3305.93648.stgit@matisse.1015granger.net>
To: bfields@redhat.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sorry for the threading and patch numbering weirdness.  Our corporate mail server hiccup'd while I was sending these.

On Aug 29, 2011, at 2:48 PM, Chuck Lever wrote:

> Hi Bruce-
> 
> Sometime soon we are going to have working and easy-to-install FedFS
> user space components.  These kernel patches are going to be needed
> to make server-side FedFS support work.
> 
> Would you consider these for 3.2?
> 
> ---
> 
> Trond Myklebust (3):
>      NFSD: Add a cache for fs_locations information
>      NFSD: Remove the ex_pathname field from struct svc_export
>      NFSD: Cleanup for nfsd4_path()
> 
> 
> fs/nfsd/export.c            |   15 +-----
> fs/nfsd/nfs4xdr.c           |  106 ++++++++++++++++++++++++++++++++-----------
> fs/nfsd/nfsd.h              |    7 +++
> fs/nfsd/vfs.c               |   15 ++++++
> include/linux/nfsd/export.h |    2 -
> 5 files changed, 103 insertions(+), 42 deletions(-)
> 
> -- 
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




