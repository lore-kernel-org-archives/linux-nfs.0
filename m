From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs over 2tb limitation
Date: Sat, 08 Apr 2006 15:01:02 -0400
Message-ID: <1144522862.8195.39.camel@lade.trondhjem.org>
References: <E80C016468F5454E93FBC2FBF2F93AE47FB4F6@EINSTEIN.idg.idgrup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FSIgX-00018v-VC
	for nfs@lists.sourceforge.net; Sat, 08 Apr 2006 12:01:25 -0700
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FSIgW-0007AS-Ko
	for nfs@lists.sourceforge.net; Sat, 08 Apr 2006 12:01:26 -0700
To: Julio Prada <julio.prada@idgrup.com>
In-Reply-To: <E80C016468F5454E93FBC2FBF2F93AE47FB4F6@EINSTEIN.idg.idgrup.com>
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

On Fri, 2006-04-07 at 09:34 +0200, Julio Prada wrote:
> Hello,
>=20
> =20
>=20
> The scenario is a Hp clustered gateway that theorically can virtualize
> up to 16TB, and it seems that the limitation it=E2=80=99s on NFS client t=
hat
> only can reach up to 2TB on large filesystems.

Nope. That is completely wrong. The NFS client neither knows nor cares
about the size of your filesystem. If you have > 2TB accessible on the
server, then the client can and will use it.

What is true, though, is that if you compile without CONFIG_LBD (or
CONFIG_LSF on 2.6.17-rc1) then the statfs() and statvfs() system calls
will incapable of displaying more than 2TB.
IOW: 'df' will display some incorrectly small size.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
