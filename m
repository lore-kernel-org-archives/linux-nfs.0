From: Angie Weller <wellera@iastate.edu>
Subject: rpcinfo -p
Date: Fri, 13 Jun 2003 10:27:14 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <14271013510351631@webmail.iastate.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailhub-4.iastate.edu ([129.186.140.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19QqSX-0001sc-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 08:27:21 -0700
Received: from mailout-2.iastate.edu (mailout-2.iastate.edu [129.186.140.2])
	by mailhub-4.iastate.edu (8.9.3p2/8.9.3) with SMTP id KAA02494
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 10:27:14 -0500
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello-I'm trying to setup an NFS server on Linux distribution 9.0 with kernel 
2.4.20-8.  I have read many documents, etc about NFS, but I'm stuck at a 
certain spot.  My dilemma: when I follow your HOWTO, I get to step 
3.3.2  "starting the portmapper" type "ps aux | grep portmap" and this is my 
output.

rpc 1766 0.0 0.0 1552 564? S Jun10 0:00 [portmap]
username 5918 0.0 0.0 3572 640pts/2 S  09:40 0:00 portmap

Also--the next step will not work...when I type rpcinfo -p I get rpcinfo: 
command not found.  Is there a package that I missed?  I did get the latest 
utilities download, but when I installed--I already had them with the new 
kernel.  So I know it is not that problem.

Please help!
Angie Weller





-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
