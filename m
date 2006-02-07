From: "Tradebit Service" <info@tradebit.com>
Subject: RE: Permission denied
Date: Tue, 7 Feb 2006 12:52:28 +0100
Message-ID: <011401c62bdc$f8f03890$0700a8c0@muelleimer>
References: <20060207123448.pqv165xvwosgk0g8@linux-smb.molly>
Reply-To: <info@tradebit.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F6ROi-0006u6-7H
	for nfs@lists.sourceforge.net; Tue, 07 Feb 2006 03:52:40 -0800
Received: from aibo.runbox.com ([193.71.199.94] helo=cujo.runbox.com)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1F6ROf-0006DW-LP
	for nfs@lists.sourceforge.net; Tue, 07 Feb 2006 03:52:40 -0800
Received: from [10.9.9.160] (helo=penny.runbox.com ident=Debian-exim)
	by greyhound.runbox.com with esmtp (Exim 4.34)
	id 1F6ROb-0001tB-Il
	for nfs@lists.sourceforge.net; Tue, 07 Feb 2006 12:52:33 +0100
Received: from [84.168.140.148] (helo=muelleimer)
	by penny.runbox.com with esmtpa  (uid:433466 )  (Exim 4.50)
	id 1F6ROb-0004Xg-6W
	for nfs@lists.sourceforge.net; Tue, 07 Feb 2006 12:52:33 +0100
To: <nfs@lists.sourceforge.net>
In-Reply-To: <20060207123448.pqv165xvwosgk0g8@linux-smb.molly>
Sender: nfs-admin@lists.sourceforge.net
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

 
> great, however, sometimes access to files and directories 
> stored on the server is denied for a certain user account. I 
> am not sure if it affects other users as well - only heard 
> complaints from that particular user so far. 

daniel,

just a wild guess: did you compare the user IDs in /etc/shadow
on both systems?

if you do a "ls -l" on the files on the client, who is the owner
and what are the access flags?

eg:

-rw-rw-r--    1 ftp      users       28076 Dec 19 18:59 somefile.tgz

that would mean, that only the user "ftp" and the members of the
group "users" could write (and delete) the file.

compare these flags and ownerships on both systems.

Cheers!

--
Ralf Schwoebel
http://www.tradebit.com/



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
