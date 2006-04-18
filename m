From: "LLLActive@GMX.Net" <LLLActive@GMX.Net>
Subject: can't umount nfs4 share
Date: Tue, 18 Apr 2006 17:23:12 +0200
Message-ID: <1145373792.25073.39.camel@L10-WS-AWS1.AWS>
Reply-To: LLLActive@GMX.Net
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FVs33-0008Pp-8q
	for nfs@lists.sourceforge.net; Tue, 18 Apr 2006 08:23:25 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FVs2y-0008Cj-Bu
	for nfs@lists.sourceforge.net; Tue, 18 Apr 2006 08:23:25 -0700
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

Hi,

I have a problem that on a production system I can not umount a nfs4
share. The NFS4 Server is not available anymore. When I try
umount /nfs4share the response is:

# umount: /nfs4share: device is busy

there is nothing accessing the share. 

with a ls -l /nfs4share the response is:

# /bin/ls: /nfs4share: Stale NFS file handle

with umount -f the response is:

# umount2: Device or resource busy
# umount: /nfs4share: device is busy
# umount2: Device or resource busy
# umount: /nfs4share: device is busy

When I look with 'mc' (midnight commander), there is a file or directory
called ~nfs4share with 0 size and dated Jan 1 1970. It can't be deleted.

How do I get rid of it or get the share unmounted without shutting down
the system?

Strangely, when the NFS Server returns, I can remount it with 
mount -t nfs4 192.168.1.2:/ /nfs4share/ //
-orsize=32768,wsize=32768,timeo=14,intr

and write to it again, but not unmount it.


:-)
Al



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
