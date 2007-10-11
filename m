From: Erik Hensema <erik@hensema.net>
Subject: Locking broke after client reset
Date: Thu, 11 Oct 2007 15:50:20 +0200
Message-ID: <200710111550.22405.erik@hensema.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfyQr-0005Aa-Mc
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 06:50:33 -0700
Received: from scrat.hensema.net ([213.207.93.150])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfyQv-0000oV-I2
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 06:50:39 -0700
Received: from dexter.home.hensema.net (dexter.hensema.net [82.192.92.36])
	(authenticated bits=0)
	by scrat.hensema.net (8.13.6/8.13.6/SuSE Linux 0.8) with ESMTP id
	l9BDoS71022522
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <nfs@lists.sourceforge.net>; Thu, 11 Oct 2007 15:50:28 +0200
Received: from bender.home.hensema.net ([192.168.3.254])
	by dexter.home.hensema.net (8.13.6/8.13.6) with ESMTP id l9BDoQ1V023417
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Thu, 11 Oct 2007 15:50:26 +0200
Received: from bender.home.hensema.net (localhost [127.0.0.1])
	by bender.home.hensema.net (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id
	l9BDoNRG010910
	for <nfs@lists.sourceforge.net>; Thu, 11 Oct 2007 15:50:26 +0200
Received: from localhost (localhost [[UNIX: localhost]])
	by bender.home.hensema.net (8.13.8/8.13.8/Submit) id l9BDoMNT010906
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 15:50:22 +0200
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

Situation:

openSUSE 10.2 NFS server, 2.6.18 kernel as supplied by novell.
openSUSE 10.1 client, 2.6.16 kernel as supplied by novell.

After a crash of the client and a reboot, locking over nfs broke. 
Processes just wait indefinitely on a lock they'll never get.
Rebooting the client doesn't help.

Restarting the nfs server by removing all kernel modules and reloading 
doesn't help either. I'd like to avoid rebooting the machine if 
possible.

How can I reset the locks? It's no problem to unmount the share on all 
clients if necessary.

I'm using nfsv4. Possibly the NLM lock recovery fails because the name 
returned by 'uname -n' does not fully match the reverse dns of the 
machine. I'm not sure how to make uname -n return the internal dns 
name but still have daemons such as sendmail use the external name 
(the machine's got two interfaces, one on the internet, one internal 
to the nfs server).
Currently uname -n returns the short hostname of the machine, not a 
fully qualified one.

Any help would be appreciated.

Met vriendelijke groet,

Erik Hensema
-- 
Email: erik@hensema.net
Website: http://www.hensema.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
