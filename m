From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: wsize & PAGE_SIZE issues on IA64 clients.
Date: Tue, 1 Apr 2003 08:25:15 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16009.12491.241236.831979@charged.uio.no>
References: <shshe9izs2g.fsf@charged.uio.no>
	<Pine.PTX.4.30.0303312210520.11440-100000@crg8.beaverton.ibm.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
    Greg Lindahl <lindahl@keyresearch.com>,
    <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 190FDI-0005rg-00
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 22:25:40 -0800
To: Mark Price <mkprice@us.ibm.com>
In-Reply-To: <Pine.PTX.4.30.0303312210520.11440-100000@crg8.beaverton.ibm.com>
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


One approach we might want to look into, would be to backport the
'wb_index' from 2.5.x, and then make that map to 4k segments (or
smaller) on ia64. That would divorce the nfs_page from the real page
size.

Needs some work in order to make reads work ('cos you would have
mapped several nfs_page into one real page => the last reader has to
remove the page lock) and a bit of plumbing in pagelist.c, but looks
doable...

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
