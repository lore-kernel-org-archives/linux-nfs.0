From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: implement option checking when remounting NFS
	filesystems (resend)
Date: Tue, 10 Jun 2008 15:26:48 -0400
Message-ID: <1213126008.20459.36.camel@localhost>
References: <1210783536-23607-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:39566 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753604AbYFJT0w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 15:26:52 -0400
In-Reply-To: <1210783536-23607-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-05-14 at 12:45 -0400, Jeff Layton wrote:
> When remounting an NFS or NFS4 filesystem, the new NFS options are not
> respected, yet the remount will still return success. This patch adds
> a remount_fs sb op for NFS that checks any new nfs mount options against
> the existing ones and fails the mount if any have changed.
> 
> This is only implemented for string-based mount options since doing
> this with binary options isn't really feasible.
> 
> This is essentially the same as the original patch I sent out, but
> adds a check to see if the addr= option has changed.
> ---

s-o-b: ?

Trond

