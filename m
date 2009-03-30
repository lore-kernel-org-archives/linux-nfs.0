From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/47] NFSv4.1 Sessions server code for 2.6.30
Date: Mon, 30 Mar 2009 14:33:38 -0400
Message-ID: <20090330183338.GE31237@fieldses.org>
References: <49CC40E5.2080506@panasas.com> <20090328000134.GH18222@fieldses.org> <49CDDFC2.4070402@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:53046 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbZC3Sdk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 14:33:40 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 28, 2009 at 11:28:50AM +0300, Benny Halevy wrote:
> On Mar. 28, 2009, 3:01 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Fri, Mar 27, 2009 at 05:58:45AM +0300, Benny Halevy wrote:
> >> Hi Bruce,
> >>
> >> Here's the latest server patches implementing the NFSv4.1
> >> Sessions features.
> >>
> >> This patchset is based over your for-2.6.30 branch
> >> and is also available from
> >> git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd41-for-2.6.30
> > 
> > There's a few merge conflicts with my current for-2.6.30--probably my
> > fault for not pushing that out recently enough, apologies.  Would you
> > mind updating?
> > 
> > --b.
> > 
> 
> Sure. Here's a rebased version with two minor changes (see below)

On the latest version of nfsd41-for-2.6.30 (a564667..) I'm getting a new NULL
dereference in the callback code.  Looks like it probably happened while
running connectathon over NFSv4.0 with krb5p.  That's all I've figured out so
far.

--b.

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<c03e4e1e>] nfs4_xdr_dec_cb_recall+0x4e/0x200
*pde = 00000000 
Oops: 0000 [#1] PREEMPT 
last sysfs file: /sys/kernel/uevent_seqnum
Modules linked in:

Pid: 3949, comm: nfs4_cb_recall Not tainted (2.6.29-rc8-00312-ga564667 #39) 
EIP: 0060:[<c03e4e1e>] EFLAGS: 00010286 CPU: 0
EIP is at nfs4_xdr_dec_cb_recall+0x4e/0x200
EAX: c7bb22a0 EBX: c7bb2298 ECX: c7bb22a0 EDX: c7bb22a4
ESI: 00000000 EDI: c66e3000 EBP: c5281ea4 ESP: c5281e6c
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process nfs4_cb_recall (pid: 3949, ti=c5280000 task=c66a6b60 task.ti=c5280000)
Stack:
 c66a6b60 00000000 c5281eb4 c086cab4 c0aa0380 00000001 c11bd4a4 c7bb22a4
 c66e302c c7bb22ac c66e302c 00000000 c6cf14e8 c66e3000 c5281ecc c08199c3
 c0819aae 00000000 c5281ee8 c5281ef0 c03e4dd0 c6cf14e8 c7bb2298 c03e4dd0
Call Trace:
 [<c086cab4>] ? schedule+0x354/0x540
 [<c08199c3>] ? rpcauth_unwrap_resp+0x63/0x90
 [<c0819aae>] ? rpcauth_checkverf+0x2e/0x70
 [<c03e4dd0>] ? nfs4_xdr_dec_cb_recall+0x0/0x200
 [<c03e4dd0>] ? nfs4_xdr_dec_cb_recall+0x0/0x200
 [<c08122ce>] ? call_decode+0x1ae/0x820
 [<c086d125>] ? out_of_line_wait_on_bit+0x65/0x80
 [<c0818720>] ? rpc_wait_bit_killable+0x0/0x40
 [<c03e4dd0>] ? nfs4_xdr_dec_cb_recall+0x0/0x200
 [<c0818e62>] ? __rpc_execute+0x92/0x290
 [<c086f4fc>] ? _spin_unlock+0x2c/0x50
 [<c08186c7>] ? rpc_set_active+0x67/0x80
 [<c081907e>] ? rpc_execute+0x1e/0x30
 [<c08129e5>] ? rpc_run_task+0x35/0x70
 [<c0812b40>] ? rpc_call_sync+0x40/0x70
 [<c03e51e0>] ? nfsd4_cb_recall+0x70/0x130
 [<c086cab4>] ? schedule+0x354/0x540
 [<c0247d1b>] ? trace_hardirqs_on+0xb/0x10
 [<c03dfd40>] ? do_recall+0x0/0x20
 [<c03dfd54>] ? do_recall+0x14/0x20
 [<c023941f>] ? kthread+0x3f/0x70
 [<c02393e0>] ? kthread+0x0/0x70
 [<c0203b67>] ? kernel_thread_helper+0x7/0x10
Code: 43 00 ba 08 00 00 00 8d 45 e4 e8 0e c1 43 00 85 c0 74 3a 8b 50 04 8d 45 e4 0f ca 83 c2 04 e8 fa c0 43 00 85 c0 0f 84 8a 00 00 00 <8b> 06 8b 00 85 c0 75 32 ba 04 00 00 00 8d 45 e4 e8 cd fe ff ff 
EIP: [<c03e4e1e>] nfs4_xdr_dec_cb_recall+0x4e/0x200 SS:ESP 0068:c5281e6c
---[ end trace 2724475d9856cb6c ]---

