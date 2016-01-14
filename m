Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42250 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753053AbcANUBB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jan 2016 15:01:01 -0500
Date: Thu, 14 Jan 2016 15:00:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Gil Amsalem <gil.amsalem@primarydata.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Reduce the probability to get port collision when asking
 for secure port. port collision = same port allocated to 2 different clients
 trying to connect to the same address.
Message-ID: <20160114200059.GA4484@fieldses.org>
References: <1449559654-14766-1-git-send-email-tigran.mkrtchyan@desy.de>
 <1449559654-14766-2-git-send-email-tigran.mkrtchyan@desy.de>
 <20160112220652.GB8256@fieldses.org>
 <CAOE_DS_M61BJV7UgyBOf7nZStj43xfUbzeSzoS_=gMM6ZDyg=w@mail.gmail.com>
 <20160113163425.GA17569@fieldses.org>
 <20160113210008.080b2a4c@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160113210008.080b2a4c@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 13, 2016 at 09:00:08PM -0500, Jeff Layton wrote:
> On Wed, 13 Jan 2016 11:34:25 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Jan 13, 2016 at 10:59:25AM +0200, Gil Amsalem wrote:
> > > Hi,
> > > 
> > > I don't know how, but I faced this issue where the *bindsocket* method
> > > bounded port 1 for two different threads.
> > > Not sure how could it happen.
> > > After my change, I got random ports of course, and the problem was solved.  
> > 
> > Huh.  OK, well I'd like to see how to reproduce the problem and
> > understand what was going on.  Maybe I'm just missing something obvious
> > but I didn't think it should be possible for two bind()s to the same
> > port to succeed simultaneously.
> > 
> 
> It is possible if you set SO_REUSEPORT on the socket. Does pynfs do
> that? Might be interesting to strace the program and see if it sets
> that option on the socket to confirm...

This is just socket.bind() with no special options so it'd be pretty
weird if it was doing an SO_REUSEPORT.  Not a bad idea to check that
with an strace if the problem shows up again, though.

Anyway, dropping the patch for now.

--b.
