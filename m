Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753326Ab2DPOWd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Apr 2012 10:22:33 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q3GEMXTr006144
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 16 Apr 2012 10:22:33 -0400
Date: Mon, 16 Apr 2012 10:23:23 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 1/9] nfsdcld: add client tracking daemon stub
Message-ID: <20120416102323.7f86eb56@corrin.poochiereds.net>
In-Reply-To: <4F8C277F.2090707@RedHat.com>
References: <1328111096-28430-1-git-send-email-jlayton@redhat.com>
	<1328111096-28430-2-git-send-email-jlayton@redhat.com>
	<4F8C277F.2090707@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 16 Apr 2012 10:06:55 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 02/01/2012 10:44 AM, Jeff Layton wrote:
> > This program opens and "listens" on the new nfsd/cld rpc_pipefs pipe.
> > The code here doesn't actually do anything on stable storage yet. That
> > will be added in a later patch.
> > 
> > The patch also adds a autoconf enable switch for the new daemon that
> > defaults to "no", and a test for the upcall description header file.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  configure.ac              |   14 +++
> >  utils/Makefile.am         |    4 +
> >  utils/nfsdcld/Makefile.am |   14 +++
> >  utils/nfsdcld/nfsdcld.c   |  275 +++++++++++++++++++++++++++++++++++++++++++++
> >  4 files changed, 307 insertions(+), 0 deletions(-)
> >  create mode 100644 utils/nfsdcld/Makefile.am
> >  create mode 100644 utils/nfsdcld/nfsdcld.c
> > 
> > diff --git a/configure.ac b/configure.ac
> > index 920e8da..d50e54e 100644
> > --- a/configure.ac
> > +++ b/configure.ac
> > @@ -185,6 +185,12 @@ else
> >  	AM_CONDITIONAL(MOUNT_CONFIG, [test "$enable_mount" = "yes"])
> >  fi
> >  
> > +AC_ARG_ENABLE(nfsdcld,
> > +	[AC_HELP_STRING([--enable-nfsdcld],
> > +			[Create nfsdcld NFSv4 clientid tracking daemon. <:@default=no@:>@])],
> > +	enable_nfsdcld=$enableval,
> > +	enable_nfsdcld="no")
> > +
> >  dnl Check for TI-RPC library and headers
> >  AC_LIBTIRPC
> >  
> > @@ -260,6 +266,13 @@ if test "$enable_nfsv4" = yes; then
> >    dnl check for the keyutils libraries and headers
> >    AC_KEYUTILS
> >  
> > +  if test "$enable_nfsdcld" = "yes"; then
> > +    AC_CHECK_HEADERS([linux/nfsd/cld.h], ,
> > +		     AC_MSG_ERROR([Cannot find header needed for nfsdcld]))
> > +  fi
> This adds a dependency on the kernel headers being present which 
> is unprecedented for nfs-utils or any other package I'm aware of
> and I just don't think its a good idea... 
> 
> So I'm wondering if there is someway around creating this
> dependency...
> 

The idea with that header was to have a common userspace/kernel header
that describes the upcall/downcall format. The proper place for those
is generally the kernel-headers package (at least on Fedora). Other
distros have a similar package.

One possibility is to include a copy of this header with nfs-utils, and
only use it if /usr/include/linux/nfsd/cld.h isn't present. It's not
ideal, but I suppose we could live with it if adding a dependency on
kernel headers is anathema. It would take some rework of the code and
autoconf/automake stuff however.

-- 
Jeff Layton <jlayton@redhat.com>
