Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36177 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753050Ab2GaNzZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 09:55:25 -0400
Message-ID: <5017E3CA.8070502@netapp.com>
Date: Tue, 31 Jul 2012 09:55:22 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Fengguang Wu <fengguang.wu@intel.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfs:devel 46/51] fs/nfs/write.c:1592:5: error: redefinition
 of 'nfs_commit_inode'
References: <20120731024328.GA10480@localhost> <4FA345DA4F4AE44899BD2B03EEEC2FA934BE82@SACEXCMBX04-PRD.hq.netapp.com> <5017D3FC.9010905@netapp.com> <1343739299.519.1.camel@lade.trondhjem.org> <5017D824.209@netapp.com> <5017DDDB.6060500@netapp.com> <1343741622.519.2.camel@lade.trondhjem.org> <5017E13F.4030909@netapp.com> <20120731135154.GA20221@localhost>
In-Reply-To: <20120731135154.GA20221@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've got one at: git://git.linux-nfs.org/projects/bjschuma/linux-nfs.git.  I don't always do a good job keeping it up-to-date, but I can try to get into the habit of putting my patches there before submitting them.

- Bryan

On 07/31/2012 09:51 AM, Fengguang Wu wrote:
> Bryan,
> 
> Do you have a git tree that I can run tests upon? That would help
> prevent problems from sneaking into Trond's tree, and hence mess up
> the maintainer's tree and waste everyone's time.
> 
> Thanks,
> Fengguang
> 

