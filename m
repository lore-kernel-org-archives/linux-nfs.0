From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Question about the nocto option in 2.4 and 2.6
Date: Fri, 07 Jul 2006 13:43:11 -0400
Message-ID: <1152294191.5714.2.camel@lade.trondhjem.org>
References: <1152293821.5385.2.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FyuMS-0005nT-O9
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 10:43:28 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FyuMS-0003E1-Q0
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 10:43:29 -0700
To: Frank Filz <ffilzlnx@us.ibm.com>
In-Reply-To: <1152293821.5385.2.camel@dyn9047022153>
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

On Fri, 2006-07-07 at 10:37 -0700, Frank Filz wrote:
> I'm consulting on an issue where we are seeing an increase in network
> traffic between 2.4.21 and 2.6.9 kernels with the use of the nocto
> option. This is raising a performance concern.
> 
> I'm wondering what has changed with this option between the two kernel
> levels.

Nothing much. What does nfsstat tell you has changed?

Cheers,
  Trond


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
