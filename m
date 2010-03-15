Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9302 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937008Ab0COWrL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Mar 2010 18:47:11 -0400
Date: Mon, 15 Mar 2010 18:47:02 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] vfs: pass struct file to do_truncate on O_TRUNC opens
Message-ID: <20100315184702.35c4d140@tlielax.poochiereds.net>
In-Reply-To: <1268692288.3040.2.camel@localhost.localdomain>
References: <1268689152-19168-1-git-send-email-jlayton@redhat.com>
	<1268692288.3040.2.camel@localhost.localdomain>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 15 Mar 2010 18:31:28 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Mon, 2010-03-15 at 17:39 -0400, Jeff Layton wrote: 
> > When a file is opened with O_TRUNC, the truncate processing is handled
> > by handle_truncate(). This function however doesn't receive any info
> > about the newly instantiated filp, and therefore can't pass that info
> > along so that the setattr can use it.
> > 
> > This makes NFSv4 misbehave. The client does an open and gets a valid
> > stateid, and then doesn't use that stateid on the subsequent truncate.
> > It uses the zero-stateid instead. Most servers ignore this fact and
> > just do the truncate anyway, but some don't like it (notably, RHEL4).
> > 
> > It seems more correct that since we have a fully instantiated file at
> > the time that handle_truncate is called, that we pass that along so
> > that the truncate operation can properly use it.
> 
> At least in the O_CREAT|O_TRUNC case, we really should modify
> nfs4_opendata_alloc() to set the attrs.ia_size to zero, so that the
> server does an atomic open(O_CREAT|O_TRUNC) for us (see the DESCRIPTION
> paragraph in RFC3530 section 14.2.16). There shouldn't be any need for
> an extra truncate RPC call.
> 
> Plain open(O_TRUNC) probably does need something along the lines of what
> you propose, however.
> 

Yeah that would be cleaner on the wire for the create case. It's not
clear to me how to implement that though. There doesn't appear to be
a straightforward way to tell the VFS to skip the truncate.

-- 
Jeff Layton <jlayton@redhat.com>
