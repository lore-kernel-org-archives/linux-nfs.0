From: "José" Vicente "Núñez" Zuleta <josevnz@yahoo.com>
Subject: Strange messages on /var/log/messages: kernel: fh_verify: lnxsrv0004/repository permission failure, acc=42, error=13
Date: Tue, 11 Jun 2002 21:29:58 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020612042958.56140.qmail@web10007.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web10007.mail.yahoo.com ([216.136.130.43])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Hzle-0002V5-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Jun 2002 21:29:58 -0700
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Greetings,

Looking into the /var/log/messages i found the
following error message:

Jun 10 10:01:11 lnxsrv0003 kernel: fh_verify:
linux0054/repository permission failure, acc=42,
error=13
Jun 10 10:01:12 lnxsrv0003 kernel: fh_verify:
linux0050/repository permission failure, acc=42,
error=13
Jun 10 10:01:12 lnxsrv0003 kernel: fh_verify:
linux0048/repository permission failure, acc=42,
error=13
Jun 10 10:01:12 lnxsrv0003 kernel: fh_verify:
linux0024/repository permission failure, acc=42,
error=13
Jun 10 10:01:13 lnxsrv0003 kernel: fh_verify:
linux0049/repository permission failure, acc=42,
error=13
Jun 10 10:01:13 lnxsrv0003 kernel: fh_verify:
linux0047/repository permission failure, acc=42,
error=13
Jun 10 10:01:14 lnxsrv0003 kernel: fh_verify:
linux0056/repository permission failure, acc=42,
error=13
Jun 10 10:01:15 lnxsrv0003 kernel: fh_verify:
linux0057/repository permission failure, acc=42,
error=13
Jun 10 10:04:00 lnxsrv0003 kernel: fh_verify:
lnxsrv0004/repository permission failure, acc=42,
error=13
Jun 10 10:04:00 lnxsrv0003 last message repeated 5
times

Any ideas? Are this messages harmfull?

JV.

=====
José Vicente Nuñez Zuleta (josevnz@yahoo.com)
Newbreak System Administrator (http://www.newbreak.com)
Office Phone:   203-355-1511, 203-355-1510
Fax:            203-355-1512
Cellular Phone: 203-570-7078

__________________________________________________
Do You Yahoo!?
Yahoo! - Official partner of 2002 FIFA World Cup
http://fifaworldcup.yahoo.com

_______________________________________________________________

Multimillion Dollar Computer Inventory
Live Webcast Auctions Thru Aug. 2002 - http://www.cowanalexander.com/calendar



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
