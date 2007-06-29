From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: Status of NFS over IPv6
Date: Sat, 30 Jun 2007 00:27:46 +0200
Message-ID: <20070629222746.GA5413@uio.no>
References: <20070629123747.GA1034@uio.no> <46858153.8060109@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I4OwR-0001fv-9F
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 15:27:51 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I4OwT-0002FM-Ea
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 15:27:54 -0700
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1I4OwM-0004CZ-S1
	for nfs@lists.sourceforge.net; Sat, 30 Jun 2007 00:27:47 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1I4OwM-0001Pr-00
	for <nfs@lists.sourceforge.net>; Sat, 30 Jun 2007 00:27:46 +0200
In-Reply-To: <46858153.8060109@oracle.com>
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

On Fri, Jun 29, 2007 at 06:01:55PM -0400, Chuck Lever wrote:
> I have some patches that add IPv6 support in the RPC client.  The server 
> is more complicated (how to deal with address-based export rules, and so 
> on).  There hasn't been much progress on the server side, but I think 
> Bull is still working on that.

OK, and they still conflict?

> [snip other useful info, thanks]

> While there is some interest in IPv6 among some of Linux's corporate 
> sponsors, there really isn't an overwhelming "killer" requirement for 
> IPv6, so there isn't much motivation to get all this completed.  I have 
> to admit I'm pretty burned out on all this because of how complicated it 
> has all become.  I'd be happy if someone stepped forward and volunteered 
> to help or take over the integration.

Well, all I can really provide is a useful test bed inside Debian. I doubt I
can get the kernel team to include NFS/IPv6-specific patches, but when it
comes to rpcbind, nfs-utils and the like, I'm sure we can work something out.
IOW, I don't think I can do much about the programming, but once stuff is
"80% there" we can at least provide an environment users can test stuff
relatively easy inside. (We already have quite good NFSv4 support
out-of-the-box.)

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
