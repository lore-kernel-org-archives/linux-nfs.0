From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS]
 http://client.linux-nfs.org/Linux-2.6.x/2.6.10/linux-2.6.10-33-access_cache.dif
Date: Sat, 05 Feb 2005 19:24:46 -0500
Message-ID: <1107649486.484.2.camel@lade.trondhjem.org>
References: <420496F7.9080900@csua.berkeley.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CxaEb-0002Gi-65
	for nfs@lists.sourceforge.net; Sat, 05 Feb 2005 16:25:05 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CxaEZ-0007nN-GJ
	for nfs@lists.sourceforge.net; Sat, 05 Feb 2005 16:25:04 -0800
To: Mark Goodman <mgoodman@CSUA.Berkeley.EDU>
In-Reply-To: <420496F7.9080900@csua.berkeley.edu>
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

lau den 05.02.2005 Klokka 01:50 (-0800) skreiv Mark Goodman:
> This patch appears to have the effect that non-existent files don't get 
> cached. When I apply it to 2.6.10, a C preprocessor workload that 
> involves opening lots of non-existent files slows down by an order of 
> magnitude and I notice tens of thousands of NFS ACCESS calls per second 
> according to nfsstat.

Nope. NFS_ACCESS can only be called on files that *do* exist.

Are you sure that you are not using it on directories that are changing
a lot?

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
