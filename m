From: "Phil Endecott" <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>
Subject: Propagation of changes in shared mmap()ed NFS files
Date: Sat, 21 Jun 2008 20:05:20 +0100
Message-ID: <1214075120367@dmwebmail.dmwebmail.chezphil.org>
Mime-Version: 1.0
Content-Type: text/plain; format="flowed"
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from japan.chezphil.org ([77.240.5.4]:4687 "EHLO japan.chezphil.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751885AbYFUTeX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 21 Jun 2008 15:34:23 -0400
Received: from localhost ([127.0.0.1] helo=chezphil.org)
	by japan.chezphil.org with esmtp (Exim 4.69)
	(envelope-from <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>)
	id 1KA8On-0001PF-Ca
	for linux-nfs@vger.kernel.org; Sat, 21 Jun 2008 20:05:21 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Experts,

I have a program which uses an mmap()ed read-mostly data file.  When 
not using NFS, each instance of the program can use inotify to detect 
when other instances have made changes to the data file.  Since inotify 
doesn't work with NFS, I have now implemented a scheme using network 
broadcasts to announce changes.  At present it works like this:

All instances of the program mmap(MAP_SHARED) the data file.

One instance stores some new data at the end of the file and calls 
msync(MS_SYNC) on the affected pages.  It then "atomically commits" the 
new data by write()ing a new header at the start of the file with an 
"end of data" field advanced to include the new data.  It then calls 
fdatasync().  Then it transmits a broadcast packet.

The other instance(s) of the program receive the broadcast packet and 
read() the header at the start of the file.  My hope was that they 
would see the new value, but they don't; they continue to see the old value.

In order to allow for network broadcasts being unreliable the 
wait-for-broadcast code has a 30 second timeout; when this timeout next 
expires the program reads the header again and now it sees the new 
end-of-data offset, and the new data in the mapped memory region.

So, what do I have to do so that the new data is visible promptly?  Is 
there more that the sender or the receiver should do to tell the local 
kernel or the NFS server to propagate changes?  For example, does 
msync(MS_INVALIDATE) do anything useful?  Do I simply have to wait for 
some delay after receiving the broadcast?

I have also observed that when the changes are finally noticed, it 
seems that the whole of the multi-megabyte file is re-fetched from the 
server as it is accessed, despite only a few hundred bytes having 
changed.  This is undesirable; is there anything that I can do to 
prevent it?  (I tried calling mlock(), mainly to check that this wasn't 
a memory-pressure problem, but it still seems to re-fetch it.)

Ideally I'd like to have something that will work with any non-ancient 
version of NFS, and perhaps even CIFS too, but for now I'd be happy 
with getting it working on this nfsv3 system.

Many thanks for any advice,

Phil.




