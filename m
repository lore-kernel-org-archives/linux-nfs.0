From: Michael Buesch <fsdeveloper@yahoo.de>
Subject: Re: processes stuck in D state
Date: Tue, 6 May 2003 18:30:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200305061830.25417.fsdeveloper@yahoo.de>
References: <200305061652.13280.fsdeveloper@yahoo.de> <200305061742.14032.fsdeveloper@yahoo.de> <16055.56630.615496.19679@charged.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: neilb@cse.unsw.edu.au,
 nfs@lists.sourceforge.net,
 linux kernel mailing list <linux-kernel@vger.kernel.org>,
 Zeev Fisher <Zeev.Fisher@il.marvell.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp013.mail.yahoo.com ([216.136.173.57])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D5S3-0000du-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 09:37:59 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <16055.56630.615496.19679@charged.uio.no>
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

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Tuesday 06 May 2003 18:05, Trond Myklebust wrote:
> >>>>> " " =3D=3D Michael Buesch <fsdeveloper@yahoo.de> writes:
>      > To reproduce the problem:
>      > - - mount some nfs from a server in your lan.
>      > - - Open an app, that uses the mounted fs. I've simply opened a
>      >   konqueror-window for the directory where the nfs is mounted.
>      > - - shut down or crash the server or just pull the
>      >     network-cable.
>      > - - Now the konqueror-process is nonkillable in D
>      >     state. There's no
>      >   chance to kill it.
>
> Unless you are using the 'intr' or 'soft' mount flags, then that is
> *documented and expected* behaviour.

I'm using intr.

> However, as I've mentioned on this list *many* times before: there
> exists a workaround if you are wanting to kill all processes in order
> to unmount the partition:
>   kill -9 all the processes.
>   kill -9 rpciod.

kill -9 doesn't work for me to kill the app.

=2D --=20
Regards Michael B=FCsch
http://www.8ung.at/tuxsoft
 18:28:55 up  2:20,  5 users,  load average: 1.02, 1.06, 1.06
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE+t+MhoxoigfggmSgRAkeqAJ0c71DxLZ13/CHqUXlTa8TvjAt2iwCeLO34
s7crt56Gr8JyKxCLZMbrNvc=3D
=3Dz8EU
=2D----END PGP SIGNATURE-----



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
