From: Chris Richardson <Chris.Richardson@icr.ac.uk>
Subject: Mount request ... gave 42
Date: Tue, 19 Sep 2006 14:26:36 +0100
Message-ID: <F57567C2-67B1-444A-A85D-6B28CAF4023F@icr.ac.uk>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GPfg1-0003Gj-9y
	for nfs@lists.sourceforge.net; Tue, 19 Sep 2006 06:30:18 -0700
Received: from mail56.messagelabs.com ([193.109.254.67])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GPffy-0005RO-Ji
	for nfs@lists.sourceforge.net; Tue, 19 Sep 2006 06:30:18 -0700
Received: from groupwise.icr.ac.uk (gw2.icr.ac.uk [193.63.217.83])
	by thames.icr.ac.uk (Postfix) with ESMTP id 427DEEB964
	for <nfs@lists.sourceforge.net>; Tue, 19 Sep 2006 14:26:54 +0100 (BST)
To: nfs@lists.sourceforge.net
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

Hello all,

I've been battling a mysterious intermittent NFS problem all day.   
Some clients can't mount exported directories, and what I get in /var/ 
log/messages is the following (I'm using -d all when I run rpc.mountd).

Sep 19 13:45:28 anu rpc.mountd: MNT3(/export/home/csbguest) called
Sep 19 13:45:28 anu rpc.mountd: mount request from 172.17.12.1:943  
for /export/home/csbguest (/export/home/csbguest) gave 42

The error is usually repeated 3 further times.

System details:

   SuSE Linux Enterprise Server 9 (dual opteron)
   Linux 2.6.8-24.14-smp
   nfs-utils-1.0.6-113 (yes, I know, I'm three years out of date)

We're a mixed client environment (IRIX 6.5, SLES, Mac OS X 10.4.7),  
but so far only the OS X clients have been giving problems.

I had a quick look at the code for nfs-utils, and from my probably  
incomplete understanding of it the error is being spat out of  
auth.c.  There's a switch that considers all the possible values of  
an enum auth_error, and the 42 is dropping out of the default case in  
that switch.  How 42 gets there, I don't know.  When I first saw 42 I  
suspected that someone had been reading too much Douglas Adams.

I can't think of any recent changes that could have precipitated this  
sudden problem.  Any advice (including the obvious advice to update  
to 1.0.10) will be gratefully received.

Regards,

Chris
--
Dr Chris Richardson - sysadmin, Structural Biology Section, icr.ac.uk


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
