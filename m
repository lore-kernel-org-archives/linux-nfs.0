From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: atimes not updated over NFS
Date: Wed, 30 Jan 2008 12:23:00 +0100
Message-ID: <20080130112300.GP15220@kernel.dk>
References: <1200943865.25562.56.camel@heimdal.trondhjem.org> <20080121210230.GA22046@janus> <20080121210925.GQ17468@fieldses.org> <20080122171717.GD24697@fieldses.org> <20080129025940.GI16785@fieldses.org> <20080129041411.GC1190@fieldses.org> <20080129083402.GN15220@kernel.dk> <20080129182721.GB28032@fieldses.org> <20080129183042.GH15220@kernel.dk> <20080129203713.GS17213@aym.net2.nerim.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:23077 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751227AbYA3LXD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jan 2008 06:23:03 -0500
In-Reply-To: <20080129203713.GS17213-956IwFboN44acnK+F/IuxqxOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 29 2008, Andre Majorel wrote:
> On 2008-01-29 19:30 +0100, Jens Axboe wrote:
> 
> > diff --git a/fs/splice.c b/fs/splice.c
> > index 0a0b79b..504a096 100644
> > --- a/fs/splice.c
> > +++ b/fs/splice.c
> > @@ -1052,8 +1052,10 @@ out_release:
> >  	/*
> >  	 * If we transferred some data, return the number of bytes:
> >  	 */
> > -	if (bytes > 0)
> > +	if (bytes > 0) {
> > +		file_accessed(in);
> >  		return bytes;
> > +	}
> >  
> >  	return ret;
> 
> Does the (bytes > 0) test mean that read(2) on an empty file will
> not update the atime ? Not a big deal for me personally, but that
> would be inconsistent with local file system behaviour.

Good point, I'll commit a fixup for that patch.

-- 
Jens Axboe

