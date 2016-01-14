Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:33432 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbcANCAM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jan 2016 21:00:12 -0500
Received: by mail-yk0-f171.google.com with SMTP id k129so488153007yke.0
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jan 2016 18:00:11 -0800 (PST)
Date: Wed, 13 Jan 2016 21:00:08 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Gil Amsalem <gil.amsalem@primarydata.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Reduce the probability to get port collision when
 asking for secure port. port collision = same port allocated to 2 different
 clients trying to connect to the same address.
Message-ID: <20160113210008.080b2a4c@synchrony.poochiereds.net>
In-Reply-To: <20160113163425.GA17569@fieldses.org>
References: <1449559654-14766-1-git-send-email-tigran.mkrtchyan@desy.de>
	<1449559654-14766-2-git-send-email-tigran.mkrtchyan@desy.de>
	<20160112220652.GB8256@fieldses.org>
	<CAOE_DS_M61BJV7UgyBOf7nZStj43xfUbzeSzoS_=gMM6ZDyg=w@mail.gmail.com>
	<20160113163425.GA17569@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 13 Jan 2016 11:34:25 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jan 13, 2016 at 10:59:25AM +0200, Gil Amsalem wrote:
> > Hi,
> > 
> > I don't know how, but I faced this issue where the *bindsocket* method
> > bounded port 1 for two different threads.
> > Not sure how could it happen.
> > After my change, I got random ports of course, and the problem was solved.  
> 
> Huh.  OK, well I'd like to see how to reproduce the problem and
> understand what was going on.  Maybe I'm just missing something obvious
> but I didn't think it should be possible for two bind()s to the same
> port to succeed simultaneously.
> 

It is possible if you set SO_REUSEPORT on the socket. Does pynfs do
that? Might be interesting to strace the program and see if it sets
that option on the socket to confirm...

-- 
Jeff Layton <jlayton@poochiereds.net>
