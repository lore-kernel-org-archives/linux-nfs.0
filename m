Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933553Ab1BPBCh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 20:02:37 -0500
Subject: Re: NFS Regression in commit 0b26a0bf6ff398
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <20110216005640.GA2841@mgebm.net>
References: <20110216005640.GA2841@mgebm.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Feb 2011 20:02:35 -0500
Message-ID: <1297818155.10103.43.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-02-15 at 19:56 -0500, Eric B Munson wrote: 
> While testing some 2.6.38 work my rsync backup script started consuming
> large amounts of memory (all available before dying with no more available
> memory).  I have bisected the problem back to 0b26a0bf6ff398.  I am
> unfamiliar with the NFS code so I don't know where to start looking for a
> possible fix.  My backups files from my home directory to an NFS mounted
> directory.  The NFS server is a Synology DS-411+ if it matters.  Let me know
> if there is any other information I can provide.

Exactly which 2.6.38 kernel are you running, and which NFS version?

I'm having trouble seeing how the patch in question can be responsible
for what you are seeing, so please could you provide more details of
your test setup.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

