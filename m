From: Norman Weathers <norman.r.weathers@conocophillips.com>
Subject: Bad results with df command on 2.4 kernels
Date: Mon, 17 May 2004 13:00:48 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200405171300.48254.norman.r.weathers@conocophillips.com>
Reply-To: norman.r.weathers@conocophillips.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPmQ0-0002qr-Sx
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 11:00:52 -0700
Received: from mailman2.ppco.com ([138.32.33.140])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BPmQ0-0006B1-JP
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 11:00:52 -0700
Received: from bvlextrd01.conoco.net (trend1.ppco.com [138.32.33.139])
	by mailman2.ppco.com (8.12.8/8.12.8) with ESMTP id i4HI0o8S018693
	for <nfs@lists.sourceforge.net>; Mon, 17 May 2004 13:00:50 -0500
Received: from bvlexbh2.conoco.net ([138.32.45.42])
	by mail1.ppco.com (8.11.6+Sun/8.11.6) with ESMTP id i4HI0no07420
	for <nfs@lists.sourceforge.net>; Mon, 17 May 2004 13:00:49 -0500 (CDT)
To: nfs@lists.sourceforge.net
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


Hello, 

I am new to the list, and have tried to search it for this question, but if I 
have missed it, I would appreciate a pointer to the correct place.

We have several new large NFS servers with larger than 5 TB volumes being 
exported to a large number of Linux clients (can't give exact numbers).  We 
are using currently RedHat 7.3 with kernel.org 2.4.21 kernel and the Trond 
NFS_ALL patch for 2.4.21.  I saw where Olaf Kirch had a patch that would work 
against the 2.6 kernel so that df's and the like would start reporting 
correctly, and he also mentioned that he had a patch for 2.4.  Has anyone 
seen that patch?  I would be very interested in getting it and trying it.  If 
it has to be patched against a newer version of the kernel, that is okay.  We 
are not necessarily married to the 2.4.21 kernel, it was just one of the 
first ones that really was stable in our environment.

I know that RedHat does something to make its kernels work (RedHat 8 and 9 
both work with large NFS volumes), but I cannot find what patches they use to 
get the job done.

Thanks alot for any place you can point me to get this to work.
-- 

Norman Weathers
SIP Linux Cluster
TCE UNIX
ConocoPhillips
Houston, TX

Office:  LO2003
Phone:   ETN  639-2727
	 or (281) 293-2727


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
