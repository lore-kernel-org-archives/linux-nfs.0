Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16129 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754705Ab1JRWik convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 18:38:40 -0400
Subject: Re: [nfsv4] back channel flags, CREATE_SESSION, BIND_CONN_TO_SESSION
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: david.noveck@emc.com
Cc: matt@linuxbox.com, linux-nfs@vger.kernel.org,
        nfs-ganesha-devel@lists.sourceforge.net, nfsv4@ietf.org
Date: Tue, 18 Oct 2011 15:38:37 -0700
In-Reply-To: <5DEA8DB993B81040A21CF3CB332489F68611DBBF@MX31A.corp.emc.com>
References: <1988930626.161.1317955756425.JavaMail.root@thunderbeast.private.linuxbox.com>
	 <953639179.163.1317956101014.JavaMail.root@thunderbeast.private.linuxbox.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B91DDFD@SACMVEXC2-PRD.hq.netapp.com>
	 <5DEA8DB993B81040A21CF3CB332489F68611DBBF@MX31A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1318977517.3213.25.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-10-18 at 17:28 -0400, david.noveck@emc.com wrote: 
> > I have _always_ argued that callbacks should be the exception and not the rule, 
> 
> Sounds right.
> 
> > due to the fact that in pretty much all cases the server will have to send 
> > out a NFS4ERR_DELAY result to whatever RPC call it is that triggered a callback. 
> 
> I may disagree depending on what you mean by "petty much" always.
> 
> V4.1 does have callbacks that are specified so as to useful asynchronously, and
> if people take advantage of them, they won't have this NFS4ERR_DELAY problem.
> 
> Examples are CB_NOTIFY, CB_RECALL_ANY, CB_PUSH_DELEG.  Over time, future versions may
> expand this list and make callbacks less exceptional, although not the rule. 

I'm not sure why you included CB_RECALL_ANY in the above list. Did you
mean CB_RECALLABLE_OBJ_AVAIL?

The main consumer of callbacks in NFSv4.1 is expected by some to be
layouts, which do not really have an asynchronous mode to notify you
when a particular layout has been made available.
Ditto for the NFSv4.0 number 1 consumer: delegations. The new
CB_PUSH_DELEG operation notifies you that you may now request a
delegation, but it doesn't help when you are just trying to OPEN a file,
and the server has to recall a delegation from someone else.

So I still think that NFS4ERR_DELAY will still be needed in order to
slow things down, unless we're careful about getting into these
situations where recalls are needed.

> -----Original Message-----
> From: nfsv4-bounces@ietf.org [mailto:nfsv4-bounces@ietf.org] On Behalf Of Myklebust, Trond
> Sent: Thursday, October 06, 2011 11:39 PM
> To: Matt W. Benjamin
> Cc: linux-nfs; nfs-ganesha-devel; nfsv4
> Subject: Re: [nfsv4] back channel flags, CREATE_SESSION, BIND_CONN_TO_SESSION
> 
> > -----Original Message-----
> > From: Matt W. Benjamin [mailto:matt@linuxbox.com]
> > Sent: Thursday, October 06, 2011 10:55 PM
> > To: Myklebust, Trond
> > Cc: linux-nfs; nfs-ganesha-devel; nfsv4
> > Subject: Re: [nfsv4] back channel flags, CREATE_SESSION,
> > BIND_CONN_TO_SESSION
> > 
> > Hi Trond,
> > 
> > I appreciate your point of view.  I appreciate Rick's comments.  I hope some
> > other comments will trickle in.  Do I think you and Rick are saying the same
> > thing?  Not really.  Do I think you're making sense when you imply I want to
> > change the standard?  No, I don't follow that.  BIND_CONN_TO_SESSION is in
> > the published standard.  Can I show a dedicated back channel improves
> 
> I never accused you of trying to change the standard. What I said was that you need to convince me that there is a good reason to accept two implementations of the same feature in the client.
> 
> > performance?  Not at present.  That's a sensible question.  I think if the
> > protocol in general is doing what it is intended to do, it should be possible for
> > some workloads, at some point.  (If callbacks are, somehow generally
> > detrimental to performance, as you state, I think maybe we have some more
> > work to do.)  (I note only one more thing--I did raise this topic on list 12
> > months ago.  Only Bruce commented, at the time.)
> 
> Fair enough, but 12 months ago, rfc5661 was in last call status, and we were all trying to move on to final implementations.
> 
> I have _always_ argued that callbacks should be the exception and not the rule, due to the fact that in pretty much all cases the server will have to send out a NFS4ERR_DELAY result to whatever RPC call it is that triggered a callback. Nothing new there in NFSv4.1. I'll add that nor has anybody successfully argued that there is any change in NFSv4.1 compared to our existing NFSv4 implementations. NFSv4 delegation callbacks are (measurably) extremely slow, and so I'd expect the exact same behavior for NFSv4.1 layout recalls etc. Nothing has changed in NFSv4 callback technology to warrant an expectation of performance improvements.
> 
> IOW: Nobody (including you) has ever convinced me that we need to consider callbacks as a scalability issue. I'd require some pretty firm evidence before I could accept that as a fact. So far, all I have seen is more or less eloquent prose. No hard numbers.
> 
> Trond
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
> 
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

