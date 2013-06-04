Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natfw.luminex.com ([50.58.139.18]:41855 "EHLO luminex.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755384Ab3FDDCB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jun 2013 23:02:01 -0400
Received: from [192.9.200.221] (emach020.luminex.com [192.9.200.221])
	by luminex.com (8.12.9/8.12.9) with ESMTP id r542fSPj025734
	for <linux-nfs@vger.kernel.org>; Mon, 3 Jun 2013 19:41:28 -0700 (PDT)
Message-ID: <51AD53CF.3080604@luminex.com>
Date: Mon, 03 Jun 2013 19:41:19 -0700
From: Brian Hawley <bhawley@luminex.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: i/o still hangs when nfs server unavailable even with soft mount
 option
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I've noticed that even with 'soft' mount specified as an option, i/o 
will continue to cache (after a server has gone away - or the clients 
links to it), at which point it hangs, instead of returning an i/o error 
as I would expect based on the man pages.

For our environment, speed is more important than reliability as when we 
lose access to one of the nfs mounts, we cease writing new data to it 
and journal it on the remaining available mounts.

Based on the descriptions in the various manuals, I would have thought 
'soft' mount would have given us an i/o error on any write (or read) 
which failed.

This however, isn't the case, unless 'sync' is also set.

I believe the reason for this has to do with somewhere in the cache 
handling.   Even when the mount is set to 'soft', without 'sync' the 
writes go to the cache, until the cache is full and the client wants to 
perform the actual write to the server.   It is at this time, that it 
stays stuck and never returns, irregardless of the timeo and retrans 
options, until the server (or links to it) have been restored.

If 'sync' is on, the i/o error occurs as expected.    However, 'sync' 
has a significant performance penalty, even if the server exports the 
filesystem as 'async'.

I wasn't able to find anything in the archives about this, but did find 
one other reference in 2010 to this same issue, but without any reply or 
comment about a solution.

Does anyone know how I might get this working, or could point me to the 
correct location in the kernel fs sources to effect my own change to the 
kernel handling?

Thanks,

-- Brian

