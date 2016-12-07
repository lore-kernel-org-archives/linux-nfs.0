Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54148 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752647AbcLGN3D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 08:29:03 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 392AE6DD85
        for <linux-nfs@vger.kernel.org>; Wed,  7 Dec 2016 13:28:43 +0000 (UTC)
Received: from [10.10.63.30] (vpn-63-30.rdu2.redhat.com [10.10.63.30])
        by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id uB7DSg5T017359
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA256 bits=256 verify=NO)
        for <linux-nfs@vger.kernel.org>; Wed, 7 Dec 2016 08:28:42 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "linux-nfs list" <linux-nfs@vger.kernel.org>
Subject: Concurrent `ls` takes out the thrash
Date: Wed, 07 Dec 2016 08:28:41 -0500
Message-ID: <C2A81CDB-ED8F-4D41-919F-3F92CBFF751B@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I was asked to figure out why the listing of very large directories was
slow.  More specifically, why concurrently listing the same large 
directory
is /very/ slow.  It seems that sometimes a user's reaction to waiting 
for
'ls' to complete is to start a few more.. and then their machine takes a
very long time to complete that work.

I can reproduce that finding.  As an example:

time ls -fl /dir/with/200000/entries/ >/dev/null

real    0m10.766s
user    0m0.716s
sys     0m0.827s

But..

for i in {1..10}; do time ls -fl /dir/with/200000/entries/ >/dev/null & 
done

Each of these ^^ 'ls' commands will take 4 to 5 minutes to complete.

The problem is that concurrent 'ls' commands stack up in nfs_readdir() 
both
waiting on the next page and taking turns filling the next page with 
xdr,
but only one of them will have desc->plus set because setting it clears 
the
flag on the directory.  So if a page is filled by a process that doesn't 
have
desc->plus then the next pass through lookup(), it dumps the entire page
cache with nfs_force_use_readdirplus().  Then the next readdir starts 
all
over filling the pagecache.  Forward progress happens, but only after 
many
steps back re-filling the pagecache.

To me most obvious fix would be to serialize nfs_readdir() on the 
directory
inode, so I'll follow-up with patch that does that with nfsi->rwsem.  
With that,
the above parallel 'ls' takes 12 seconds for each 'ls' to complete.

This only works because with concurrent 'ls' there is a consistent 
buffer
size so a waiting nfs_readdir() started in the same place for an 
unmodified
directory should always hit the cache after waiting.  Serializing
nfs_readdir() will not solve this problem for concurrent callers with
differing buffer sizes, or starting at different offsets, since there's 
a
good chance the waiting readdir() will not see the readdirplus flag when 
it
resumes and so will not prime the dcache.

While I think it's an OK fix, it feels bad to serialize.  At the same
time, nfs_readdir() is already serialized on the pagecache when 
concurrent
callers need to go to the server.  There might be other problems I 
haven't
thought about.

Maybe there's another way to fix this, or maybe we can just say "Don't 
do ls
more than once, you impatient bastards!"

Ben
