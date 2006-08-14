From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Kernel oops (NLM?)
Date: Mon, 14 Aug 2006 13:29:25 -0400
Message-ID: <20060814172925.GH17184@fieldses.org>
References: <Pine.LNX.4.62.0608140949350.23888@office2.c1.internal>
	<1155566027.5664.56.camel@localhost>
	<Pine.LNX.4.62.0608141725080.13398@office2.c1.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, tech@byte.nl,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCgFl-0007iw-2I
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 10:29:29 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GCgFk-0002qd-Ds
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 10:29:29 -0700
To: Allard Hoeve <allard@byte.nl>
In-Reply-To: <Pine.LNX.4.62.0608141725080.13398@office2.c1.internal>
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

On Mon, Aug 14, 2006 at 05:39:45PM +0200, Allard Hoeve wrote:
> Ironically, we experienced an entirely different NFS crash on 2.6.17.8 
> kernel as well :)
> 
> Short description:
> 
> * All nfsd threads hanging (state D)
> * All clients stalled
> * Restarting the nfs-kernel-server didn't help
> * No syslog entries
> * No dmesg entries
> 
> Due to the lack of logs, I can't be more verbose...

You could try alt-syrq-T (or "echo t >/proc/sysrq-trigger").  That'll
dump to the logs a stack for every process.  (It's the nfsd ones that
are most likely to be interesting).  So we might be able to figure out
where the nfsd threads are hanging.

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
