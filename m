From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: Stopping NFS, ip address take over, zero-copy NFS for 2.4.21, and misc
Date: Fri, 19 Sep 2003 14:50:24 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200309191450.24184.bernd-schubert@web.de>
References: <1063900790.8031.9644.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A0KiV-0006Q1-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Sep 2003 05:50:31 -0700
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A0KiU-00059B-I1
	for nfs@lists.sourceforge.net; Fri, 19 Sep 2003 05:50:30 -0700
To: Chris Worley <cworley@lnxi.com>, nfs@lists.sourceforge.net
In-Reply-To: <1063900790.8031.9644.camel@localhost.localdomain>
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

> 2) IP address takeover between NFS servers.
>
> With NFS stateless, and not running lock servers, I thought a simple IP
> address takeover scheme (when an I/O server goes down, another just adds
> the failed server's IP address as a virtual interface) would allow
> clients to immediately renegotiate with the same IP address pointing to
> another NFS server (serving the same partitions).  The take-over is
> successful: the clients can communicate with the new I/O server, but I
> get "permission denied" (as root or otherwise) on the NFS mounted
> partitions most of the time (sometimes it works).
>
> What am I missing?
>

Don't know whats going wrong at your network, but it works pretty well on o=
ur=20
systems.=20
How do you sync both server system (main server and fall back server)? Well=
,=20
since its here a root-fs server and changes are done rarely, we simply=20
connect them via nbd and sync using dd of the whole device once a night.
=46or our main-data server (/home, etc) there is currently no fall back, bu=
t we=20
plan to doing this in the near future. To do so, we want to connect via enb=
d=20
and do a network raid1 between both systems.=20
Let me guess, do you sync using tar, etc.? This won't work since you need t=
he=20
very same inode numbers. The only way to do so, is to use network raid or a=
=20
1:1 copy of the whole partion-device.

Cheers,
	Bernd


Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
