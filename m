From: =?ISO-8859-1?Q?Ga=EBl_Roualland?= <gael.roualland@oleane.net>
Subject: Re: NFS write speed and file permissions (2.6.0-test10 kernel)
Date: Wed, 26 Nov 2003 04:19:26 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0311260406050.1383-100000@oleane.net>
References: <200311260305.hAQ354Hi001376@hal.oleane.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AOqDJ-0001Ll-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Nov 2003 19:19:37 -0800
Received: from hal.oleane.net ([62.161.136.5])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AOqDI-00020o-PT
	for nfs@lists.sourceforge.net; Tue, 25 Nov 2003 19:19:36 -0800
To: Stephen Beahm <stephenbeahm@adelphia.net>
In-Reply-To: <200311260305.hAQ354Hi001376@hal.oleane.net>
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

Stephen Beahm a =E9crit :
> I am seeing huge speed differences in NFS file writes based on file
> permissions.
>
> create a test file:
> dd if=3D/dev/zero of=3Dtestfile bs=3D4k count=3D65535
>
> chmod 664 testfile
> time cp testfile /mnt/gwpub
> real    0m36.818s
> user    0m0.018s
> sys     0m2.574s
>
> chmod 755 testfile
> time cp testfile /mnt/gwpub
> real    4m6.056s
> user    0m0.054s
> sys     0m5.835s
>
>
> I can consistently reproduce this problem with a 2.6.0-test9 or 2.6.0-
> test10 kernel on the client side. There does not seem to be any
> problems here with a 2.4.22 kernel. Reading does not seem to be
> affected, only writes. Neither export nor mount options make a
> difference. If the test is performed as root, all is fast.
>
> I am using NFSv3 and nfs-utils-1.06.
>
> This is only an observation and not mean anything:
> using a 2.4.22 client, open() does not pass any mode,
> but a 2.6.0-testX client does this: open("/mnt/gwpub/testfile",
> O_WRONLY|O_CREAT|O_LARGEFILE, 0100755)

I'm experiencing the exact same problem with 2.6.0-test10 as NFS client
and a FreeBSD server, in NFSv2 and NFSv3.

Looking at the network dumps, it looks like writes are being done
synchronously when the file permissions is 755, just as if O_SYNC
was set. Also, when open is called with perm 0755, the CREATE call is
passed a mode of 0100755, but in its reply the server only aknowledges
0755, while when open is called with 0644, CREATE is passed
exactly that and the server agrees. I don't know if that matters,
though...

Ga=EBl.

--=20
Ga=EBl Roualland -+- gael.roualland@oleane.net



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
