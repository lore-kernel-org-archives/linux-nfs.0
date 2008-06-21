From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Propagation of changes in shared mmap()ed NFS files
Date: Sat, 21 Jun 2008 18:12:52 -0400
Message-ID: <1214086372.7493.9.camel@localhost>
References: <1214084624.7493.0.camel@localhost>
	 <1214085757714@dmwebmail.dmwebmail.chezphil.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:42793 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518AbYFUWM4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 21 Jun 2008 18:12:56 -0400
In-Reply-To: <1214085757714-YnoLgZYwwYuCbKHnblo0pmrPP3OPMK55cpQHUIT47Ck@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2008-06-21 at 23:02 +0100, Phil Endecott wrote:
> Trond Myklebust wrote:
> > On Sat, 2008-06-21 at 20:05 +0100, Phil Endecott wrote:
> >> Dear Experts,
> >> 
> >> I have a program which uses an mmap()ed read-mostly data file.  When 
> >> not using NFS, each instance of the program can use inotify to detect 
> >> when other instances have made changes to the data file.  Since inotify 
> >> doesn't work with NFS, I have now implemented a scheme using network 
> >> broadcasts to announce changes.  At present it works like this:
> >> 
> >> All instances of the program mmap(MAP_SHARED) the data file.
> >> 
> >> One instance stores some new data at the end of the file and calls 
> >> msync(MS_SYNC) on the affected pages.  It then "atomically commits" the 
> >> new data by write()ing a new header at the start of the file with an 
> >> "end of data" field advanced to include the new data.  It then calls 
> >> fdatasync().  Then it transmits a broadcast packet.
> >> 
> >> The other instance(s) of the program receive the broadcast packet and 
> >> read() the header at the start of the file.  My hope was that they 
> >> would see the new value, but they don't; they continue to see the old value.
> >
> > open(O_DIRECT) is your friend.
> 
> Thanks Trond, I'll give it a try.
> 
> This only affects the write()s and read()s though, doesn't it?  So are 
> you suggesting that the mmap()ed data is correctly propagated already, 
> and only the write-to-read needs fixing?
> 
> BTW the man page is a bit discouraging about the combination of 
> O_DIRECT and mmap(): "applications should avoid mixing mmap(2) of files 
> with direct I/O to the same files."  Fingers crossed....

You shouldn't use mmap() to read data in this situation. mmap() is
designed for cases where the authoritative copy of the data can be kept
in local memory.
In your situation, the authoritative copy is always on disk (or the NFS
server), and so the correct paradigm is to use O_DIRECT read() and
write() or to use POSIX file locking. The latter allows the NFS clients
to do the read()/write() synchronisation for you, whereas the former
assumes that you are doing some other form of locking to ensure
synchronisation between readers and writers.

Cheers
  Trond

