From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] fix statd -n
Date: Mon, 5 May 2008 11:58:58 -0400
Message-ID: <20080505155858.GF8259@fieldses.org>
References: <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com> <481B96D0.8010802@gmail.com> <24c1515f0805021724q7dfe5294r702a9c8ffde01129@mail.gmail.com> <20080505144538.GB8259@fieldses.org> <481F20B6.8080603@gmail.com> <24c1515f0805050801m66cce68k94073914ba26511e@mail.gmail.com> <481F2600.20501@gmail.com> <24c1515f0805050823s14f4caf7s3a4ff06a70c220be@mail.gmail.com> <20080505152519.GE8259@fieldses.org> <24c1515f0805050828o3aa5b33aod2a6e4e0b5b6c9dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wendy Cheng <s.wendy.cheng@gmail.com>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54451 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752288AbYEEP7D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 11:59:03 -0400
In-Reply-To: <24c1515f0805050828o3aa5b33aod2a6e4e0b5b6c9dc-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 05, 2008 at 11:28:03AM -0400, Janne Karhunen wrote:
> On Mon, May 5, 2008 at 11:25 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> >  > As statd runs this directly and reads name for -v from
> >  > MY_NAME,
> >
> >  Nope; see the -L option to statd.
> 
> So the let the user worry approach. Statd does not
> notify anyone and user is supposed to do it with
> sm-notify manually.

We should modify distro startup scripts to run sm-notify and add -L to
statd, following the recommendations in nfs-utils/README.

That will leave the -v option to sm-notify, which will need to be added
somehow to handle the highly-available-nfs case.

> This will work, but -n looks cleaner me..

I've lost the thread here a little.  Let me try to summarize, and tell
me what I've forgotten:

So we've got multiple nfs servers that may serve the same export.  Only
one serves a given export at a time.

To keep the clients from having to understand this, we tell them to
mount a single "floating" ip address, and when we want to use a
different server, we move that floating ip address, and the clients
automatically follow it.  The only problem is that the new server
doesn't know about locks held on the old server.  We solve that problem
by telling clients that the server has rebooted, and that they must
reclaim locks.

To make that work, we need to ensure that statd notifies the clients
that "floating-ip" has rebooted.  (They will get confused if they are
notified that "some-other-ip" has rebooted, where "some-other-ip" is
just some random ip that the new server happens to use on a different
interface.)

In the case that you care about, a given server only has one floating ip
address pointing at it at a time.  For your case, you could start statd
either with:

	sm-notify -v <floating ip>
	statd -L

or (assuming it was fixed)

	statd -n <floating ip>

and either would do the job of notifying all monitored clients that
<floating ip> has "rebooted".

Wendy also worries about the case of a server with multiple floating
ip's that may move independently of each other, or with both floating
ip's and ip's that don't move.  In that case we want to notify only
some subset of the clients.

So she uses 'statd -H' to modify the way statd stores its records, so
that it can easily distinguish between clients that are associated with
a floating ip that's moving (and need to be notified), and clients that
aren't (and don't need to be notified right now).

The statd -n option has actually *never* worked, in any previous version
of nfs-utils--with it specified, statd can no longer communicate with
the nfs server on the same host.  That means the server won't find out
when a client reboots.  (But I guess even the broken -n may still have
been sufficient to allow clients to monitor the server and find out when
the server reboots.)

--b.
