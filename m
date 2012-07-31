Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:30849 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753533Ab2GaNwA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 09:52:00 -0400
Date: Tue, 31 Jul 2012 21:51:54 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfs:devel 46/51] fs/nfs/write.c:1592:5: error: redefinition of
 'nfs_commit_inode'
Message-ID: <20120731135154.GA20221@localhost>
References: <20120731024328.GA10480@localhost>
 <4FA345DA4F4AE44899BD2B03EEEC2FA934BE82@SACEXCMBX04-PRD.hq.netapp.com>
 <5017D3FC.9010905@netapp.com>
 <1343739299.519.1.camel@lade.trondhjem.org>
 <5017D824.209@netapp.com>
 <5017DDDB.6060500@netapp.com>
 <1343741622.519.2.camel@lade.trondhjem.org>
 <5017E13F.4030909@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5017E13F.4030909@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bryan,

Do you have a git tree that I can run tests upon? That would help
prevent problems from sneaking into Trond's tree, and hence mess up
the maintainer's tree and waste everyone's time.

Thanks,
Fengguang
