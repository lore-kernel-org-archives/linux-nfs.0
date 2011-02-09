Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41015 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846Ab1BIAXe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 19:23:34 -0500
Date: Tue, 8 Feb 2011 19:23:33 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Haynes <tdh@excfb.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Debugging mount failure with netgroup
Message-ID: <20110209002333.GB13617@fieldses.org>
References: <20110207195609.GA13225@adept.internal.excfb.com>
 <20110207201202.GA3055@fieldses.org>
 <20110207205306.GA13731@adept.internal.excfb.com>
 <20110207211917.GA3853@fieldses.org>
 <20110207215344.GA15778@adept.internal.excfb.com>
 <20110207215935.GB3853@fieldses.org>
 <20110207232110.GB15778@adept.internal.excfb.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110207232110.GB15778@adept.internal.excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 07, 2011 at 05:21:10PM -0600, Tom Haynes wrote:
> On Mon, Feb 07, 2011 at 04:59:35PM -0500, J. Bruce Fields wrote:
> > 
> > Changes to /etc/exports aren't automatically detected, so you need a
> > server restart or an exportfs -ra after any change.
> 
> Yep:
> 
> exportfs -au  # unload old rules
> exportfs      # verify it is empty
> exportfs -a   # load it up
> exportfs      # verify it loaded
> 
> So I would have expected it to have reloaded.

Sorry, and you said that in your original email.  OK.

> > OK, so maybe the problem was just that mountd never found out about your
> > original /etc/exports file?
> 
> That wouldn't explain why it has stopped working now.
> 
> Neither the exportfs commands above nor a service nfs stop/start
> yields a working mount from the client.
> 
> Restarting nfsd with an export of:
> 
> [root@adept internal.excfb.com]# exportfs
> /fooper       	192.168.2.0/255.255.255.0
> [root@adept internal.excfb.com]# uname -a
> Linux adept.internal.excfb.com 2.6.34.7-66.fc13.i686.PAE #1 SMP Wed Dec 15 07:21:49 UTC 2010 i686 i686 i386 GNU/Linux
> 
> Does yield a mount.

And it's failing in the same way?  ("unmatched host"?)

Like I say, I suppose my next step would be to get out the nfs-utils
source and figure out where it's failing (probably somewhere in
auth_authenticate_newcache -> get_client_hostname -> client_compose ->
client_check -> check_netgroup()).

If it's reporting "unmatched host", and if you can see it making the
right NIS request (and getting the right response), then I'm out of
other debugging ideas....

--b.
