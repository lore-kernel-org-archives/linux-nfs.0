Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 8bytes.org ([85.214.48.195]:56005 "EHLO
	h2027444.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624Ab2FGPbY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 11:31:24 -0400
Received: from localhost (localhost [127.0.0.1])
	by h2027444.stratoserver.net (Postfix) with SMTP id 64E2912AFE9
	for <linux-nfs@vger.kernel.org>; Thu,  7 Jun 2012 17:31:23 +0200 (CEST)
Date: Thu, 7 Jun 2012 17:31:22 +0200
From: Joerg Roedel <joro@8bytes.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS regression in v3.5-rc1: mount.nfs yells about incorrect
 mount option
Message-ID: <20120607153122.GP12795@8bytes.org>
References: <20120607150456.GO12795@8bytes.org>
 <4FD0C4C2.8020605@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FD0C4C2.8020605@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 07, 2012 at 11:12:02AM -0400, Bryan Schumaker wrote:
> On 06/07/2012 11:04 AM, Joerg Roedel wrote:
> 
> Can you use `mount -v` to get more output?

Hmm, that is weird. When I use mount -v it actually does mount the
remote NFS tree. Here is the output:

root@chrom:~# mount -v lemmy:/data/repos /data/lemmy/
mount: no type was given - I'll assume nfs because of the colon
mount.nfs: timeout set for Thu Jun  7 17:21:54 2012
mount.nfs: text-based options: 'addr=165.204.15.93'
mount.nfs: mount(2): Protocol not supported
mount.nfs: trying 165.204.15.93 prog 100003 vers 3 prot UDP port 2049
mount.nfs: trying 165.204.15.93 prog 100005 vers 3 prot UDP port 39332
mount.nfs: text-based options (retry): 'addr=165.204.15.93,vers=3,proto=udp,mountvers=3,mountproto=udp,mountport=39332'
lemmy:/data/repos on /data/lemmy type nfs (rw)

When I unmount and try to mount it again without -v I still get the
error message and the mount fails.

With 3.4 the mount -v output is:

mount: no type was given - I'll assume nfs because of the colon
mount.nfs: timeout set for Thu Jun  7 17:19:44 2012
mount.nfs: text-based options: 'addr=165.204.15.93'
lemmy:/data/repos/ on /data/lemmy type nfs (rw)

So for some reason the text-based options are different. Maybe that has
something to do with the problem.

Regards,

	Joerg


