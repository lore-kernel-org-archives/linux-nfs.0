Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:52305 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540Ab3AKFWx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jan 2013 00:22:53 -0500
Date: Fri, 11 Jan 2013 13:22:50 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [SUNPRC] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000070
Message-ID: <20130111052250.GA13133@localhost>
References: <20130111024644.GA9508@localhost>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9119984C5@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9119984C5@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 11, 2013 at 04:24:45AM +0000, Trond Myklebust wrote:
> On Fri, 2013-01-11 at 10:46 +0800, Fengguang Wu wrote:
> > tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
> > commit: 51b63a538c54cb9c3b83c4d62572cf18da165cba [1/1] SUNRPC: Ensure we release the socket write lock if the rpc_task exits early
> > 
> > [  106.308511] md: autorun ...
> > [  106.309477] md: ... autorun DONE.
> > [  107.923634] BUG: unable to handle kernel NULL pointer dereference at 0000000000000070
> > [  107.926207] IP: [<ffffffff82a7c8ac>] xprt_release+0x24/0x1cb

> Hi Fengguang,
> 
> Thanks for testing! The above Oops should be fixed in commit
> 87ed50036b866db2ec2ba16b2a7aec4a2b0b7c39, which is in the current
> linux-next branch on git.linux-nfs.org. It was due to a missing test for
> task->tk_client != NULL.

Yes, sorry that bug was actually caught several days before, however
I was too busy to look into it..

> I should also have fixed the RCU dereference warning that the build
> robot found on Tuesday.

Trond, thank you for the fixes!

Thanks,
Fengguang
