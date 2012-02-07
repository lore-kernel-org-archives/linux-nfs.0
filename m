Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754671Ab2BGTNC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 14:13:02 -0500
Date: Tue, 7 Feb 2012 14:12:54 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bjschuma@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS: Fall back on old idmapper if request_key()
 fails
Message-ID: <20120207141254.2948e735@tlielax.poochiereds.net>
In-Reply-To: <1327614865-29322-1-git-send-email-bjschuma@netapp.com>
References: <1327614865-29322-1-git-send-email-bjschuma@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 26 Jan 2012 16:54:23 -0500
bjschuma@netapp.com wrote:

> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> This patch removes the CONFIG_NFS_USE_NEW_IDMAPPER compile option.
> First, the idmapper will attempt to map the id using /sbin/request-key
> and nfsidmap.  If this fails (if /etc/request-key.conf is not configured
> properly) then the idmapper will call the legacy code to perform the
> mapping.  I left a comment stating where the legacy code begins to make
> it easier for somebody to remove in the future.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---


I think this patch is the right approach and will make the transition
easier. But there is still a bit of a problem here...

One of the main complaints about the old idmapper was that it did a
rather large allocation on every time a new nfs_client is created:

-----------------------[snip]----------------------

int
nfs_idmap_new(struct nfs_client *clp)
{
        struct idmap *idmap;
        struct rpc_pipe *pipe;
        int error;

        BUG_ON(clp->cl_idmap != NULL);

        idmap = kzalloc(sizeof(*idmap), GFP_KERNEL);
        if (idmap == NULL)
                return -ENOMEM;

-----------------------[snip]----------------------

On a 32-bit box when you try to mount and low memory is heavily
fragmented, you can get a NULL pointer back on that kzalloc with a
nice stack trace headed by a message like this:

    mount.nfs: page allocation failure. order:4, mode:0xc0d0

Here's a RHBZ against RHEL6 if you're interested in gory details:

    https://bugzilla.redhat.com/show_bug.cgi?id=730045

In any case, this problem was one of the reasons for pushing the new
idmapper. A number of people have complained about this problem in the
past and we told them "use the new idmapper". Now, with this patchset,
that won't help.

I think the right solution is to probably look at breaking up the idmap
structure in the legacy idmapper into multiple allocations. It's more
complicated to deal with and will mean restructuring the code a bit,
but it will allow for a relatively graceful transition to the new
idmapper.

Thoughts?

-- 
Jeff Layton <jlayton@redhat.com>
