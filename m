From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 08:17:19 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DF4F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
        "Steve Dickson" <SteveD@redhat.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH2Qr-0002U3-Nf
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 08:17:37 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH2Qr-0000f9-Fs
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 08:17:37 -0700
To: "Olaf Kirch" <okir@suse.de>
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

> On Fri, Apr 23, 2004 at 07:48:11AM -0700, Lever, Charles wrote:
> > there appears to be a real problem when restoring from a backup,
> > or using rsync.  the file size and the mtime stay precisely the
> > same, but the file handle changes.  i'm not sure anything can be
> > done about this in NFSv2/3?
>=20
> Well, namei_open could interpret an ESTALE error as "retry the
> lookup and open, ignoring the cache".
> I think this would solve 99% of all problems.

my impression was that viro would wretch at the idea of adding
file-system specific logic to the VFS layer.  %^)


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
