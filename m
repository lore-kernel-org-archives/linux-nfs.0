Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44986 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754116Ab2BDALP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Feb 2012 19:11:15 -0500
Date: Fri, 3 Feb 2012 19:11:13 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Koen Wilde <koen@chillheid.nl>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: Re: oops when copying a file from a nfs mount
Message-ID: <20120204001113.GA5320@fieldses.org>
References: <20120203223604.98C91405DC@mail.chillheid.nl>
 <20120203230811.GH2999@fieldses.org>
 <20120203232427.20B21405DC@mail.chillheid.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120203232427.20B21405DC@mail.chillheid.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 04, 2012 at 12:24:27AM +0100, Koen Wilde wrote:
> On Fri, 3 Feb 2012 18:08:11 -0500, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > Is this really the start of the trace, or were there any lines before?
> > 
> 
> This is really the start of the trace as it appears in syslog's logs. On
> the physical screen it had some extra lines on top though (I'm typing this
> over from a photo):
> 
>     BUG: unable to handle kernel NULL pointer dereference at   (null)
>     IP: [<c01f3c00>] page_address+0x10/0xe0
>     << continuing from here with the *pde line >>
> 
> > But I take it you're comfortable building a kernel from source?  If so,
> > getting a stable git repo, then:
> > 
> > 	git checkout v3.2.2
> > 	git revert 628fc192adbaae0c6178b9015fb916ce61d72b36
> > 
> > and then testing the resulting kernel--it'd be interesting to know if
> > the bug goes away.
> 
> Sure, I can build a kernel from source:) I'll get back to you with the
> results.

OK, but--probably ignore my suggestion and try applying Trond's patch
instead....

(Also, I assume mainline needs it as well as v3.2.2 ?)

--b.
