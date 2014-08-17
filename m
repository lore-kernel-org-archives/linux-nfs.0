Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:36454 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbaHQNMB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Aug 2014 09:12:01 -0400
Received: by mail-qg0-f53.google.com with SMTP id z60so204195qgd.26
        for <linux-nfs@vger.kernel.org>; Sun, 17 Aug 2014 06:12:00 -0700 (PDT)
Date: Sun, 17 Aug 2014 09:11:56 -0400
From: Tejun Heo <tj@kernel.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] NFS: state manager thread must stay running.
Message-ID: <20140817131156.GB7679@mtj.dyndns.org>
References: <20140813140831.22f3e9c7@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140813140831.22f3e9c7@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Neil.

On Wed, Aug 13, 2014 at 02:08:31PM +1000, NeilBrown wrote:
> There are two interesting requirements for the manager thread:
> 1/ It must allow SIGKILL, which can abort NFS transactions to
>    a dead server.
> 2/ It may continue running after the filesystem is unmounted,
>    until the server recovers or the thread is SIGKILLed

Out of curiosity, why is SIGKILL handling necessary at all?  Can't nfs
just keep the manager running while any mount is active?

Thanks.

-- 
tejun
