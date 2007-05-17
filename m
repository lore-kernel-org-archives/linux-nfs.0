From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC, PATCH 7/14] knfsd: export svc_sock_enqueue,
 svc_sock_received
Date: Thu, 17 May 2007 08:23:58 -0400
Message-ID: <EXNANE01WXopokhQLVp00000a25@exnane01.hq.netapp.com>
References: <20070516192425.GM9626@sgi.com>
	<20070516211703.GF18927@fieldses.org>
	<20070517074518.GF27247@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hof1Z-0006vt-Gp
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 05:24:05 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hof1b-0000Co-6u
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 05:24:08 -0700
In-Reply-To: <20070517074518.GF27247@sgi.com>
References: <20070516192425.GM9626@sgi.com>
	<20070516211703.GF18927@fieldses.org>
	<20070517074518.GF27247@sgi.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At 03:45 AM 5/17/2007, Greg Banks wrote:
> I was planning
>to add a new file to /proc/fs/nfsd roughly analagous to the ports and
>versions files, where the init script could write a string to indicate
>which transports are enabled or disabled.  Transports would be managed
>in a global list of structures analagous to struct xprt_type in Chuck's
>client patches.

I like this, it seems nearly the same as the /proc/fs/nfsd/thread node
that's in there now. A new /proc/fs/nfsd/protocols node makes sense
to me.

Another option might be to support switches to the nfsd command,
like other os's do (nfsd -u). This makes a lot of sense if the current
#ifdef's to enable nfsd's protocols is retained. If module loading is
supported, I like the dynamic /proc aproach better.

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
