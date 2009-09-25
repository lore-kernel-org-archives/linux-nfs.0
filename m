From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: Ping: [pnfs] [RFC 1/1] nfs4: optionally return status from
	state_manager
Date: Fri, 25 Sep 2009 10:10:15 -0400
Message-ID: <20090925141015.GA26587@fieldses.org>
References: <4A9EDDE6.1090308@panasas.com> <1251990924-3904-1-git-send-email-bhalevy@panasas.com> <4ABC477E.4060709@panasas.com> <1253885382.31072.14.camel@heimdal.trondhjem.org> <4ABCCB4D.4020603@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54185 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752404AbZIYOKG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2009 10:10:06 -0400
In-Reply-To: <4ABCCB4D.4020603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 25, 2009 at 04:53:17PM +0300, Benny Halevy wrote:
> On 2009-09-25 16:29, Trond Myklebust wrote:
> > On Fri, 2009-09-25 at 07:30 +0300, Benny Halevy wrote:
> >> Trond,
> >>
> >> Is the patch below acceptable?
> >>
> >> Benny
> > 
> > I'm still not entirely happy with the idea that the state manager can
> > get into situations where it needs outside help, and you haven't really
> > explained to me the root cause of the scenario.
> > You said something about
> > 
> > nfs4_create_server()
> > nfs4_init_session()
> > nfs4_recover_expired_lease()
> >         nfs4_schedule_state_recovery()
> >                 # and the failure happens within the state engine
> >                 nfs4_proc_create_session()
> >                 nfs4_proc_get_lease_time() return -2
> > 
> > Where does that ENOENT come from?
> > 
> > You said something about it being an error in OP_PUTROOTFH, but as far
> > as I can see, the only permitted errors for putrootfh are either session
> > related errors (which should be handled by the state machine),
> > NFS4ERR_DELAY (which should be handled by the state machine) and
> > NFS4ERR_WRONGSEC. So which error is generating your ENOENT?
> > 
> 
> That scenario is caused when the server's /etc/exports
> is badly configured, where the export entry for nfsv4
> (fsid=0) exports a non-existing path.
> 
> I agree that the server should not return ENOENT
> for PUTROOTFH as it contradicts the spec.
> NFS4ERR_SERVERFAULT seems more appropriate.
> 
> The main reason for getting the failure from
> the state engine in nfsv4.1 is that we need to
> create a session before nfs4_path_walk in nfs4_create_server
> and we do that using the state manager.
> In the nfsv4.0 case we create no state at this point.

So is there any actual client-side bug here?

--b.
