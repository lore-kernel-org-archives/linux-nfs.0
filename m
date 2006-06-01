From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: Fusing Debian patches back into nfs-utils
Date: Thu, 1 Jun 2006 22:29:26 +0200
Message-ID: <20060601202926.GA2248@uio.no>
References: <20060601155929.GA890@uio.no> <4d569c330606010942u6900ca96w1795b5a624ea21ee@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FltnQ-0004Mt-Rs
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 13:29:32 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FltnQ-00010O-Hg
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 13:29:32 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FltnJ-0005YJ-8r
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 13:29:29 -0700
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <4d569c330606010942u6900ca96w1795b5a624ea21ee@mail.gmail.com>
Sender: nfs-admin@lists.sourceforge.net
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

On Thu, Jun 01, 2006 at 12:42:47PM -0400, Kevin Coffman wrote:
> There is a similar issue in the svcgssd code.  However, while I was
> looking into this, it appeared that the kernel code uses "-2" in
> places as well.  It seems like a similar change may be needed in the
> kernel code as well?

Hm, that's possible; the change is a bit less critical for svcgssd, though,
as the default configuration file explicitly seems to specify the user
"nobody" (or am I thinking of the wrong user here?).

/* Steinar */
-- 
Homepage: http://www.sesse.net/


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
