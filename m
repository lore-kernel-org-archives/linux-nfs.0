From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Q: How can I run nfs-utils on MIPS
	uclibc-based	distro	with kernel 2.6?
Date: Wed, 04 Jan 2006 13:43:16 +0100
Message-ID: <1136378596.31785.53.camel@lade.trondhjem.org>
References: <20060104123138.2682.qmail@hoster903.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eu7zL-0006iO-TJ
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 04:43:35 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Eu7zJ-00076V-An
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 04:43:35 -0800
To: linux <linux@karasik.org>
In-Reply-To: <20060104123138.2682.qmail@hoster903.com>
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

On Wed, 2006-01-04 at 12:31 +0000, linux wrote:
> >  > Well, NFS server starts and  runs when I use nfs-utils v.1.0.1 with kernel 2.6 (BTW, I compiled nfs-utils without nfsv4 support).
> >  > But it runs so slowly and produces tons of errors...
> >  > I see two potencial sources for this problem:
> >  > - bugs in nfs kernel code in my kernel version (2.6.12)
> >  > - interoperability problems between old nfs-utils and new kernel
> >  
> >  A list of the nfsd errors that you see might help...
> I sent "dmesg" output in my previous letter (http://sourceforge.net/mailarchive/forum.php?thread_id=9380678&forum_id=4930)
>   
> >  As I said, though, the error you listed earlier looks to be a kernel
> >  bug. It has nothing at all to do with nfs-utils.
> I'm not  enough familiar with a calls between user- and kernel-space parts of NFS server, so I just suspect that  2.4 and 2.6 kernels have some differences in NFS API...

No. That trace shows clearly that this is a kernel bug, and as I said,
it looks as if your network card driver might be to blame (something in
that call path has called local_bh_enable without a matching call to
local_bh_disable).

Cheers
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
