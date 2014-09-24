Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f179.google.com ([74.125.82.179]:60132 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbaIXO4q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 10:56:46 -0400
Received: by mail-we0-f179.google.com with SMTP id u56so6326120wes.24
        for <linux-nfs@vger.kernel.org>; Wed, 24 Sep 2014 07:56:45 -0700 (PDT)
Received: from sys880.ldn.framestore.com (firewall.framestore.com. [193.203.83.19])
        by mx.google.com with ESMTPSA id ba3sm6057080wib.10.2014.09.24.07.56.44
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 07:56:44 -0700 (PDT)
Date: Wed, 24 Sep 2014 15:56:38 +0100 (BST)
From: Mark Hills <mark.hills@framestore.com>
To: linux-nfs@vger.kernel.org
Subject: NFS server QoS ideas
Message-ID: <alpine.LFD.2.01.1409241248320.7614@sys880.ldn.framestore.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I am looking at possibilities to implement QoS (quality of service) in an 
NFS server -- for a multiuser HPC environment, on NFSv3.

The desire is for a fully loaded server to process requests in some kind 
of "fair share" (like round robin) or priorities based on some attribute; 
eg. uid at the client, request type + origin, or even directory etc.

Criteria could be fairly blunt and specific to our use case to begin with.

I've looked at the code with the following ideas for where to start.

It seems the implementation depends a lot on which attributes to 
share/schedule on:

1) by client IP:

   make use the existing structures

   enhance the svc_xprt_enqueue/dequeue process to schedule svc_xprt
   as these are already per-client

2) by client uid or other RPC attribute:

   have svc_recv make multiple calls to svc_handle_xprt

   buffer the requests into multiple queues held at svc_pool (re-use 
   xpt_deferred?)

3) by NFS operation, file handle etc.:

   most awkward, as there is not buffering of requests at the NFS level
   or shared between threads

   perhaps do as (2) but with a function in svc_program to return
   scheduling criteria

It looks like I need to consider the behaviour when there are multiple 
svc_pool (ie. NUMA)

This is the first time I've looked into this code, I'm interested in any 
comments/criticisms or alternatives.

Thanks

-- 
Mark
