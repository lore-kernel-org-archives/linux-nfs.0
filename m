From: Peter Astrand <peter@cendio.se>
Subject: Re: mountd gives "illegal port"
Date: Wed, 27 Oct 2004 20:28:15 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0410272016420.3713-100000@maggie.lkpg.cendio.se>
References: <20041027162321.GD4333@fi.muni.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMsX2-0004lc-OI
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 11:28:24 -0700
Received: from tl.cendio.se ([193.12.253.68] helo=mail.cendio.se)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CMsWy-0002d3-2b
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 11:28:24 -0700
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 9EA4D25DA36
	for <nfs@lists.sourceforge.net>; Wed, 27 Oct 2004 20:28:15 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20041027162321.GD4333@fi.muni.cz>
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

On Wed, 27 Oct 2004, Jan Kasprzak wrote:

> 	Of course, but I don't want to do this. The problem is that client
> is querying portmap over TCP and from privileged port. By changing this
> we can use twice as much mounts in the TIME_WAIT period. We may also
> force mount to query mountd over UDP, but I don't know how to do this.
> -o udp is probably for nfsd traffic, isn't it?

As far as I know, this has never been documented. This is somewhat related
to the Fedora bug 128100: Even if you specify -o tcp, port= and
mountport=, the mount command tries to "autodetect" if it should use TCP
or UDP for the MOUNT protocol by contacting the portmapper (which fails in 
many cases, if you use SSH tunnels, for example). 

Most people nowadays have realized that it was a mistake to separate the 
NFS and the MOUNT protocol. It's much more convenient to run them on the 
same port, using the same transport. With the current mountd/knfsd 
implementation it might be a little hard to use the same port number, but 
with unfsd, for example, it's easy to use the same port. Using the same 
transport type, though, is easy. 
 
So, my opinion is that you should either use TCP for both the NFS and 
MOUNT protocol, or UDP for both. 

Perhaps this "illegal port" problem can be solved by making the mount 
command use SO_REUSEADDR?


-- 
Peter Åstrand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Linköping        Phone: +46-13-21 46 00



-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
