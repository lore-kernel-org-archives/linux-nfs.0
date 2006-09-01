From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd: rejected NSM callback from 7f000001:30001
Date: Fri, 01 Sep 2006 12:11:11 -0400
Message-ID: <1157127071.5632.59.camel@localhost>
References: <20060901132854.GA25597@bigboss.venod.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJBcB-0000HG-7N
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:11:31 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJBcB-0000AO-CR
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:11:31 -0700
Received: from mail-mx4.uio.no ([129.240.10.45])
	by pat.uio.no with esmtp (Exim 4.43) id 1GJBc5-0002Mr-6V
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 18:11:25 +0200
To: Haakon Riiser <haakon.riiser@fys.uio.no>
In-Reply-To: <20060901132854.GA25597@bigboss.venod.com>
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

On Fri, 2006-09-01 at 15:28 +0200, Haakon Riiser wrote:
> A few months ago, I upgraded my file server from FC3 to FC5,
> and at the same time, upgraded all of the file server's hardware
> except the disks (a single SATA drive that holds the OS plus four
> SATA drives in a software RAID5 array).
> 
> After this upgrade (at least that's when I think it first started to
> happen), I started seeing
> 
>   lockd: rejected NSM callback from 7f000001:30001

This is very intentional. The kernel won't accept notifications from
unprivileged ports. If it did, then any local user would be able to
trick the kernel into thinking that some server had rebooted, by sending
the appropriate RPC message.

Change your /etc/sysconfig/nfs so that it sets a value < 1024 for
STATD_OUTGOING_PORT.

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
