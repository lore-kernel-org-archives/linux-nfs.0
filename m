Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.alpinelinux.org ([74.117.189.114]:33276 "EHLO
	mail.alpinelinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755485AbaHHJik (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Aug 2014 05:38:40 -0400
Date: Fri, 8 Aug 2014 11:38:33 +0200
From: Natanael Copa <ncopa@alpinelinux.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 11/11] exportfs: only do glibc specific hackery on glibc
Message-ID: <20140808113833.48f192ab@ncopa-desktop.alpinelinux.org>
In-Reply-To: <53E36DC5.7020200@RedHat.com>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
	<1406719399-1735-12-git-send-email-ncopa@alpinelinux.org>
	<53E36DC5.7020200@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 07 Aug 2014 08:15:01 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 07/30/2014 07:23 AM, Natanael Copa wrote:
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
> You still have this typo here... and the only reason
> it compiled is HAVE_GETNAMEINFO is not defined 
> in your world....

I do have HAVE_GETNAMEINFO or I wouldn't have this issue in first place.

$ grep HAVE_GETNAMEINFO support/include/config.h
#define HAVE_GETNAMEINFO 1


> How well were these change tested against glibc? I'm 
> concern about eliminating chunks of need code with
> all these new  defines.... 

Argh! Sorry my bad. I fixed but must missed it in a redo.

I have not tested those in glibc at all.

When I look now, this is wrong anyway. It was supposed to fix a
segfault due to a just-in-case free() below:

        /*
         * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
         */
        if (ai != NULL) {
                free(ai->ai_canonname);         /* just in case */
                ai->ai_canonname = strdup(buf);
                if (ai->ai_canonname == NULL) {
                        freeaddrinfo(ai);
                        ai = NULL;
                }
        }

I but I think my patch does the ifdef in wrong place. When I grep for
'never fills' in the sources i find that there are 2 places where there
is an

  ai->ai_canonname = strdup(buf);

With the assumption that freeaddrinfo() will free ai->ai_canonname for
us. I think this is wrong.

The just in case free(ai->ai_canonname) causes segfault on uclibc (and
used to do so on musl too) and I am pretty sure the "ai->ai_canonname =
strdup(buf);" will cause memleak, atleast on musl libc.

I'd be happy if you applied the other 10 patches though.

Do you want me to resend the others 10 with a v3 prefix?

-nc



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

