From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Oops on killing process with soft-unmounted NFS3 krb5 mount
Date: Mon, 31 Jan 2005 18:35:41 -0800
Message-ID: <1107225341.16985.53.camel@lade.trondhjem.org>
References: <41FE9A03.1030008@csua.berkeley.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-n6CG+Krk5x4HtgKDvNyz"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cvnx5-0007MN-Fj
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 18:39:39 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cvnx4-00012i-Rn
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 18:39:39 -0800
To: Mark Goodman <mgoodman@CSUA.Berkeley.EDU>
In-Reply-To: <41FE9A03.1030008@csua.berkeley.edu>
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


--=-n6CG+Krk5x4HtgKDvNyz
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

m=E5 den 31.01.2005 Klokka 12:50 (-0800) skreiv Mark Goodman:
> I am running 2.6.11-rc2 with your patches. I recall this behavior on=20
> 2.6.8 as well.
>=20
> I can consistently reproduce this oops on my Fedora Core 3 machine with=20
> the following steps:
>=20
> Login as a normal user with a home directory on an NFS3 krb5 mount
> Login as root and run init 1. init 1 unmounts the mount.
> Kill the normal user's shell.
>=20
> In practice, this often happens when switching to runlevel 6 for a reboot=
.
>=20
> Jan 31 12:32:39 soda kernel: net/sunrpc/rpc_pipe.c: rpc_lookup_parent=20
> failed to find path /nfs/clnt0/krb5

OK. Looks like kill_litter_super() might be the culprit here:
d_genocide() will give the above symptom. Does the appended patch work?

Cheers
  Trond

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-n6CG+Krk5x4HtgKDvNyz
Content-Disposition: inline; filename=linux-2.6.11-20-pipefs_detachmntfix.dif
Content-Type: text/plain; name=linux-2.6.11-20-pipefs_detachmntfix.dif; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

RPC: Fix an oopsable condition on detached mount of rpc_pipefs

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 rpc_pipe.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.11-rc2/net/sunrpc/rpc_pipe.c
===================================================================
--- linux-2.6.11-rc2.orig/net/sunrpc/rpc_pipe.c
+++ linux-2.6.11-rc2/net/sunrpc/rpc_pipe.c
@@ -795,7 +795,7 @@ static struct file_system_type rpc_pipe_
 	.owner		= THIS_MODULE,
 	.name		= "rpc_pipefs",
 	.get_sb		= rpc_get_sb,
-	.kill_sb	= kill_litter_super,
+	.kill_sb	= kill_anon_super,
 };
 
 static void

--=-n6CG+Krk5x4HtgKDvNyz--



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
