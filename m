Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47729 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756114AbZCKWHw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 18:07:52 -0400
Subject: Re: NFS and RPC queues
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Callahan <callahan@temerity.us>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <49B8186F.5070601@temerity.us>
References: <49B8186F.5070601@temerity.us>
Content-Type: text/plain
Date: Wed, 11 Mar 2009 18:07:28 -0400
Message-Id: <1236809248.12697.44.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2009-03-11 at 16:00 -0400, Jim Callahan wrote:
> I'm trying to diagnose an NFS performance problem and need to know a bit 
> more about how the Linux NFS client works internally.  I've got a single 
> NFS client which is connected to a network appliance file server via 1Gb 
                                     NetApp ?
> ethernet.  We've removed all switches between the client and server to 
> remove that variable from the equation.  We have two benchmarking 
> scripts, one which performs generates mostly GETATTR requests and the 
> other which generates mostly READ/WRITE requests from the server.  The 
> file system is mounted using "actimeo=1".  This is required for our 
> purposes since we need file status information which cannot be out of 
> date by more than 1 second.
> 
> When we run the GETATTR test alone, we see around 6000 requests per 
> second.  When we run one or more of the READ/WRITE tests at the same 
> time from the same host, we see GETATTR performance drop considerably.  
> Here's the average performance based on the number of READ/WRITE 
> threads:  1=500/sec, 2=215/sec, 4=110/sec, 8=45/sec, 16=15/sec.   So 
> there clearly seems to be some interaction between the response times to 
> GETATTR based on the number of READ/WRITE operations going on.  Now, I'd 
> assume that there would be some degradation but considering that GETATTR 
> is a fast operation for the server to perform and the amount of data 
> being send both ways is very small its more than I was expecting.
> 
> We then tried adding a second network card, connection and NFS mount 
> from the same client to the same file server.  We segregated all GETATTR 
> traffic to use one mount and the READ/WRITE to use the other mount.  
> With this setup, GETATTR request seem to be almost completely unaffected 
> by any amount of READ/WRITE activity.  Interestingly, the READ/WRITE 
> performance was identical as in the one network/mount case.  So this 
> seemed to validate that the GETATTR requests do not require much bandwidth.
> 
> We also performed this same set of tests on a different file server 
> which has a completely different architecture and is also much older and 
> it delivered nearly identical results.  This this what make us think it 
> might be an NFS client related problem and not the server at all.
> 
> Sorry to be so long winded, but I needed a proper context to ask my 
> questions...
> 
> Is the RPC queue used by NFS processed in a serial fashion for each 
> mount to a unique IP address?  One possible explanation is that the 
> GETATTR requests are simply waiting in line behind READ/WRITES in the 
> one network case and that explains the drop in performance.  So does 
> using a different IP address for the second mount create a second RPC 
> queue which is processed in an asynchronous manner?  That might explain 
> the lack of interaction between the GETATTR's and READ/WRITES in our 
> second test...

Try increasing the value of the sunrpc.tcp_slot_table_entries sysctl
entry on the Linux client. That sysctl controls the maximum number of
simultaneous RPC messages that are allowed on the TCP connection.

The default is 16, but it can be increased to 128. Just make sure that
you umount all NFS partitions before changing it. (Doing 'mount
-oremount' won't work...)

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
