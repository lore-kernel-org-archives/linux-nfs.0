From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: append-only attribute support
Date: Fri, 21 Jan 2005 13:02:38 -0500
Message-ID: <1106330559.9849.73.camel@lade.trondhjem.org>
References: <8381054C-6B13-11D9-BFA6-000D933B35AA@bdi.com>
	 <1106318654.3200.38.camel@tribesman.namesys.com>
	 <1106322787.30627.5.camel@lade.trondhjem.org>  <41F12C75.5040007@bdi.com>
	 <1106327280.9849.32.camel@lade.trondhjem.org>  <41F1423F.3080800@bdi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cs37T-0003Bn-50
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 10:02:51 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cs37Q-0008Ke-W6
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 10:02:50 -0800
To: "Aaron D. Ball" <adb@bdi.com>
In-Reply-To: <41F1423F.3080800@bdi.com>
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

fr den 21.01.2005 Klokka 12:56 (-0500) skreiv Aaron D. Ball:

> --- vfs.c~      2004-12-24 16:34:31.000000000 -0500
> +++ vfs.c       2005-01-21 12:52:14.000000000 -0500
> @@ -658,7 +658,7 @@
>          * with mandatory locking enabled
>          */
>         err = nfserr_perm;
> -       if (IS_APPEND(inode) || IS_ISMNDLK(inode))
> +       if ((IS_APPEND(inode) || (access & MAY_WRITE)) || 
> IS_ISMNDLK(inode))
>                 goto out;
>         if (!inode->i_fop)
>                 goto out;

Don't you mean

	if ((IS_APPEND(inode) && (access & MAY_WRITE)) || IS_ISMNDLK(inode))

;-)

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
