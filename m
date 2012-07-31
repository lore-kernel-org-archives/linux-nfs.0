Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:46311 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933Ab2GaOKO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 10:10:14 -0400
Date: Tue, 31 Jul 2012 22:10:07 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfs:devel 46/51] fs/nfs/write.c:1592:5: error: redefinition of
 'nfs_commit_inode'
Message-ID: <20120731141007.GA20369@localhost>
References: <20120731024328.GA10480@localhost>
 <4FA345DA4F4AE44899BD2B03EEEC2FA934BE82@SACEXCMBX04-PRD.hq.netapp.com>
 <5017D3FC.9010905@netapp.com>
 <1343739299.519.1.camel@lade.trondhjem.org>
 <5017D824.209@netapp.com>
 <5017DDDB.6060500@netapp.com>
 <1343741622.519.2.camel@lade.trondhjem.org>
 <5017E13F.4030909@netapp.com>
 <1343743122.519.4.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1343743122.519.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > Easy enough, the patch that fixes it is the last one in the series that I sent in yesterday.
> 
> I don't understand. That is the patch series that Fengguang was testing
> afaik. His tests were on 
> 
> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel
> head:   5c13c9e1c15ee2ca9ab2b953224001af53d9be09
> 
> which includes your patch series from yesterday, no?

Trond, I typically do commit-by-commit tests and will complain if
*any* point of the tree is not bisect-able. A fix at the HEAD won't
stop the email notification for a defect in the middle point..

On the other hand, I do maintain a list of non-rebaseable
tree/branches, on which the HEAD commit will be tested first, and only
if any problems are found, go back to find out the first bad commit.

If you prefer the latter behavior, I can add your tree or any branch
of it to the non-rebaseable list.

Thanks,
Fengguang
