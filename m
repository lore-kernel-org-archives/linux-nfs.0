From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv3 and SYNC option
Date: Mon, 17 Jul 2006 08:05:05 -0400
Message-ID: <1153137905.5835.11.camel@localhost>
References: <20060717091137.62C9221400D@rekin14.go2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2Rqm-0007JN-2q
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 05:05:24 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G2Rqh-0007xy-W6
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 05:05:24 -0700
To: przemyslaw_sowa@o2.pl
In-Reply-To: <20060717091137.62C9221400D@rekin14.go2.pl>
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

On Mon, 2006-07-17 at 11:11 +0200, przemyslaw_sowa@o2.pl wrote:
> Hello,
> 
> I'd like to know if the "sync" option in /etc/exports makes NFSv3 works
> like NFSv2? I mean if it then always waits for the data to be written to
> the drive before sending reply?

No. The 'sync' option just ensures that all RPC calls that require data
to be put to stable storage are honoured. The result is that you should
be guaranteed correct recovery semantics in case of a server
crash/reboot (which is what you want).

> If not, is there any way to guarantee stable storage on the server (v3)
> side (ex. client can mount with the async option)?

Yes. NFSv3 has protocol support for safe server-side cached writes (this
is the main reason why NFSv3 is considered to be faster than NFSv2). By
"safe", I mean that there is no loss of data in the case of a server
crash/reboot.
This caching behaviour is enabled by default: no need for additional
mount options.

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
