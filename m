From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: lockd fails to purge blocked NLM_LOCKs
Date: Mon, 4 Aug 2003 15:34:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16173.61548.939819.343488@gargle.gargle.HOWL>
References: <Pine.LNX.4.33.0308011225280.1062-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jY0x-0005h7-00
	for <nfs@lists.sourceforge.net>; Sun, 03 Aug 2003 22:36:11 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <markhe@veritas.com>) (for <trond.myklebust@fys.uio.no>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Mon, 4 Aug 2003 15:36:00 +1000
To: Mark Hemment <markhe@veritas.com>
In-Reply-To: message from Mark Hemment on Friday August 1
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

On Friday August 1, markhe@veritas.com wrote:
>   When stopping server-side NFS, or deleting a client (NFSCTL_DELCLIENT),
> lockd fails to purge blocked lockd requests.

Thanks Mark.  I'm at least largely convinced.

My only question concerns nlmsvc_traverse_blocks.
This uses b_host and you have (subtley) changed the meaning of b_host.

Do we also need to change both occurances of b_host in
nlmsvc_traverse_blocks to b_call.a_host ??

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
