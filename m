From: Yusuf Goolamabbas <yusufg@outblaze.com>
Subject: Re: df hangs on down nfs server mounted with hard,intr, can't kill
Date: Mon, 15 Mar 2004 13:21:06 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040315052106.GB17106@outblaze.com>
References: <482A3FA0050D21419C269D13989C61130435DD25@lavender-fe.eng.netapp.com> <20040310080910.GA21031@suse.de> <1078946326.1940.35.camel@nidelv.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B2kXK-0006ND-VR
	for nfs@lists.sourceforge.net; Sun, 14 Mar 2004 21:21:14 -0800
Received: from corpmail.outblaze.com ([203.86.166.82])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B2kXK-0001QN-1y
	for nfs@lists.sourceforge.net; Sun, 14 Mar 2004 21:21:14 -0800
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by corpmail.outblaze.com (Postfix) with ESMTP id A687037AEB
	for <nfs@lists.sourceforge.net>; Mon, 15 Mar 2004 05:21:08 +0000 (GMT)
Received: from yusufg.portal2.com (210-177-227-130.outblaze.com [210.177.227.130])
	by corpmail.outblaze.com (Postfix) with SMTP id D3ACE16DD95
	for <nfs@lists.sourceforge.net>; Mon, 15 Mar 2004 05:21:07 +0000 (GMT)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1078946326.1940.35.camel@nidelv.trondhjem.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> I've got your patch queued in the latest NFS4_ALL, and I believe I
> already pushed it to Andrew (so it should already be in the latest
> 2.6.3-mm). I'm aiming to push it into 2.6.5-preX as soon as Linus
> releases the final version of 2.6.4...
> 
> FYI: you can for the moment assume that *all* patches that are in the
> http://www.fys.uio.no/~trondmy/src/Linux-2.6.x subdirectories are being
> queued for inclusion in Linus' kernel. Only if a patch shows serious
> problems under testing will it be dropped.
> 

Trond, Looking at the latest bk/web it seems some of your NFS4_ALL
patches got in to mainline whilst 2.6.4-mm2 has some patches which akpm
calls

- Some significant NFS client enhancements: reads smaller than PAGE_SIZE
  are no longer synchronous, support for smaller-than-PAGE_SIZE reads,
  etc.

http://marc.theaimsgroup.com/?l=linux-kernel&m=107931425909684&w=2

Are these going to mature in -mm for a while or are they going to be
2.6.5 also ?

Also, what's the status with the nfszerostats patch from Steve Dickson
of Redhat

http://people.redhat.com/steved/NFS/nfszerostats/

Regards, Yusuf


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
