From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: inode caching
Date: Wed, 28 May 2008 09:59:35 -0400
Message-ID: <20080528135935.GA17606@fieldses.org>
References: <1211835499.3904.231.camel@hurina> <483C031B.80601@redhat.com> <1211902848.3904.279.camel@hurina> <483C4E61.7020102@redhat.com> <0BF144BC-6CBB-49FA-8F49-D765FB58AF5E@iki.fi> <483CEFD5.8050507@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo Sirainen <tss@iki.fi>, Peter Staubach <staubach@redhat.com>,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40850 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855AbYE1OAA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 May 2008 10:00:00 -0400
In-Reply-To: <483CEFD5.8050507@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 28, 2008 at 08:38:29AM +0300, Benny Halevy wrote:
> On May. 27, 2008, 22:13 +0300, Timo Sirainen <tss@iki.fi> wrote:
> > I'd still like to understand why exactly this happens though. Maybe  
> > there's a chance that this is just a bug in the current NFS  
> > implementation so I could keep using my current code (which is  
> > actually very difficult to break even with stress testing, so if this  
> > doesn't get fixed on kernel side I'll probably just leave my code as  
> > it is). I guess I'll start debugging the NFS code to find out what's  
> > really going on.
> 
> My guess would be that the new incarnation of the inode generates the
> same filehandle as the old one, not just the same inode number.

That sounds like a server bug (either in the server itself, or the
filesystem it's exporting); the generation number is supposed to prevent
this.

--b.
