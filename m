From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [patch 3/4] NFS: Remove use of the Big Kernel Lock	around
	calls to	rpc_call_sync
Date: Wed, 18 Oct 2006 18:34:23 -0400
Message-ID: <1161210863.6095.197.camel@lade.trondhjem.org>
References: <1161105878.3315.23.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaJze-0006lM-L5
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 15:34:34 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GaJze-0003ud-4i
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 15:34:35 -0700
To: Frank Filz <ffilzlnx@us.ibm.com>
In-Reply-To: <1161105878.3315.23.camel@dyn9047022153>
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

On Tue, 2006-10-17 at 10:24 -0700, Frank Filz wrote:
> Remove use of the Big Kernel Lock around calls to rpc_call_sync.

Applied...


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
