Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:2298 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754997Ab3JXPKO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Oct 2013 11:10:14 -0400
Date: Thu, 24 Oct 2013 11:10:07 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>
Message-ID: <240479729.48.1382627407924.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1382627297.6430.0.camel@leira.trondhjem.org>
Subject: Re: XATTRs in NFS?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Sorry I was not clear.  I was not re-stating support for this banned feature.

I'm interested in implementation code I can use privately under GPLv2.

Thanks!

Matt

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-10-24 at 11:05 -0400, Matt W. Benjamin wrote:
> > Hi,
> > 
> > Presumably Linux client and server implementations would restrict
> use of "system."
> > Perhaps would be more to talk about, if xattrs were implemented
> experimentally.
> > 
> > I'm interested in knowing about patches that might be floating
> around for the Linux client, for NFSv4.x.  (I've seen NFSv3 work.)
> > 
> > Thanks,
> > 
> > Matt
> 
> We've already talked about this, Matt. The answer is still NO.
> 
> Trond
> 
> > ----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Oct 24, 2013, at 3:13 PM, Christoph Anton Mitterer
> > > <calestyo@scientia.net> wrote:
> > > 
> > > > On Thu, 2013-10-24 at 08:45 +0000, Myklebust, Trond wrote:
> > > >> labeled NFS (i.e. security labels for NFS) is already supported
> in
> > > Linux 3.10 and newer.
> > > > Sure, but that doesn't really help me.
> > > > 
> > > > 
> > > >> There are no plans to merge general purpose xattrs.
> > > > Why not? Is it a big deal?
> > > > 
> > > 
> > > Linux xattrs are a rabid mess.
> > > 
> > > The whole "system" namespace is something that cannot and should
> not
> > > ever be exposed on a network.
> > > The "trusted" and "user" namespaces just offer specialised
> storage.
> > > Why are they needed?
> > > 
> > > > 
> > > >> Please just use an application-specific database.
> > > > Well that won't work,... since that wouldn't be updated if e.g.
> > > > pathnames are changed by any program (cp, mv)
> > > 
> > > If the data needs to follow the file, then store it in the file.
> Why
> > > do you need the filesystem to manage that for you?
> > > 
> > > Cheers
> > >   Trond--
> > > To unsubscribe from this list: send the line "unsubscribe
> linux-nfs"
> > > in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at 
> http://vger.kernel.org/majordomo-info.html
> > 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
