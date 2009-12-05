From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: RE: [PATCH 0/12] Fix session reset deadlocks Version 4
Date: Fri, 4 Dec 2009 23:05:49 -0800
Message-ID: <273FE88A07F5D445824060902F70034408A1A330@SACMVEXC1-PRD.hq.netapp.com>
References: <1259965498.2825.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	"Adamson, Andy" <William.Adamson@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22834 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752308AbZLEHGi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Dec 2009 02:06:38 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB576gPv001817
	for <linux-nfs@vger.kernel.org>; Fri, 4 Dec 2009 23:06:42 -0800 (PST)
In-Reply-To: <1259965498.2825.5.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm seeing a problem with the bits in the nfs-for-next branch when I run
v4.1.  If a bad session is received after a server reboot, the client
issues a flood of sequence requests.  The sequence RPCs contain the last
sequenceID from the previous session with the new sessionID.  This is
repeated over and over until you ctrl-C the triggering process.  The
server replies with sequence misordered, but the client issues the exact
same RPC over and over.

Also to note is that right after the session is destroyed, the client
will issue sequence requests with sessionID of 0 right before the create
session succeeds.

- ricardo


> -----Original Message-----
> From: Myklebust, Trond
> Sent: Friday, December 04, 2009 2:25 PM
> To: Adamson, Andy
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: [PATCH 0/12] Fix session reset deadlocks Version 4
> 
> On Fri, 2009-12-04 at 17:01 -0500, Trond Myklebust wrote:
> > Those look good to me. I had to fix them up a bit in order to have
them
> > apply on top of the nfs-for-next branch, but nothing major.
> 
> I figured I might as well push them out immediately. They compile, and
> they don't seem to have any adverse effects on the NFSv4 stuff.
> 
> You can find them as the nfs-for-next branch on
> git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git
> 
> Cheers
>   Trond
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
