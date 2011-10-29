Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout1.mh.bbc.co.uk ([132.185.144.153]:51076 "EHLO
	mailout1.mh.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370Ab1J2VIU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2011 17:08:20 -0400
Date: Sat, 29 Oct 2011 21:07:41 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>, Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: NFS4ERR_STALE_CLIENTID loop
Message-ID: <20111029210741.GF2011@rd.bbc.co.uk>
References: <20111027221742.GI32587@rd.bbc.co.uk>
 <20111029002500.GA2011@rd.bbc.co.uk>
 <1319909376.2760.11.camel@lade.trondhjem.org>
 <20111029181509.GE12122@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7474@SACMVEXC2-PRD.hq.netapp.com>
 <20111029184759.GG12122@fieldses.org>
 <4B27362C-FBC1-4F64-B611-85D5FF6C5359@oracle.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7479@SACMVEXC2-PRD.hq.netapp.com>
 <20111029195249.GE2011@rd.bbc.co.uk>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7481@SACMVEXC2-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7481@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Myklebust, Trond (Trond.Myklebust@netapp.com) wrote:
> BAD_STATEID is a different matter, and is one that we should have
> resolved in the NFS client in the upstream kernel. At least on newer
> clients, we should be trying to reopen the file and re-establish all
> locks when we get a BAD_STATEID. Can you please remind us which kernel
> you are using?

Ah, i see.  This was all on 3.0.0 and 3.0.4 (a quick check didn't reveal
any relevant changes between the two).

Are there any stable patches that can be applied to 3.0.y?

> That said... Even on new clients, the recovery attempt may fail due to
> the STALE_CLIENTID bug. That will still hit us when we call OPEN in
> order to get a new stateid.

The interval between retries on that was ~1-1.5ms, could this be made
slower? -- same questions as before really.

Regards,

..david
