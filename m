From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
Date: Fri, 29 May 2009 14:29:29 -0400
Message-ID: <1243621769.7155.97.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <41044976-395B-4ED0-BBA1-153FD76BDA53@oracle.com>
	 <OF1B5F174D.1ADF159F-ON852575C5.005FEEB7-852575C5.0060E305@us.ibm.com>
	 <1243618968.7155.60.camel@heimdal.trondhjem.org>
	 <OF4385ED29.7ACEF71B-ON852575C5.00621211-852575C5.00626F39@us.ibm.com>
	 <1243620455.7155.80.camel@heimdal.trondhjem.org>
	 <OFA11F5AE0.259995DA-ON852575C5.0063C023-852575C5.00648F55@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Brian R Cowan <brcowan@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:49464 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752123AbZE2S3g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 May 2009 14:29:36 -0400
In-Reply-To: <OFA11F5AE0.259995DA-ON852575C5.0063C023-852575C5.00648F55@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-29 at 14:18 -0400, Brian R Cowan wrote:
> There is a third option, that the COMMIT calls are not coming from the 
> same thread of execution that the write call is. The symptoms would seem 
> to bear that out. As would the fact that the performance degradation 
> occurs both when the server is Linux itself and when it is Solaris (any 
> NFSv3-supporting version). I'm not saying that Solaris is bug-free, but it 
> would be unusual if they are both broken the same way. The linux nfs FAQ 
> says:
> 
> -----------------------
> * NFS Version 3 introduces the concept of "safe asynchronous writes." A 
> Version 3 client can specify that the server is allowed to reply before it 
> has saved the requested data to disk, permitting the server to gather 
> small NFS write operations into a single efficient disk write operation. A 
> Version 3 client can also specify that the data must be written to disk 
> before the server replies, just like a Version 2 write. The client 
> specifies the type of write by setting the stable_how field in the 
> arguments of each write operation to UNSTABLE to request a safe 
> asynchronous write, and FILE_SYNC for an NFS Version 2 style write.
> 
> Servers indicate whether the requested data is permanently stored by 
> setting a corresponding field in the response to each NFS write operation. 
> A server can respond to an UNSTABLE write request with an UNSTABLE reply 
> or a FILE_SYNC reply, depending on whether or not the requested data 
> resides on permanent storage yet. An NFS protocol-compliant server must 
> respond to a FILE_SYNC request only with a FILE_SYNC reply.
> 
> Clients ensure that data that was written using a safe asynchronous write 
> has been written onto permanent storage using a new operation available in 
> Version 3 called a COMMIT. Servers do not send a response to a COMMIT 
> operation until all data specified in the request has been written to 
> permanent storage. NFS Version 3 clients must protect buffered data that 
> has been written using a safe asynchronous write but not yet committed. If 
> a server reboots before a client has sent an appropriate COMMIT, the 
> server can reply to the eventual COMMIT request in a way that forces the 
> client to resend the original write operation. Version 3 clients use 
> COMMIT operations when flushing safe asynchronous writes to the server 
> during a close(2) or fsync(2) system call, or when encountering memory 
> pressure. 
> -----------------------
> 
> Now, what happens in the client when the server cones back with the 
> UNSTABLE reply?

The server cannot reply with an UNSTABLE reply to a stable write
request. See above.

As for your assertion that the COMMIT comes from some other thread of
execution. I don't see how that can change anything. Some thread,
somewhere has to wait for that COMMIT to complete. If it isn't your
application, then the same burden falls on another application or the
pdflush thread. While that may feel more interactive to you, it still
means that you are making the server + some local process do more work
(extra RPC round trip) for no good reason.

Trond

> =================================================================
> Brian Cowan
> Advisory Software Engineer
> ClearCase Customer Advocacy Group (CAG)
> Rational Software
> IBM Software Group
> 81 Hartwell Ave
> Lexington, MA
>  
> Phone: 1.781.372.3580
> Web: http://www.ibm.com/software/rational/support/
>  
> 
> Please be sure to update your PMR using ESR at 
> http://www-306.ibm.com/software/support/probsub.html or cc all 
> correspondence to sw_support@us.ibm.com to be sure your PMR is updated in 
> case I am not available.
> 
> 
> 
> From:
> Trond Myklebust <trond.myklebust@fys.uio.no>
> To:
> Brian R Cowan/Cupertino/IBM@IBMUS
> Cc:
> Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org, 
> linux-nfs-owner@vger.kernel.org, Peter Staubach <staubach@redhat.com>
> Date:
> 05/29/2009 02:07 PM
> Subject:
> Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
> 
> 
> 
> On Fri, 2009-05-29 at 13:55 -0400, Brian R Cowan wrote:
> > > Yes. If the page is dirty, but not up to date, then it needs to be
> > > cleaned before you can overwrite the contents with the results of a
> > > fresh read.
> > > That means flushing the data to disk... Which again means doing either 
> a
> > > stable write or an unstable write+commit. The former is more efficient
> > > that the latter, 'cos it accomplishes the exact same work in a single
> > > RPC call.
> > 
> > I suspect that the COMMIT RPC's are done somewhere other than in the 
> flush 
> > itself. If the "write + commit" operation was happening in the that 
> exact 
> > matter, then the change in the git at the beginning of this thread 
> *would 
> > not have impacted client performance*. I can demonstrate -- at will -- 
> > that it does impact performance. So, there is something that keeps track 
> 
> > of the number of writes and issues the commits without slowing down the 
> > application. This git change bypasses that and degrades the linker 
> > performance.
> 
> If the server gives slower performance for a single stable write, vs.
> the same unstable write + commit, then you are demonstrating that the
> server is seriously _broken_.
> 
> The only other explanation, is if the client prior to that patch being
> applied was somehow failing to send out the COMMIT. If so, then the
> client was broken, and the patch is a fix that results in correct
> behaviour. That would mean that the rest of the client flush code is
> probably still broken, but at least the nfs_wb_page() is now correct.
> 
> Those are the only 2 options.
> 
> Trond
> 
> 
> 


