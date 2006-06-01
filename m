From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: Fusing Debian patches back into nfs-utils
Date: Fri, 2 Jun 2006 00:09:54 +0200
Message-ID: <20060601220954.GA6739@uio.no>
References: <20060601155929.GA890@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7]
	helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FlvUu-0000hr-C7
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 15:18:32 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1FlvMX-0000rA-2g
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 15:09:53 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FlvMU-0006ZH-5Y
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 15:09:53 -0700
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1FlvMQ-00039z-1B
	for nfs@lists.sourceforge.net; Fri, 02 Jun 2006 00:09:46 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1FlvMY-0001lJ-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Jun 2006 00:09:54 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20060601155929.GA890@uio.no>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Jun 01, 2006 at 05:59:29PM +0200, Steinar H. Gunderson wrote:
>  - fix_anonuid_and_anongid.diff: The current code uses -2 for default
>    anonymous uid and gid, in the hope that it will be equivalent to 65534.
>    However, on systems with 32-bit uids and gids, this returns another value
>    entirely, which gives rise to an unpredictable default uid and gid (which
>    probably doesn't match what's in passwd and group). This patch fixes the
>    code and documentation to use 65534 explicitly instead.

I just noticed this patch is incomplete; you'll also need to make the same
change in utils/exportfs/exportfs.c. The extra patch is trivial, though, but
I missed it the first time. :-)

/* Steinar */
-- 
Homepage: http://www.sesse.net/


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
