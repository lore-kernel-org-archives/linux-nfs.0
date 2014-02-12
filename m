Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:53267 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbaBLMel convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Feb 2014 07:34:41 -0500
Received: by mail-ie0-f175.google.com with SMTP id ar20so5485728iec.34
        for <linux-nfs@vger.kernel.org>; Wed, 12 Feb 2014 04:34:41 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH v2] NFSv4.1: new layout stateid can not be overwrite by one out of date
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1392199580-14249-1-git-send-email-shaobingqing@bwstor.com.cn>
Date: Wed, 12 Feb 2014 07:34:38 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Message-Id: <EF4B0DD4-D0EC-498C-B10B-6FE157061C5F@primarydata.com>
References: <N> <1392199580-14249-1-git-send-email-shaobingqing@bwstor.com.cn>
To: shaobingqing <shaobingqing@bwstor.com.cn>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 12, 2014, at 5:06, shaobingqing <shaobingqing@bwstor.com.cn> wrote:

> If initiate_file_draining returned NFS4ERR_DELAY, all the lsegs of
> a file might be released before the retrying cb_layout request arriving
> at the client. In this situation, layoutget request of the file will
> use open stateid to obtain a new layout stateid. And if the retrying
> cb_layout request arrived at the client after the layoutget reply,
> new layout stateid would be overwrite by one out of date.
> 
> Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
> ---
> fs/nfs/callback.h      |    5 +++++
> fs/nfs/callback_proc.c |   24 ++++++++++++++++++++++++
> fs/nfs/inode.c         |    1 +
> include/linux/nfs_fs.h |    1 +
> 4 files changed, 31 insertions(+), 0 deletions(-)
> 
<snip>
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 3ea4cde..ba47870 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -181,6 +181,7 @@ struct nfs_inode {
> 	struct nfs4_cached_acl	*nfs4_acl;
>         /* NFSv4 state */
> 	struct list_head	open_states;
> +	struct list_head	cb_stale_state_list;
> 	struct nfs_delegation __rcu *delegation;
> 	fmode_t			 delegation_state;
> 	struct rw_semaphore	rwsem;

No. We are definitely not adding new fields to the inode in order to track old layout stateids.
_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

