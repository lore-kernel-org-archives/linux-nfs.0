From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Question about the nocto option in 2.4 and 2.6
Date: Fri, 07 Jul 2006 14:22:36 -0400
Message-ID: <1152296557.5714.10.camel@lade.trondhjem.org>
References: <1152293821.5385.2.camel@dyn9047022153>
	<1152294191.5714.2.camel@lade.trondhjem.org>
	<1152295253.5385.5.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyuyZ-0000n6-MA
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 11:22:51 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FyuyY-0005za-GX
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 11:22:52 -0700
To: Frank Filz <ffilzlnx@us.ibm.com>
In-Reply-To: <1152295253.5385.5.camel@dyn9047022153>
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

On Fri, 2006-07-07 at 11:00 -0700, Frank Filz wrote:
> I currently don't have access to the machines involved. I'm trying to
> get a bit more information. Looking at the code, I do see that the check
> for the nocto option has moved from nfs_open to nfs_lookup_verify_inode.

Yes. That is because we have moved the close-to-open cache consistency
checking into nfs_lookup()/nfs_lookup_revalidate().

Cheers,
  Trond


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
