From: Greg Lindahl <lindahl@keyresearch.com>
Subject: Re: wsize & PAGE_SIZE issues on IA64 clients.
Date: Mon, 31 Mar 2003 11:09:57 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030331190957.GA1206@greglaptop.internal.keyresearch.com>
References: <Pine.LNX.4.44.0303271219410.2496-100000@mprice-laptop.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 66-122-194-201.ded.pacbell.net ([66.122.194.201] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1904fs-0007G4-00
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 11:10:28 -0800
Received: from localhost.localdomain (localhost [127.0.0.1])
	by localhost.localdomain (8.12.8/8.12.5) with ESMTP id h2VJ9vMb001218
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 11:09:57 -0800
Received: (from lindahl@localhost)
	by localhost.localdomain (8.12.8/8.12.8/Submit) id h2VJ9vbo001216
	for nfs@lists.sourceforge.net; Mon, 31 Mar 2003 11:09:57 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.44.0303271219410.2496-100000@mprice-laptop.beaverton.ibm.com>
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

> The fix/workaround was to either increase wsize to 16K, or reduce 
> PAGE_SIZE to 4K, obviously increasing wsize to 16K makes more sense.
> 
> However this leads to a problem between Linux clients and servers where 
> the maximum supported block size on the server is 8K and the page size on 
> the IA64 client is 16K.

Is the "wsize < PAGE_SIZE" problem worth a printf in mount or mountd or
the kernel?

-- greg



-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
