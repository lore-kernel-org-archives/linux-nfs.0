From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [NFS] NFS Digest, Vol 18, Issue 70 (NFS performance problems)
Date: Mon, 03 Dec 2007 16:13:02 -0500
Message-ID: <4754715E.9050400@redhat.com>
References: <mailman.194659.1195581701.26582.nfs@lists.sourceforge.net>
	<BAY104-W43766F661E50E7FFCDA8EBA7F0@phx.gbl>
	<47434ED7.4010100@redhat.com> <47435049.1010800@redhat.com>
	<47445727.5090705@oracle.com> <474A3D6B.2060208@redhat.com>
	<20071126050230.GD21120@fieldses.org>
	<18254.19187.470275.538680@notabene.brown>
	<1196314230.7950.42.camel@heimdal.trondhjem.org>
	<475039E4.5070903@redhat.com> <20071203203139.GF28201@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: chuck.lever@oracle.com, nfs@lists.sourceforge.net,
	NeilBrown <neilb-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:41276 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033AbXLCVOH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Dec 2007 16:14:07 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1IzIc9-0007Rc-2r
	for linux-nfs@vger.kernel.org; Tue, 04 Dec 2007 08:14:05 +1100
In-Reply-To: <20071203203139.GF28201@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Nov 30, 2007 at 11:27:16AM -0500, Wendy Cheng wrote:
>   
>> Well, a dumb question from me (borrowing Bruce's line :) ) ... even with 
>> "sync" in place, when server rebooted, the RPC reply cache is gone. How 
>> does linux server handle re-transmitted non-idempotent requests ?
>>     
>
> Badly!
>
> Somebody should figure out whether it would be possible for us to
> implement persistent sessions in v4.1:
>
> 	http://www.nfsv4-editor.org/draft-17/draft-ietf-nfsv4-minorversion1-17.html#Persistence
>
> It looks hard!
>   
Or use cluster (a backup server is quite affordable nowadays) ? Was 
about to kick off a new discussion about this ...

I did a prototype about 4 years ago on 2.4 kernel where the RPC reply 
cache (slightly modified to include raw NFS request packets) was 
mirrored by backup server (in memory). The reply was delayed to go back 
to client until the mirrored reply cache entry was acknowledged by the 
backup server. Upon crash, the backup server piggybacked its logic on 
ext3's journal recovery code. For reply cache entries not replayed or 
not recognized by jbd, nfsd resent the NFS raw requests down to 
filesystem just like any new arrived requested. The prototype code was 
able to gain at least 70% of the async mode performance without losing 
the data.

One of other issues with our current linux-based NFS cluster failover is 
also right in this arena - that is, upon failover, the non-idempotent 
could introduce stale filehandle errors that have been causing headaches 
with some of the applications. So mirroring RPC reply cache (to another 
machine) seems to be attractive.

Any comment ? Mind I write this up and send out for discussion ?

-- Wendy

-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

