Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:57250 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753726AbdGNOZq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 10:25:46 -0400
Date: Fri, 14 Jul 2017 10:25:43 -0400
From: Dave Jones <davej@codemonkey.org.uk>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: torvalds@linux-foundation.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
Message-ID: <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 13, 2017 at 05:16:24PM -0400, Anna Schumaker wrote:
 > Hi Linus,
 > 
 > The following changes since commit 32c1431eea4881a6b17bd7c639315010aeefa452:
 > 
 >   Linux 4.12-rc5 (2017-06-11 16:48:20 -0700)
 > 
 > are available in the git repository at:
 > 
 >   git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.13-1
 > 
 > for you to fetch changes up to b4f937cffa66b3d56eb8f586e620d0b223a281a3:
 > 
 >   NFS: Don't run wake_up_bit() when nobody is waiting... (2017-07-13 16:57:18 -0400)

Since this landed, I'm seeing this during boot..

 ==================================================================
 BUG: KASAN: global-out-of-bounds in strscpy+0x4a/0x230
 Read of size 8 at addr ffffffffb4eeaf20 by task nfsd/688
 
 CPU: 0 PID: 688 Comm: nfsd Not tainted 4.12.0-firewall+ #14 
 Call Trace:
  dump_stack+0x68/0x94
  print_address_description+0x2c/0x270
  ? strscpy+0x4a/0x230
  kasan_report+0x239/0x350
  __asan_load8+0x55/0x90
  strscpy+0x4a/0x230
  __ip_map_lookup+0x85/0x150
  ? ip_map_init+0x50/0x50
  ? lock_acquire+0x270/0x270
  svcauth_unix_set_client+0x9f3/0xdc0
  ? svcauth_unix_set_client+0x5/0xdc0
  ? unix_gid_parse+0x340/0x340
  ? kasan_kmalloc+0xbb/0xf0
  ? groups_alloc+0x29/0x80
  ? __kmalloc+0x13b/0x360
  ? groups_alloc+0x29/0x80
  ? groups_alloc+0x48/0x80
  ? svcauth_unix_accept+0x3a5/0x3c0
  svc_set_client+0x50/0x60
  svc_process+0x901/0x10b0
  ? svc_register+0x430/0x430
  ? __might_sleep+0x78/0xf0
  ? preempt_count_sub+0xaf/0x120
  ? __validate_process_creds+0x9e/0x160
  nfsd+0x250/0x380
  ? nfsd+0x5/0x380
  kthread+0x1ab/0x200
  ? nfsd_destroy+0x1f0/0x1f0
  ? __kthread_create_on_node+0x340/0x340
  ret_from_fork+0x27/0x40
 
 The buggy address belongs to the variable:
  str__nfsd__trace_system_name+0x3a0/0x3e0
 
 Memory state around the buggy address:
  ffffffffb4eeae00: 00 00 00 01 fa fa fa fa 00 00 00 00 00 04 fa fa
  ffffffffb4eeae80: fa fa fa fa 04 fa fa fa fa fa fa fa 04 fa fa fa
 >ffffffffb4eeaf00: fa fa fa fa 05 fa fa fa fa fa fa fa 00 00 00 00
                                ^   
  ffffffffb4eeaf80: 00 fa fa fa fa fa fa fa 00 00 05 fa fa fa fa fa
  ffffffffb4eeb000: 00 03 fa fa fa fa fa fa 00 07 fa fa fa fa fa fa
 ==================================================================

