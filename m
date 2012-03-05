Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52325 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932348Ab2CEOjx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 09:39:53 -0500
Date: Mon, 5 Mar 2012 09:39:48 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 5/6] nfsd: add the infrastructure to handle the cld
 upcall
Message-ID: <20120305093948.435f39cc@tlielax.poochiereds.net>
In-Reply-To: <4F54B6B7.1010703@parallels.com>
References: <1330720950-5872-1-git-send-email-jlayton@redhat.com>
	<1330720950-5872-6-git-send-email-jlayton@redhat.com>
	<4F547DF1.8090003@parallels.com>
	<20120305074256.6dc36fed@tlielax.poochiereds.net>
	<4F54B6B7.1010703@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 05 Mar 2012 16:51:03 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 05.03.2012 16:42, Jeff Layton пишет:
> >>
> >>
> >> Would be great to replace hard-coded cld_pipe here with a passed one.
> >> For example, put this cld_pipe on cld_msg structure.
> >> And initialize this pointer (hard-coded value for now) below in
> >> nfsd4_cld_create() and all other places where alloc_cld_upcall() is called.
> >>
> >> BTW, maybe allocate this struct cld_upcall per NFS client somehow? And thus get
> >> rid of alloc-free calls?
> >>
> >>
> >
> > Ok, I think I must have misunderstood what you meant when you said no
> > per-net ops required. I'll respin and see if I can get closer to what
> > you intended.
> >
> > Since most of the upcalls are infrequent and come from nfsd threads,
> > the number of calls in flight will always be less than the order of the
> > number of nfsd threads. That value may be much less than the number of
> > nfs4_clients, so we're probably best off allocating these dynamically.
> >
> 
> 
> Sure, it's up to you. Only wanna note, that this dynamic allocation in several 
> places looks a little bit confusing to me.
> 
> 
> > Now that I've had some time to look, I think what you're probably going
> > to want to do eventually is to add a new per-namespace object for nfsd,
> > similar to struct nfs_net for the nfs client. This container will hold
> > the pointer to the upcall pipe as well as other objects.
> >
> 
> Exactly.
> 
> > The nfs4_client objects for nfsd will then need to be per-namespace,
> > and will have a pointer back to "struct nfsd_net" or whatever you end up
> > calling it. From that they'll be able to get the rpc_pipe pointer.
> >
> 
> You most probably right (I'm not working on NFSd yet - so hard to be sure).
> 
> > For now, I'll just hardcode init_net in the appropriate places under the
> > assumption that eventually you'll be able to get a rpc_pipe pointer
> > given a pointer to an nfs4_client struct.
> >
> 
> Yes, thank you, Jeff.
> 

Ok, I've started looking at the existing examples to try and ease the
eventual containerization of this. Am I correct that the existing
blocklayout pipe containerization is not yet complete?

AIUI, you have a rpc_pipe per nfs_net struct, and those structs are
allocated on a per-net basis. bl_pipe_downcall does this however:

        if (copy_from_user(&bl_mount_reply, src, mlen) != 0)
                return -EFAULT;

...but bl_mount_reply is global:

    static struct bl_dev_msg bl_mount_reply;

So, if you're getting downcalls in two different network namespaces at
the same time this could end up corrupt. It seems like bl_mount_reply
needs to be part of nfs_net as well.

When you get a downcall, you have a filp pointer. Is there any way to
determine the "correct" nfs_net object for a particular filp?

-- 
Jeff Layton <jlayton@redhat.com>
