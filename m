From: "Phil Endecott" <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>
Subject: Re: Propagation of changes in shared mmap()ed NFS files
Date: Sun, 22 Jun 2008 13:09:44 +0100
Message-ID: <1214136584741@dmwebmail.dmwebmail.chezphil.org>
References: <1214086372.7493.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; format="flowed"
Cc: <linux-nfs@vger.kernel.org>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from japan.chezphil.org ([77.240.5.4]:3942 "EHLO japan.chezphil.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751637AbYFVMJs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Jun 2008 08:09:48 -0400
Received: from localhost ([127.0.0.1] helo=chezphil.org)
	by japan.chezphil.org with esmtp (Exim 4.69)
	(envelope-from <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>)
	id 1KAOOA-0000LP-RI
	for linux-nfs@vger.kernel.org; Sun, 22 Jun 2008 13:09:46 +0100
In-Reply-To: <1214086372.7493.9.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
>> > On Sat, 2008-06-21 at 20:05 +0100, Phil Endecott wrote:
>> >> Dear Experts,
>> >> 
>> >> I have a program which uses an mmap()ed read-mostly data file.  When 
>> >> not using NFS, each instance of the program can use inotify to detect 
>> >> when other instances have made changes to the data file.  Since inotify 
>> >> doesn't work with NFS, I have now implemented a scheme using network 
>> >> broadcasts to announce changes.  At present it works like this:
>> >> 
>> >> All instances of the program mmap(MAP_SHARED) the data file.
>> >> 
>> >> One instance stores some new data at the end of the file and calls 
>> >> msync(MS_SYNC) on the affected pages.  It then "atomically commits" the 
>> >> new data by write()ing a new header at the start of the file with an 
>> >> "end of data" field advanced to include the new data.  It then calls 
>> >> fdatasync().  Then it transmits a broadcast packet.
>> >> 
>> >> The other instance(s) of the program receive the broadcast packet and 
>> >> read() the header at the start of the file.  My hope was that they 
>> >> would see the new value, but they don't; they continue to see the old value.

> You shouldn't use mmap() to read data in this situation. mmap() is
> designed for cases where the authoritative copy of the data can be kept
> in local memory.
> In your situation, the authoritative copy is always on disk (or the NFS
> server), and so the correct paradigm is to use O_DIRECT read() and
> write() or to use POSIX file locking. The latter allows the NFS clients
> to do the read()/write() synchronisation for you, whereas the former
> assumes that you are doing some other form of locking to ensure
> synchronisation between readers and writers.

Hmmm.  OK.   But mmap(MAP_SHARED) does exactly what I want in the more 
common case where the files are not on NFS; I can have multiple 
instances of the program and only one RAM copy of the data is needed, 
and changes made by one instance are immediately visible to the 
others.  The problem is that the NFS implementation of mmap(MAP_SHARED) 
doesn't match the behaviour of the non-NFS version.

It looks to me as if the writer does the right thing: after it modifies 
pages they are written back to the server when I call msync().  But, 
IIUC, the server has no way to inform the other clients that those 
pages are modified.  Instead, the clients will revalidate with the 
server after some timeout; this revalidation is not per-page but 
per-file, so the server will tell them that the whole file has changed 
and the clients will invalidate all of their pages.  Is this true?

So: is there anything that I can do on the client to say:

- "even though the timeout hasn't expired, invalidate these cached 
pages now"?
- "even though the timeout has expired, and the server says that the 
file has changed, keep using your cached copies of these pages"?


Phil.




