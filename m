From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSERR_EAGAIN
Date: 11 Jul 2003 00:41:13 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsbrw20zue.fsf@charged.uio.no>
References: <3F0DB088.303@cinesite.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs <nfs@lists.sourceforge.net>,  Iain Irwin-Powell <Iain@cinesite.co.uk>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ak6R-0003In-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Jul 2003 15:41:27 -0700
To: Danny Smith <dannys@cinesite.co.uk>
In-Reply-To: <3F0DB088.303@cinesite.co.uk>
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

>>>>> " " == Danny Smith <dannys@cinesite.co.uk> writes:

     > Looking through nfs2xdr.c and nfs.h and googling, it seems that
     > error number 11 is not properly defined, but certainly seems to
     > be in use by SGI. From nfs2xdr.c:

     >      { NFSERR_NXIO, ENXIO },

     > /* { NFSERR_EAGAIN, EAGAIN }, */
     >       { NFSERR_ACCES, EACCES },

     > (EAGAIN having value 11)

     > Does anyone know much about the history of this? Was this
     > removed in order to be RFC compliant, or is there a stronger
     > motivation not to have this?

Why should we be supporting something which isn't documented in the RFCs?

What is this error anyway? Is it some SGI hack for emulating
NFS3ERR_JUKEBOX under NFSv2?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
