Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59909 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754104AbcAMQe3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jan 2016 11:34:29 -0500
Date: Wed, 13 Jan 2016 11:34:25 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Gil Amsalem <gil.amsalem@primarydata.com>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Reduce the probability to get port collision when asking
 for secure port. port collision = same port allocated to 2 different clients
 trying to connect to the same address.
Message-ID: <20160113163425.GA17569@fieldses.org>
References: <1449559654-14766-1-git-send-email-tigran.mkrtchyan@desy.de>
 <1449559654-14766-2-git-send-email-tigran.mkrtchyan@desy.de>
 <20160112220652.GB8256@fieldses.org>
 <CAOE_DS_M61BJV7UgyBOf7nZStj43xfUbzeSzoS_=gMM6ZDyg=w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAOE_DS_M61BJV7UgyBOf7nZStj43xfUbzeSzoS_=gMM6ZDyg=w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 13, 2016 at 10:59:25AM +0200, Gil Amsalem wrote:
> Hi,
> 
> I don't know how, but I faced this issue where the *bindsocket* method
> bounded port 1 for two different threads.
> Not sure how could it happen.
> After my change, I got random ports of course, and the problem was solved.

Huh.  OK, well I'd like to see how to reproduce the problem and
understand what was going on.  Maybe I'm just missing something obvious
but I didn't think it should be possible for two bind()s to the same
port to succeed simultaneously.

--b.
