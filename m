From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfsd closes port 2049
Date: Thu, 18 Oct 2007 09:44:56 -0400
Message-ID: <EXNANE01FT3kMUVfNIJ00000760@exnane01.hq.netapp.com>
References: <47139C02.9020009@cineca.it>
	<18195.52347.544844.155538@notabene.brown>
	<4713E25D.6090302@users.sourceforge.net>
	<EXNANE014r3mbfJ8VrR0000070e@exnane01.hq.netapp.com>
	<18198.64875.25036.248314@notabene.brown>
	<EXNANE013MBhe3WYIgo0000075b@exnane01.hq.netapp.com>
	<471754BA.7000907@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: righiandr@users.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiVgM-00020t-NS
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 06:45:03 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IiVgQ-00021P-Vs
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 06:45:08 -0700
In-Reply-To: <471754BA.7000907@users.sourceforge.net>
References: <47139C02.9020009@cineca.it>
	<18195.52347.544844.155538@notabene.brown>
	<4713E25D.6090302@users.sourceforge.net>
	<EXNANE014r3mbfJ8VrR0000070e@exnane01.hq.netapp.com>
	<18198.64875.25036.248314@notabene.brown>
	<EXNANE013MBhe3WYIgo0000075b@exnane01.hq.netapp.com>
	<471754BA.7000907@users.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At 08:42 AM 10/18/2007, Andrea Righi wrote:
>The NFS server is working fine for the 2nd day using the fix (with kernel
>2.6.16.53-0.8-smp), but I'm not yet using the no_subtree_check option. I tried
>to stress the filesystem with multiple accesses from all the clients (256),
>alterning with periods of inactivity. This was a good "pattern" to 
>reproduce the
>problem and since it didn't happen anymore I'm considering the issue resolved.

Great! Do you have any "nfsd_acceptable" failures in the server's syslog?
If none, then the second issue didn't occur either, a good thing in itself. :-)

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
