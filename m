Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout0.thls.bbc.co.uk ([132.185.240.35]:35557 "EHLO
	mailout0.thls.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932323Ab1J2S3a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2011 14:29:30 -0400
Date: Sat, 29 Oct 2011 18:29:06 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, David Flynn <davidf@rd.bbc.co.uk>,
        linux-nfs@vger.kernel.org
Subject: Re: NFS4ERR_STALE_CLIENTID loop
Message-ID: <20111029182906.GD2011@rd.bbc.co.uk>
References: <1319463165.2734.1.camel@lade.trondhjem.org>
 <20111024145027.GF32587@rd.bbc.co.uk>
 <1319470302.2734.4.camel@lade.trondhjem.org>
 <20111027221742.GI32587@rd.bbc.co.uk>
 <20111029002500.GA2011@rd.bbc.co.uk>
 <1319909376.2760.11.camel@lade.trondhjem.org>
 <20111029180227.GC2011@rd.bbc.co.uk>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7475@SACMVEXC2-PRD.hq.netapp.com>
 <3B165534-0846-4290-AB12-91E06FD8ED11@oracle.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7476@SACMVEXC2-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7476@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Myklebust, Trond (Trond.Myklebust@netapp.com) wrote:
> No. Not in this case: the state manager was doing RENEW, then exiting
> because it was told all is A_OK by the server.
> The open() system call would be the one that was looping.

Sometimes it worked, somtimes not.  From memory:
 - kill -9 worked in situations that suffered from NFS4ERR_STALE_CLIENTID
 - kill -9 failed in situations that suffered from BAD_STATEID

..david
