From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS limits?
Date: Mon, 8 May 2006 14:19:14 -0400
Message-ID: <20060508181914.GG13972@fieldses.org>
References: <445F8356.1030605@cnm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FdEw2-00011i-Pt
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 16:14:38 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FdAKG-00048I-Hv
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 11:19:20 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FdAKF-0001bZ-96
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 11:19:20 -0700
To: Marten Lehmann <lehmann@cnm.de>
In-Reply-To: <445F8356.1030605@cnm.de>
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

On Mon, May 08, 2006 at 07:43:50PM +0200, Marten Lehmann wrote:
> Hello,
> 
> a mailserver of us is storing the messages on another server with NFS 
> through TCP. A lot of concurrent deliveries occur, but I can only see 
> about 8 nfs processes on the storage server. The mailserver which 
> accesses the storage often has very high I/O waits (>400 seconds), 
> because the NFS server doesn't respond in time. How can I increase the 
> NFS-processes on the storage server? Right NFS is a real bottleneck and 
> a lot of mails are delivered with a delay of 1-3 hours.

See 
http://nfs.sourceforge.net/nfs-howto/performance.html#NFSD-INSTANCE

and "man nfsd".

--b.


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
