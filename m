From: "Cole, Timothy D." <tdcole@northropgrumman.com>
Subject: RE: Re: broken umount -f
Date: Tue, 14 Jan 2003 11:30:08 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <7F21D7A9E7D9D51192CB0002A53F93C73C28E5@xcgmd024.md.essd.northgrum.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from xcgmd811.northgrum.com ([155.104.240.101])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YWn5-0003Sn-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 11:32:03 -0800
To: nfs@lists.sourceforge.net
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

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Tuesday, January 14, 2003 14:06
> To: Scott Mcdermott
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] Re: broken umount -f

> Linux will not allow you to unmount without killing those processes,
> and I'd be opposed to any patch that tries to kill active processes
> from within the filesystem.

> This is something that needs to be resolved in userland.

The few times I've needed to use umount -f, the processes in question
weren't killable from userland.  Is there an architectural reason for this?

(i.e. instead of killing them, why can't their pending system calls return
with -EIO if a umount is forced, as I've seen some other unices do in
similar situations [pending RPCs + a dead server pinning a mount]?)


-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
