From: "ian sison (mailing list)" <ian.s@qsr.com.ph>
Subject: An NFS-HA HOWTO anyone? WAS> Re: Stopping NFS, ip address take
 over, zero-copy NFS for 2.4.21, and misc
Date: Sat, 20 Sep 2003 18:22:56 +0800 (PHT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33L2.0309201819250.29042-100000@jeprox.qsr.com.ph>
References: <291.3f6ac6ae.b6b79@altium.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A0erj-0006bf-00
	for <nfs@lists.sourceforge.net>; Sat, 20 Sep 2003 03:21:23 -0700
Received: from [202.8.246.187] (helo=jeprox.qsr.com.ph ident=ysywtk)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A0erf-0001WQ-Ll
	for nfs@lists.sourceforge.net; Sat, 20 Sep 2003 03:21:19 -0700
Received: from localhost (localhost [127.0.0.1])
	by jeprox.qsr.com.ph (Postfix) with ESMTP id 030F0256D3
	for <nfs@lists.sourceforge.net>; Sat, 20 Sep 2003 18:22:59 +0800 (PHT)
Received: from jeprox.qsr.com.ph ([127.0.0.1])
 by localhost (jeprox.qsr.com.ph [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 23036-08 for <nfs@lists.sourceforge.net>;
 Sat, 20 Sep 2003 18:22:56 +0800 (PHT)
Received: from localhost (localhost [127.0.0.1])
	by jeprox.qsr.com.ph (Postfix) with ESMTP id 9B32D256C9
	for <nfs@lists.sourceforge.net>; Sat, 20 Sep 2003 18:22:56 +0800 (PHT)
To: <nfs@lists.sourceforge.net>
In-Reply-To: <291.3f6ac6ae.b6b79@altium.nl>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


On Fri, 19 Sep 2003 rnews@tasking.nl wrote:

> Chris Worley <cworley@lnxi.com> wrote:
> | 2) IP address takeover between NFS servers.
> |
> | With NFS stateless, and not running lock servers, I thought a simple IP
> | address takeover scheme (when an I/O server goes down, another just adds
> | the failed server's IP address as a virtual interface) would allow
> | clients to immediately renegotiate with the same IP address pointing to
> | another NFS server (serving the same partitions).  The take-over is
> | successful: the clients can communicate with the new I/O server, but I
> | get "permission denied" (as root or otherwise) on the NFS mounted
> | partitions most of the time (sometimes it works).
>
> You need to migrate the entries in /var/lib/nfs/rmtab to the new
> machine. Also, when the device number on the new machine differs
> from the device number on the old machine, you need to use the "fsid"
> option in /etc/exports, to make sure the file handles don't change.

This is important information, and it should go into a howto. NFS-HA is a
very common requirement nowadays, and there's very little information i've
seen on the net except for the Mission Critical Linux site.





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
