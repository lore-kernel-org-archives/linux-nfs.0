Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18313 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293Ab2LUSlP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Dec 2012 13:41:15 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>
Subject: Re: nfsd oops on Linus' current tree.
Date: Fri, 21 Dec 2012 18:40:54 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91197273D@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121221153348.GA32151@redhat.com>
	 <20121221180824.GA27729@fieldses.org>
In-Reply-To: <20121221180824.GA27729@fieldses.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-12-21 at 13:08 -0500, J. Bruce Fields wrote:
+AD4- On Fri, Dec 21, 2012 at 10:33:48AM -0500, Dave Jones wrote:
+AD4- +AD4- Did a mount from a client (also running Linus current), and the
+AD4- +AD4- server spat this out..
+AD4- +AD4- 
+AD4- +AD4- +AFs- 6936.306135+AF0- ------------+AFs- cut here +AF0-------------
+AD4- +AD4- +AFs- 6936.306154+AF0- WARNING: at net/sunrpc/clnt.c:617 rpc+AF8-shutdown+AF8-client+-0x12a/0x1b0 +AFs-sunrpc+AF0-()
+AD4- 
+AD4- This is a warning added by 168e4b39d1afb79a7e3ea6c3bb246b4c82c6bdb9
+AD4- +ACI-SUNRPC: add WARN+AF8-ON+AF8-ONCE for potential deadlock+ACI-, pointing out that
+AD4- nfsd is calling shutdown+AF8-client from a workqueue, which is a problem
+AD4- because shutdown+AF8-client has to wait on rpc tasks that run on a
+AD4- workqueue.
+AD4- 
+AD4- I don't believe there's any circular dependency among the workqueues
+AD4- (we're calling shutdown+AF8-client from callback+AF8-wq, not rpciod+AF8-workqueue),

We were getting deadlocks with rpciod when calling rpc+AF8-shutdown+AF8-client
from the nfsiod workqueue.

The problem here is that the workqueues all run using the same pool of
threads, and so you can get +ACI-interesting+ACI- deadlocks when one of these
threads has to wait for another one.

+AD4- but 168e4b39d1afb.. says that we could get a deadlock if both are
+AD4- running on the same kworker thread.
+AD4- 
+AD4- I'm not sure what to do about that.
+AD4- 

The question is if you really do need the call to rpc+AF8-killall+AF8-tasks and
the synchronous wait for completion of old tasks? If you don't care,
then we could just have you call rpc+AF8-release+AF8-client() in order to
release your reference on the rpc+AF8-client.

+AD4- +AD4- +AFs- 6936.306156+AF0- Hardware name:         
+AD4- +AD4- +AFs- 6936.306157+AF0- Modules linked in: ip6t+AF8-REJECT nf+AF8-conntrack+AF8-ipv6 nf+AF8-defrag+AF8-ipv6 xt+AF8-conntrack nf+AF8-conntrack ip6table+AF8-filter ip6+AF8-tables xfs coretemp iTCO+AF8-wdt iTCO+AF8-vendor+AF8-support snd+AF8-emu10k1 microcode snd+AF8-util+AF8-mem snd+AF8-ac97+AF8-codec ac97+AF8-bus snd+AF8-hwdep snd+AF8-seq snd+AF8-pcm snd+AF8-page+AF8-alloc snd+AF8-timer e1000e snd+AF8-rawmidi snd+AF8-seq+AF8-device snd emu10k1+AF8-gp pcspkr i2c+AF8-i801 soundcore gameport lpc+AF8-ich mfd+AF8-core i82975x+AF8-edac edac+AF8-core vhost+AF8-net tun macvtap macvlan kvm+AF8-intel kvm binfmt+AF8-misc nfsd auth+AF8-rpcgss nfs+AF8-acl lockd sunrpc btrfs libcrc32c zlib+AF8-deflate usb+AF8-storage firewire+AF8-ohci firewire+AF8-core sata+AF8-sil crc+AF8-itu+AF8-t radeon i2c+AF8-algo+AF8-bit drm+AF8-kms+AF8-helper ttm drm i2c+AF8-core floppy
+AD4- +AD4- +AFs- 6936.306214+AF0- Pid: 52, comm: kworker/u:2 Not tainted 3.7.0+- +ACM-34
+AD4- +AD4- +AFs- 6936.306216+AF0- Call Trace:
+AD4- +AD4- +AFs- 6936.306224+AF0-  +AFsAPA-ffffffff8106badf+AD4AXQ- warn+AF8-slowpath+AF8-common+-0x7f/0xc0
+AD4- +AD4- +AFs- 6936.306227+AF0-  +AFsAPA-ffffffff8106bb3a+AD4AXQ- warn+AF8-slowpath+AF8-null+-0x1a/0x20
+AD4- +AD4- +AFs- 6936.306235+AF0-  +AFsAPA-ffffffffa02c62ca+AD4AXQ- rpc+AF8-shutdown+AF8-client+-0x12a/0x1b0 +AFs-sunrpc+AF0-
+AD4- +AD4- +AFs- 6936.306240+AF0-  +AFsAPA-ffffffff81368318+AD4AXQ- ? delay+AF8-tsc+-0x98/0xf0
+AD4- +AD4- +AFs- 6936.306252+AF0-  +AFsAPA-ffffffffa034a60b+AD4AXQ- nfsd4+AF8-process+AF8-cb+AF8-update.isra.16+-0x4b/0x230 +AFs-nfsd+AF0-
+AD4- +AD4- +AFs- 6936.306256+AF0-  +AFsAPA-ffffffff8109677c+AD4AXQ- ? +AF8AXw-rcu+AF8-read+AF8-unlock+-0x5c/0xa0
+AD4- +AD4- +AFs- 6936.306260+AF0-  +AFsAPA-ffffffff81370d46+AD4AXQ- ? debug+AF8-object+AF8-deactivate+-0x46/0x130
+AD4- +AD4- +AFs- 6936.306269+AF0-  +AFsAPA-ffffffffa034a87d+AD4AXQ- nfsd4+AF8-do+AF8-callback+AF8-rpc+-0x8d/0xa0 +AFs-nfsd+AF0-
+AD4- +AD4- +AFs- 6936.306272+AF0-  +AFsAPA-ffffffff810900f7+AD4AXQ- process+AF8-one+AF8-work+-0x207/0x760
+AD4- +AD4- +AFs- 6936.306274+AF0-  +AFsAPA-ffffffff81090087+AD4AXQ- ? process+AF8-one+AF8-work+-0x197/0x760
+AD4- +AD4- +AFs- 6936.306277+AF0-  +AFsAPA-ffffffff81090afe+AD4AXQ- ? worker+AF8-thread+-0x21e/0x440
+AD4- +AD4- +AFs- 6936.306285+AF0-  +AFsAPA-ffffffffa034a7f0+AD4AXQ- ? nfsd4+AF8-process+AF8-cb+AF8-update.isra.16+-0x230/0x230 +AFs-nfsd+AF0-
+AD4- +AD4- +AFs- 6936.306289+AF0-  +AFsAPA-ffffffff81090a3e+AD4AXQ- worker+AF8-thread+-0x15e/0x440
+AD4- +AD4- +AFs- 6936.306292+AF0-  +AFsAPA-ffffffff810908e0+AD4AXQ- ? rescuer+AF8-thread+-0x250/0x250
+AD4- +AD4- +AFs- 6936.306295+AF0-  +AFsAPA-ffffffff8109b16d+AD4AXQ- kthread+-0xed/0x100
+AD4- +AD4- +AFs- 6936.306299+AF0-  +AFsAPA-ffffffff810dd86e+AD4AXQ- ? put+AF8-lock+AF8-stats.isra.25+-0xe/0x40
+AD4- +AD4- +AFs- 6936.306302+AF0-  +AFsAPA-ffffffff8109b080+AD4AXQ- ? kthread+AF8-create+AF8-on+AF8-node+-0x160/0x160
+AD4- +AD4- +AFs- 6936.306307+AF0-  +AFsAPA-ffffffff81711e2c+AD4AXQ- ret+AF8-from+AF8-fork+-0x7c/0xb0
+AD4- +AD4- +AFs- 6936.306310+AF0-  +AFsAPA-ffffffff8109b080+AD4AXQ- ? kthread+AF8-create+AF8-on+AF8-node+-0x160/0x160
+AD4- +AD4- +AFs- 6936.306312+AF0- ---+AFs- end trace 5bab69e086ae3c6f +AF0----
+AD4- +AD4- +AFs- 6936.363213+AF0- ------------+AFs- cut here +AF0-------------
+AD4- +AD4- +AFs- 6936.363226+AF0- WARNING: at fs/nfsd/vfs.c:937 nfsd+AF8-vfs+AF8-read.isra.13+-0x197/0x1b0 +AFs-nfsd+AF0-()
+AD4- 
+AD4- This warning is unrelated, and is probably just carelessness on my part:
+AD4- I couldn't see why this condition would happen, and I stuck the warning
+AD4- in there without looking much harder.  Probably we should just revert
+AD4- 79f77bf9a4e3dd5ead006b8f17e7c4ff07d8374e +ACI-nfsd: warn on odd reply state
+AD4- in nfsd+AF8-vfs+AF8-read+ACI- while I go stare at the code.
+AD4- 
+AD4- --b.
+AD4- 
+AD4- +AD4- +AFs- 6936.363229+AF0- Hardware name:         
+AD4- +AD4- +AFs- 6936.363230+AF0- Modules linked in: ip6t+AF8-REJECT nf+AF8-conntrack+AF8-ipv6 nf+AF8-defrag+AF8-ipv6 xt+AF8-conntrack nf+AF8-conntrack ip6table+AF8-filter ip6+AF8-tables xfs coretemp iTCO+AF8-wdt iTCO+AF8-vendor+AF8-support snd+AF8-emu10k1 microcode snd+AF8-util+AF8-mem snd+AF8-ac97+AF8-codec ac97+AF8-bus snd+AF8-hwdep snd+AF8-seq snd+AF8-pcm snd+AF8-page+AF8-alloc snd+AF8-timer e1000e snd+AF8-rawmidi snd+AF8-seq+AF8-device snd emu10k1+AF8-gp pcspkr i2c+AF8-i801 soundcore gameport lpc+AF8-ich mfd+AF8-core i82975x+AF8-edac edac+AF8-core vhost+AF8-net tun macvtap macvlan kvm+AF8-intel kvm binfmt+AF8-misc nfsd auth+AF8-rpcgss nfs+AF8-acl lockd sunrpc btrfs libcrc32c zlib+AF8-deflate usb+AF8-storage firewire+AF8-ohci firewire+AF8-core sata+AF8-sil crc+AF8-itu+AF8-t radeon i2c+AF8-algo+AF8-bit drm+AF8-kms+AF8-helper ttm drm i2c+AF8-core floppy
+AD4- +AD4- +AFs- 6936.363284+AF0- Pid: 699, comm: nfsd Tainted: G        W    3.7.0+- +ACM-34
+AD4- +AD4- +AFs- 6936.363286+AF0- Call Trace:
+AD4- +AD4- +AFs- 6936.363293+AF0-  +AFsAPA-ffffffff8106badf+AD4AXQ- warn+AF8-slowpath+AF8-common+-0x7f/0xc0
+AD4- +AD4- +AFs- 6936.363296+AF0-  +AFsAPA-ffffffff8106bb3a+AD4AXQ- warn+AF8-slowpath+AF8-null+-0x1a/0x20
+AD4- +AD4- +AFs- 6936.363302+AF0-  +AFsAPA-ffffffffa031ef77+AD4AXQ- nfsd+AF8-vfs+AF8-read.isra.13+-0x197/0x1b0 +AFs-nfsd+AF0-
+AD4- +AD4- +AFs- 6936.363310+AF0-  +AFsAPA-ffffffffa0321948+AD4AXQ- nfsd+AF8-read+AF8-file+-0x88/0xb0 +AFs-nfsd+AF0-
+AD4- +AD4- +AFs- 6936.363317+AF0-  +AFsAPA-ffffffffa0332956+AD4AXQ- nfsd4+AF8-encode+AF8-read+-0x186/0x260 +AFs-nfsd+AF0-
+AD4- +AD4- +AFs- 6936.363325+AF0-  +AFsAPA-ffffffffa03391cc+AD4AXQ- nfsd4+AF8-encode+AF8-operation+-0x5c/0xa0 +AFs-nfsd+AF0-
+AD4- +AD4- +AFs- 6936.363333+AF0-  +AFsAPA-ffffffffa032e5a9+AD4AXQ- nfsd4+AF8-proc+AF8-compound+-0x289/0x780 +AFs-nfsd+AF0-
+AD4- +AD4- +AFs- 6936.363339+AF0-  +AFsAPA-ffffffffa0319e5b+AD4AXQ- nfsd+AF8-dispatch+-0xeb/0x230 +AFs-nfsd+AF0-
+AD4- +AD4- +AFs- 6936.363355+AF0-  +AFsAPA-ffffffffa02d3d38+AD4AXQ- svc+AF8-process+AF8-common+-0x328/0x6d0 +AFs-sunrpc+AF0-
+AD4- +AD4- +AFs- 6936.363365+AF0-  +AFsAPA-ffffffffa02d4433+AD4AXQ- svc+AF8-process+-0x103/0x160 +AFs-sunrpc+AF0-
+AD4- +AD4- +AFs- 6936.363371+AF0-  +AFsAPA-ffffffffa031921b+AD4AXQ- nfsd+-0xdb/0x160 +AFs-nfsd+AF0-
+AD4- +AD4- +AFs- 6936.363378+AF0-  +AFsAPA-ffffffffa0319140+AD4AXQ- ? nfsd+AF8-destroy+-0x210/0x210 +AFs-nfsd+AF0-
+AD4- +AD4- +AFs- 6936.363381+AF0-  +AFsAPA-ffffffff8109b16d+AD4AXQ- kthread+-0xed/0x100
+AD4- +AD4- +AFs- 6936.363385+AF0-  +AFsAPA-ffffffff810dd86e+AD4AXQ- ? put+AF8-lock+AF8-stats.isra.25+-0xe/0x40
+AD4- +AD4- +AFs- 6936.363388+AF0-  +AFsAPA-ffffffff8109b080+AD4AXQ- ? kthread+AF8-create+AF8-on+AF8-node+-0x160/0x160
+AD4- +AD4- +AFs- 6936.363393+AF0-  +AFsAPA-ffffffff81711e2c+AD4AXQ- ret+AF8-from+AF8-fork+-0x7c/0xb0
+AD4- +AD4- +AFs- 6936.363396+AF0-  +AFsAPA-ffffffff8109b080+AD4AXQ- ? kthread+AF8-create+AF8-on+AF8-node+-0x160/0x160
+AD4- +AD4- +AFs- 6936.363398+AF0- ---+AFs- end trace 5bab69e086ae3c70 +AF0----
+AD4- +AD4- 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
