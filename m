From: Norman Weathers <norman.r.weathers@conocophillips.com>
Subject: Some questions regarding NFS over TCP
Date: Tue, 27 Jul 2004 10:10:51 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407271010.51405.norman.r.weathers@conocophillips.com>
Reply-To: norman.r.weathers@conocophillips.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpTbT-0004Sv-EM
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 08:10:55 -0700
Received: from mailman2.ppco.com ([138.32.33.140])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BpTbT-0000Mj-0G
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 08:10:55 -0700
Received: from bvlextrd01.conoco.net (trend1.ppco.com [138.32.33.139])
	by mailman2.ppco.com (8.12.8/8.12.8) with ESMTP id i6RFAr8S026031
	for <nfs@lists.sourceforge.net>; Tue, 27 Jul 2004 10:10:53 -0500
Received: from bvlexbh1.conoco.net (bvlexbh1.conoco.net [138.32.45.41])
	by mail1.ppco.com (8.11.6+Sun/8.11.6) with ESMTP id i6RFAqo21488
	for <nfs@lists.sourceforge.net>; Tue, 27 Jul 2004 10:10:52 -0500 (CDT)
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


I have been on the list only for a short time now, and I have started some 
research, but have noticed that some of the documentation is slightly out of 
date, and had a couple of questions regarding NFS over TCP.  If there is some 
new info, please point me to it so that I don't take up the mailing list 
bandwidth.

Information about nodes:

Servers - Various P3 nodes running from 600MHz to 2.4 GHz.  600 MHz nodes are 
bonded 100 MB fast ethernet, other servers are all single GB connection.  All 
servers running RedHat 7.3 with 2.4.21 kernel and Trond NFS all patch.

Clients - Various P3, P4, and Athlons.  Some nodes have single 100 MB 
connections back to switches, others have GB back to switches.  All nodes 
runinng RedHat 2.4.26 with Trond NFS all patch.


All nodes running nfs-utils-1.0.1-1.


1)  We have a decent sized cluster utilizing NFS.  We currently use udp as the 
transport protocol.  One of the issues that we have is when running sync 
transfers are slow.  We recently moved to async in the /etc/exports on the 
servers.  This has helped some, but we still have some performance issues (I 
know that the server nodes can do more than 10 - 15 MB / sec NFS traffic).  
One of the things that I have seen alot of on the list lately is the use of 
TCP.  I have read the older documentation concerning NFS over TCP, and was 
wondering if the old disadvantages and advantages still hold true (ie, 
advantage:  GB servers to 100 MB clients better transfer rates, disadvantage:  
Server crash requires unmount of all cluster nodes that had the NFS server 
mounted).

2)  Should we see a large difference between sync and async NFS mounted 
servers?

Thanks in advance.  Like I said, if this has been discussed recently, please 
let me know, and I will look up the discussion thread.
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
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
