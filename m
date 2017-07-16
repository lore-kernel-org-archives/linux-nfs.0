Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:36448 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751244AbdGPVPe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Jul 2017 17:15:34 -0400
Date: Sun, 16 Jul 2017 17:15:30 -0400
From: Dave Jones <davej@codemonkey.org.uk>
To: Anna Schumaker <schumaker.anna@gmail.com>,
        torvalds@linux-foundation.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
Message-ID: <20170716211530.sx7mn35f2mhmykug@codemonkey.org.uk>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 14, 2017 at 10:25:43AM -0400, Dave Jones wrote:
 > On Thu, Jul 13, 2017 at 05:16:24PM -0400, Anna Schumaker wrote:
 >  > Hi Linus,
 >  > 
 >  > The following changes since commit 32c1431eea4881a6b17bd7c639315010aeefa452:
 >  > 
 >  >   Linux 4.12-rc5 (2017-06-11 16:48:20 -0700)
 >  > 
 >  > are available in the git repository at:
 >  > 
 >  >   git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.13-1
 >  > 
 >  > for you to fetch changes up to b4f937cffa66b3d56eb8f586e620d0b223a281a3:
 >  > 
 >  >   NFS: Don't run wake_up_bit() when nobody is waiting... (2017-07-13 16:57:18 -0400)
 > 
 > Since this landed, I'm seeing this during boot..
 > 
 >  ==================================================================
 >  BUG: KASAN: global-out-of-bounds in strscpy+0x4a/0x230
 >  Read of size 8 at addr ffffffffb4eeaf20 by task nfsd/688

Now that this one got fixed, this one fell out instead..
Will dig deeper tomorrow.

==================================================================
BUG: KASAN: global-out-of-bounds in call_start+0x93/0x100
Read of size 8 at addr ffffffff8d582588 by task kworker/0:1/22

CPU: 0 PID: 22 Comm: kworker/0:1 Not tainted 4.13.0-rc1-firewall+ #1 
Workqueue: rpciod rpc_async_schedule
Call Trace:
 dump_stack+0x68/0x94
 print_address_description+0x2c/0x270
 ? call_start+0x93/0x100
 kasan_report+0x239/0x350
 __asan_load8+0x55/0x90
 call_start+0x93/0x100
 ? rpc_default_callback+0x10/0x10
 ? rpc_default_callback+0x10/0x10
 __rpc_execute+0x170/0x740
 ? rpc_wake_up_queued_task+0x50/0x50
 ? __lock_is_held+0x9f/0x110
 rpc_async_schedule+0x12/0x20
 process_one_work+0x4ba/0xb10
 ? process_one_work+0x401/0xb10
 ? pwq_dec_nr_in_flight+0x120/0x120
 worker_thread+0x91/0x670
 ? __sched_text_start+0x8/0x8
 kthread+0x1ab/0x200
 ? process_one_work+0xb10/0xb10
 ? __kthread_create_on_node+0x340/0x340
 ret_from_fork+0x27/0x40

The buggy address belongs to the variable:
 nfs_cb_version+0x8/0x740

Memory state around the buggy address:
 ffffffff8d582480: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffffffff8d582500: 00 00 00 00 00 00 00 00 00 00 fa fa fa fa fa fa
>ffffffff8d582580: 00 fa fa fa fa fa fa fa 00 00 00 00 00 00 00 00
                      ^
 ffffffff8d582600: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffffffff8d582680: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
==================================================================

