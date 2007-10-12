From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: 2.6.23-rc9-CITI_NFS4_ALL-1 connectathon suite testdir error
Date: Fri, 12 Oct 2007 16:12:13 +0200
Message-ID: <470F80BD.1090608@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: nfsv4 <nfsv4@linux-nfs.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgLFN-0000rd-3U
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 07:12:13 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IgLFR-0007SH-S9
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 07:12:18 -0700
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

Hi,

Running 2.6.23-rc9-CITI_NFS4_ALL-1 on two Intel X86_64 bi-ways machines as
client and server, get the following error with the runtest (-s) of the special
tests of the connectathon suite when running it with several other robustness
tests (fsx,iozone,fssbfss_stress) in the same time:

 Second check for lost reply on non-idempotent requests
 testing 50 idempotencies in directory "testdir"
 rmdir 1: Directory not empty
 special tests failed


 
------------------------------------------------------------- 
Bug: 
  http://bugzilla.linux-nfs.org/show_bug.cgi?id=150  
  
Cheers
  

-- 
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic 
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
