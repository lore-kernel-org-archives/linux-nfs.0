From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: File corruption linux 2.4 nfs client to freebsd server
Date: 19 Nov 2003 10:37:13 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs8ymcs72u.fsf@charged.uio.no>
References: <1069235928.1215.79.camel@krypton.medical-insight.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMUOQ-0004xA-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 07:37:22 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AMUOP-0006D5-JP
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 07:37:21 -0800
To: Morten Sylvest Olsen <mso@medical-insight.com>
In-Reply-To: <1069235928.1215.79.camel@krypton.medical-insight.com>
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

>>>>> " " == Morten Sylvest Olsen <mso@medical-insight.com> writes:

     > I hope somebody have an idea of what goes wrong.

Have you tried running memtest86 (see http://www.memtest86.com/)? If
you are seeing gcc internal errors, then that is usually the very
first thing you want to do.

If you machine passes memtest86, then try downloading fsx-linux
(http://www.codemonkey.org.uk/cruft/fsx-linux.c) and running
that. That should be able to give a more precise picture of what is
going wrong ("File shrank by 0 bytes" isn't one of the usual kernel
errors 8-)).

The other thing that comes to mind is to check if you've been playing
with setting disk quotas on the server.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
