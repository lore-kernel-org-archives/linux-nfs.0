From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: wsize & PAGE_SIZE issues on IA64 clients.
Date: Mon, 31 Mar 2003 15:25:59 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D55484@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1908fp-0003mD-00
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 15:26:41 -0800
To: "Greg Lindahl" <lindahl@keyresearch.com>
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

> Is the "wsize < PAGE_SIZE" problem worth a printf in mount or=20
> mountd or
> the kernel?

perhaps an entry in the NFS FAQ might be more timely, considering
how long it would take this kind of change to make it into the
common commercial distributions.


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
