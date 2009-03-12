Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vps680.inmotionhosting.com ([74.124.198.230]:39424 "EHLO
	vps680.inmotionhosting.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751678AbZCLWA4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 18:00:56 -0400
Received: from cpe-98-149-71-108.socal.res.rr.com ([98.149.71.108]:12845 helo=[192.168.2.107])
	by vps680.inmotionhosting.com with esmtpa (Exim 4.63)
	(envelope-from <callahan@temerity.us>)
	id 1LhsxS-0000Oo-KL
	for linux-nfs@vger.kernel.org; Thu, 12 Mar 2009 15:00:54 -0700
Message-ID: <49B9780B.2020609@temerity.us>
Date: Thu, 12 Mar 2009 17:00:59 -0400
From: Jim Callahan <callahan@temerity.us>
To: linux-nfs@vger.kernel.org
Subject: Best A->B large file copy performance
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm trying to determine the most optimal way to have a single NFS client 
copy large numbers (100-1000) of fairly large (1-50M) files from one 
location on an file server to another location on the same file server.  
There seem to be several API layers which influence this:

1. Number of OS level processes performing the copy in parallel.
2. Record size used buy the C-library read()/write() calls from these 
processes.
3. NFS client rsize/wsize settings.
4. Ethernet MTU size.
5. Bandwidth of the ethernet network and switches.

So far we've played around with larger MTU and rsize/wsize settings 
without seeing a huge difference.  Since we have been using "cp" to 
perform (1), we've not tweaked the record size at all at this point.   
My suspicion is that we should be carefully coordinating the sizes 
specified in for the layers 2, 3 and 4.  Perhaps we should be using "dd" 
instead of "cp" so we can control the record size being used.   Since 
the number of permutations of these three settings are large I was 
hoping that I might get some advise from this list about a range of 
values we should be investigating and any unpleasant interactions 
between these levels of settings we should be aware of to narrow our 
search.  Also, if there are other major factors outside those listed I'd 
appreciate being pointed in the right direction.

---

While I'm on the subject, has there been any discussion about adding an 
NFS request that would allow copying files from one location to another 
on the same NFS server without requiring a round trip to a client?  Its 
not at all uncommon to need to move data around in this manner and it 
seems a huge waste of bandwidth to have to send all this data from the 
server to the client just to have the client send the data back 
unaltered to a different location.  Such a COPY request would be high 
level along the lines of RENAME and each server vendor could optimize 
this for their particular hardware architecture.  For our particular 
application, having such a request would make a huge difference in 
performance.

-- 
Jim Callahan - President - Temerity Software <www.temerity.us>
