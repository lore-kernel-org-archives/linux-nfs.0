From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Oops on flock on NFS3 krb5 mount
Date: Fri, 28 Jan 2005 11:24:35 -0800
Message-ID: <1106940275.14321.42.camel@lade.trondhjem.org>
References: <41F9FB44.9060002@csua.berkeley.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cubmz-0008RI-7N
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 11:28:17 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cubje-0001Xy-5a
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 11:28:17 -0800
To: Mark Goodman <mgoodman@CSUA.Berkeley.EDU>
In-Reply-To: <41F9FB44.9060002@csua.berkeley.edu>
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

fr den 28.01.2005 Klokka 00:43 (-0800) skreiv Mark Goodman:
> On 2.6.11-rc2 with Trond's patches applied, when I run the following on
> my NFS3 krb5 mount:

Thanks for the report! I'll look into it tonight.

Please note, though, that the RPCSEC_GSS code in my NFS_ALL patches is
likely to be a bit unstable over the next few days as I'm in the process
of merging the keyring support.

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
