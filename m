From: Morten Sylvest Olsen <mso@medical-insight.com>
Subject: Re: File corruption linux 2.4 nfs client to freebsd server
Date: 19 Nov 2003 17:41:39 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1069260099.2348.14.camel@krypton.medical-insight.com>
References: <1069235928.1215.79.camel@krypton.medical-insight.com>
	 <shs8ymcs72u.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMVOg-0004ZX-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 08:41:42 -0800
Received: from [62.242.251.241] (helo=arsenium.medical-insight.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AMVOg-0000og-3y
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 08:41:42 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs8ymcs72u.fsf@charged.uio.no>
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

ons, 2003-11-19 kl. 16:37 skrev Trond Myklebust:
> >>>>> " " == Morten Sylvest Olsen <mso@medical-insight.com> writes:
> 
>      > I hope somebody have an idea of what goes wrong.
> 
> Have you tried running memtest86 (see http://www.memtest86.com/)? If
> you are seeing gcc internal errors, then that is usually the very
> first thing you want to do.
> 
> If you machine passes memtest86, then try downloading fsx-linux
> (http://www.codemonkey.org.uk/cruft/fsx-linux.c) and running
> that. That should be able to give a more precise picture of what is
> going wrong ("File shrank by 0 bytes" isn't one of the usual kernel
> errors 8-)).

Yeah, sorry thats not very clear I guess.. :) I didn't really have a
small test-case, and had forgot about the filesystem exerciser.

I have a range of clients, from laptops to 3 identical IBM
Intellistations, which all exhibit the behavior. (which have ECC memory,
although thats probably no guarantee). I guess the gcc internal error
stems from it not responding well to I/O errors. 

There are no quotas on the server, and no kernel messages or anything to
indicate disk trouble. I can run fsx locally and over a loopback nfs
mount on the server without errors.

I can reproduce the problem on the clients using fsx. The error occurs
after 25407 fsx operations with an I/O error, with no difference between
test file and fsxgood file. (default options to fsx)

- Morten
-- 
Morten Sylvest Olsen
System Developer

Medical Insight A/S
Hovedgaden 451 C
DK-2640 Hedehusene, Denmark
Phone: +45-46550444, Mobile: +45-51573092
E-mail: mso@medical-insight.com



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
