Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:48384 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750994AbeAWQru (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jan 2018 11:47:50 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] nfs: Use proper enum definitions for nfs_show_stable
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180118195500.10840.21322.stgit@manet.1015granger.net>
Date: Tue, 23 Jan 2018 08:47:51 -0800
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A6A2326E-19F3-4679-84C6-D393C9334758@oracle.com>
References: <20180118195500.10840.21322.stgit@manet.1015granger.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey-

Any comments on this? It would be great to see it in v4.16,
especially since the fix for the bug I mentioned is already
in v4.15-rc9.


> On Jan 18, 2018, at 11:55 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> Commit 8224b2734ab1 ("NFS: Add static NFS I/O tracepoints") had a
> hack to work around some odd behavior observed with
> __print_symbolic. I couldn't ever get it to display NFS_FILE_SYNC
> when using TRACE_DEFINE_ENUM macros to set up the enum values.
> 
> I tracked down the actual bug that forced me to add the workaround.
> That issue will be addressed soon, so replace the hack with a proper
> implementation.
> 
> Fixes: 8224b2734ab1 ("NFS: Add static NFS I/O tracepoints")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> fs/nfs/nfstrace.h |   22 +++++++++++-----------
> 1 file changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
> index 093290c..c6dbd48 100644
> --- a/fs/nfs/nfstrace.h
> +++ b/fs/nfs/nfstrace.h
> @@ -796,15 +796,15 @@
> 		)
> );
> 
> -/*
> - * XXX: I tried using NFS_UNSTABLE and friends in this table, but they
> - * all evaluate to 0 for some reason, even if I include linux/nfs.h.
> - */
> +TRACE_DEFINE_ENUM(NFS_UNSTABLE);
> +TRACE_DEFINE_ENUM(NFS_DATA_SYNC);
> +TRACE_DEFINE_ENUM(NFS_FILE_SYNC);
> +
> #define nfs_show_stable(stable) \
> 	__print_symbolic(stable, \
> -			{ 0, " (UNSTABLE)" }, \
> -			{ 1, " (DATA_SYNC)" }, \
> -			{ 2, " (FILE_SYNC)" })
> +			{ NFS_UNSTABLE, "UNSTABLE" }, \
> +			{ NFS_DATA_SYNC, "DATA_SYNC" }, \
> +			{ NFS_FILE_SYNC, "FILE_SYNC" })
> 
> TRACE_EVENT(nfs_initiate_write,
> 		TP_PROTO(
> @@ -837,12 +837,12 @@
> 
> 		TP_printk(
> 			"fileid=%02x:%02x:%llu fhandle=0x%08x "
> -			"offset=%lld count=%lu stable=%d%s",
> +			"offset=%lld count=%lu stable=%s",
> 			MAJOR(__entry->dev), MINOR(__entry->dev),
> 			(unsigned long long)__entry->fileid,
> 			__entry->fhandle,
> 			__entry->offset, __entry->count,
> -			__entry->stable, nfs_show_stable(__entry->stable)
> +			nfs_show_stable(__entry->stable)
> 		)
> );
> 
> @@ -881,13 +881,13 @@
> 
> 		TP_printk(
> 			"fileid=%02x:%02x:%llu fhandle=0x%08x "
> -			"offset=%lld status=%d stable=%d%s "
> +			"offset=%lld status=%d stable=%s "
> 			"verifier 0x%016llx",
> 			MAJOR(__entry->dev), MINOR(__entry->dev),
> 			(unsigned long long)__entry->fileid,
> 			__entry->fhandle,
> 			__entry->offset, __entry->status,
> -			__entry->stable, nfs_show_stable(__entry->stable),
> +			nfs_show_stable(__entry->stable),
> 			__entry->verifier
> 		)
> );
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



