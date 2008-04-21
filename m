From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] fix statd -n
Date: Mon, 21 Apr 2008 12:59:03 -0400
Message-ID: <20080421165903.GB4379@fieldses.org>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com> <20080418173646.GC19038@fieldses.org> <480902CA.1070805@redhat.com> <48090356.9020703@redhat.com> <20080418203225.GD28277@fieldses.org> <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com> <20080421000214.GA5453@fieldses.org> <24c1515f0804210746t2d392b8ct6575f09dc7254b07@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44261 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754537AbYDUQ7S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Apr 2008 12:59:18 -0400
In-Reply-To: <24c1515f0804210746t2d392b8ct6575f09dc7254b07-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 21, 2008 at 10:46:00AM -0400, Janne Karhunen wrote:
> On Sun, Apr 20, 2008 at 8:02 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> >  > >  > Sorry, not very clear.  Perhaps statd should bind to the loopback
> >  > >  > interface in addition to any other interfaces if it doesn't bind
> >  > >  > to INADDR_ANY.
> >  > >
> >  > >  Right, that's what would make the most sense to me.  Janne, is there any
> >  > >  reason that wouldn't solve your problem?
> >  >
> >  > I didn't get the idea. So the idea is to use multiple sockets,
> >  > one bound to LOOPBACK and one to external interface?
> >
> >  I suppose so.  One socket would be for communication for the local
> >  kernel nfsd, one for communication with statd peers.
> 
> So shall we add yet another port option for statd or talk
> to portmap about the port assignment?  It's ugly any way
> you put it.

I'm confused--why is either needed?

--b.
