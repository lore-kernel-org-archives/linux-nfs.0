Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vps680.inmotionhosting.com ([74.124.198.230]:41664 "EHLO
	vps680.inmotionhosting.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754196AbZCMWkA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2009 18:40:00 -0400
Message-ID: <49BAD2B8.6000005@temerity.us>
Date: Fri, 13 Mar 2009 17:40:08 -0400
From: Jim Callahan <callahan@temerity.us>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: linux-nfs@vger.kernel.org
Subject: Re: Best A->B large file copy performance
References: <49B9780B.2020609@temerity.us> <1236971813.7265.23.camel@heimdal.trondhjem.org>
In-Reply-To: <1236971813.7265.23.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:
> On Thu, 2009-03-12 at 17:00 -0400, Jim Callahan wrote:
>> While I'm on the subject, has there been any discussion about adding an 
>> NFS request that would allow copying files from one location to another 
>> on the same NFS server without requiring a round trip to a client?  Its 
>> not at all uncommon to need to move data around in this manner and it 
>> seems a huge waste of bandwidth to have to send all this data from the 
>> server to the client just to have the client send the data back 
>> unaltered to a different location.  Such a COPY request would be high 
>> level along the lines of RENAME and each server vendor could optimize 
>> this for their particular hardware architecture.  For our particular 
>> application, having such a request would make a huge difference in 
>> performance.
>>     
>
> I don't think anyone has talked about a server-to-server protocol, but I
> believe there will be a proposal for file copy at the coming IETF
> meeting. If you want server-to-server, then now is the time to speak up
> and make the case. You'd probably want to start a thread on
> nfsv4@ietf.org...
>   
Thanks for the responses Trond.  I wasn't actually suggesting a 
server-to-server protocol, but rather an additional client-server 
protocol request to tell the server to copy files internally.   The idea 
being that the typical usage of "cp" via NFS is wasting bandwidth 
transmitting the contents of the source file from the server to client 
only to have the client send it back unaltered.   If this was instead 
performed internally on the server itself, it seems to me that it might 
be dramatically faster and not waste valuable network bandwidth.  The 
calling convention would be identical to the current RENAME request.  
The implementation would of course be different in this new COPY request 
would create a new i-node for the target and then copy all data from he 
source to target file.   A vendor could choose the most efficient manner 
for performing this based on their hardware/software architecture.

Thanks for the pointer to nfsv4@ietf.org.  I'll bring this up there as 
well...

In case you are wondering, we make an application which includes version 
control features somewhat along the lines of CVS or SVN.  In other 
words, there is a central repository for checked-in versions and 
independent scratch areas for users who can have their own copies of 
files.  So both check-in and check-out operations frequently involve 
performing a "cp" from file A to B located on the same NFS server.

-- 
Jim Callahan - President - Temerity Software <www.temerity.us>
