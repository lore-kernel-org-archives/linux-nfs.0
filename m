Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18826 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752370Ab1J2VMF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2011 17:12:05 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: NFS4ERR_STALE_CLIENTID loop
Date: Sat, 29 Oct 2011 14:12:03 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7488@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20111029210741.GF2011@rd.bbc.co.uk>
References: <20111027221742.GI32587@rd.bbc.co.uk> <20111029002500.GA2011@rd.bbc.co.uk> <1319909376.2760.11.camel@lade.trondhjem.org> <20111029181509.GE12122@fieldses.org> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7474@SACMVEXC2-PRD.hq.netapp.com> <20111029184759.GG12122@fieldses.org> <4B27362C-FBC1-4F64-B611-85D5FF6C5359@oracle.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7479@SACMVEXC2-PRD.hq.netapp.com> <20111029195249.GE2011@rd.bbc.co.uk> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7481@SACMVEXC2-PRD.hq.netapp.com> <20111029210741.GF2011@rd.bbc.co.uk>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "David Flynn" <davidf@rd.bbc.co.uk>
Cc: "Chuck Lever" <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: David Flynn [mailto:davidf@rd.bbc.co.uk]
> Sent: Saturday, October 29, 2011 11:08 PM
> To: Myklebust, Trond
> Cc: David Flynn; Chuck Lever; J. Bruce Fields;
linux-nfs@vger.kernel.org
> Subject: Re: NFS4ERR_STALE_CLIENTID loop
> 
> * Myklebust, Trond (Trond.Myklebust@netapp.com) wrote:
> > BAD_STATEID is a different matter, and is one that we should have
> > resolved in the NFS client in the upstream kernel. At least on newer
> > clients, we should be trying to reopen the file and re-establish all
> > locks when we get a BAD_STATEID. Can you please remind us which
kernel
> > you are using?
> 
> Ah, i see.  This was all on 3.0.0 and 3.0.4 (a quick check didn't
reveal any
> relevant changes between the two).
> 
> Are there any stable patches that can be applied to 3.0.y?
> 
> > That said... Even on new clients, the recovery attempt may fail due
to
> > the STALE_CLIENTID bug. That will still hit us when we call OPEN in
> > order to get a new stateid.
> 
> The interval between retries on that was ~1-1.5ms, could this be made
> slower? -- same questions as before really.

Given that things such as reboot recovery are subject to a recovery
window (grace period), I'm, again, very reluctant to add an artificial
backoff as that may have consequences for behaviour in the bug-free
case.

If the server wants us to back off, it can say so itself by using the
NFS4ERR_DELAY error mechanism.

Cheers
  Trond

