From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: mountd gives "illegal port"
Date: Wed, 27 Oct 2004 12:39:10 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041027163910.GB4292@fieldses.org>
References: <20041027124228.GJ4724@fi.muni.cz> <20041027154548.GA4292@fieldses.org> <20041027162321.GD4333@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMqpG-00069f-3c
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 09:39:06 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CMqpE-0001VL-K9
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 09:39:06 -0700
To: Jan Kasprzak <kas@fi.muni.cz>
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

On Wed, Oct 27, 2004 at 06:23:22PM +0200, Jan Kasprzak wrote:
> J. Bruce Fields wrote:
> : On Wed, Oct 27, 2004 at 02:42:28PM +0200, Jan Kasprzak wrote:
> : > I have discovered the following problem in Linux NFS: When you mount
> : > many filesystems from the same server, mountd sometimes refuses the
> : > request with "illegal port" message in syslog. To reproduce this, I did
> : > the following:
> : 
> : Just add the "insecure" export option to the server's export.
> : 
> 	Of course, but I don't want to do this.

Why not?

> The problem is that client is querying portmap over TCP and from
> privileged port. By changing this we can use twice as much mounts in
> the TIME_WAIT period.

OK.  It seems like kind of an obscure thing to care about....

> We may also force mount to query mountd over UDP, but I don't know how
> to do this.  -o udp is probably for nfsd traffic, isn't it?

That's what I'd assume, but I don't know.--b.


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
