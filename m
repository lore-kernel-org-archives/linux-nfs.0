From: Michael Gale <michael.gale@utilitran.com>
Subject: NFS as shared storage ?
Date: Mon, 13 Sep 2004 10:40:42 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040913104042.39926296@mgalepc.utilitran.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C6tpZ-0005uF-7q
	for nfs@lists.sourceforge.net; Mon, 13 Sep 2004 09:37:29 -0700
Received: from [64.42.239.181] (helo=mail.utilitran.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C6tpX-0005Cw-PB
	for nfs@lists.sourceforge.net; Mon, 13 Sep 2004 09:37:29 -0700
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

	I have some questions about NFS for a shared storage solution. 

We would like to setup a LVS box that would do FTP direct routing to two box, lets call them FTP1 and FTP2. So
both FTP1 and FTP2 would be active and LVS would do least connection load balancing between the two.

Now eventually we might buy a SAN ... (6months to when ever). So I would like to use a NFS box as my shared storage
solution. Now depending on how NFS could handle the load I was thinking of the following setup:

1. NFS server exports a directory "/home/ftpservers/" which has a completer slackware install as in "/home/ftpservers"
would be the root during the install. 
 - Now when either FTP1 or FTP2 server booted they would mount their root directory from the NFS server
/home/ftpservers.

	- This way all configuration and upgrades would completely affect box servers.

I have the following concerns:

1. Load ? With the whole root file system being on a shared storage solution what about log file updates maybe by a busy
FTP server ?

	Our servers are high end Intel dual 2.4Ghz Xeon processors with 15,000 RPM SCSI drives, each with 2B of RAM.


Option 2 was:

	Only have the /home directory required by both FTP's server being exported from the NFS server, to reduce load. 

Please let me know if any one has tried this or if they have a better solution with out buying the SAN.


-- 
Michael Gale
Network Administrator
Utilitran Corporation


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
