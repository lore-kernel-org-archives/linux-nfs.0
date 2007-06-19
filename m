From: philippe musial <happylinuxuser@yahoo.fr>
Subject: RE : Re:  unknow auth error with a nfs mounted root client
Date: Tue, 19 Jun 2007 12:14:27 +0200 (CEST)
Message-ID: <61151.15762.qm@web23008.mail.ird.yahoo.com>
References: <1182189668.6455.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I0bfM-0006Vf-Gs
	for nfs@lists.sourceforge.net; Tue, 19 Jun 2007 04:14:34 -0700
Received: from web23008.mail.ird.yahoo.com ([217.146.189.33])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1I0bfM-0002kk-W3
	for nfs@lists.sourceforge.net; Tue, 19 Jun 2007 04:14:35 -0700
In-Reply-To: <1182189668.6455.12.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--- Trond Myklebust <trond.myklebust@fys.uio.no> a
=E9crit :

> On Mon, 2007-06-18 at 16:49 +0200, philippe musial
> wrote:
> > Hi everybody,
> > =

> > I try to duplicate a model built in a chrooted
> > environment under Debian Etch with replicator. I
> made
> > a boot disk and when I use it on the target
> computer
> > (192.168.1.3) I get this message:
> > call_verify: unknown auth error: 7
> =

> Are you perhaps trying to export
> /export/install/miniroot using
> kerberos/rpcsec_gss security? There is no way
> nfsroot can mount that:
> you have no rpc.gssd daemon running, and neither do
> you have any
> credentials.

Hello Trond,
I am not trying to export using kerberos/rpcsec_gss
security:
here is my /etc/exports:
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync)
hostname2(ro,sync)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=3D0,crossmnt)
# /srv/nfs4/homes  gss/krb5i(rw,sync)
#
/export/install/miniroot
garfield.le.chat(rw,no_root_squash)

> =

> Cheers
>   Trond
> =

> =

Regards
Philippe


      _____________________________________________________________________=
________ =

Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo! Mai=
l =


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
