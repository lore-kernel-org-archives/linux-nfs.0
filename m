From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Trouble with nfs via nfs
Date: Sat, 24 Dec 2005 16:46:23 +0100
Message-ID: <1135439183.8063.13.camel@lade.trondhjem.org>
References: <a97bcc260512240625w60a0b048l@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EqBbU-0006hp-CL
	for nfs@lists.sourceforge.net; Sat, 24 Dec 2005 07:46:40 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EqBbQ-0000Aw-WF
	for nfs@lists.sourceforge.net; Sat, 24 Dec 2005 07:46:40 -0800
To: Andrew Diakin <adiakin@gmail.com>
In-Reply-To: <a97bcc260512240625w60a0b048l@mail.gmail.com>
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

On Sat, 2005-12-24 at 17:25 +0300, Andrew Diakin wrote:
> Hello, I have a trouble in such thing - on server (server2) I mount
> nfs or samba (the result will be same) resource from server1 in /path,
> then write in /etc/exports
> /path client1(rw) and restart nfs server. Next I mount on client1
> mount server2:/path /mnt/path and under /mnt/path I don't see any
> files while I cat perfectly see directories. Does anybody know why and
> how to change this?
> P.S. sorry for my english

Reexporting NFS client partitions is not currently supported by the
server.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
