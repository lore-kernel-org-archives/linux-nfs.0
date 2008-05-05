From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] fix statd -n
Date: Mon, 5 May 2008 13:02:28 -0400
Message-ID: <20080505170228.GB11809@fieldses.org>
References: <24c1515f0805021724q7dfe5294r702a9c8ffde01129@mail.gmail.com> <20080505144538.GB8259@fieldses.org> <481F20B6.8080603@gmail.com> <24c1515f0805050801m66cce68k94073914ba26511e@mail.gmail.com> <481F2600.20501@gmail.com> <24c1515f0805050823s14f4caf7s3a4ff06a70c220be@mail.gmail.com> <20080505152519.GE8259@fieldses.org> <24c1515f0805050828o3aa5b33aod2a6e4e0b5b6c9dc@mail.gmail.com> <20080505155858.GF8259@fieldses.org> <24c1515f0805050942h26a0aaefi471216482fbabef5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wendy Cheng <s.wendy.cheng@gmail.com>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41806 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755640AbYEERCb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 13:02:31 -0400
In-Reply-To: <24c1515f0805050942h26a0aaefi471216482fbabef5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 05, 2008 at 12:42:49PM -0400, Janne Karhunen wrote:
> On Mon, May 5, 2008 at 11:58 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >  The statd -n option has actually *never* worked, in any previous version
> >  of nfs-utils--with it specified, statd can no longer communicate with
> >  the nfs server on the same host.  That means the server won't find out
> >  when a client reboots.  (But I guess even the broken -n may still have
> >  been sufficient to allow clients to monitor the server and find out when
> >  the server reboots.)
> 
> -n may work as is in 1.1.* tree:

Oh, right, I'd forgotten about that change.

> a) It will bind to ANY, so kernel lockd will see packets coming
> in from LO. 1.0.x bound the -n interface which will break.
> 
> b) sm-notify is run with -v and correct name (that will bind to
> correct IP and use the right name)
> 
> So the only thing missing would be to limit the port visibility
> of long-standing sockets; but this should probably be
> discussed in another thread if you think it's worth it?

Is the only justification just to limit the consequences if a remote
exploit is found in statd?

If so, iptables seems the better solution, since it provides a uniform
way of limiting the exposure of the ports for all the various
nfs-related (and other) services, as opposed to just being a one-off
thing for statd.

--b.
