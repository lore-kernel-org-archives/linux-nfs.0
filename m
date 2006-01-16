From: "Wally Winchester" <wally_winchester@fastmail.fm>
Subject: Stale nfs file handle - cwd without path - workaround?
Date: Mon, 16 Jan 2006 09:16:06 +0000
Message-ID: <1137402966.3299.251938119@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EyQTD-0000Ef-SR
	for nfs@lists.sourceforge.net; Mon, 16 Jan 2006 01:16:11 -0800
Received: from out4.smtp.messagingengine.com ([66.111.4.28])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EyQTC-00088e-HP
	for nfs@lists.sourceforge.net; Mon, 16 Jan 2006 01:16:11 -0800
Received: from frontend1.internal (mysql-sessions.internal [10.202.2.149])
	by frontend1.messagingengine.com (Postfix) with ESMTP id 49E82D2F6E9
	for <nfs@lists.sourceforge.net>; Mon, 16 Jan 2006 04:16:06 -0500 (EST)
To: nfs@lists.sourceforge.net
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

Hello,

I have an nfs setup with heartbeat failover that is working nicely. I
only have one problem, I hope someone can help.

When nfs1 dies, and nfs2 takes over, everything works - as long as the
clients are writing files using the full paths.
If the path is omitted, i.e. they are expecting a write to their cwd, a
"stale nfs file handle" warning is issued.

Is there a way around this?

e.g. this works
touch /nfs-mount/file
(failover)
touch /nfs-mount/file

e.g. this doesn't work
cd /nfs-mount/
touch file
(failover)
touch file
(stale nfs file handle)

Thanks
-- 
  Wally Winchester
  wally_winchester@fastmail.fm

-- 
http://www.fastmail.fm - Access all of your messages and folders
                          wherever you are



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
