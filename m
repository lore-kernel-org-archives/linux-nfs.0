From: Michael <mikore.li@gmail.com>
Subject: newbie question
Date: Fri, 12 Aug 2005 12:12:30 +0800
Message-ID: <bc572709050811211255587aba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E3QuM-0005vV-Kb
	for nfs@lists.sourceforge.net; Thu, 11 Aug 2005 21:12:38 -0700
Received: from wproxy.gmail.com ([64.233.184.192])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E3QuL-0000pe-9L
	for nfs@lists.sourceforge.net; Thu, 11 Aug 2005 21:12:38 -0700
Received: by wproxy.gmail.com with SMTP id i3so493330wra
        for <nfs@lists.sourceforge.net>; Thu, 11 Aug 2005 21:12:30 -0700 (PDT)
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

Hi,=20

how can I understand following output from "tcpdump -p", at that time,
I am "dd" a file into a nfs mount point. Can anyone send me a
reference link to me? especially what's the meaning of "frag
55141:1292@2960", what's "DF"...

11:40:16.499209 192.168.0.148.3554257722 > 192.168.0.90.nfs: 1472
write [|nfs] (frag 55140:1480@0+)
11:40:16.499412 192.168.0.90.nfs > 192.168.0.148.3302599482: reply ok 136 (=
DF)
11:40:16.499450 192.168.0.148 > 192.168.0.90: udp (frag 55141:1292@2960)
11:40:16.499458 192.168.0.148 > 192.168.0.90: udp (frag 55141:1480@1480+)
11:40:16.499464 192.168.0.148.3571034938 > 192.168.0.90.nfs: 1472
write [|nfs] (frag 55141:1480@0+)
11:40:16.499777 192.168.0.90.nfs > 192.168.0.148.3319376698: reply ok 136 (=
DF)
11:40:16.499813 192.168.0.148 > 192.168.0.90: udp (frag 55142:1292@2960)
11:40:16.499821 192.168.0.148 > 192.168.0.90: udp (frag 55142:1480@1480+)

Thank,

Mike


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
