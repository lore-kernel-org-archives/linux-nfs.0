Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vps680.inmotionhosting.com ([74.124.198.230]:37139 "EHLO
	vps680.inmotionhosting.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751667AbZCKVvl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2009 17:51:41 -0400
Received: from cpe-98-149-71-108.socal.res.rr.com ([98.149.71.108]:14482 helo=[192.168.2.107])
	by vps680.inmotionhosting.com with esmtpa (Exim 4.63)
	(envelope-from <callahan@temerity.us>)
	id 1LhVXn-0000UL-Tg
	for linux-nfs@vger.kernel.org; Wed, 11 Mar 2009 14:00:52 -0700
Message-ID: <49B8186F.5070601@temerity.us>
Date: Wed, 11 Mar 2009 16:00:47 -0400
From: Jim Callahan <callahan@temerity.us>
To: linux-nfs@vger.kernel.org
Subject: NFS and RPC queues
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm trying to diagnose an NFS performance problem and need to know a bit 
more about how the Linux NFS client works internally.  I've got a single 
NFS client which is connected to a network appliance file server via 1Gb 
ethernet.  We've removed all switches between the client and server to 
remove that variable from the equation.  We have two benchmarking 
scripts, one which performs generates mostly GETATTR requests and the 
other which generates mostly READ/WRITE requests from the server.  The 
file system is mounted using "actimeo=1".  This is required for our 
purposes since we need file status information which cannot be out of 
date by more than 1 second.

When we run the GETATTR test alone, we see around 6000 requests per 
second.  When we run one or more of the READ/WRITE tests at the same 
time from the same host, we see GETATTR performance drop considerably.  
Here's the average performance based on the number of READ/WRITE 
threads:  1=500/sec, 2=215/sec, 4=110/sec, 8=45/sec, 16=15/sec.   So 
there clearly seems to be some interaction between the response times to 
GETATTR based on the number of READ/WRITE operations going on.  Now, I'd 
assume that there would be some degradation but considering that GETATTR 
is a fast operation for the server to perform and the amount of data 
being send both ways is very small its more than I was expecting.

We then tried adding a second network card, connection and NFS mount 
from the same client to the same file server.  We segregated all GETATTR 
traffic to use one mount and the READ/WRITE to use the other mount.  
With this setup, GETATTR request seem to be almost completely unaffected 
by any amount of READ/WRITE activity.  Interestingly, the READ/WRITE 
performance was identical as in the one network/mount case.  So this 
seemed to validate that the GETATTR requests do not require much bandwidth.

We also performed this same set of tests on a different file server 
which has a completely different architecture and is also much older and 
it delivered nearly identical results.  This this what make us think it 
might be an NFS client related problem and not the server at all.

Sorry to be so long winded, but I needed a proper context to ask my 
questions...

Is the RPC queue used by NFS processed in a serial fashion for each 
mount to a unique IP address?  One possible explanation is that the 
GETATTR requests are simply waiting in line behind READ/WRITES in the 
one network case and that explains the drop in performance.  So does 
using a different IP address for the second mount create a second RPC 
queue which is processed in an asynchronous manner?  That might explain 
the lack of interaction between the GETATTR's and READ/WRITES in our 
second test...

If this is not the case, can you suggest any theories that might explain 
this results along with any tests we might perform to validate these 
theories?  Many thanks in advance for any insights you can provide!

-- 
Jim Callahan - President - Temerity Software <www.temerity.us>
