From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: RPC retransmission of write requests containing bogus data
Date: Fri, 17 Oct 2008 09:51:01 -0400
Message-ID: <RTPCLUEXC1-PRDllNY3000001ad@RTPMVEXC1-PRD.hq.netapp.com>
References: <1224241273.9053.109.camel@zakaz.uk.xensource.com>
 <RTPCLUEXC1-PRDVjCRG000001ab@RTPMVEXC1-PRD.hq.netapp.com>
 <1224250599.7722.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <Ian.Campbell@citrix.com>, linux-nfs@vger.kernel.org,
	mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37615 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753855AbYJQNv5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 09:51:57 -0400
In-Reply-To: <1224250599.7722.17.camel@localhost>
References: <1224241273.9053.109.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
 <RTPCLUEXC1-PRDVjCRG000001ab-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <1224250599.7722.17.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 09:36 AM 10/17/2008, Trond Myklebust wrote:
>On Fri, 2008-10-17 at 09:32 -0400, Talpey, Thomas wrote:
>> The fix here is to break the connection before retrying, a long-standing
>> pet peeve of mine that NFSv3 historically does not do. 
>
>It's not a perfect fix, which is why we haven't done that for NFSv3.
>
>When you break the connection, there is the chance that a reply to a
>non-idempotent request may get lost, and that the server doesn't
>recognise the retransmission due to the above mentioned imperfections
>with the replay cache. In that case, the client may get a downright
>_wrong_ reply (for instance, it may see an EEXIST reply to a mkdir
>request that was actually successful).

Well, the NFSv4 client will suffer the same issue in the above case.
So, it's choose your poison. The antidote is to adopt NFSv4.1 asap. ;-) 

Sorry about the crossing replies btw. My own transmission was scheduled
before pulling email to look for other replies! Hmm...

Tom.

