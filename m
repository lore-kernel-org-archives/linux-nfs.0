From: Allard Hoeve <allard@byte.nl>
Subject: Re: Kernel oops (NLM?)
Date: Mon, 14 Aug 2006 17:39:45 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0608141725080.13398@office2.c1.internal>
References: <Pine.LNX.4.62.0608140949350.23888@office2.c1.internal>
	<1155566027.5664.56.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, tech@byte.nl
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCeXi-00066L-6N
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 08:39:54 -0700
Received: from ip-82-94-214-63.ams.byte.nl ([82.94.214.63] helo=smtp.byte.nl)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GCeXh-0002xv-Dh
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 08:39:54 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1155566027.5664.56.camel@localhost>
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


Hello Trond,

> I'd suggest upgrading. We've eliminated a lot of races in NLM since
> then, and have (among other things) completely removed the codepath that
> appears to have Oopsed below.

Thanks for your reply.

We've upgraded to vanilla 2.6.17.8 since (for other reasons as well). It 
looks like the codepath still exists there? Is the mainstream kernel in 
sync? What version do you recommend (NFS-wise)?



Ironically, we experienced an entirely different NFS crash on 2.6.17.8 
kernel as well :)

Short description:

* All nfsd threads hanging (state D)
* All clients stalled
* Restarting the nfs-kernel-server didn't help
* No syslog entries
* No dmesg entries

Due to the lack of logs, I can't be more verbose...

Regards,

Allard

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
