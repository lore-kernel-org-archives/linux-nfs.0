From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: exporting UDF medium
Date: Sun, 17 Sep 2006 16:54:32 -0400
Message-ID: <20060917205432.GA13396@fieldses.org>
References: <65a4d3a049c6fe88fcb53d6cbaf0e2fe@cs.tu-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GP3eu-0005VN-1F
	for nfs@lists.sourceforge.net; Sun, 17 Sep 2006 13:54:36 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GP3et-00064f-MB
	for nfs@lists.sourceforge.net; Sun, 17 Sep 2006 13:54:36 -0700
To: Volker Eckert <volkere@cs.tu-berlin.de>
In-Reply-To: <65a4d3a049c6fe88fcb53d6cbaf0e2fe@cs.tu-berlin.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sat, Sep 16, 2006 at 08:36:36PM +0200, Volker Eckert wrote:
> i'm having trouble exporting my DVD-RAM media (i get 'permission 
> denied'). searched groups and www to no avail so far. any help/info 
> would be very appreciated.

bfields@puzzle:linux$ git grep export_operations fs/udf
bfields@puzzle:linux$

So at a guess, I'd say you're out of luck until someone writes udf
support for exporting via nfs.

It'd be nice if we could give a better error message in this case....

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
