Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15782 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933507Ab1IIVF2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 17:05:28 -0400
Date: Fri, 9 Sep 2011 17:05:20 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: shouldn't rpc_pipe_upcall message structs be
 __attribute__((packed)) ?
Message-ID: <20110909170520.6531c008@tlielax.poochiereds.net>
In-Reply-To: <20110909200304.GA32125@fieldses.org>
References: <20110909143605.57d54899@tlielax.poochiereds.net>
	<20110909200304.GA32125@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 9 Sep 2011 16:03:04 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Sep 09, 2011 at 02:36:05PM -0400, Jeff Layton wrote:
> > I've been looking at replacing the current scheme that knfsd uses to
> > track client_id4's (aka the v4recoverydir stuff), with an
> > upcall/downcall scheme. Primarily this is to allow for more robust
> > handling of clustered NFSv4 services.
> > 
> > In the process, I've been looking at the various upcall schemes we use
> > to see which ones might be suitable to use in this effort. I've noticed
> > that we have several upcalls that use rpc_pipefs, and that all of them
> > seem to make assumptions that the userspace programs will align their
> > message structs identically to how the kernel does.
> > 
> > For instance, here's the idmap one:
> > 
> > struct idmap_msg {
> >         __u8  im_type;
> >         __u8  im_conv;
> >         char  im_name[IDMAP_NAMESZ];
> >         __u32 im_id;
> >         __u8  im_status;
> > };
> 
> That's the "legacy" idmap code, right?
> 
> In which case we want to leave it alone if at all possible and move
> people to the new idmapper.
> 
> --b.
> 

Ahh good point. No need to sweat this one then.

-- 
Jeff Layton <jlayton@redhat.com>
