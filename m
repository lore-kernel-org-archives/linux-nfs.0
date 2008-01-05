From: Jeff Garzik <jeff@garzik.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 19:51:44 -0500
Message-ID: <477ED4A0.7080501@garzik.org>
References: <200801041711.MAA19577@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Rick Macklem <rick-bYVALtacgsT800Iu1Vt84J3p9npsUQCG@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54690 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753332AbYAEAvr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 19:51:47 -0500
In-Reply-To: <200801041711.MAA19577-bYVALtacgsT800Iu1Vt84J3p9npsUQCG@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rick Macklem wrote:
>> heh, tell me about it.  First I started out using rpcgen, then rewrote 
>> everything to do raw XDR decoding.  OPEN is huge.
>>
>> IMO, OPEN should be split into multiple operations, probably one for 
>> each "OPEN arm".  It's not like new opcode numbers are expensive.
> 
> As I hinted at, Open is the way it is, since Windows requires one Op
> so that Open/Share locks can be implemented correctly. Anything else
> would not have satisfied a Win client's requirements.

My apologies for being unclear.  I meant something along the lines of 
giving each OPEN arm its own opcode, to "flatten" things a bit.  The 
guarantees should and would remain the same, and Windows would continue 
to work.


>> One of my personal desires is for a high level of cache coherence 
>> throughout the system for all clients (though perhaps an admin could 
>> optionally relax this requirement).  I'm a fan of Google's "Chubby", a 
>> distributed reliable filesystem that stalls client writes until cache 
>> invalidations for the associated byte range are processed for all 
>> interested clients.
> 
> Delegations provide cache coherency "in a sense". When a client has a
> delegation, it knows that no-one else is writing the file. Unfortunately,
> as soon as a client gets an Open without a delegation, in no longer
> gets the conherency guarantee (and servers are completely free to not
> issue delegations if they don't feel like doing so). A client can
> re-open a file when it gets an Open without a delegation, but if the
> server still doesn't give it a delegation, it can't do anything more.
> (The re-open trick is useful for an Open that requires confirmation, since
>  the server can't issue a delegation for that case.)

Yes, delegation makes for nice caching.  I'm interested in making the 
other stuff coherent (as possible) too, for use cases such as 
shared-writer files with locking, "watched" files (1 writer, many 
readers), files to which many clients append data (a la GoogleFS's 
atomic append), directories that are polled by many clients, etc.

It's all in how one juggles workload-specific priorities, really.  Some 
workloads are nice with push-invalidation strategies like Chubby, others 
not so much.

	Jeff



