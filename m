From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: NFS readonly failover and linux?
Date: Thu, 27 Jan 2005 16:15:09 -0800
Message-ID: <1106871309.6181.254.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuJny-00038G-7P
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 16:16:06 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CuJn8-00021C-57
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 16:16:05 -0800
To: nfs@lists.sourceforge.net
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


The autofs man pages on Redhat Enterprise Linux 3 as well as Fedora Core
3 both say that autofs supports replicated, readonly fileserver failover
- but then there's a footnote of sorts that says autofs only supports it
to the extent that mount does.

Upon trying to do such a mount, I get:

seki-root> mount
dcslib1.nacs.uci.edu,dcslib4.nacs.uci.edu:/dcspdb/rhel-3-i686 /mnt/nfs
mount: warning: multiple hostnames not supported
Thu Jan 27 16:12:18

seki-root> 


Is there a version of mount available, or in early development, that
supports this feature?

Thanks!




-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
