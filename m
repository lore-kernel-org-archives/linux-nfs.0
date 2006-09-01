From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: lockd: rejected NSM callback from 7f000001:30001
Date: Fri, 1 Sep 2006 18:54:13 +0200
Message-ID: <20060901165413.GA27120@bigboss.venod.com>
References: <20060901132854.GA25597@bigboss.venod.com>
	<1157127071.5632.59.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJCHj-0004A6-Pj
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:54:27 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJCHi-0004ju-5E
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:54:28 -0700
Received: from mail-mx1.uio.no ([129.240.10.29])
	by pat.uio.no with esmtp (Exim 4.43) id 1GJCHb-0007CK-Pb
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 18:54:19 +0200
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1157127071.5632.59.camel@localhost>
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

[Trond Myklebust]

> On Fri, 2006-09-01 at 15:28 +0200, Haakon Riiser wrote:

>>   lockd: rejected NSM callback from 7f000001:30001

> This is very intentional. The kernel won't accept notifications
> from unprivileged ports. If it did, then any local user would
> be able to trick the kernel into thinking that some server had
> rebooted, by sending the appropriate RPC message.
> Change your /etc/sysconfig/nfs so that it sets a value < 1024
> for STATD_OUTGOING_PORT.

Strange that I didn't see this error before, and that I picked
a port number this high if the random port assignments were
below 1024.  Back when I decided to use fixed port assignments
(in a possibly misguided attempt at improving security), I tried
to pick numbers that stayed close to the random assignments.

Anyway, thanks for the quick response.  Either I'll assign a
privileged port, or I'll do away with fixed port assignments and
the associated firewall rules entirely.

-- 
 Haakon

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
