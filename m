From: Jan Kasprzak <kas@fi.muni.cz>
Subject: Re: mountd gives "illegal port"
Date: Wed, 27 Oct 2004 18:23:22 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041027162321.GD4333@fi.muni.cz>
References: <20041027124228.GJ4724@fi.muni.cz> <20041027154548.GA4292@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMqaA-00053b-DH
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 09:23:30 -0700
Received: from anor.ics.muni.cz ([147.251.4.35] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CMqa9-0008Bf-HH
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 09:23:30 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20041027154548.GA4292@fieldses.org>
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

J. Bruce Fields wrote:
: On Wed, Oct 27, 2004 at 02:42:28PM +0200, Jan Kasprzak wrote:
: > I have discovered the following problem in Linux NFS: When you mount
: > many filesystems from the same server, mountd sometimes refuses the
: > request with "illegal port" message in syslog. To reproduce this, I did
: > the following:
: 
: Just add the "insecure" export option to the server's export.
: 
	Of course, but I don't want to do this. The problem is that client
is querying portmap over TCP and from privileged port. By changing this
we can use twice as much mounts in the TIME_WAIT period. We may also
force mount to query mountd over UDP, but I don't know how to do this.
-o udp is probably for nfsd traffic, isn't it?

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
