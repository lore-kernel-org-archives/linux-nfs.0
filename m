Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aa.linuxbox.com ([134.215.213.37]:3926 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714Ab1ASDbO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jan 2011 22:31:14 -0500
Date: Tue, 18 Jan 2011 22:30:59 -0500 (EST)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: rees@umich.edu, androsadamson@gmail.com, linux-nfs@vger.kernel.org,
        bhalevy@panasas.com, Daniel Muntz <Daniel.Muntz@emc.com>
Message-ID: <630966826.173.1295407859285.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1295405796.2919.2.camel@heimdal.trondhjem.org>
Subject: Re: 4.1 no-pnfs mount option?
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The server has indicated that it supports pnfs.  Why is the client obligated to request it?

Matt

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2011-01-18 at 21:29 -0500, Daniel.Muntz@emc.com wrote: 
> > 
> > > -----Original Message-----
> > > From: Trond Myklebust [mailto:Trond.Myklebust@netapp.com] 
> > > Sent: Tuesday, January 18, 2011 5:45 PM
> > > To: Muntz, Daniel
> > > Cc: matt@linuxbox.com; rees@umich.edu; 
> > > androsadamson@gmail.com; linux-nfs@vger.kernel.org; 
> > > bhalevy@panasas.com
> > > Subject: RE: 4.1 no-pnfs mount option?
> > > 
> > > On Tue, 2011-01-18 at 19:53 -0500, Daniel.Muntz@emc.com wrote: 
> > > > 
> > > > > -----Original Message-----
> > > > > From: Trond Myklebust [mailto:Trond.Myklebust@netapp.com] 
> > > > > Sent: Tuesday, January 18, 2011 11:15 AM
> > > > > To: Matt W. Benjamin
> > > > > Cc: Muntz, Daniel; rees@umich.edu; androsadamson@gmail.com; 
> > > > > linux-nfs@vger.kernel.org; Benny Halevy
> > > > > Subject: Re: 4.1 no-pnfs mount option?
> > > > > 
> > > > > On Tue, 2011-01-18 at 13:46 -0500, Matt W. Benjamin wrote: 
> > > > > > Hi,
> > > > > > 
> > > > > > Isn't by mount a plausible way to select for pnfs 
> > > > > independent of debugging?  Is it assured that a client 
> > > > > administrator would never reasonably wish to do this?
> > > > > 
> > > > > "Why would an administrator never want to do this?" is 
> > > not a helpful
> > > > > question.
> > > > > 
> > > > > A more useful question is "what reason would you possibly have
> for
> > > > > overriding the server's request that you do pNFS when 
> > > your client has
> > > > > pNFS support?" What makes pNFS so special that we must allow
> > > > > administrators to do this on a per-mount basis?
> > > > 
> > > > By the same logic, why should a user be allowed to select 
> > > which version of NFS they use for mounting when the server 
> > > has a perfectly reasonable way of negotiating it?  Getting to 
> > > choose v2 vs. v3 vs. v4 seems like much less of a distinction 
> > > than choosing between pNFS and no pNFS.  Frankly, it never 
> > > even occurred to me that there wouldn't be a mount option to 
> > > make this choice.  Enabling/disabling the layout driver 
> > > doesn't fit the existing model of choosing mount behavior, 
> > > and is a big hammer--it's all or nothing.
> > > > 
> > > > Anyway, here's a use case: I'm working at an 
> > > HPC/gas+oil/satellite data site.  We have an awesome pNFS 
> > > server for our big data and I want to access my big data with 
> > > pNFS.  We have another server for homedirs, some big data, 
> > > and other stuff.  Some mounts are fine with pNFS, others are 
> > > abysmal.  So, I want to mount some directories with pNFS, and 
> > > some without pNFS, on the same client, independent of the 
> > > server configuration.
> > > 
> > > mount -t nfs -overs=4,minorversion=0 foo:/ /bar
> > > 
> > > Done... Any more questions?
> > 
> > Several, but I'll stick to one rhetorical.  Does NFSv4.1 have any
> features, other than pNFS, that are not in 4.0?
> 
> Why stop now, when you were batting 100? I told you what the criteria
> were for adding more mount options, and you start whining about not
> being able to conceive of a world without mount options.
> 
> The point is that NFSv4.1 was supposed to let the _server_ tell the
> client when to use pNFS. The reason why you let the _server_ do this,
> is
> because pNFS is about enabling _server_ scalability. It is not about
> faster clients...
> If you don't want the client to use pNFS, then fix the _server_
> settings...
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

-- 

Matt Benjamin

The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
