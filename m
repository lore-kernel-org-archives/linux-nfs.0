From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS mount count is incremented incorrectly
Date: Fri, 15 Aug 2003 11:17:42 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16188.13494.650071.936039@gargle.gargle.HOWL>
References: <20030814132006.7C2A.KAKMY@mvh.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: util-linux@math.uio.no,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19nTEP-0005Id-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Aug 2003 18:18:17 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <kakmy@mvh.biglobe.ne.jp>) (for <util-linux@math.uio.no>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 15 Aug 2003 11:17:47 +1000
To: fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>
In-Reply-To: message from fumihiko kakuma on Thursday August 14
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

On Thursday August 14, kakmy@mvh.biglobe.ne.jp wrote:
> Hello
> 
> We assume that an NFS client tries to mount a filesystem
> on an NFS server.
> A mount count in /var/lib/nfs/rmtab may be incremented
> even when a mount command fails.
> 

It is possible that mount could be modified to do a slightly better
job of keeping this count right, but it is really a loosing battle.

The MOUNT protocol is simply not a reliable way to keep rmtab exactly
correct.  Tinkering may improve the situation but it can never make it
perfect.

You really should think of rmtab as a list of client how have had
filesystems mounted in the past, and may still have them mounted.
It is no more precise than that.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
