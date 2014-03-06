Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:61575 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbaCFOfF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 09:35:05 -0500
Received: by mail-ig0-f174.google.com with SMTP id h18so16426445igc.1
        for <linux-nfs@vger.kernel.org>; Thu, 06 Mar 2014 06:35:04 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH][RESEND] vfs: Make __d_materialise_dentry() set the materialised dentry name correctly
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1394115376-17109-1-git-send-email-zheng.z.yan@intel.com>
Date: Thu, 6 Mar 2014 09:35:01 -0500
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        Viro Alexander <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org, sage@inktank.com
Message-Id: <6487FCC2-FB5C-4A32-94EF-5D3352A39781@primarydata.com>
References: <1394115376-17109-1-git-send-email-zheng.z.yan@intel.com>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 6, 2014, at 9:16, Yan, Zheng <zheng.z.yan@intel.com> wrote:

> From: David Howells <dhowells@redhat.com>
> 
> Make __d_materialise_dentry() set the materialised dentry name correctly by
> flipping the arguments to switch_names().
> 
> switch_names() is lazy: if both names are internal to their dentries, it'll
> overwrite that of the first dentry with that of the second, and won't update
> that of the second.
> 
> In the case of __d_materialise_dentry(), the second is an already extant
> anonymous dentry that we want to insert into the tree in place of the dentry we
> just looked up[*].  However, the dentry we just looked up carries the name we
> actually want to use.
> 
> [*] This is used by NFS to join a mount of a subtree into a mount of a tree
> nearer the root when the two meet, where both mounts share a superblock and
> thus a set of dentries.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> fs/dcache.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 265e0ce..ff779d4 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -2698,7 +2698,7 @@ static void __d_materialise_dentry(struct dentry *dentry, struct dentry *anon)
> 
> 	dparent = dentry->d_parent;
> 
> -	switch_names(dentry, anon);
> +	switch_names(anon, dentry);
> 	swap(dentry->d_name.hash, anon->d_name.hash);
> 
> 	dentry->d_parent = dentry;

Well spotted...

We ought to better document the fact that ’switch_names’ is asymmetrical. Perhaps change it to ‘update_target_name’, and then switch the argument names so that the ’target’ really is the thing that gets updated?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

