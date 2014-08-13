Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.alpinelinux.org ([74.117.189.114]:46839 "EHLO
	mail.alpinelinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbaHMJEV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2014 05:04:21 -0400
Date: Wed, 13 Aug 2014 11:04:15 +0200
From: Natanael Copa <ncopa@alpinelinux.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 11/11] exportfs: only do glibc specific hackery on
 glibc
Message-ID: <20140813110415.4f1ff493@ncopa-desktop.alpinelinux.org>
In-Reply-To: <53E9F49A.4070500@RedHat.com>
References: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org>
	<1407306306-29796-12-git-send-email-ncopa@alpinelinux.org>
	<53E9F49A.4070500@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 12 Aug 2014 07:03:54 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 08/06/2014 02:25 AM, Natanael Copa wrote:
> > We should not depend on the libc do free(3) on ai_canonname as that is
> > completely up to implementation and known o break things on uclibc and
> > musl libc.
> > 
> > Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
> > ---
> >  support/export/hostname.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/support/export/hostname.c b/support/export/hostname.c
> > index d9153e1..30584b4 100644
> > --- a/support/export/hostname.c
> > +++ b/support/export/hostname.c
> > @@ -382,6 +382,7 @@ host_numeric_addrinfo(const struct sockaddr *sap)
> >  
> >  	ai = host_pton(buf);
> >  
> > +#if !definded(__UCLIBC__) && defined(__GLIBC__)
>         ^^^^^^^^
> Are you kidding me???? How are you testing these patches? 

my bad sorry.

> 
> I'm all for this port but I'm a bit concern about the 
> stability since things like this don't even compile... 

I have compile tested them and run tested them on musl libc. Without
those patches code does not compile with musl libc and without some of
the patches the application segfaults with musl libc (due to the way
basename(3) is used)

Patch 11 is supposed to fix a segfault due to nfs-utils expects
getaddrinfo(3)/freeaddrinfo(3) to malloc/free the ai_canonname field,
but i messed up in the countless rebases I have done. Patch 11/11 is bad
and can be discarded.

The problem is still there though and I believe it leads to a memleak
if you ai->ai_canonname = strdup(buf), depending on the
getaddrinfo/freeaddrinfo implementation.

I know for sure that this line used to case a segfault on uclibc:
                free(ai->ai_canonname);         /* just in case */

I think the proper way to fix it requires some refactoring so I think
we can do that separately.

The other 10 patches should be good though.

Note that even with those patches nfs-utils does not actually work with
musl libc due to the use of FILE* IO to access of /proc/net/rpc. It
does work with Timos "rework access to /proc/net/rpc" patch (but I
believe it still leaks memory)


> steved.
>  
> >  	/*
> >  	 * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
> >  	 */
> > @@ -392,7 +393,9 @@ host_numeric_addrinfo(const struct sockaddr *sap)
> >  			ai = NULL;
> >  		}
> >  	}
> > +#endif
> >  
> >  	return ai;
> >  }
> > +
> >  #endif	/* !HAVE_GETNAMEINFO */
> > 

