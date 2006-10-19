From: Helge Bahmann <hcb@chaoticmind.net>
Subject: Re: NFSv3 server: lockd hangs
Date: Thu, 19 Oct 2006 09:56:33 +0200 (CEST)
Message-ID: <Pine.LNX.4.44.0610190943400.12867-100000@lothlorien.local>
References: <1161195658.6095.88.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaSlc-0005F1-Fd
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 00:56:40 -0700
Received: from m4s07.vlinux.de ([83.151.27.105])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1GaSlc-0005Yw-6W
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 00:56:41 -0700
Received: from pd95de5d9.dip.t-dialin.net ([217.93.229.217]
	helo=lothlorien.local)
	by m4s07.vlinux.de with asmtp (Exim 3.35 #1 (Debian))
	id 1GaSlY-0005v3-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Oct 2006 09:56:37 +0200
Received: from helge (helo=localhost)
	by lothlorien.local with local-esmtp (Exim 4.50) id 1GaSlV-0003NN-OJ
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 09:56:33 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <1161195658.6095.88.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> There is a known deadlock in lockd for stock 2.6.17. See the fix at
>
>   http://client.linux-nfs.org/Linux-2.6.x/2.6.18-rc4/linux-2.6.18-011-fix_nlm_traverse_files_deadlock.dif
>
>
> This patch will be included in the next stable release for 2.6.17.

Okay thanks; upgraded to 2.6.18 which apparently contains the fix (and
hopefully no regressions)

Is there also a known problem with NFSv3 file locking and sec=krb5 mounts?
Sometimes a process on the NFS client hangs trying to lock a file which is
definitely *not* locked on any other client -- strange thing is, it
happens only if the same process does more than one lock/unlock cycle, and
it only happens after multiple ticket expiries. However if it has happened
once, it becomes quite reproducable. Rebooting the client fixes the
problem. Rebooting the server does as well.

Is there something I could do to diagnose the problem once the problem
starts appearing?

Thanks again and best regards
-- 
Helge Bahmann <hcb@chaoticmind.net>                     /| \__
The past: Smart users in front of dumb terminals       /_|____\
                                                     _/\ |   __)
Wer im finally-Block sitzt, sollte nicht             \\ \|__/__|
mit exceptions werfen.                                \\/___/ |
                                                        |


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
