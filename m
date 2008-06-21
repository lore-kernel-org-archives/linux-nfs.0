From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Propagation of changes in shared mmap()ed NFS files
Date: Sat, 21 Jun 2008 17:43:44 -0400
Message-ID: <1214084624.7493.0.camel@localhost>
References: <1214075120367@dmwebmail.dmwebmail.chezphil.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:41033 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753145AbYFUVnt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 21 Jun 2008 17:43:49 -0400
In-Reply-To: <1214075120367-YnoLgZYwwYuCbKHnblo0pmrPP3OPMK55cpQHUIT47Ck@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2008-06-21 at 20:05 +0100, Phil Endecott wrote:
> Dear Experts,
> 
> I have a program which uses an mmap()ed read-mostly data file.  When 
> not using NFS, each instance of the program can use inotify to detect 
> when other instances have made changes to the data file.  Since inotify 
> doesn't work with NFS, I have now implemented a scheme using network 
> broadcasts to announce changes.  At present it works like this:
> 
> All instances of the program mmap(MAP_SHARED) the data file.
> 
> One instance stores some new data at the end of the file and calls 
> msync(MS_SYNC) on the affected pages.  It then "atomically commits" the 
> new data by write()ing a new header at the start of the file with an 
> "end of data" field advanced to include the new data.  It then calls 
> fdatasync().  Then it transmits a broadcast packet.
> 
> The other instance(s) of the program receive the broadcast packet and 
> read() the header at the start of the file.  My hope was that they 
> would see the new value, but they don't; they continue to see the old value.

open(O_DIRECT) is your friend.

Cheers
  Trond

