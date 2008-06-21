From: "Phil Endecott" <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>
Subject: Re: Propagation of changes in shared mmap()ed NFS files
Date: Sat, 21 Jun 2008 23:02:37 +0100
Message-ID: <1214085757714@dmwebmail.dmwebmail.chezphil.org>
References: <1214084624.7493.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; format="flowed"
Cc: <linux-nfs@vger.kernel.org>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from japan.chezphil.org ([77.240.5.4]:2789 "EHLO japan.chezphil.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752282AbYFUWCk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 21 Jun 2008 18:02:40 -0400
Received: from localhost ([127.0.0.1] helo=chezphil.org)
	by japan.chezphil.org with esmtp (Exim 4.69)
	(envelope-from <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>)
	id 1KABAM-0005Is-Up
	for linux-nfs@vger.kernel.org; Sat, 21 Jun 2008 23:02:39 +0100
In-Reply-To: <1214084624.7493.0.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Sat, 2008-06-21 at 20:05 +0100, Phil Endecott wrote:
>> Dear Experts,
>> 
>> I have a program which uses an mmap()ed read-mostly data file.  When 
>> not using NFS, each instance of the program can use inotify to detect 
>> when other instances have made changes to the data file.  Since inotify 
>> doesn't work with NFS, I have now implemented a scheme using network 
>> broadcasts to announce changes.  At present it works like this:
>> 
>> All instances of the program mmap(MAP_SHARED) the data file.
>> 
>> One instance stores some new data at the end of the file and calls 
>> msync(MS_SYNC) on the affected pages.  It then "atomically commits" the 
>> new data by write()ing a new header at the start of the file with an 
>> "end of data" field advanced to include the new data.  It then calls 
>> fdatasync().  Then it transmits a broadcast packet.
>> 
>> The other instance(s) of the program receive the broadcast packet and 
>> read() the header at the start of the file.  My hope was that they 
>> would see the new value, but they don't; they continue to see the old value.
>
> open(O_DIRECT) is your friend.

Thanks Trond, I'll give it a try.

This only affects the write()s and read()s though, doesn't it?  So are 
you suggesting that the mmap()ed data is correctly propagated already, 
and only the write-to-read needs fixing?

BTW the man page is a bit discouraging about the combination of 
O_DIRECT and mmap(): "applications should avoid mixing mmap(2) of files 
with direct I/O to the same files."  Fingers crossed....


Phil.




