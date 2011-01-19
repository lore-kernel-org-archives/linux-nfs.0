Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48697 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752847Ab1ASD6H convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jan 2011 22:58:07 -0500
Subject: Re: 4.1 no-pnfs mount option?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: rees@umich.edu, androsadamson@gmail.com, linux-nfs@vger.kernel.org,
        bhalevy@panasas.com, Daniel Muntz <Daniel.Muntz@emc.com>
In-Reply-To: <630966826.173.1295407859285.JavaMail.root@thunderbeast.private.linuxbox.com>
References: <630966826.173.1295407859285.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 18 Jan 2011 22:57:27 -0500
Message-ID: <1295409447.2801.12.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-01-18 at 22:30 -0500, Matt W. Benjamin wrote: 
> The server has indicated that it supports pnfs.  Why is the client obligated to request it?

It is not required by the protocol, but the client had better have a
damned good reason for not doing so. As stated several times previously,
pNFS is all about increasing _server_ scalability. If the server doesn't
need to scale out, why would it tell us to use pNFS for those files in
the first place?

Trond


> ----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> 
> > On Tue, 2011-01-18 at 21:29 -0500, Daniel.Muntz@emc.com wrote: 
> > > 
> > > > -----Original Message-----
> > > > From: Trond Myklebust [mailto:Trond.Myklebust@netapp.com] 
> > > > Sent: Tuesday, January 18, 2011 5:45 PM
> > > > To: Muntz, Daniel
> > > > Cc: matt@linuxbox.com; rees@umich.edu; 
> > > > androsadamson@gmail.com; linux-nfs@vger.kernel.org; 
> > > > bhalevy@panasas.com
> > > > Subject: RE: 4.1 no-pnfs mount option?
> > > > 
> > > > On Tue, 2011-01-18 at 19:53 -0500, Daniel.Muntz@emc.com wrote: 
> > > > > 
> > > > > > -----Original Message-----
> > > > > > From: Trond Myklebust [mailto:Trond.Myklebust@netapp.com] 
> > > > > > Sent: Tuesday, January 18, 2011 11:15 AM
> > > > > > To: Matt W. Benjamin
> > > > > > Cc: Muntz, Daniel; rees@umich.edu; androsadamson@gmail.com; 
> > > > > > linux-nfs@vger.kernel.org; Benny Halevy
> > > > > > Subject: Re: 4.1 no-pnfs mount option?
> > > > > > 
> > > > > > On Tue, 2011-01-18 at 13:46 -0500, Matt W. Benjamin wrote: 
> > > > > > > Hi,
> > > > > > > 
> > > > > > > Isn't by mount a plausible way to select for pnfs 
> > > > > > independent of debugging?  Is it assured that a client 
> > > > > > administrator would never reasonably wish to do this?
> > > > > > 
> > > > > > "Why would an administrator never want to do this?" is 
> > > > not a helpful
> > > > > > question.
> > > > > > 
> > > > > > A more useful question is "what reason would you possibly have
> > for
> > > > > > overriding the server's request that you do pNFS when 
> > > > your client has
> > > > > > pNFS support?" What makes pNFS so special that we must allow
> > > > > > administrators to do this on a per-mount basis?
> > > > > 
> > > > > By the same logic, why should a user be allowed to select 
> > > > which version of NFS they use for mounting when the server 
> > > > has a perfectly reasonable way of negotiating it?  Getting to 
> > > > choose v2 vs. v3 vs. v4 seems like much less of a distinction 
> > > > than choosing between pNFS and no pNFS.  Frankly, it never 
> > > > even occurred to me that there wouldn't be a mount option to 
> > > > make this choice.  Enabling/disabling the layout driver 
> > > > doesn't fit the existing model of choosing mount behavior, 
> > > > and is a big hammer--it's all or nothing.
> > > > > 
> > > > > Anyway, here's a use case: I'm working at an 
> > > > HPC/gas+oil/satellite data site.  We have an awesome pNFS 
> > > > server for our big data and I want to access my big data with 
> > > > pNFS.  We have another server for homedirs, some big data, 
> > > > and other stuff.  Some mounts are fine with pNFS, others are 
> > > > abysmal.  So, I want to mount some directories with pNFS, and 
> > > > some without pNFS, on the same client, independent of the 
> > > > server configuration.
> > > > 
> > > > mount -t nfs -overs=4,minorversion=0 foo:/ /bar
> > > > 
> > > > Done... Any more questions?
> > > 
> > > Several, but I'll stick to one rhetorical.  Does NFSv4.1 have any
> > features, other than pNFS, that are not in 4.0?
> > 
> > Why stop now, when you were batting 100? I told you what the criteria
> > were for adding more mount options, and you start whining about not
> > being able to conceive of a world without mount options.
> > 
> > The point is that NFSv4.1 was supposed to let the _server_ tell the
> > client when to use pNFS. The reason why you let the _server_ do this,
> > is
> > because pNFS is about enabling _server_ scalability. It is not about
> > faster clients...
> > If you don't want the client to use pNFS, then fix the _server_
> > settings...
> > 
> > -- 
> > Trond Myklebust
> > Linux NFS client maintainer
> > 
> > NetApp
> > Trond.Myklebust@netapp.com
> > www.netapp.com
> 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

