Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 8bytes.org ([85.214.48.195]:44577 "EHLO mail.8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755344Ab2I0Pjb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Sep 2012 11:39:31 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id 62F3312AFA1
	for <linux-nfs@vger.kernel.org>; Thu, 27 Sep 2012 17:39:29 +0200 (CEST)
Date: Thu, 27 Sep 2012 17:39:28 +0200
From: Joerg Roedel <joro@8bytes.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Joerg Roedel <joerg.roedel@amd.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
Message-ID: <20120927153928.GB18962@8bytes.org>
References: <20120807134156.GP1996@amd.com>
 <20120927145217.GA18962@8bytes.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF572@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF572@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 27, 2012 at 03:32:02PM +0000, Myklebust, Trond wrote:

> Does your checked out copy of 3.6-rc7 contain commit c50669 (NFS:
> Clear key construction data if the idmap upcall fails)? The latter was
> merged in3.6-rc3, and is reported to fix the problem for the other
> testers.

Yes, it contains that commit. I was about to test plain v3.6-rc7 without
my patches (not nfs related, of cource) on-top, but unfortunatly the
disk with the root-fs died :-/
I am about to set up the box again and test plain -rc7.


	Joerg


