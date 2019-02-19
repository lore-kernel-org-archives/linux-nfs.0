Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2D3DC10F00
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:45:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AD6EE21773
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:45:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726546AbfBSQpr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 11:45:47 -0500
Received: from out02.mta.xmission.com ([166.70.13.232]:36707 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725820AbfBSQpr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 11:45:47 -0500
Received: from in02.mta.xmission.com ([166.70.13.52])
        by out02.mta.xmission.com with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.87)
        (envelope-from <ebiederm@xmission.com>)
        id 1gw8Wf-0002cJ-D4; Tue, 19 Feb 2019 09:45:45 -0700
Received: from ip68-227-174-240.om.om.cox.net ([68.227.174.240] helo=x220.xmission.com)
        by in02.mta.xmission.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.87)
        (envelope-from <ebiederm@xmission.com>)
        id 1gw8We-0006S1-L9; Tue, 19 Feb 2019 09:45:45 -0700
From:   ebiederm@xmission.com (Eric W. Biederman)
To:     David Howells <dhowells@redhat.com>
Cc:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org, linux-security-module@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, rgb@redhat.com,
        linux-kernel@vger.kernel.org
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
        <155024688620.21651.16013251077091180213.stgit@warthog.procyon.org.uk>
Date:   Tue, 19 Feb 2019 10:45:33 -0600
In-Reply-To: <155024688620.21651.16013251077091180213.stgit@warthog.procyon.org.uk>
        (David Howells's message of "Fri, 15 Feb 2019 16:08:06 +0000")
Message-ID: <8736ojwwuq.fsf@xmission.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/25.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1gw8We-0006S1-L9;;;mid=<8736ojwwuq.fsf@xmission.com>;;;hst=in02.mta.xmission.com;;;ip=68.227.174.240;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX1+0bCbJs2NZ1f0Qu2dc3RqzP0PhMAUsnbg=
X-SA-Exim-Connect-IP: 68.227.174.240
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [RFC PATCH 06/27] containers, vfs: Allow syscall dirfd arguments to take a container fd
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

David Howells <dhowells@redhat.com> writes:

> Some filesystem system calls, such as mkdirat(), take a 'directory fd' to
> specify the pathwalk origin.  This takes either AT_FDCWD or a file
> descriptor that refers to an open directory.
>
> Make it possible to supply a container fd, as obtained from
> container_create(), instead thereby specifying the container's root as the
> origin.  This performs the filesystem operation into the container's mount
> namespace.  For example:
>
> 	int cfd = container_create("fred", CONTAINER_NEW_MNT_NS, 0);
> 	mkdirat(cfd, "/fred", 0755);
>
> A better way to do this might be to temporarily override current->fs and
> current->nsproxy, but this requires splitting those fields so that procfs
> doesn't see the override.
>
> A sequence number and lock are available to protect the root pointer in
> case container_chroot() and/or container_pivot_root() are implemented.

If this is desirable we can do this without a ``container''.  We already
have mount namespaces.

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

In fact if you take care to use a path that starts with '/' the normal
dirfd based operations work just fine.

So I don't see the point of this system call at all.


> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>
>  fs/namei.c |   45 ++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 34 insertions(+), 11 deletions(-)
>
> diff --git a/fs/namei.c b/fs/namei.c
> index a85deb55d0c9..4932b5467285 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -2232,20 +2232,43 @@ static const char *path_init(struct nameidata *nd, unsigned flags)
>  		if (!f.file)
>  			return ERR_PTR(-EBADF);
>  
> -		dentry = f.file->f_path.dentry;
> +		if (is_container_file(f.file)) {
> +			struct container *c = f.file->private_data;
> +			unsigned seq;
>  
> -		if (*s && unlikely(!d_can_lookup(dentry))) {
> -			fdput(f);
> -			return ERR_PTR(-ENOTDIR);
> -		}
> +			if (!*s)
> +				return ERR_PTR(-EINVAL);
>  
> -		nd->path = f.file->f_path;
> -		if (flags & LOOKUP_RCU) {
> -			nd->inode = nd->path.dentry->d_inode;
> -			nd->seq = read_seqcount_begin(&nd->path.dentry->d_seq);
> +			if (flags & LOOKUP_RCU) {
> +				do {
> +					seq = read_seqcount_begin(&c->seq);
> +					nd->path = c->root;
> +					nd->inode = nd->path.dentry->d_inode;
> +					nd->seq = __read_seqcount_begin(&nd->path.dentry->d_seq);
> +				} while (read_seqcount_retry(&c->seq, seq));
> +			} else {
> +				spin_lock(&c->lock);
> +				nd->path = c->root;
> +				path_get(&nd->path);
> +				spin_unlock(&c->lock);
> +				nd->inode = nd->path.dentry->d_inode;
> +			}
>  		} else {
> -			path_get(&nd->path);
> -			nd->inode = nd->path.dentry->d_inode;
> +			dentry = f.file->f_path.dentry;
> +
> +			if (*s && unlikely(!d_can_lookup(dentry))) {
> +				fdput(f);
> +				return ERR_PTR(-ENOTDIR);
> +			}
> +
> +			nd->path = f.file->f_path;
> +			if (flags & LOOKUP_RCU) {
> +				nd->inode = nd->path.dentry->d_inode;
> +				nd->seq = read_seqcount_begin(&nd->path.dentry->d_seq);
> +			} else {
> +				path_get(&nd->path);
> +				nd->inode = nd->path.dentry->d_inode;
> +			}
>  		}
>  		fdput(f);
>  		return s;
