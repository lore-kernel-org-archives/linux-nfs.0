From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS client write performance issue ... thoughts?
Date: Mon, 5 Jan 2004 23:34:42 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16378.15074.348051.673492@guts.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Adivl-0004tc-54
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 20:35:01 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Adivk-0001Ps-NG
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 20:35:00 -0800
Received: from mail-mx4.uio.no ([129.240.10.45])
	by pat.uio.no with esmtp (Exim 4.20)
	id 1Adivc-0006hY-Fs
	for nfs@lists.sourceforge.net; Tue, 06 Jan 2004 05:34:52 +0100
Received: from ulrik.uio.no ([129.240.12.4])
	by mail-mx4.uio.no with esmtp (Exim 4.14)
	id 1AdivY-0007Zc-AH
	for nfs@lists.sourceforge.net; Tue, 06 Jan 2004 05:34:48 +0100
Received: from guts.uio.no ([129.240.87.181])
	by ulrik.uio.no with esmtp (Exim 2.12 #7)
	id 1AdivX-00050E-00
	for nfs@lists.sourceforge.net; Tue, 6 Jan 2004 05:34:47 +0100
Received: from trondmy by guts.uio.no with local (Exim 4.22)
	id 1AdivX-00079h-Sp
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 22:34:47 -0600
To: nfs@lists.sourceforge.net
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


På må , 05/01/2004 klokka 17:11, skreiv Paul Smith:
> Hi all; we've been doing some examination of NFS client performance, and
> have seen this apparently sub-optimal behavior: anyone here have any
> comments on this observation or thoughts about it?

Does your observation include numbers, or is it just conjecture?

If we actually are doing contiguous sequential writes, the Linux
implementation has the obvious advantage that it doesn't issue any
read requests to the server at all.

The Solaris approach is only a win in the particular case where you
are doing several non-contiguous writes into the same page (and
without any byte-range locking).
Note that like Linux, two processes that do not share the same RPC
credentials still cannot merge their writes since you cannot rely on
them having the same file write permissions.

Looking at your particular example of GDBM, you should recall that
Solaris is forced to revert to uncached synchronous reads and writes
when doing byte range locking precisely because their page cache
writes back entire pages (the ugly alternative would be to demand that
byte range locks must be page-aligned).
OTOH Linux can continue to do cached asynchronous reads and writes
right up until the user forces an fsync()+cache invalidation by
changing the locking range because our page cache writes are not
required to be page aligned.

However, GDBM is a pretty poor example of a database. Large
professional databases will tend to want to use their own custom
locking protocols, and manage their caching entirely on their own
(using O_DIRECT in order to circumvent the kernel page cache). The
asynchronous read/write code doesn't apply at all in this case.


Finally, please note that you can actually obtain the Solaris
behaviour on the existing Linux NFS client, if you so desire, by
replacing write() with mmap().

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
