From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: nfsprog support
Date: Thu, 15 Apr 2004 20:39:56 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200404152040.06227.bernd-schubert@web.de>
References: <200404151750.53209.bernd-schubert@web.de> <20040415175143.GA25858@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BEBmV-0000je-AN
	for nfs@lists.sourceforge.net; Thu, 15 Apr 2004 11:40:11 -0700
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BEBmU-000842-F6
	for nfs@lists.sourceforge.net; Thu, 15 Apr 2004 11:40:10 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040415175143.GA25858@suse.de>
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

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Thursday 15 April 2004 19:51, Olaf Kirch wrote:
> Hi,
>
> On Thu, Apr 15, 2004 at 05:50:39PM +0200, Bernd Schubert wrote:
> > about a year ago I already asked about nfsprog support and that time
> > Trond told me that the kernel doesn't support it yet.
>
> Allow me this dumb question, but what is nfsprog support?
>

citing from 'man 5 nfs':

nfsprog=3Dn	Use  an  alternate  RPC  program number to contact the 	=09
			NFS daemon on the remote host.
			This option is useful for hosts that can run multiple NFS servers.  The =
=09
			default value  is 100003 which is the standard RPC NFS daemon program=20
			number.


Bernd


=2D --=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAftcCC8BUnAF+ydYRAoO9AJ4k06PckVxT2NJ/4ybon2qCMNbNugCdFtWD
IXh6ZOKpwDyjPu5yEd8MMMg=3D
=3DjVmV
=2D----END PGP SIGNATURE-----


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
