From: Neil Brown <neilb@suse.de>
Subject: Re: inotify and nfsd exported filesystem
Date: Wed, 23 Jan 2008 08:34:01 +1100
Message-ID: <18326.24905.512220.221488@notabene.brown>
References: <120349239@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: devzero-S0/GAf8tV78@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:34837 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbYAVVeJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jan 2008 16:34:09 -0500
In-Reply-To: message from devzero-S0/GAf8tV78@public.gmane.org on Tuesday January 22
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday January 22, devzero-S0/GAf8tV78@public.gmane.org wrote:
> i was only testing for IN_OPEN and IN_CLOSE_NOWRITE  ( http://inotify-tools.sourceforge.net/api/inotifytools_8h.html )
> 
> can do more in depth test tomorrow.

If you are watching for inotify events on the server, and performing
accesses on some client, then I would expect you to get an IN_OPEN
followed immediately by an IN_CLOSE_{NO,}WRITE each time the client
sends a READ or WRITE request respectively.

So if the client just opens the file and then closes it, you would get
no INOTIFY events.
If the client performs open/read/close repeatedly, subsequent reads
would come from cache, so you would only get one
IN_OPEN/IN_CLOSE_NOWRITE
pair.

If the client performs writes, you should get a more predictable
stream of IN_OPEN/IN_CLOSE_WRITE pairs, though they could be delayed a
bit.

You results will probably be different (and possible more like what
you expect) if you use NFSv4.

NeilBrown
