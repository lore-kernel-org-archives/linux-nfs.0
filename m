From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH]
Date: Tue, 19 Aug 2003 08:58:04 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16193.23036.233353.498168@gargle.gargle.HOWL>
References: <Pine.LNX.4.33.0308181207560.1203-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19osx5-0002By-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Aug 2003 15:58:15 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <markhe@veritas.com>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 19 Aug 2003 08:58:08 +1000
To: Mark Hemment <markhe@veritas.com>
In-Reply-To: message from Mark Hemment on Monday August 18
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

On Monday August 18, markhe@veritas.com wrote:
>   For RPC over UDP, after receiving a packet kick another thread as soon
> as possible.  This helps NFS performance.
>   Patch is against 2.6.0-test3.
> 

Yep, I like this.  I'll send it on.

Have you measured any performance improvement, or it is just
theoretical?

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
