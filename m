Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:60689 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909Ab2CHRcc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Mar 2012 12:32:32 -0500
Received: from sim by peace.netnation.com with local (Exim 4.72)
	(envelope-from <sim@netnation.com>)
	id 1S5hCZ-0001jR-PO
	for linux-nfs@vger.kernel.org; Thu, 08 Mar 2012 09:32:31 -0800
Date: Thu, 8 Mar 2012 09:32:31 -0800
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: nfs_file_splice_read() not interruptible
Message-ID: <20120308173231.GA620@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While trying to figure out why we keep getting TCP NFSv3 client mounts in
CLOSE_WAIT state, I notice that the socket closes and the host becomes
remountable if I kill all D-state processes blocking on it. However, some
Apache processes are often uninterruptible:

# cat /proc/8959/stack
[<ffffffff810d6b69>] sleep_on_page+0x9/0x10
[<ffffffff810d6b54>] __lock_page+0x64/0x70
[<ffffffff81147f5d>] __generic_file_splice_read+0x2dd/0x500
[<ffffffff811481cd>] generic_file_splice_read+0x4d/0x90
[<ffffffff811f70b5>] nfs_file_splice_read+0x85/0xd0
[<ffffffff81146522>] do_splice_to+0x72/0xa0
[<ffffffff81146d54>] splice_direct_to_actor+0xc4/0x1d0
[<ffffffff81146eb2>] do_splice_direct+0x52/0x70
[<ffffffff8111c1fe>] do_sendfile+0x16e/0x1e0
[<ffffffff8111c2f5>] sys_sendfile64+0x85/0xb0
[<ffffffff816e1392>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

However, from loking in generic_file_splice_read, it looks like not
something easy to make interruptible....

What causes the sockets to close, anyway? I notice there seems to be some
sort of idle timeout. Is this configured somewhere, so I can set it
really low and reproduce this more easily? I suspect we must have some
race with the socket closing and something trying to use it again...

Simon-
