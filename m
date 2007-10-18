From: Andrea Righi <righiandr@users.sourceforge.net>
Subject: Re: nfsd closes port 2049
Date: Thu, 18 Oct 2007 16:34:54 +0200 (MEST)
Message-ID: <47176F0E.2000007@users.sourceforge.net>
References: <47139C02.9020009@cineca.it>
	<18195.52347.544844.155538@notabene.brown>
	<4713E25D.6090302@users.sourceforge.net>
	<EXNANE014r3mbfJ8VrR0000070e@exnane01.hq.netapp.com>
	<18198.64875.25036.248314@notabene.brown>
	<EXNANE013MBhe3WYIgo0000075b@exnane01.hq.netapp.com>
	<471754BA.7000907@users.sourceforge.net>
	<EXNANE01FT3kMUVfNIJ00000760@exnane01.hq.netapp.com>
Reply-To: righiandr@users.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiWSw-0007YF-N5
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 07:35:14 -0700
Received: from as1.cineca.com ([130.186.84.251])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IiWSz-00052k-CW
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 07:35:20 -0700
In-Reply-To: <EXNANE01FT3kMUVfNIJ00000760@exnane01.hq.netapp.com>
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

Talpey, Thomas wrote:
> At 08:42 AM 10/18/2007, Andrea Righi wrote:
>> The NFS server is working fine for the 2nd day using the fix (with kernel
>> 2.6.16.53-0.8-smp), but I'm not yet using the no_subtree_check option. I tried
>> to stress the filesystem with multiple accesses from all the clients (256),
>> alterning with periods of inactivity. This was a good "pattern" to 
>> reproduce the
>> problem and since it didn't happen anymore I'm considering the issue resolved.
> 
> Great! Do you have any "nfsd_acceptable" failures in the server's syslog?
> If none, then the second issue didn't occur either, a good thing in itself. :-)
> 
> Tom.
> 

I rebooted the NFS server with the new kernel on Oct 17 10:45:24, and:

node0101:~ # (bzcat /var/log/messages-2007101[78].bz2; cat /var/log/messages) | grep nfsd_acceptable
Oct 16 23:04:41 node0101 kernel: nfsd_acceptable failed at ffff810155e88150
Oct 17 07:52:38 node0101 kernel: nfsd_acceptable failed at ffff81015da98970
Oct 17 10:22:33 node0101 kernel: nfsd_acceptable failed at ffff8100d8cffa40

So, any nfsd_acceptable failure in the logs.

-Andrea

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
