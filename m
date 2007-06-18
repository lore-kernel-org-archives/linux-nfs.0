From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: unknow auth error with a nfs mounted root client
Date: Mon, 18 Jun 2007 14:01:08 -0400
Message-ID: <1182189668.6455.12.camel@heimdal.trondhjem.org>
References: <20070618144943.8723.qmail@web23003.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: philippe musial <happylinuxuser@yahoo.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I0LXR-00077e-Ar
	for nfs@lists.sourceforge.net; Mon, 18 Jun 2007 11:01:17 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19ZpD5MvkbStxhs2+R8F1up0K8WLbPBxTw=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I0LXR-0001Ry-8Y
	for nfs@lists.sourceforge.net; Mon, 18 Jun 2007 11:01:20 -0700
In-Reply-To: <20070618144943.8723.qmail@web23003.mail.ird.yahoo.com>
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

On Mon, 2007-06-18 at 16:49 +0200, philippe musial wrote:
> Hi everybody,
> 
> I try to duplicate a model built in a chrooted
> environment under Debian Etch with replicator. I made
> a boot disk and when I use it on the target computer
> (192.168.1.3) I get this message:
> call_verify: unknown auth error: 7

Are you perhaps trying to export /export/install/miniroot using
kerberos/rpcsec_gss security? There is no way nfsroot can mount that:
you have no rpc.gssd daemon running, and neither do you have any
credentials.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
