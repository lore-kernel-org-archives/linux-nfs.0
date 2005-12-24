From: Andrew Diakin <adiakin@gmail.com>
Subject: Trouble with nfs via nfs
Date: Sat, 24 Dec 2005 17:25:30 +0300
Message-ID: <a97bcc260512240625w60a0b048l@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EqAL4-00026D-BX
	for nfs@lists.sourceforge.net; Sat, 24 Dec 2005 06:25:38 -0800
Received: from xproxy.gmail.com ([66.249.82.205])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EqAL3-0005gM-3p
	for nfs@lists.sourceforge.net; Sat, 24 Dec 2005 06:25:38 -0800
Received: by xproxy.gmail.com with SMTP id s6so627662wxc
        for <nfs@lists.sourceforge.net>; Sat, 24 Dec 2005 06:25:31 -0800 (PST)
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

Hello, I have a trouble in such thing - on server (server2) I mount
nfs or samba (the result will be same) resource from server1 in /path,
then write in /etc/exports
/path client1(rw) and restart nfs server. Next I mount on client1
mount server2:/path /mnt/path and under /mnt/path I don't see any
files while I cat perfectly see directories. Does anybody know why and
how to change this?
P.S. sorry for my english


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
