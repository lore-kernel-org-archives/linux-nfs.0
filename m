From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] nfs-utils - 4 of 6 - nfsstat - removed needless warning
Date: Wed, 2 Jul 2003 16:52:50 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16130.33090.338448.760040@gargle.gargle.HOWL>
References: <3EF0A8D9.5070301@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19XbU8-00082Z-00
	for <nfs@lists.sourceforge.net>; Tue, 01 Jul 2003 23:52:57 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <SteveD@redhat.com>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Wed, 2 Jul 2003 16:52:50 +1000
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: message from Steve Dickson on Wednesday June 18
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

On Wednesday June 18, SteveD@redhat.com wrote:
> Reworked the diagnostics of nfsstat so warnings
> are not displayed for statistics that are not
> asked for and don't exist.
> 

I've committed this and the two mountd patches to CVS.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
