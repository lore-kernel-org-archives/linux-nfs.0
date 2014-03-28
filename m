Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55845 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855AbaC1WAv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2014 18:00:51 -0400
Date: Fri, 28 Mar 2014 18:00:38 -0400
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Andrew Martin <amartin@xes-inc.com>, Jim Rees <rees@umich.edu>,
        bhawley@luminex.com, Brown Neil <neilb@suse.de>,
        linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
Message-ID: <20140328220038.GK6041@fieldses.org>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>
 <20140306173632.GA18545@umich.edu>
 <1397912955.101159.1394130906695.JavaMail.zimbra@xes-inc.com>
 <B454F556-9381-4DB7-B864-EC066DBEAC63@primarydata.com>
 <2043391310.134091.1394135196565.JavaMail.zimbra@xes-inc.com>
 <76B038DA-3E86-4C46-BFB6-928BFB8202D8@primarydata.com>
 <521763040.159828.1394138758307.JavaMail.zimbra@xes-inc.com>
 <40C20DD8-9E8D-4625-B98C-A1E61D00AC17@primarydata.com>
 <693414378.60415.1395179429651.JavaMail.zimbra@xes-inc.com>
 <A95B7939-BDEB-4FFB-BCC0-6EAD9487E7D8@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <A95B7939-BDEB-4FFB-BCC0-6EAD9487E7D8@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 18, 2014 at 06:27:57PM -0400, Trond Myklebust wrote:
> 
> On Mar 18, 2014, at 17:50, Andrew Martin <amartin@xes-inc.com> wrote:
> 
> > ----- Original Message -----
> >> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
> >> To: "Andrew Martin" <amartin@xes-inc.com>
> >> Cc: "Jim Rees" <rees@umich.edu>, bhawley@luminex.com, "Brown Neil" <neilb@suse.de>, linux-nfs-owner@vger.kernel.org,
> >> linux-nfs@vger.kernel.org
> >> Sent: Thursday, March 6, 2014 3:01:03 PM
> >> Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
> >> 
> >> 
> > 
> > Trond,
> > 
> > This problem has reoccurred, and I have captured the debug output that you requested:
> > 
> > echo 0 >/proc/sys/sunrpc/rpc_debug:
> > http://pastebin.com/9juDs2TW
> > 
> > echo w > /proc/sysrq-trigger ; dmesg:
> > http://pastebin.com/1vDx9bNf
> > 
> > netstat -tn:
> > http://pastebin.com/mjxqjmuL
> > 
> > One suggestion for debug was to attempt to run "umount -f /path/to/mountpoint"
> > repeatedly to attempt to send SIGKILL back up to the application. This always
> > returned "Device or resource busy" and I was unable to unmount the filesystem
> > until I used "mount -l". 
> > 
> > I was able to kill -9 all but two of the processes that were blocking in
> > uninterruptable sleep. Note that I was able to get lsof output on these
> > processes this time, and they all appeared to be blocking on access to a
> > single file on the nfs share. If I tried to cat said file from this client,
> > my terminal would block:
> > open("/path/to/file", O_RDONLY)        = 3
> > fstat(3, {st_mode=S_IFREG|0644, st_size=42385, ...}) = 0
> > mmap(NULL, 1056768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fb00f0dc000
> > read(3,
> > 
> > However, I could cat the file just fine from another nfs client. Does this 
> > additional information shed any light on the source of this problem?
> > 
> 
> Ah… So this machine is acting both as a NFSv3 client and a NFSv4 server?
> 
> 	• [1140235.544551] SysRq : Show Blocked State
> 	• [1140235.547126]   task                        PC stack   pid father
> 	• [1140235.547145] rpciod/0      D 0000000000000001     0   833      2 0x00000000
> 	• [1140235.547150]  ffff8802812a3c20 0000000000000046 0000000000015e00 0000000000015e00
> 	• [1140235.547155]  ffff880297251ad0 ffff8802812a3fd8 0000000000015e00 ffff880297251700
> 	• [1140235.547159]  0000000000015e00 ffff8802812a3fd8 0000000000015e00 ffff880297251ad0
> 	• [1140235.547164] Call Trace:
> 	• [1140235.547175]  [<ffffffff8156a1a5>] schedule_timeout+0x195/0x300
> 	• [1140235.547182]  [<ffffffff81078130>] ? process_timeout+0x0/0x10
> 	• [1140235.547197]  [<ffffffffa009ef52>] rpc_shutdown_client+0xc2/0x100 [sunrpc]
> 	• [1140235.547203]  [<ffffffff81086750>] ? autoremove_wake_function+0x0/0x40
> 	• [1140235.547216]  [<ffffffffa01aa62c>] put_nfs4_client+0x4c/0xb0 [nfsd]
> 	• [1140235.547227]  [<ffffffffa01ae669>] nfsd4_cb_probe_done+0x29/0x60 [nfsd]
> 	• [1140235.547238]  [<ffffffffa00a5d0c>] rpc_exit_task+0x2c/0x60 [sunrpc]
> 	• [1140235.547250]  [<ffffffffa00a64e6>] __rpc_execute+0x66/0x2a0 [sunrpc]
> 	• [1140235.547261]  [<ffffffffa00a6750>] ? rpc_async_schedule+0x0/0x20 [sunrpc]
> 	• [1140235.547272]  [<ffffffffa00a6765>] rpc_async_schedule+0x15/0x20 [sunrpc]
> 	• [1140235.547276]  [<ffffffff81081ba7>] run_workqueue+0xc7/0x1a0
> 	• [1140235.547279]  [<ffffffff81081d23>] worker_thread+0xa3/0x110
> 	• [1140235.547284]  [<ffffffff81086750>] ? autoremove_wake_function+0x0/0x40
> 	• [1140235.547287]  [<ffffffff81081c80>] ? worker_thread+0x0/0x110
> 	• [1140235.547291]  [<ffffffff810863d6>] kthread+0x96/0xa0
> 	• [1140235.547295]  [<ffffffff810141aa>] child_rip+0xa/0x20
> 	• [1140235.547299]  [<ffffffff81086340>] ? kthread+0x0/0xa0
> 	• [1140235.547302]  [<ffffffff810141a0>] ? child_rip+0x0/0x20
> 
> the above looks bad. The rpciod thread is sleeping, waiting for the rpc client to terminate, and the only task running on that rpc client, according to your rpc_debug output is the above CB_NULL probe. Deadlock...
> 
> Bruce, it looks like the above should have been fixed in Linux 2.6.35 with commit 9045b4b9f7f3 (nfsd4: remove probe task's reference on client), is that correct?

Yes, that definitely looks it would explain the bug.  And the sysrq
trace shows 2.6.32-57.

Andrew Martin, can you confirm that the problem is no longer
reproduceable on a kernel with that patch applied?

--b.
