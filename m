Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:18960 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932903Ab3GVSw0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jul 2013 14:52:26 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH v1 01/19] NFS: Never use user credentials for lease renewal
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1374518026.7972.12.camel@leira.trondhjem.org>
Date: Mon, 22 Jul 2013 14:52:21 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <82846EE9-8390-45FF-80DF-E3C04538618B@oracle.com>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net> <20130712163135.1444.68565.stgit@seurat.1015granger.net> <1374518026.7972.12.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 22, 2013, at 2:33 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2013-07-12 at 12:31 -0400, Chuck Lever wrote:
>> Don't try to use a non-UID-0 user credential for lease management,
>> as that credential can change out from under us.  The server will
>> block NFSv4 lease recovery with NFS4ERR_CLID_INUSE.
>> 
>> Replace minor version-specific callouts with a single function.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> fs/nfs/nfs4_fs.h     |    4 +---
>> fs/nfs/nfs4proc.c    |    6 +----
>> fs/nfs/nfs4session.c |    2 +-
>> fs/nfs/nfs4state.c   |   55 ++++++--------------------------------------------
>> 4 files changed, 10 insertions(+), 57 deletions(-)
> 
> This won't apply to upstream kernels.

Thanks for having a look... As the cover letter stated, this series applies to 3.10.

Now that 3.11-rc2 is available, I'm porting the series to the latest upstream, with appropriate adjustments for NFSv4.2 support.  I hope to post the new series tomorrow or Wednesday.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




