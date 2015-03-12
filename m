Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:51616 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbbCLXPO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2015 19:15:14 -0400
From: Nix <nix@esperi.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/3] NFS: Don't invalidate a submounted dentry in nfs_prime_dcache()
References: <1424736897-95767-1-git-send-email-trond.myklebust@primarydata.com>
Date: Thu, 12 Mar 2015 23:15:10 +0000
In-Reply-To: <1424736897-95767-1-git-send-email-trond.myklebust@primarydata.com>
	(Trond Myklebust's message of "Mon, 23 Feb 2015 19:14:55 -0500")
Message-ID: <87wq2llse9.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 24 Feb 2015, Trond Myklebust stated:

> If we're traversing a directory which contains a submounted filesystem,
> or one that has a referral, the NFS server that is processing the READDIR
> request will often return information for the underlying (mounted-on)
> directory. It may, or may not, also return filehandle information.

FWIW, this never seems to have made it into 3.19.x, nor is it in the
stable queue. Was this intentional?

> Cc: stable@vger.kernel.org # 3.18+

(... hm, I guess so...)

-- 
NULL && (void)
