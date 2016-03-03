Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:40489 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699AbcCCAUu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Mar 2016 19:20:50 -0500
Subject: Re: [PATCH nfs-utils v2] statd: Don't unregister statd service on
 failing to execute callout
References: <1455582968-4474-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Message-ID: <56D78348.2070205@lab.ntt.co.jp>
Date: Thu, 3 Mar 2016 09:20:24 +0900
MIME-Version: 1.0
In-Reply-To: <1455582968-4474-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
To: Steve Dickson <steved@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

On 2016/02/16 9:36, Toshiaki Makita wrote:
> statd calls atexit(statd_unregister) to unregister statd service on exit,
> which actually has a side-effect that ha_callout() unregisters statd
> service even when the child callout process exits on execl() failure.
> 
> Certain clustering software's deployment script adds -H option with its
> specified file non-existent, when it is configured not to use callout.
> In other words, -H seems to be used no matter if callout is needed or not,
> but when callout is unnecessary, the specified callout program is not
> deployed.
> This causes statd not to work once a lock is requested by its NFS client,
> as execl() in ha_callout() results in ENOENT and exit() of the child
> process calls exit-handler statd_unregister(). Eventually, the NFS client
> gets stuck with messages "lockd: cannot monitor xxx" on the NFS server.
> 
> Also, execl() could fail for other reasons like ENFILE or EIO as well.
> 
> A forked child must not unregister the statd RPC server, so use
> _exit(), which does not call any exit-handlers, instead of exit().
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

Would you tell me the status of this patch?

Regards,
Toshiaki Makita


