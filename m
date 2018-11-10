Return-Path: <SRS0=tn5C=NV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58F7FC43441
	for <linux-nfs@archiver.kernel.org>; Sat, 10 Nov 2018 21:49:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D5E302089A
	for <linux-nfs@archiver.kernel.org>; Sat, 10 Nov 2018 21:49:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5E302089A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725779AbeKKHgG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 11 Nov 2018 02:36:06 -0500
Received: from fieldses.org ([173.255.197.46]:42190 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725778AbeKKHgG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 11 Nov 2018 02:36:06 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 392121E67; Sat, 10 Nov 2018 16:49:39 -0500 (EST)
Date:   Sat, 10 Nov 2018 16:49:39 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chucklever@gmail.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NULL dereference in rpcauth_lookup_credcache
Message-ID: <20181110214939.GA16755@fieldses.org>
References: <20181108214452.GH6090@fieldses.org>
 <04114B00-B5A8-4F8A-B052-A266AED7725D@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04114B00-B5A8-4F8A-B052-A266AED7725D@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Looks like it's the fault of

07d02a67b7faae "SUNRPC: Simplify lookup code"

--b.

On Fri, Nov 09, 2018 at 01:01:30PM -0500, Chuck Lever wrote:
> 
> 
> > On Nov 8, 2018, at 4:44 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > Since -rc1 my regression tests crash my client.  Is this a known
> > problem?  I'll investigate some more, I haven't even looked at the code
> > yet or checked which test exactly is hitting this.
> > 
> > --b.
> > 
> > [  164.109570] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> > [  164.111207] PGD 0 P4D 0 
> > [  164.111528] Oops: 0000 [#1] PREEMPT SMP PTI
> > [  164.112303] CPU: 2 PID: 2947 Comm: kworker/u8:5 Not tainted 4.20.0-rc1-13223-gafb6d1c474ef #1898
> > [  164.113487] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS ?-20180531_142017-buildhw-08.phx2.fedoraproject.org-1.fc28 04/01/2014
> > [  164.115301] Workqueue: rpciod rpc_async_schedule [sunrpc]
> > [  164.115920] RIP: 0010:rpcauth_lookup_credcache+0x3d/0x450 [sunrpc]
> > [  164.116700] Code: 89 f5 41 54 41 89 d4 53 48 83 ec 38 89 4d b0 4c 8b 7f 20 65 48 8b 04 25 28 00 00 00 48 89 45 d0 31 c0 48 8d 45 c0 48 89 45 c8 <41> 8b 77 08 48 89 45 c0 48 8b 47 10 4c 89 ef 48 8b 40 28 e8 cb d2
> > [  164.119299] RSP: 0018:ffffc90001ee3cf0 EFLAGS: 00010246
> > [  164.119872] RAX: ffffc90001ee3d10 RBX: ffff88007cc18180 RCX: 0000000000600040
> > [  164.120800] RDX: 0000000000000001 RSI: ffffc90001ee3d60 RDI: ffff88007cafb198
> > [  164.121643] RBP: ffffc90001ee3d50 R08: 0000000000000000 R09: 0000000000000000
> > [  164.122464] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000001
> > [  164.123373] R13: ffffc90001ee3d60 R14: ffff88007cafb198 R15: 0000000000000000
> > [  164.124296] FS:  0000000000000000(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000
> > [  164.125322] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  164.126006] CR2: 0000000000000008 CR3: 000000007829c003 CR4: 00000000001606e0
> > [  164.126860] Call Trace:
> > [  164.127045]  ? call_retry_reserve+0x30/0x30 [sunrpc]
> > [  164.127622]  rpcauth_lookupcred+0xa0/0xc0 [sunrpc]
> > [  164.128200]  rpcauth_refreshcred+0x15f/0x170 [sunrpc]
> > [  164.128807]  __rpc_execute+0xa9/0x460 [sunrpc]
> > [  164.129281]  process_one_work+0x227/0x630
> > [  164.129684]  worker_thread+0x3c/0x390
> > [  164.130062]  ? process_one_work+0x630/0x630
> > [  164.130609]  kthread+0x11d/0x140
> > [  164.130936]  ? kthread_park+0x80/0x80
> > [  164.131339]  ret_from_fork+0x3a/0x50
> > [  164.131676] Modules linked in: rpcsec_gss_krb5 nfsv4 nfs lockd grace auth_rpcgss sunrpc
> > [  164.132719] CR2: 0000000000000008
> > [  164.133050] ---[ end trace b4028a6781a696ad ]---
> > 
> 
> I just encountered this repeatedly with cthon04 general tests.
> 
> MNTOPTIONS="rw,proto=tcp,vers=4.1,sec=sys"
> 
> 
> --
> Chuck Lever
> chucklever@gmail.com
> 
> 
