From: Jan Kasprzak <kas@fi.muni.cz>
Subject: Re: permission denied under load
Date: Thu, 11 Nov 2004 15:58:15 +0100
Message-ID: <20041111145815.GM13905@fi.muni.cz>
References: <41937BBE.5010208@kcp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CSGP1-0000eT-PA
	for nfs@lists.sourceforge.net; Thu, 11 Nov 2004 06:58:23 -0800
Received: from anor.ics.muni.cz ([147.251.4.35] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CSGP0-0001kf-J1
	for nfs@lists.sourceforge.net; Thu, 11 Nov 2004 06:58:23 -0800
To: Michael Haverkamp <mhaverkamp@kcp.com>
In-Reply-To: <41937BBE.5010208@kcp.com>
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

Michael Haverkamp wrote:
: I have a system running Gentoo Linux with a 2.6.9 kernel that is acting 
: as an NFS server for several Solaris 7,8,9 systems.  Everything appears 
: to work fine for a while, but at seemingly random times the clients get 
: "Permission denied" when trying to access a file or directory that they 
: are normally able to access.  This problem may persist for a few 
: minutes, but then everything returns to normal again.  This happens 
: multiple times a day.
: 
	See the list archive from the last week or so - I think this
is an "out of privileged ports" problem. Does by any chance the server
(rpc.mountd in particular) complain about unprivileged ports?

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
