From: Per Olofsson <pelle@dsv.su.se>
Subject: Re: NFSv3+Krb5 and mountd
Date: Mon, 30 Aug 2004 17:45:41 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040830154541.GA3671@nasse>
References: <20040824184138.GB3251@nasse> <Pine.LNX.4.61.0408300238530.2441@fogarty.jakma.org> <20040830020132.GA28919@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Jakma <paul@clubi.ie>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1oLw-0002gD-8m
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 08:45:52 -0700
Received: from amsfep12-int.chello.nl ([213.46.243.18] helo=amsfep20-int.chello.nl)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C1oLu-0001SK-3D
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 08:45:52 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040830020132.GA28919@fieldses.org>
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

J. Bruce Fields:
> This doesn't fix the problem Per Olofsson describes, which is that
> unless you use nfsv4, there's no way to export to krb5 without also
> exporting vi auth_sys.
> 
> Since mountd itself doesn't currently have rpcsec_gss support (and, on
> the client side, neither does mount), MOUNT requests are going to use
> auth_sys.  So mountd is going to decide whether to respond based on
> their IP address.
> 
> It'd seem that the right solution is to add rpcsec_gss support to mount
> and mountd, which shouldn't be a big project, so if you export only to
> krb5 then you also answer krb5-protected mount requests.  I don't know
> whether other clients will like that, though.

OK, I understand. I don't really need authenticated mount requests
though, I only need authenticated file system accesses. In other
words, I don't care who mounts the file system as long as they can't
impersonate a user without a valid ticket. Is this easier to
implement? Does it have any other security implications?

-- 
Pelle


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
