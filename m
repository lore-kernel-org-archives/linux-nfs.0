From: Ben Myers <bpm@sgi.com>
Subject: Re: [PATCH] mountd: use separate lockfiles
Date: Thu, 19 Mar 2009 14:53:57 -0500
Message-ID: <20090319195357.GH26378@sgi.com>
References: <20090319172841.GF26378@sgi.com> <1237485682.7534.39.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:37254 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751711AbZCSTvq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2009 15:51:46 -0400
In-Reply-To: <1237485682.7534.39.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Thu, Mar 19, 2009 at 02:01:21PM -0400, Trond Myklebust wrote:
> On Thu, 2009-03-19 at 12:28 -0500, Ben Myers wrote:
> > @@ -58,12 +59,17 @@ xflock(char *fname, char *type)
> >  	struct flock	fl = { readonly? F_RDLCK : F_WRLCK, SEEK_SET, 0, 0, 0 };
> >  	int		fd;
> >  
> > -	if (readonly)
> > -		fd = open(fname, O_RDONLY);
> > -	else
> > -		fd = open(fname, (O_RDWR|O_CREAT), mode);
> > +again:
> > +	fd = open(fname, readonly ? O_RDONLY : (O_RDWR|O_CREAT), 0600);
> > +	if (fd < 0 && readonly && errno == ENOENT) {
> > +		/* create a new lockfile */
> > +		fd = open(fname, O_RDONLY|O_CREAT, 0600);
> 
> I don't see how you expect to get EEXIST with a non-exclusive create.
>
> Why do you need a second call to open() in the first place? How is this
> better than just doing
> 
> 	if (readonly)
> 		fd = open(fname, O_RDONLY|O_CREAT, 0600);
> 	else
> 		fd = open(fname, O_RDWR|O_CREAT, 0600);
>
> ...or, since these are now all private lockfiles, and so we shouldn't
> need to care much about read-only vs read-write

My O_RDONLY|O_CREAT open was failing with EACCES because of a problem
somewhere between my chair and keyboard.  Compounding that, I mistakenly
jumped to the conclusion that the errno was EEXIST.  ;(

I'll give it another try.

-Ben
