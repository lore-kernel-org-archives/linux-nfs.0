From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: Crash in dec_zone_page_state when nfs_page req is freed
Date: Fri, 13 Oct 2006 08:18:07 -0700
Message-ID: <1160752687.3809.0.camel@dyn9047022153>
References: <1158623736.3376.8.camel@dyn9047022153>
	<1158636275.5896.14.camel@lade.trondhjem.org>
	<1160418641.3376.103.camel@dyn9047022153>
	<1160425510.5466.44.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GYOnP-0005yK-HF
	for nfs@lists.sourceforge.net; Fri, 13 Oct 2006 08:18:00 -0700
Received: from e36.co.us.ibm.com ([32.97.110.154])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GYOnL-0005zf-Jx
	for nfs@lists.sourceforge.net; Fri, 13 Oct 2006 08:18:00 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com
	[9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9DFHkaa015509
	for <nfs@lists.sourceforge.net>; Fri, 13 Oct 2006 11:17:46 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k9DFHj4B351584
	for <nfs@lists.sourceforge.net>; Fri, 13 Oct 2006 09:17:45 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k9DFHjVK003627
	for <nfs@lists.sourceforge.net>; Fri, 13 Oct 2006 09:17:45 -0600
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1160425510.5466.44.camel@lade.trondhjem.org>
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

On Mon, 2006-10-09 at 16:25 -0400, Trond Myklebust wrote:
> On Mon, 2006-10-09 at 11:30 -0700, Frank Filz wrote:
> > I've had a chance to do some testing of this. It turns out that
> > nfs_inode_remove_request() will set wb_page to NULL, so it looks like
> > the call to dec_zone_page_state needs to be moved up before
> > nfs_inode_remove_request(). I'm testing that right now, but I start to
> > wonder exactly what the dec_zone_page_state is doing in this case, I
> > know that was a recent addition.
> 
> Yup, that makes sense. Furthermore, it looks like the call to
> nfs_clear_page_writeback is redundant, since nfs_inode_remove_request
> will cause the tags to be implicitly cleared.
> 
> How does the attached patch work for you?

That did the trick. Thanks.

Frank



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
