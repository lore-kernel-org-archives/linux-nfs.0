Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:65507 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbaCGNFu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Mar 2014 08:05:50 -0500
Received: by mail-pa0-f41.google.com with SMTP id fa1so4161685pad.28
        for <linux-nfs@vger.kernel.org>; Fri, 07 Mar 2014 05:05:50 -0800 (PST)
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: NFS4 patch 08/20 (BAD_SEQID recovery)
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <53199445.3010808@pml.ac.uk>
Date: Fri, 7 Mar 2014 08:05:46 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <69B89FEE-5B58-468F-95CE-B384033B2E65@primarydata.com>
References: <53199445.3010808@pml.ac.uk>
To: Ben Taylor <benj@pml.ac.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 7, 2014, at 4:41, Ben Taylor <benj@pml.ac.uk> wrote:

> Hi
> 
> We've been getting weird occasional failures on our NFS systems where
> our processing gridnodes will gradually grind to a halt (we lose a
> couple of machines a day requiring a reboot - hard reboot if left long
> enough). Hunting through Wireshark dumps, the problem is that the NFS
> client is making repeated requests to open the same file on our
> fileserver and every one has the same owner ID and a sequence ID of 0
> (which the server throws out again as a bad sequence ID). I've got a
> dump I can give you if you want it.
> 
> I am convinced that the problem is that described in patch 08/20 from
> Chuck Lever (see http://www.spinics.net/lists/linux-nfs/msg29413.html),
> where in this case the client gets the same open owner ID from the
> server and retries with that, which makes the server think it's the same
> request and throw it out again. In that patch Chuck added a uniqifier to
> the owner ID to avoid this problem.
> 
> The problem is that we can't find any kernel versions that include that
> patch - easy way to
> check is look for the " therefore safely retry using a new one. We
> should still warn the user though..." part - if the "warn the user" part
> is there, it's not been patched (we did check other bits of the patch
> too). We're running both Fedora 17 and Fedora 19 at the moment (yes, I
> know 17 is EOL), neither of which includes the patch. We also can't see
> it in the NFS client or server trees at
> 
> http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git;a=blob;f=fs/nfs/nfs4proc.c;h=2da6a698b8f7719c14eefec65e6148a48d030bb3;hb=HEAD#l2327
> 
> http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git;a=blob;f=fs/nfs/nfs4proc.c;h=2da6a698b8f7719c14eefec65e6148a48d030bb3;hb=HEAD#l2327
> 
> ...and nor does Chuck appear to have it in his merging tree:
> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=blob;f=fs/nfs/nfs4proc.c;h=15052b81df4245e4f797adb0d0b2e523338b23cc;hb=HEAD#l2327
> 
> Can anyone tell me what happened to this patch please? Was it lost or
> superseded?

It was superseded by commit 95b72eb0bdef6 (NFSv4: Ensure we do not reuse open owner names), which is available in linux 3.4 and newer.
_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

