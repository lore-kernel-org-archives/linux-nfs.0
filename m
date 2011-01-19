Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47011 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752850Ab1ASOFS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jan 2011 09:05:18 -0500
Subject: RE: 4.1 no-pnfs mount option?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Daniel.Muntz@emc.com
Cc: matt@linuxbox.com, rees@umich.edu, androsadamson@gmail.com,
        linux-nfs@vger.kernel.org, bhalevy@panasas.com
In-Reply-To: <DE966DA98A4ABE438D726BDF1699CF61043985B65A@MX05A.corp.emc.com>
References: <DE966DA98A4ABE438D726BDF1699CF61043985B644@MX05A.corp.emc.com>
	 <1295405796.2919.2.camel@heimdal.trondhjem.org>
	 <DE966DA98A4ABE438D726BDF1699CF61043985B65A@MX05A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 19 Jan 2011 09:05:12 -0500
Message-ID: <1295445912.3444.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-19 at 00:54 -0500, Daniel.Muntz@emc.com wrote: 
> 
> > -----Original Message-----
> > From: Trond Myklebust [mailto:Trond.Myklebust@netapp.com] 
> > Sent: Tuesday, January 18, 2011 6:57 PM
> > To: Muntz, Daniel
> > Cc: matt@linuxbox.com; rees@umich.edu; 
> > androsadamson@gmail.com; linux-nfs@vger.kernel.org; 
> > bhalevy@panasas.com
> > Subject: RE: 4.1 no-pnfs mount option?
> > 
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
> > > > > > A more useful question is "what reason would you 
> > possibly have for
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
> > > Several, but I'll stick to one rhetorical.  Does NFSv4.1 
> > have any features, other than pNFS, that are not in 4.0?
> > 
> > Why stop now, when you were batting 100? I told you what the criteria
> > were for adding more mount options, and you start whining about not
> > being able to conceive of a world without mount options.
> > 
> > The point is that NFSv4.1 was supposed to let the _server_ tell the
> > client when to use pNFS. The reason why you let the _server_ 
> > do this, is
> > because pNFS is about enabling _server_ scalability. It is not about
> > faster clients...
> > If you don't want the client to use pNFS, then fix the _server_
> > settings...
> 
> I don't miss the kiss-up-kick-down model of software development...
> 
> The criteria was a use case, so I gave a use case.  I wouldn't rule out the "testing use case" either, as a mount option makes it possible to test mixed pnfs/non-pnfs 4.1 traffic without multiple servers.
> 
> The point is that pNFS, like everything else, is about the users.

The criteria was a use case that explains adequately why the client
needs to be able to override the server settings, not just random 'I
might want to do this' moments.

Rhetorical crap like 'it's about the users' isn't helping much either.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

