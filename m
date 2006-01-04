From: "=?iso-8859-1?Q?linux?=" <linux@karasik.org>
Subject: Re: Q: How can I run nfs-utils on MIPS uclibc-based	distro	with kernel 2.6?
Date: Wed, 04 Jan 2006 12:31:38 +0000
Message-ID: <20060104123138.2682.qmail@hoster903.com>
Reply-To: "=?iso-8859-1?Q?linux?=" <linux@karasik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: "" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eu7nq-0005iV-MU
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 04:31:42 -0800
Received: from hoster903.com ([66.211.137.15])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1Eu7np-000129-C1
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 04:31:42 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

>  > Well, NFS server starts and=A0=A0runs when I use nfs-utils v.1.0.1 w=
ith kernel 2.6 (BTW, I compiled nfs-utils without nfsv4 support).
>  > But it runs so slowly and produces tons of errors...
>  > I see two potencial sources for this problem:
>  > - bugs in nfs kernel code in my kernel version (2.6.12)
>  > - interoperability problems between old nfs-utils and new kernel
> =20
>  A list of the nfsd errors that you see might help...
I sent "dmesg" output in my previous letter (http://sourceforge.net/maila=
rchive/forum.php?thread_id=3D9380678&forum_id=3D4930)
 =20
>  As I said, though, the error you listed earlier looks to be a kernel
>  bug. It has nothing at all to do with nfs-utils.
I'm not  enough familiar with a calls between user- and kernel-space part=
s of NFS server, so I just suspect that  2.4 and 2.6 kernels have some di=
fferences in NFS API...


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
