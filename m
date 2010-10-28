Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:36665 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758406Ab0J1Noc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 09:44:32 -0400
Subject: Re: [PATCH] [bz 192] Fixed Regression in NFS Direct I/O path
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Christoph Hellwig <hch@infradead.org>
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <20101028123859.GA28972@infradead.org>
References: <1288268274-9444-1-git-send-email-steved@redhat.com>
	 <20101028123859.GA28972@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Oct 2010 09:44:21 -0400
Message-ID: <1288273461.3194.19.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-10-28 at 08:38 -0400, Christoph Hellwig wrote:
> On Thu, Oct 28, 2010 at 08:17:54AM -0400, Steve Dickson wrote:
> > A typo, introduced by commit f11ac8db, in the nfs_direct_write()
> > routine causes writes with O_DIRECT set to fail with a ENOMEM error.
> 
> I guess someone should run xfstests on nfs more regularly :)

Sigh, yes... I should set up a VM to run all the test suites on a
regular basis...

Trond

