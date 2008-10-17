From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: RPC retransmission of write requests containing bogus data
Date: Fri, 17 Oct 2008 09:36:39 -0400
Message-ID: <1224250599.7722.17.camel@localhost>
References: <1224241273.9053.109.camel@zakaz.uk.xensource.com>
	 <RTPCLUEXC1-PRDVjCRG000001ab@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <Ian.Campbell@citrix.com>, linux-nfs@vger.kernel.org,
	mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45578 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754414AbYJQNhj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 09:37:39 -0400
In-Reply-To: <RTPCLUEXC1-PRDVjCRG000001ab-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-10-17 at 09:32 -0400, Talpey, Thomas wrote:
> At 07:01 AM 10/17/2008, Ian Campbell wrote:
> >(please CC me, I am not currently subscribed to linux-nfs)
> >...
> >Presumably in the case of a decent NFS server the XID request cache
> >would prevent the bogus data actually reaching the disk but on a
> >non-decent server I suspect it might actually lead to corruption (AIUI
> >the request cache is not a hard requirement of the NFS protocol?).
> >Perhaps even a decent server might have timed out the entry in the cache
> >after such a delay?
> 
> Unfortunately no - because 1) your retransmissions are not, in fact,
> duplicates since the data has changed and 2) no NFSv3 reply cache
> works perfectly, especially under heavy load. The NFSv4.1 session
> addresses this, but that's not at issue here.
> 
> This is a really nasty race. The whole thing starts with the dropped
> TCP segment evidenced at #2 of your trace. Then, the retransmission
> appears to have been scheduled prior to the write reply making it back
> to the client through the TCP storm, so the retransmit is actually pending
> on the wire while the NFS write operation is completed.
> 
> The fix here is to break the connection before retrying, a long-standing
> pet peeve of mine that NFSv3 historically does not do. Setting the
> clnt->cl_discrtry bit in the RPC client struct is all that's required. The
> NFSv4 client does this by default, btw.
> 
> Tom.

It's not a perfect fix, which is why we haven't done that for NFSv3.

When you break the connection, there is the chance that a reply to a
non-idempotent request may get lost, and that the server doesn't
recognise the retransmission due to the above mentioned imperfections
with the replay cache. In that case, the client may get a downright
_wrong_ reply (for instance, it may see an EEXIST reply to a mkdir
request that was actually successful).

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
