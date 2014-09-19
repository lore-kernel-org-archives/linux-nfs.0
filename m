Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out.cae.wisc.edu ([144.92.12.194]:45762 "EHLO
	smtp-out.cae.wisc.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756810AbaISRUK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Sep 2014 13:20:10 -0400
Message-ID: <541C6499.3080606@engr.wisc.edu>
Date: Fri, 19 Sep 2014 12:15:05 -0500
From: Ken Hahn <khahn@engr.wisc.edu>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS Kernel Bug
References: <541AD7E5.8020409@engr.wisc.edu>	 <CAHQdGtQZ0kcBZ0QCb+sf52thERjJgz-5M++CsT7kdoDweG61sQ@mail.gmail.com> <1411056020.10845.1.camel@leira.trondhjem.org>
In-Reply-To: <1411056020.10845.1.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I work with drews@engr.wisc.edu.

On 09/18/2014 11:00 AM, Trond Myklebust wrote:
>>
>> Argh. This is a situation where the client shouldn't have called
>> OPEN_DOWNGRADE, but should have done a CLOSE. The issue is that the
>> client opens the file with OPEN4_SHARE_ACCESS_BOTH, so it is not
>> allowed to downgrade to OPEN4_SHARE_ACCESS_READ. Instead it should
>> have closed the file, and then used the delegation...
>>
> 
> Does the following patch help (and does it still fix your original
> bugreport)?

I tried it out, patching the Debian 3.14.15 kernel.. had to alter the
patch a tiny bit, but I don't think I messed up any real functionality.

Indeed it passes the old test, and avoids the new bug too.

Thanks!

-Ken Hahn

Here's the altered patch for what it is worth (for anyone else using the
current debian backports kernel):

--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2560,20 +2560,22 @@ static void nfs4_close_prepare(struct rpc_task
*task, void *data)
        is_rdwr = test_bit(NFS_O_RDWR_STATE, &state->flags);
        is_rdonly = test_bit(NFS_O_RDONLY_STATE, &state->flags);
        is_wronly = test_bit(NFS_O_WRONLY_STATE, &state->flags);
-       if (is_rdonly || is_rdwr)
-               calldata->arg.fmode |= FMODE_READ;
-       if (is_wronly || is_rdwr)
-               calldata->arg.fmode |= FMODE_WRITE;
+       calldata->arg.fmode = 0;
        if (state->n_rdwr == 0) {
-               if (state->n_rdonly == 0) {
-                       call_close |= is_rdonly || is_rdwr;
-                       calldata->arg.fmode &= ~FMODE_READ;
-               }
-               if (state->n_wronly == 0) {
-                       call_close |= is_wronly || is_rdwr;
-                       calldata->arg.fmode &= ~FMODE_WRITE;
-               }
-       }
+               if (state->n_rdonly == 0)
+                       call_close |= is_rdonly;
+               else if (is_rdonly)
+                       calldata->arg.fmode |= FMODE_READ;
+               if (state->n_wronly == 0)
+                       call_close |= is_wronly;
+               else if (is_wronly)
+                       calldata->arg.fmode |= FMODE_WRITE;
+       } else if (is_rdwr)
+               calldata->arg.fmode |= FMODE_READ|FMODE_WRITE;
+
+       if (calldata->arg.fmode == 0)
+               call_close |= is_rdwr;
+
        if (!nfs4_valid_open_stateid(state))
                call_close = 0;
        spin_unlock(&state->owner->so_lock);
--
1.9.3



