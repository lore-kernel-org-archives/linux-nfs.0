Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48685 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751937Ab1ISP10 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 11:27:26 -0400
Date: Mon, 19 Sep 2011 11:27:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] configure.ac: Added server 4.1 support
 configuration option
Message-ID: <20110919152725.GA1800@fieldses.org>
References: <1316272622-4894-1-git-send-email-steved@redhat.com>
 <20110917183645.GA24278@fieldses.org>
 <4E7710B7.7070804@RedHat.com>
 <20110919133845.GA1106@fieldses.org>
 <4E774FB6.6040707@RedHat.com>
 <20110919143503.GA1474@fieldses.org>
 <4E775CC5.8090001@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E775CC5.8090001@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 19, 2011 at 11:16:21AM -0400, Steve Dickson wrote:
> 
> 
> On 09/19/2011 10:35 AM, J. Bruce Fields wrote:
> > On Mon, Sep 19, 2011 at 10:20:38AM -0400, Steve Dickson wrote:
> >>
> >>
> >> On 09/19/2011 09:38 AM, J. Bruce Fields wrote:
> >>> diff --git a/configure.ac b/configure.ac
> >>> index 1a28f8a..7000324 100644
> >>> --- a/configure.ac
> >>> +++ b/configure.ac
> >>> @@ -73,19 +73,6 @@ AC_ARG_ENABLE(nfsv4,
> >>>  	AC_SUBST(enable_nfsv4)
> >>>  	AM_CONDITIONAL(CONFIG_NFSV4, [test "$enable_nfsv4" = "yes"])
> >>>  
> >>> -AC_ARG_ENABLE(nfsv41,
> >>> -	[AC_HELP_STRING([--enable-nfsv41],
> >>> -                        [enable support for NFSv41 @<:@default=no@:>@])],
> >>> -	enable_nfsv41=$enableval,
> >>> -	enable_nfsv41=no)
> >>> -	if test "$enable_nfsv41" = yes; then
> >>> -		AC_DEFINE(NFS41_SUPPORTED, 1, [Define this if you want NFSv41 support compiled in])
> >>> -	else
> >>> -		enable_nfsv41=
> >>> -	fi
> >>> -	AC_SUBST(enable_nfsv41)
> >>> -	AM_CONDITIONAL(CONFIG_NFSV41, [test "$enable_nfsv41" = "yes"])
> >>> -
> >> I think we still need this for the 4.1 client code.
> > 
> > OK.  Or I can wait and resend a patch after you've committed the changes
> > for the client's block daemon, if you'd prefer.
> I'll deal with the configure code....
> 
> > 
> >>> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> >>> index e7e1470..fa9c429 100644
> >>> --- a/utils/nfsd/nfsd.c
> >>> +++ b/utils/nfsd/nfsd.c
> >>> @@ -40,6 +40,7 @@ static struct option longopts[] =
> >>>  	{ "port", 1, 0, 'p' },
> >>>  	{ "debug", 0, 0, 'd' },
> >>>  	{ "syslog", 0, 0, 's' },
> >>> +	{ "enable-41", 0, 0, 'X' },
> >>>  	{ NULL, 0, 0, 0 }
> >>>  };
> >> Introducing temporary, undocumented command line arguments
> >> is generally not a good thing... IMHO... I was think more
> >> of an echo to /proc/fs/nfsd/versions to enable the support.
> > 
> > I think it's a reasonable thing to do for experimental code.
> > 
> > But we could do the following instead.  (Warning: still untested.)
> > 
> > --b.
> > 
> > commit 8d69da4c556f8ad2d42caa3875a665761c27463e
> > Author: J. Bruce Fields <bfields@citi.umich.edu>
> > Date:   Thu Dec 17 17:11:54 2009 -0500
> > 
> >     nfsd: allow choosing server 41 support at runtime
> >     
> >     In the case where -N 4.1 is left off the commandline, the current code
> >     explicitly turns it on or off anyway, depending on configure options.
> >     
> >     Instead, just leave 4.1 support alone.  This allows a user to add an
> >     "echo +4.1 >/proc/fs/nfsd/versions" to their init scripts, if they want.
> >     Otherwise they will get the kernel's default (currently to leave 4.1
> >     off, as long as 4.1 support is experimental).
> I think this is a good compromise... Could you spend a few 
> cycles on making sure that echo does indeed turn on 4.1 support?

Yep, will do.

--b.
