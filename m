From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] kNFSd: Fixes a problem with inode clean up for
	vxfs
Date: Thu, 7 Aug 2003 09:30:49 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16177.36777.849782.71565@gargle.gargle.HOWL>
References: <3F3128A4.8030305@RedHat.com>
	<1060187198.14950.0.camel@laptop.fenrus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
    nfs@lists.sourceforge.net,
    linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19kXk7-0004IH-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Aug 2003 16:30:56 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <arjanv@redhat.com>) (for <SteveD@redhat.com>)
	(for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By note With Smtp ;
	Thu, 7 Aug 2003 09:30:50 +1000
To: arjanv@redhat.com
In-Reply-To: message from Arjan van de Ven on Wednesday August 6
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

On Wednesday August 6, arjanv@redhat.com wrote:
> On Wed, 2003-08-06 at 18:11, Steve Dickson wrote:
> > , vfat, ntfs
> 
> you can't NFS export vfat..... for lots of other reasons

Have you tried?

It is certainly not bullet-proof, but it works in simple cases (but
probably not in cases where the patch in question becomes an issue).

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
