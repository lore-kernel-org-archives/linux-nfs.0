From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: newbie question
Date: Thu, 11 Aug 2005 22:01:15 -0700 (PDT)
Message-ID: <20050812050115.50816.qmail@web51613.mail.yahoo.com>
References: <bc572709050811211255587aba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E3RfW-0007P3-Ib
	for nfs@lists.sourceforge.net; Thu, 11 Aug 2005 22:01:22 -0700
Received: from web51613.mail.yahoo.com ([68.142.224.86])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1E3RfV-0007CU-4v
	for nfs@lists.sourceforge.net; Thu, 11 Aug 2005 22:01:22 -0700
To: Michael <mikore.li@gmail.com>, nfs@lists.sourceforge.net
In-Reply-To: <bc572709050811211255587aba@mail.gmail.com>
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

Just in case you need it ....
For more readable output use=20
tethereal -V
--- Michael <mikore.li@gmail.com> wrote:

> Hi,=20
>=20
> how can I understand following output from "tcpdump
> -p", at that time,
> I am "dd" a file into a nfs mount point. Can anyone
> send me a
> reference link to me? especially what's the meaning
> of "frag
> 55141:1292@2960", what's "DF"...
>=20
> 11:40:16.499209 192.168.0.148.3554257722 >
> 192.168.0.90.nfs: 1472
> write [|nfs] (frag 55140:1480@0+)
> 11:40:16.499412 192.168.0.90.nfs >
> 192.168.0.148.3302599482: reply ok 136 (DF)
> 11:40:16.499450 192.168.0.148 > 192.168.0.90: udp
> (frag 55141:1292@2960)
> 11:40:16.499458 192.168.0.148 > 192.168.0.90: udp
> (frag 55141:1480@1480+)
> 11:40:16.499464 192.168.0.148.3571034938 >
> 192.168.0.90.nfs: 1472
> write [|nfs] (frag 55141:1480@0+)
> 11:40:16.499777 192.168.0.90.nfs >
> 192.168.0.148.3319376698: reply ok 136 (DF)
> 11:40:16.499813 192.168.0.148 > 192.168.0.90: udp
> (frag 55142:1292@2960)
> 11:40:16.499821 192.168.0.148 > 192.168.0.90: udp
> (frag 55142:1480@1480+)
>=20
> Thank,
>=20
> Mike
>=20
>=20
>
-------------------------------------------------------
> SF.Net email is Sponsored by the Better Software
> Conference & EXPO
> September 19-22, 2005 * San Francisco, CA *
> Development Lifecycle Practices
> Agile & Plan-Driven Development * Managing Projects
> & Teams * Testing & QA
> Security * Process Improvement & Measurement *
> http://www.sqe.com/bsce5sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practic=
es
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & Q=
A
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
