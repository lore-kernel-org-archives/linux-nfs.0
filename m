From: Helge Bahmann <hcb@chaoticmind.net>
Subject: Re: NFSv3 server: lockd hangs
Date: Thu, 19 Oct 2006 16:14:33 +0200 (CEST)
Message-ID: <Pine.LNX.4.44.0610191558030.13593-100000@lothlorien.local>
References: <1161264623.28834.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaYfa-0006zb-JD
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 07:14:52 -0700
Received: from m4s07.vlinux.de ([83.151.27.105])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1GaYfX-0007eP-7e
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 07:14:51 -0700
Received: from pd95de5d9.dip.t-dialin.net ([217.93.229.217]
	helo=lothlorien.local)
	by m4s07.vlinux.de with asmtp (Exim 3.35 #1 (Debian))
	id 1GaYfP-0005Fs-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Oct 2006 16:14:39 +0200
Received: from helge (helo=localhost)
	by lothlorien.local with local-esmtp (Exim 4.50) id 1GaYfJ-0003Xn-PJ
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 16:14:33 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <1161264623.28834.6.camel@lade.trondhjem.org>
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

> > Is there also a known problem with NFSv3 file locking and sec=krb5 mounts?
[snip]
> > Is there something I could do to diagnose the problem once the problem
> > starts appearing?
>
> cat /proc/locks on both the client and server. The 5th column there
> should be in the form 'device_major:device_minor:inode_number'. See if
> you can find a match for the file that is not supposed to be locked.

it just happened again; output from /proc/locks on the NFS client (only
for the relevant file):
1: POSIX  ADVISORY  WRITE 30962 00:16:976311 0 EOF

and again on the the server:
9: POSIX  ADVISORY  READ  30183 fe:09:976311 0 EOF
9: -> POSIX  ADVISORY  WRITE 30962 fe:09:976311 0 EOF

sure enough 30183 was the pid of (one of the) processes on the NFS client
that previously had the file locked (there is only one client machine ever
accessing that file); however there is no process (or thread, for that
matter) with the pid 30183 on the client anymore

it seems there is one program that reliably triggers the problem
(kcminit); I think I can now reproduce it -- what kind of traces
should I take to produce useful information?

Thanks and best regards
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
