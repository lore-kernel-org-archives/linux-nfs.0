Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.15]:56129 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993AbaJSUeP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 19 Oct 2014 16:34:15 -0400
Message-ID: <54442040.5070601@gmx.de>
Date: Sun, 19 Oct 2014 22:34:08 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Trond Myklebust <trondmy@gmail.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz testing gave today : "kernel: NFS: nfs4_reclaim_open_state:
 unhandled error -13"
References: <5442E2A4.9030006@gmx.de> <CAABAsM4ETHB6obPVa4Zf8T7Vb--t6--Q2tS5ibOurA1BN3as=g@mail.gmail.com>
In-Reply-To: <CAABAsM4ETHB6obPVa4Zf8T7Vb--t6--Q2tS5ibOurA1BN3as=g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/19/2014 10:03 PM, Trond Myklebust wrote:
> Errno 13 is EACCES. Might the test case involve changing the mode
> bits/acls on an open file, then putting the client in situation where
> an expired lease causes it to attempt open state recovery?

right - that's likely possible due to 2 trinity childs running in parallel


-- 
Toralf
pgp key: 0076 E94E

