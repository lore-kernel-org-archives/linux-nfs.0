Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:35724 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920Ab2FRO63 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jun 2012 10:58:29 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Apple Message framework v1278)
Subject: Fwd: [PATCH] rpcdebug: Add new "state" flag for the nfs module
From: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 18 Jun 2012 10:58:22 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9DF5655A-AC4B-4218-BE51-717016D4D7F3@oracle.com>
References: <20120604210153.13269.10747.stgit@oracle-2.citi.umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ping... :-)

Begin forwarded message:

> From: Chuck Lever <chuck.lever@oracle.com>
> Subject: [PATCH] rpcdebug: Add new "state" flag for the nfs module
> Date: June 4, 2012 5:01:53 PM EDT
> To: steved@redhat.com
> Cc: linux-nfs@vger.kernel.org
> 
> Kernel 3.5 adds a debugging flag for showing NFS client debugging
> messages having to do with NFSv4 state operations.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> support/include/nfs/debug.h |    1 +
> tools/rpcdebug/rpcdebug.c   |    1 +
> 2 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/support/include/nfs/debug.h b/support/include/nfs/debug.h
> index dbec5ba..80a1b1d 100644
> --- a/support/include/nfs/debug.h
> +++ b/support/include/nfs/debug.h
> @@ -79,6 +79,7 @@ enum {
> #define NFSDBG_FSCACHE		0x0800
> #define NFSDBG_PNFS			0x1000
> #define NFSDBG_PNFS_LD		0x2000
> +#define NFSDBG_STATE		0x4000
> #define NFSDBG_ALL		0xFFFF
> 
> #endif /* _NFS_DEBUG_H */
> diff --git a/tools/rpcdebug/rpcdebug.c b/tools/rpcdebug/rpcdebug.c
> index 444616d..d6e10d3 100644
> --- a/tools/rpcdebug/rpcdebug.c
> +++ b/tools/rpcdebug/rpcdebug.c
> @@ -170,6 +170,7 @@ static struct flagmap {
> 	FLAG(NFS,       FSCACHE),
> 	FLAG(NFS,       PNFS),
> 	FLAG(NFS,       PNFS_LD),
> +	FLAG(NFS,	STATE),
> 	FLAG(NFS,	ALL),
> 
> 	/* nfsd */
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




