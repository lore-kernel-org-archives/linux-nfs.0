From: "Wendy Cheng" <s_wendy_cheng@hotmail.com>
Subject: question on sk_sem within svc_sendto
Date: Wed, 30 Apr 2003 11:00:30 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <BAY2-DAV28rRZ1UbDBR000085f3@hotmail.com>
References: <E199G1Z-0004eg-00@sc8-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bay2-dav28.bay2.hotmail.com ([65.54.246.85] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19At4V-0001rT-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Apr 2003 08:00:35 -0700
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

We're in the middle of fine-tuning our linux-based file 
server and currently examining the NFS zero-copy 
path with 2.5.x kernel. There is a semaphore (sk_sem) 
within svc_sendto() that serializes the outgoing data. 
Could someone shed some light and give us an 
explanation why this semaphore is needed - just for 
education purpose.Great thanks...

Wendy


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
