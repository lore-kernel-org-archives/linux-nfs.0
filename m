From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: A bug or misconfigured?
Date: Sun, 27 Jul 2003 07:44:47 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16162.63055.324571.428089@gargle.gargle.HOWL>
References: <BAY2-F52l8HvNuSNGDQ00006b25@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19gWqW-0000I4-00
	for <nfs@lists.sourceforge.net>; Sat, 26 Jul 2003 14:44:56 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <adydeac@hotmail.com>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Sun, 27 Jul 2003 07:44:51 +1000
To: "Deac Mihai Adrian" <adydeac@hotmail.com>
In-Reply-To: message from Deac Mihai Adrian on Sunday July 27
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

On Sunday July 27, adydeac@hotmail.com wrote:
> Hi!
> I am using nfs-utils Version 1.0.4. After mounting something (anything) from 
> a client, i get the following line into /var/log/messages:
> rpc.mountd: authenticated mount request from (null):764 for /opt/ltsp/i386 
> (/opt/ltsp/i386)

A bug.  Sorry 'bout that.
Get 1.0.5

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
