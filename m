From: Giulio Troccoli <Giulio.Troccoli-xnMMdYoS6WpEKMMhf/gKZA@public.gmane.org>
Subject: Re: [NFS] Compileing nfs-utils 1.1.5 on RHEL4 fails in tcpwrapper.c
Date: Fri, 27 Mar 2009 14:15:36 +0000
Message-ID: <6680A70380E6BA44A2D94ED7085718EE066A0807AB@ln1exc03>
References: <6680A70380E6BA44A2D94ED7085718EE066A08079D@ln1exc03>
	<49CCDBD2.2000709@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: 'Steve Dickson' <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44647 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751864AbZC0ORv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2009 10:17:51 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LnCsV-0005xZ-97
	for linux-nfs@vger.kernel.org; Sat, 28 Mar 2009 01:17:47 +1100
In-Reply-To: <49CCDBD2.2000709-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



>


Linedata Services (UK) Ltd
Registered Office: Bishopsgate Court, 4-12 Norton Folgate, London, E1 6DB
Registered in England and Wales No 3027851    VAT Reg No 778499447

-----Original Message-----


> From: Steve Dickson [mailto:SteveD@redhat.com]
> Sent: 27 March 2009 14:00
> To: Giulio Troccoli
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] Compileing nfs-utils 1.1.5 on RHEL4 fails
> in tcpwrapper.c
>
>
>
> Giulio Troccoli wrote:
> > Hi,
> >
> > I want to upgrade nfs-utils from 1.0.6 to 1.1.5, so I have
> downloaded
> > the source code form sourceforge.net and issue the following
> > ./configure command
> >
> > ./configure --disable-nfsv4 --disable-static
> --with-statduser=rpcuser
> > --disable-gss
> >
> > Which finishes without errors. But then when I make I get the
> > following
> >
> > make[2]: Entering directory
> `/usr/local/src/nfs-utils-1.1.5/support/misc'
> > gcc -DHAVE_CONFIG_H -I. -I../../support/include
> -I/usr/include -D_GNU_SOURCE -Wall -Wstrict-prototypes  -pipe
> -g -O2 -MT tcpwrapper.o -MD -MP -MF .deps/tcpwrapper.Tpo -c
> -o tcpwrapper.o tcpwrapper.c
> > tcpwrapper.c: In function `haccess_add':
> > tcpwrapper.c:117: warning: implicit declaration of function
> `TAILQ_EMPTY'
> > tcpwrapper.c:119: error: syntax error before "else"
> > tcpwrapper.c: At top level:
> > tcpwrapper.c:121: error: syntax error before '}' token
> > tcpwrapper.c: In function `haccess_lookup':
> > tcpwrapper.c:131: warning: implicit declaration of function
> `TAILQ_FOREACH'
> > tcpwrapper.c:131: error: `list' undeclared (first use in this
> > function)
> > tcpwrapper.c:131: error: (Each undeclared identifier is
> reported only
> > once
> > tcpwrapper.c:131: error: for each function it appears in.)
> > tcpwrapper.c:131: error: syntax error before '{' token
> > make[2]: *** [tcpwrapper.o] Error 1
> > make[2]: Leaving directory
> `/usr/local/src/nfs-utils-1.1.5/support/misc'
> > make[1]: *** [all-recursive] Error 1
> > make[1]: Leaving directory `/usr/local/src/nfs-utils-1.1.5/support'
> > make: *** [all-recursive] Error 1
> >
> > I have found the TAILQ_ definitions in utils/idmapd/queue.h
> but most importantly in /usr/include/sys/queue.h which
> tcpwrapper.c should have picked up.
> >
> > Can anubody help? I'm not subscribed to the list so please
> make sure to CC me.
> This is a bit strange... What environment are you compiling this in?
> You can also try the "--without-tcp-wrappers" config flag
>
> steved.

Thanks Steve, that actually worked, i.e. it compiled. Only now I notice that ./configure --help does mention with package.

Now, before I install the new NFS I'd like to make sure that I built NFS with what I need.

I have a RHEL4 machine that we use for source control. On this server we have an up-to-date copy of the source code. Other building machines (at the moment an AIX and a Solaris) mount the copy of the source code as local file systems. The building area contains sym links to the mounted file system.

>From time to time the build failes becuase some files are not available when they are compiled. This is not strictly true, the file is available but the building machine is told it's not.

I'm not sure how to go on investigating and fixing this issue but I thought I would start getting the latest NFS.

I don't know much about NFS and the option I chose for the configure script are just becuase otherwise it didn't compile. So, do you guys think that even without nfsv4, gss and tcp-wrapper I would achive what I need?

Thanks a lot
Giulio


------------------------------------------------------------------------------
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

