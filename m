From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Q: How can I run nfs-utils on MIPS uclibc-based
	distro	with kernel 2.6?
Date: Wed, 04 Jan 2006 13:24:29 +0100
Message-ID: <1136377469.31785.45.camel@lade.trondhjem.org>
References: <20060104113444.6847.qmail@hoster903.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eu7hG-0005XH-0q
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 04:24:54 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Eu7hE-0006Ul-EW
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 04:24:54 -0800
To: linux <linux@karasik.org>
In-Reply-To: <20060104113444.6847.qmail@hoster903.com>
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

On Wed, 2006-01-04 at 11:34 +0000, linux wrote:

> Well, NFS server starts and  runs when I use nfs-utils v.1.0.1 with kernel 2.6 (BTW, I compiled nfs-utils without nfsv4 support).
> But it runs so slowly and produces tons of errors...
> I see two potencial sources for this problem:
> - bugs in nfs kernel code in my kernel version (2.6.12)
> - interoperability problems between old nfs-utils and new kernel

A list of the nfsd errors that you see might help...

As I said, though, the error you listed earlier looks to be a kernel
bug. It has nothing at all to do with nfs-utils.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
