From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Fail to start rpc nfsd
Date: Sun, 12 Nov 2006 19:49:31 -0500
Message-ID: <20061113004930.GA22758@fieldses.org>
References: <1163333766.3131.7.camel@tleilax.poochiereds.net>
	<20061113002623.8621.qmail@web35213.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjQ10-0006mj-Q1
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 16:49:35 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GjQ10-0003r5-Te
	for nfs@lists.sourceforge.net; Sun, 12 Nov 2006 16:49:36 -0800
To: Stephen Liu <satimis@yahoo.com>
In-Reply-To: <20061113002623.8621.qmail@web35213.mail.mud.yahoo.com>
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

On Mon, Nov 13, 2006 at 08:26:23AM +0800, Stephen Liu wrote:
> $ ps -ef | egrep '/nfs-kernel-server'
> satimis   4841  4786  0 08:16 pts/2    00:00:00 grep -E
> /nfs-kernel-server

It's portmap you need to grep for.

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
