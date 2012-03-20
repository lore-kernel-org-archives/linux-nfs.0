Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51742 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753563Ab2CTDLg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 23:11:36 -0400
Message-ID: <4F67F542.50906@panasas.com>
Date: Mon, 19 Mar 2012 20:10:58 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        Benny Halevy <bhalevy@tonian.com>, Steve Dickson <steved@redhat.com>,
        "Welch, Brent" <welch@panasas.com>
Subject: Re: [PATCH 3/4] pnfs-obj: autologin: Add support for protocol autologin
References: <4F62DADD.3010502@panasas.com> <4F62DC6A.5080709@panasas.com>  <1331934052.13255.7.camel@lade.trondhjem.org>  <4F679DEF.3040002@panasas.com> <1332191559.2636.34.camel@lade.trondhjem.org> <4F67BFE9.5040809@panasas.com> <4F67DA7E.80307@panasas.com>
In-Reply-To: <4F67DA7E.80307@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/19/2012 06:16 PM, Boaz Harrosh wrote:
> Subject: [PATCH] SQUASHME: pnf-obj: Fix as according to Trond's comments
> 

<snip>

> * Don't wait for ever for osd_login to finish, only wait osd_login_upcall_timeout
>     number of seconds, else fail.


OK I'm dropping this thing for now. The call to call_usermodehelper_xxx infrastructure
is not built for this.

What happens is that the (*cleanup) function passed to call_usermodehelper_fns is always
call from within the call_usermodehelper_fns(), before it's return. If it's waiting
for the execution - UMH_WAIT_EXEC - then just after execution, if UMH_WAIT_PROC then
after the program ends, if UMH_NO_WAIT it is called immediately. So there is no event
out of the kmode.c subsystem that can always notify us when the PROC ended.

For that I will need to either spun yet another thread, (The call_usermodehelper_exec
already spuns 3. Or change call_usermodehelper_exec to receive a third vector that
will be called on PROC completion. (Which will be redundant if  UMH_WAIT_PROC)

Since both options are too heavyweights for me right now, I will leave this option
to a TODO, and drop the timeout support for now.

Trond please confirm.

Thanks
Boaz
