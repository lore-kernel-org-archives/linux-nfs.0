From: James Pearson <james-p@moving-picture.com>
Subject: Re: Strange messages on /var/log/messages: kernel: fh_verify:
 lnxsrv0004/repository permission failure, acc=42, error=13
Date: Wed, 12 Jun 2002 10:02:12 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D070E14.DF563CED@moving-picture.com>
References: <20020612042958.56140.qmail@web10007.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17I41I-0003PP-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Jun 2002 02:02:24 -0700
To: =?iso-8859-1?Q?Jos=E9?= Vicente =?iso-8859-1?Q?N=FA=F1ez?= Zuleta
	<josevnz@yahoo.com>
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

See question 6 (and the answer) in the NFS FAQ at
http://nfs.sourceforge.net/ :

> 6. Q. I keep getting permission failure messages at my nfs server. What are they?
> Jan 7 09:15:29 server kernel: fh_verify: mail/guest permission failure, acc=4, error=13
> Jan 7 09:23:51 server kernel: fh_verify: ekonomi/test permission failure, acc=4, error=13
> 
> They happen when a NFS setattr operation is attempted on a file you don't have 
> write access to. These messages are harmless.

If you want, you could remove the offending 'printk' line from the knfsd
code ...

James Pearson

"José Vicente Núñez Zuleta" wrote:
> 
> Greetings,
> 
> Looking into the /var/log/messages i found the
> following error message:
> 
> Jun 10 10:01:11 lnxsrv0003 kernel: fh_verify:
> linux0054/repository permission failure, acc=42,
> error=13
> Jun 10 10:01:12 lnxsrv0003 kernel: fh_verify:
> linux0050/repository permission failure, acc=42,
> error=13
> Jun 10 10:01:12 lnxsrv0003 kernel: fh_verify:
> linux0048/repository permission failure, acc=42,
> error=13
> Jun 10 10:01:12 lnxsrv0003 kernel: fh_verify:
> linux0024/repository permission failure, acc=42,
> error=13
> Jun 10 10:01:13 lnxsrv0003 kernel: fh_verify:
> linux0049/repository permission failure, acc=42,
> error=13
> Jun 10 10:01:13 lnxsrv0003 kernel: fh_verify:
> linux0047/repository permission failure, acc=42,
> error=13
> Jun 10 10:01:14 lnxsrv0003 kernel: fh_verify:
> linux0056/repository permission failure, acc=42,
> error=13
> Jun 10 10:01:15 lnxsrv0003 kernel: fh_verify:
> linux0057/repository permission failure, acc=42,
> error=13
> Jun 10 10:04:00 lnxsrv0003 kernel: fh_verify:
> lnxsrv0004/repository permission failure, acc=42,
> error=13
> Jun 10 10:04:00 lnxsrv0003 last message repeated 5
> times
> 
> Any ideas? Are this messages harmfull?
> 
> JV.
> 
> =====
> José Vicente Nuñez Zuleta (josevnz@yahoo.com)
> Newbreak System Administrator (http://www.newbreak.com)
> Office Phone:   203-355-1511, 203-355-1510
> Fax:            203-355-1512
> Cellular Phone: 203-570-7078
> 
> __________________________________________________
> Do You Yahoo!?
> Yahoo! - Official partner of 2002 FIFA World Cup
> http://fifaworldcup.yahoo.com
> 
> _______________________________________________________________
> 
> Multimillion Dollar Computer Inventory
> Live Webcast Auctions Thru Aug. 2002 - http://www.cowanalexander.com/calendar
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
