From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: I have two Linux ( 2.6.8 ?)   NFS client/server problems
Date: Tue, 12 Oct 2004 00:24:27 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097533466.6599.78.camel@lade.trondhjem.org>
References: <20041011.141946.8277.9770@webmail11.lax.untd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CH8au-00049y-ED
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 15:24:40 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CH8as-0001wF-WF
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 15:24:40 -0700
To: Alexander Povolotsky <pevnev@juno.com>
In-Reply-To: <20041011.141946.8277.9770@webmail11.lax.untd.com>
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

P=E5 m=E5 , 11/10/2004 klokka 23:19, skreiv Alexander Povolotsky:

> # cd /fadsroot
> #sbin/pivot_root /fadsroot /tmp
> pivot_root: pivot_root: Device or resource busy

What does this have to do with NFS?

man pivot_root.
        EBUSY: new_root or put_old are on the current root file=20
        system,  or  a file system is already mounted on put_old.

Have you tried the form recommended by the manpage?

  pivot_root . /tmp

Trond



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
