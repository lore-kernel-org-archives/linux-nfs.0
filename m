Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:49699 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751549AbZCMTQ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Mar 2009 15:16:59 -0400
Subject: Re: Best A->B large file copy performance
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jim Callahan <callahan@temerity.us>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <49B9780B.2020609@temerity.us>
References: <49B9780B.2020609@temerity.us>
Content-Type: text/plain
Date: Fri, 13 Mar 2009 15:16:53 -0400
Message-Id: <1236971813.7265.23.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2009-03-12 at 17:00 -0400, Jim Callahan wrote:
> I'm trying to determine the most optimal way to have a single NFS client 
> copy large numbers (100-1000) of fairly large (1-50M) files from one 
> location on an file server to another location on the same file server.  
> There seem to be several API layers which influence this:
> 
> 1. Number of OS level processes performing the copy in parallel.
> 2. Record size used buy the C-library read()/write() calls from these 
> processes.
> 3. NFS client rsize/wsize settings.
> 4. Ethernet MTU size.
> 5. Bandwidth of the ethernet network and switches.
> 
> So far we've played around with larger MTU and rsize/wsize settings 
> without seeing a huge difference.  Since we have been using "cp" to 
> perform (1), we've not tweaked the record size at all at this point.   
> My suspicion is that we should be carefully coordinating the sizes 
> specified in for the layers 2, 3 and 4.  Perhaps we should be using "dd" 
> instead of "cp" so we can control the record size being used.   Since 
> the number of permutations of these three settings are large I was 
> hoping that I might get some advise from this list about a range of 
> values we should be investigating and any unpleasant interactions 
> between these levels of settings we should be aware of to narrow our 
> search.  Also, if there are other major factors outside those listed I'd 
> appreciate being pointed in the right direction.

MTU, and rsize/wsize settings shouldn't matter much unless you're using
a UDP connection. I'd recommend just using the default r/wsize
negotiated by the client and server, and then whatever MTU is most
convenient for the other applications you may have.

Bandwidth and switch quality do matter (a lot). Particularly so if you
have many clients...

If you're just copying and not interested in using the file or its
contents afterwards, then you might consider using direct i/o instead of
ordinary cached i/o.

> While I'm on the subject, has there been any discussion about adding an 
> NFS request that would allow copying files from one location to another 
> on the same NFS server without requiring a round trip to a client?  Its 
> not at all uncommon to need to move data around in this manner and it 
> seems a huge waste of bandwidth to have to send all this data from the 
> server to the client just to have the client send the data back 
> unaltered to a different location.  Such a COPY request would be high 
> level along the lines of RENAME and each server vendor could optimize 
> this for their particular hardware architecture.  For our particular 
> application, having such a request would make a huge difference in 
> performance.

I don't think anyone has talked about a server-to-server protocol, but I
believe there will be a proposal for file copy at the coming IETF
meeting. If you want server-to-server, then now is the time to speak up
and make the case. You'd probably want to start a thread on
nfsv4@ietf.org...

Cheers
  Trond

