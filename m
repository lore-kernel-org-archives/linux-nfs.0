Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:56477 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752077AbZHZQ5x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Aug 2009 12:57:53 -0400
Subject: Re: [PATCH 4/4] nfs-utils: nfs-iostat.py autofs cleanup and option
 to sort by ops/s
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Lans Carstensen <Lans.Carstensen@dreamworks.com>,
        NFS list <linux-nfs@vger.kernel.org>
In-Reply-To: <08E0F2AC-2747-4F98-9686-CF665490B0F1@oracle.com>
References: <4A94C13E.6070403@dreamworks.com>
	 <10C29C3A-4BF4-4C45-AEEF-CE22F77911BD@oracle.com>
	 <4A954C4D.3060701@dreamworks.com>
	 <08E0F2AC-2747-4F98-9686-CF665490B0F1@oracle.com>
Content-Type: text/plain
Date: Wed, 26 Aug 2009 12:57:39 -0400
Message-Id: <1251305859.5226.9.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2009-08-26 at 11:47 -0400, Chuck Lever wrote:
> On Aug 26, 2009, at 10:53 AM, Lans Carstensen wrote:
> 
> > Greetings!  Comments inline.  Chuck Lever wrote:
> >> Hi Lans-
> >> I was thinking about this feature a little more.  Would it be  
> >> interesting to allow sorting by other metrics besides ops/s ?   
> >> That's another feature that the "top" command has that this new  
> >> option doesn't.
> >> I also don't like the bare integer options.  What if, at some  
> >> point, we want "-4" and "-6" for IPv6 support (not that we do, but  
> >> what if)?  Plus, having the bare integers doesn't give any clues  
> >> about what the number means.
> >> In which case I propose:
> >>  --sort=ops --list=<n>
> >> which provides more flexibility and helps make the options more  
> >> self-documenting.
> >
> > Again, thanks for looking this over.
> >
> > I had thought about the sorting a little bit, but decided that every  
> > case we cared about devolved to sorting by ops/s.  We'd use a tool  
> > like this in an operational group where they've lost control of a  
> > particular rogue workload in the mix of thousands of other  
> > workloads, and the operational group is trying to figure out what  
> > workload is generating a disproportionate amount of traffic (ops/ 
> > s).  If someone wanted to extend the implementation further where  
> > leaving "--sort" unadorned sorts by ops and using "-- 
> > sort=readdirplus" or somesuch, I'd be all for it - but it didn't  
> > seem worth the work for our use.  So I'd encourage that to be  
> > adopted as-is and if someone wants to put the extra effort into it  
> > I'm all for it.
> 
> Well, the problem is once we choose a command line option, it's hard  
> to change it later.  I think having two choices, like --sort=ops and -- 
> sort=def[ault] would be fine for now, and give us room to grow later.

There is precedent for having both an option "--sort" with no arguments,
and "--sort=". See for instance 'ls --color'/'ls --color=WHEN'.

We could therefore just add '--sort' for now, and then add a --sort=KEY
type option when someone decides they need it.

Cheers
  Trond

