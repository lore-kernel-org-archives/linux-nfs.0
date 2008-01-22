From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: inotify and nfsd exported filesystem
Date: Tue, 22 Jan 2008 16:39:34 -0500
Message-ID: <20080122213934.GN24697@fieldses.org>
References: <120349239@web.de> <18326.24905.512220.221488@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devzero-S0/GAf8tV78@public.gmane.org, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51393 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751929AbYAVVji (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jan 2008 16:39:38 -0500
In-Reply-To: <18326.24905.512220.221488-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 23, 2008 at 08:34:01AM +1100, Neil Brown wrote:
> On Tuesday January 22, devzero-S0/GAf8tV78@public.gmane.org wrote:
> > i was only testing for IN_OPEN and IN_CLOSE_NOWRITE  ( http://inotify-tools.sourceforge.net/api/inotifytools_8h.html )
> > 
> > can do more in depth test tomorrow.
> 
> If you are watching for inotify events on the server, and performing
> accesses on some client, then I would expect you to get an IN_OPEN
> followed immediately by an IN_CLOSE_{NO,}WRITE each time the client
> sends a READ or WRITE request respectively.
> 
> So if the client just opens the file and then closes it, you would get
> no INOTIFY events.
> If the client performs open/read/close repeatedly, subsequent reads
> would come from cache, so you would only get one
> IN_OPEN/IN_CLOSE_NOWRITE
> pair.
> 
> If the client performs writes, you should get a more predictable
> stream of IN_OPEN/IN_CLOSE_WRITE pairs, though they could be delayed a
> bit.
> 
> You results will probably be different (and possible more like what
> you expect) if you use NFSv4.

Until delegations are granted, and then you'll start missing some of the
client's opens again....

I'd expect inotify to notice changes to directories and (after some
delay) to file data, but wouldn't count on more than that.

--b.
