From: Helge Bahmann <hcb@chaoticmind.net>
Subject: Re: NFS over localhost?
Date: Mon, 5 Dec 2005 16:41:57 +0100 (CET)
Message-ID: <Pine.LNX.4.44.0512051623290.19000-100000@lothlorien.local>
References: <1133788419.8027.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EjITZ-0005HP-F3
	for nfs@lists.sourceforge.net; Mon, 05 Dec 2005 07:42:01 -0800
Received: from m4s07.vlinux.de ([83.151.27.105])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1EjITW-0007mV-TD
	for nfs@lists.sourceforge.net; Mon, 05 Dec 2005 07:42:01 -0800
Received: from p54b4e15f.dip.t-dialin.net ([84.180.225.95] helo=lothlorien.local)
	by m4s07.vlinux.de with asmtp (Exim 3.35 #1 (Debian))
	id 1EjITS-0000NC-00
	for <nfs@lists.sourceforge.net>; Mon, 05 Dec 2005 16:41:54 +0100
Received: from helge (helo=localhost)
	by lothlorien.local with local-esmtp (Exim 3.35 #1 (Debian))
	id 1EjITV-0004yH-00
	for <nfs@lists.sourceforge.net>; Mon, 05 Dec 2005 16:41:57 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <1133788419.8027.24.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, 5 Dec 2005 Trond Myklebust wrote:

> No, that kind of deadlock is not _supposed_ to happen, but it is very
> hard to avoid. Doing loopback mounts will always confuse the VM.

okay I understand... "Don't do that" then, at least for the moment.

> A setup in which client and server are not the same should be a lot more
> stable, but there are scenarios where deadlocks can occur there too.

The way you phrased it really bothers me because it almost sounds like
"expect some completely random lockups and deal with them" :) Could you
narrow down a little bit more under what conditions such deadlocks can
occur?

e.g. something like "it can only happen if the clients are generating
writes faster than the server can commit to disk AND the server does have
insufficient RAM to handle a load spike" would be very reassuring.

Thanks and best regards
-- 
Helge Bahmann <hcb@chaoticmind.net>                     /| \__
The past: Smart users in front of dumb terminals       /_|____\
                                                     _/\ |   __)
$ ./configure                                        \\ \|__/__|
checking whether build environment is sane... yes     \\/___/ |
checking for AIX... no (we already did this)            |




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
