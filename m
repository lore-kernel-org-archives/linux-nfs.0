Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:56686 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbaI2RLe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Sep 2014 13:11:34 -0400
Received: by mail-qc0-f182.google.com with SMTP id i17so2462165qcy.13
        for <linux-nfs@vger.kernel.org>; Mon, 29 Sep 2014 10:11:33 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 29 Sep 2014 13:11:30 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] nfsd: support for lifting grace period early
Message-ID: <20140929131130.3ba5d987@tlielax.poochiereds.net>
In-Reply-To: <20140929164425.GF30691@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
	<20140926183949.GC27412@fieldses.org>
	<20140926145446.21a99698@tlielax.poochiereds.net>
	<20140926194616.GE27412@fieldses.org>
	<20140927090458.62806936@synchrony.poochiereds.net>
	<20140929164425.GF30691@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 29 Sep 2014 12:44:26 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Sat, Sep 27, 2014 at 09:04:58AM -0400, Jeff Layton wrote:
> > On Fri, 26 Sep 2014 15:46:17 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Fri, Sep 26, 2014 at 02:54:46PM -0400, Jeff Layton wrote:
> > > > On Fri, 26 Sep 2014 14:39:49 -0400
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > 
> > > > > By the way, I've seen the following *before* your patches, but in case
> > > > > you're still looking at reboot recovery problems:
> > > > > 
> > > > > I'm getting sporadic failures in the REBT6 pynfs test--a reclaim open
> > > > > succeeds after a previous boot (with full grace period) during which the
> > > > > client had failed to reclaim.
> > > > > 
> > > > > I managed to catch one trace, the relevant parts looked like:
> > > > > 
> > > > > 	SETCLIENTID client1
> > > > > 	OPEN
> > > > > 	LOCK
> > > > > 
> > > > > 	(server restart here)
> > > > > 
> > > > > 	SETCLIENTID client2
> > > > > 	OPEN
> > > > > 	LOCK (lock that conflicts with client1's)
> > > > > 
> > > > > 	(server restart here)
> > > > > 
> > > > > 	SETCLIENTID client1
> > > > > 	OPEN CLAIM_PREVIOUS
> > > > > 
> > > > > And all those ops (including the last reclaim open) succeeded.
> > > > > 
> > > > > So I didn't have a chance to review it more carefully, but it certainly
> > > > > looks like a server bug, not a test bug.  (Well, technically the server
> > > > > behavior above is correct since it's not required to refuse anything
> > > > > till we actually attempt to reclaim the original lock, but we know our
> > > > > server's not that smart.)
> > > > > 
> > > > > But I haven't gotten any further than that....
> > > > > 
> > > > > --b.
> > > > > 
> > > > 
> > > > Ewww...v4.0... ;)
> > > > 
> > > > Well, I guess that could happen if, after the first reboot, client1 also
> > > > did a SETCLIENTID *and* reclaimed something that didn't conflict with
> > > > the lock that client2 grabs...or, did an OPEN/OPEN_CONFIRM after the
> > > > grace period without reclaiming its lock previously.
> > > > 
> > > > If it didn't do one or the other, then its record should have been
> > > > cleaned out of the DB after the grace period ended between the reboots
> > > > and it wouldn't have been able to reclaim after the second reboot.
> > > 
> > > Yeah.  Is there an easy way to tell nfsdcltrack to log everything?  I'm
> > > only seeing this occasionally.
> > > 
> > 
> > If you can make sure that it's run with the '-d' flag then that'll make
> > it do debug level logging. Unfortunately, the kernel doesn't have a
> > handy switch to enable that so you'll need to patch the kernel (or
> > maybe wrap nfsdcltrack) to make that happen.
> > 
> > Maybe we should add a module parm to nfsd.ko that makes it run
> > nfsdcltrack with -d?
> 
> Would userland configuration (e.g. and optional /etc/ file) be more
> flexible?
> 

Yeah, that might not hurt.

We do want this thing to run pretty quickly, but if the config file
were only processed if it were present (and it usually wasn't) then
that might not be too bad.

> > 
> > > > It's a bit of a pathological case, and I don't see a way to fix that in
> > > > the context of v4.0. The fact that there's no RECLAIM_COMPLETE is a
> > > > pretty nasty protocol bug, IMO. Yet another reason to start really
> > > > moving people toward v4.1+...
> > > 
> > > I don't belive there's a protocol bug here.
> > > 
> > > A correct NFSv4.0 client wouldn't send the open reclaim in the case you
> > > describe above.
> > > 
> > 
> > It would in the partial reclaim case.
> 
> My (and I think Trond's) understanding is that client1 would not send
> the reclaim in that case.  In the case of a partial reclaim, a correct
> 4.0 client will stop trying to reclaim the state that it failed to
> reclaim previously.  My understanding is that is how the linux client in
> fact behaves.
> 
> So the bug would be in the client, not the protocol.  That said,
> admittedly:
> 
> 	- the "protocol" here seems to be largely in our heads; the spec
> 	  does a poor job of explaining all this.
> 	- we (not suprisingly) disagree on some of the details.
> 
> Nevertheless, I believe that despite our disagreement there's no actual
> bug at least between the existing Linux client and server.  And that
> 3530bis and 5661 were at least *supposed* to deal with this case....
> 
> Oh, look, Trond and you have written a pile more of text on this on the
> ietf list.  Should I even try to catch up, or would be better off just
> spending the rest of my day back in bed?
> 
> --b.
> 

If there is any bug, I think it's only going to crop up under extremely
rare circumstances -- network partitions cropping up during reclaims,
multiple reboots, etc...

We probably ought to try and clarify this stuff for the spec (and our
own implementations) but I don't think there's any cause for alarm...

-- 
Jeff Layton <jlayton@primarydata.com>
