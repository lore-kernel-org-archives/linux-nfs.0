From: Jan Kasprzak <kas@fi.muni.cz>
Subject: Re: mountd gives "illegal port"
Date: Wed, 27 Oct 2004 18:12:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041027161256.GC4333@fi.muni.cz>
References: <20041027124228.GJ4724@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: unix@fi.muni.cz
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMqQP-0004N6-08
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 09:13:25 -0700
Received: from anor.ics.muni.cz ([147.251.4.35] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CMqQO-0007BG-3j
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 09:13:24 -0700
Received: from anxur.fi.muni.cz (IDENT:0@anxur.fi.muni.cz [147.251.48.3])
	by anor.ics.muni.cz (8.12.1/8.12.1) with ESMTP id i9RGDI4k030272
	for <nfs@lists.sourceforge.net>; Wed, 27 Oct 2004 18:13:18 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20041027124228.GJ4724@fi.muni.cz>
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

Jan Kasprzak wrote:
: I have discovered the following problem in Linux NFS: When you mount
: many filesystems from the same server, mountd sometimes refuses the
: request with "illegal port" message in syslog.

	Well, the mountd is probably OK, and it is the client who runs
out of privileged ports. netstat -ta on the client looks like this:

tcp        0      0 nfs-client.fi.muni.cz:880  nfs-server.fi.muni.c:sunrpc TIME_WAIT
tcp        0      0 nfs-client.fi.muni.cz:883  nfs-server.fi.muni.c:sunrpc TIME_WAIT
tcp        0      0 nfs-client.fi.muni.cz:884  nfs-server.fi.muni.c:sunrpc TIME_WAIT
tcp        0      0 nfs-client.fi.muni.cz:887  nfs-server.fi.muni.c:sunrpc TIME_WAIT
tcp        0      0 nfs-client.fi.muni.cz:888  nfs-server.fi.muni.c:sunrpc TIME_WAIT
tcp        0      0 nfs-client.fi.muni.cz:891  nfs-server.fi.muni.c:sunrpc TIME_WAIT
[...]    

	The solution might be to query portmap over UDP from the NFS client
instead of TCP. Or to query portmap from an unprivileged port (why we
send query to portmap from privileged port anyway?).

	 I have even tried echo 2 > /proc/sys/net/ipv4/tcp_fin_timeout,
but this did not solve the problem - connections to server's portmap
remain for 60 seconds in FIN_WAIT.

-Yenya

-- 
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - private}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18A5E |
| http://www.fi.muni.cz/~kas/   Czech Linux Homepage: http://www.linux.cz/ |
> Whatever the Java applications and desktop dances may lead to, Unix will <
> still be pushing the packets around for a quite a while.      --Rob Pike <


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
