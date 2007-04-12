From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: Missing handling for
	NFS4ERR_OLD_STATEID	in	nfs4_handle_exception?
Date: Thu, 12 Apr 2007 10:11:02 -0700
Message-ID: <1176397862.3531.20.camel@dyn9047022153>
References: <1175616589.3531.8.camel@dyn9047022153>
	<461E1F2C.7000605@poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@poochiereds.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc2mf-0007BO-IP
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 10:08:35 -0700
Received: from e6.ny.us.ibm.com ([32.97.182.146])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hc2mg-0003Is-Lc
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 10:08:36 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3CH9AKa026908
	for <nfs@lists.sourceforge.net>; Thu, 12 Apr 2007 13:09:10 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l3CH8Rmm292600
	for <nfs@lists.sourceforge.net>; Thu, 12 Apr 2007 13:08:27 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l3CH8Rte013193
	for <nfs@lists.sourceforge.net>; Thu, 12 Apr 2007 13:08:27 -0400
In-Reply-To: <461E1F2C.7000605@poochiereds.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-04-12 at 07:59 -0400, Jeff Layton wrote:
> This looks pretty much correct to me as-is. If we set ret=0 on 
> -NFS4ERR_OLD_STATEID, then the caller won't get back an error code. This 
> makes an assumption that every caller of nfs4_handle_exception is 
> looping based on exception->retry. I'm not sure if that's a safe 
> assumption. A better idea *might* be to fix up nfs4_map_errors not to 
> throw the warning for some errors < -1000, but still return an error.

nfs4_map_errors should warn about errors, because it's a last defense
against leaking NFS4 error numbers to the rest of the kernel (that
doesn't recognize them). So before calling nfs4_map_errors(), the error
code should already be converted to an errno code.

It looked to me like every caller of nfs4_handle_exception() does loop
on exception-retry(), and in that case, does not look at the error
returned.

> This sounds sort of like addressing the symptom and not the real 
> problem, however. The real question ought to be why you're getting 
> OLD_STATEID errors back from the server here. There can be legit 
> reasons, but these errors ought to be fairly rare. I generally only have 
> seen them when processes are signalled while RPC requests are in flight.

Sure, understanding why we are getting them is important, but since it
appears that handling might be missing, we may be seeing more of them
than expected.

> Also, it seems like when we hit -NFS4ERR_DELAY, we want to retry but 
> only if the delay didn't hit an error. It looks like it only returns 
> error if process was signalled while in nfs4_delay, and then we want to 
> pass an -ERESTARTSYS back up the call chain (and not retry). So I think 
> that's also correct as-is.

I agree that's correct.

Frank



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
