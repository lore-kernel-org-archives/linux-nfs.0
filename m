Return-Path: linux-nfs-owner@vger.kernel.org
Received: from intranet.asianux.com ([58.214.24.6]:3980 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755488Ab2JPBgA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Oct 2012 21:36:00 -0400
Message-ID: <507CBA3F.6000204@asianux.com>
Date: Tue, 16 Oct 2012 09:37:03 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [Bug fix] nfs-client: fix nfs_inode_attrs_need_update for async
 read_done comes during truncating to smaller size
References: <507B70F1.7040903@asianux.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA909236BB5@SACEXCMBX04-PRD.hq.netapp.com>  <507B968A.9090104@asianux.com> <4FA345DA4F4AE44899BD2B03EEEC2FA90923F1C4@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90923F1C4@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

于 2012年10月15日 20:32, Myklebust, Trond 写道:
> RPC is not ordered. The fact that we get one RPC reply before another
> does not mean that the server sent them in that order.
> 
> This is doubly true when you use UDP as the transport protocol.

1) is it means: nfs_inode_attrs_need_update need not consider async
read_done situation ?

2) for correctness, I do not think "nfs_size_to_loff_t(fattr->size) >
i_size_read(inode)" in nfs_size_need_update is enough. (at least need
use "!=" instead of '>'), do you think so ?


3) another reference:

  A) for an old kernel version (such as 2.6.27-rc9), no such issue
(because it did not have nfs_size_need_update).

  B) the test tools which I use is from the LTP (Linux Test Project),
they use both udp and tcp to test both the nfsv2 and nfsv3.

  C) truly LTP has its limitations: "for stress test, LTP let nfs client
and server under the same machine, which will cause kernel stable
issue", but for net test, LTP use different machine (I got our issue
from LTP net test).


-- 
Chen Gang

Asianux Corporation
