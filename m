From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [nfsv4] Linux pNFS status meeting 07/08
Date: Thu, 08 Jul 2010 23:09:17 -0400
Message-ID: <1278644957.3148.5.camel@heimdal.trondhjem.org>
References: <OF60B406A7.E52268C8-ON8825775A.000C6BD9-8825775A.000C8A46@us.ibm.com>
	 <20100708154802.GB19375@fieldses.org>
	 <op.vfi7ssfcunckof@usensfaibisl2e.eng.emc.com>
	 <20100708160637.GC19375@fieldses.org> <20100708174558.GE19375@fieldses.org>
	 <op.vfj1i5vyunckof@usensfaibisl2e.eng.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Marc Eshel <eshel@almaden.ibm.com>,
	nfsv4 list <nfsv4@ietf.org>
To: sfaibish <sfaibish@emc.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:41864 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753216Ab0GIDJZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jul 2010 23:09:25 -0400
In-Reply-To: <op.vfj1i5vyunckof-sXut7+96orlxdPWQvOaHCoI83tS8F2Zb0E9HWUfgJXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Sorin,

I'm getting a 'There are no rooms available for the dates you specified'
reply when I try to book for the dates 10/4 to 10/8 using the link you
provided on the web page below. Should I be using a special booking
code?

Cheers
  Trond

On Thu, 2010-07-08 at 22:36 -0400, sfaibish wrote:
> I posted a preliminary web page announcement for the Fall Bake-a-Thon in  
> Boston
> on CITI website:
> 
>   http://www.citi.umich.edu/projects/nfsv4/citi_bakeathon/15th_nfsv4_bakeathon.html
> 
> 
> On Thu, 08 Jul 2010 13:45:58 -0400, J. Bruce Fields <bfields@fieldses.org>  
> wrote:
> 
> > Also I'd like to hand off running and taking notes on this meeting to
> > someone else for a while.  (Benny, maybe?)  Or we can go back to making
> > the meeting more informal if that's preferred.
> >
> > --b.
> >
> > 1. upstream status/merge plans (trond, bfields)
> > 	- upstream at 2.6.35-rc4.
> > 	- server side: some bugfixes merged to callback code; allocation
> > 	  failures changed to return DELAY.
> > 	- discussion of error return on client callback-parsing error.
> > 	- trond: everything from before bakeathon is in nfs-2.6.36
> > 	  branch or upstream.  Also some file locking bugfixes
> > 	  (bugzilla.kernel.org #14501).  Also sending release_lockowner
> > 	  more often to keep server resources down.
> >
> > 2. State of pNFS tree (bhalevy)
> > 	- working on patches from boaz and andy for release branch.
> > 	  Anyone else have big pending patchsets?
> > 		- Jim is getting complex-volume block patches tested,
> > 		  will send them out soon.
> > 		- Fred has some pending stuff ("minor cleanup")
> > 	- next week would like to start cleaning up and squashing
> > 	  together patches.  Also will truncate some of the history.
> >
> > 3. Client
> > 	3.1. Client pNFS status
> > 		- Andy needs to look at state reclaim stuff?
> > 		- Andy still wondering what to do with the nfs inode
> > 		  layout pointer.  What's the lifetime of the thing that
> > 		  points to?
> > 	3.2. Client state management design documentation (trond)
> > 		- Also, on docs: Andy will check that wiki docs are
> > 		  uptodate.  And will do some more documentation of
> > 		  refcnts, as will Fred.
> >
> > 4. Server
> > 	4.1. Todo's for minimal 4.1 server (bfields)
> > 		- still working on callback changes.  Trond notes
> > 		  ongoing rpc code improvements may allow us to do much
> > 		  of this by keeping a single client and modifying its
> > 		  transports, in which case I may be able to replace my
> > 		  callbacks with single rpc tasks.
> > 		- also fixing 4.0/4.1 bug that prevents exclusive locks
> > 		  on upgraded open.
> > 	4.2. pnfs
> > 		- pnfs/gfs2
> > 			- I'll ask Eric for a report on gfs2 bakeathon
> > 			  testing.
> > 		- exofs
> > 			- I'll ask Brian about citi exofs setup status.
> >
> > 5. boston bakeathon
> > 	- October 4-8.
> > 	- Details are finalized, to be posted soon.
> > 	- If your company will be bringing large equipment, let Sorin
> > 	  know.
> > 	- If anyone would be interested in sponsoring a reception or
> > 	  other addition to the bakeathon, contact Sorin.  (Or if you
> > 	  know who at your company would handle such a thing, let Sorin
> > 	  know.)
> >
> > 6. new business
> > 	- Sorin asked Trond for summary of layout-commit discussion.
> > 	  Discussion ensued.
> >
> > 7. next meeting
> > 	- next week as usual.
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
> 
> 
> 



