Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45077 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756403Ab2B2VoE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Feb 2012 16:44:04 -0500
Date: Wed, 29 Feb 2012 16:44:00 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v7 5/5] nfsd: add the infrastructure to handle the cld
 upcall
Message-ID: <20120229214400.GA6506@fieldses.org>
References: <1330535757-24925-1-git-send-email-jlayton@redhat.com>
 <1330535757-24925-6-git-send-email-jlayton@redhat.com>
 <4F4E70C5.9030608@parallels.com>
 <20120229144512.37de84e7@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120229144512.37de84e7@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 29, 2012 at 02:45:12PM -0500, Jeff Layton wrote:
> On Wed, 29 Feb 2012 22:39:01 +0400
> Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
> 
> > Hi, Jeff.
> > I'll try to explain, how all this namespaces-aware SUNRPC PipeFS works.
> > The main idea is, that today we have 2 types of independently created and 
> > destroyed but linked objects:
> > 1) pipe data itself. This object is created whenever kernel requires (on mount, 
> > module install, whatever)
> > 2) dentry/inode for this pipe. This object is created on PipeFS superblock creation.
> > This means, any kernel user of SUNRPC pipes have to provide two mechanisms:
> > 1) Safe call (in per-net operations, if the object is global your case) for 
> > PipeFS dentry/inode pair. This is done this in nfsd4_init_cld_pipe().
> >
> > 2) Notifier callback for PipeFS mount/umount operations. Note: this callback is 
> > done from SUNRPC module (i.e. you have to get nfsd module); this callback is 
> > safe - i.e you can be sure, that superblock is valid.
> > 
> 
> This is the part I'm having a hard time with. IIUC, the existing
> examples are fairly clear since you have a 1:1 ratio of objects: a
> per-net object (the pipe data) that is hooked up to a dentry/inode in a
> per-net sb.
> 
> Here though, we don't really have that. We have a global pipe object
> and I don't see how you can hook that up to multiple dentries/inodes.
> 
> One possibility is to completely "namespacify" this code -- don't use a
> global rpc_pipe object and make it per-net instead. If I do that though,
> then I suppose I'll also need to make all of the
> nfsd4_client_tracking_ops take a struct net arg as well?

That does sound like what we'll want eventually.

And callers will use pass svc_rqst->rq_xprt->xpt_net there, I assume.

(Or actually we may need a pointer to the netns from the nfs4 client?)

--b.
