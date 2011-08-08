Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bollo.wholemeal.co.nz ([120.138.17.108]:48607 "EHLO
	bollo.wholemeal.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821Ab1HHNJZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2011 09:09:25 -0400
Date: Tue, 9 Aug 2011 00:51:14 +1200
From: Malcolm Locke <malc@wholemeal.co.nz>
To: linux-nfs@vger.kernel.org
Message-ID: <20110808125114.GB5217@rudy>
Content-Type: text/plain; charset=us-ascii
Subject: Problems with locking, permanent 'lockd: server in grace period'
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

First off, apologies for bringing such mundane matters to the list, but
we're at the end of our tethers and way out of our depth on this.  We
have a problem on our production machine that we are unable to replicate
on a test machine, and would greatly appreciate any pointers of where to
look next.

We're in the process of upgrading a DRBD pair running Ubuntu hardy to
Debian squeeze.  The first of the pair has been upgraded, and NFS works
correctly except for locking.  Calls to flock() from any client on an
NFS mount hang indefinitely.

We've installed a fresh Debian squeeze machine to test, but are
completely unable to reproduce the issue.  Pertinent details about the
set up:

Kernel on both machines:
  Linux debian 2.6.32-5-openvz-amd64 #1 SMP Tue Jun 14 10:46:15 UTC 2011
  x86_64 GNU/Linux

  Debian package versions:
  nfs-common 1.2.2-4
  nfs-kernel-server 1.2.2-4
  rpcbind 0.2.0-4.1

  Filesystem is ext3 rw,relatime,errors=remount-ro,data=ordered
  /etc/exports has rw,no_root_squash,async,no_subtree_check

On both the working and failing hosts, the NFS is mounted with default
options, e.g. mount host:/home /mnt

Below is the nlm debug from the working host (hostname debian on the
left) and the failing host (itchy on the right).  Apologies for the wide
text, I've aligned the log messages from a single flock() attempt so the
corresponding lines match up for each host.  In both cases, the NFS
client and server are the same host.

Points I note from this are:

- xdr_dec_stat_res doesn't get called on the failing host
- nlm_lookup_host reports 'found host' on the failing host, and
  'created host' on the working host.
- vfs_lock_file returned 0 doesn't log on the failing host.  I think
  this is because one of the following checks is returning true:

    // fs/lockd/svclock.c:411
    if (locks_in_grace() && !reclaim) {
            ret = nlm_lck_denied_grace_period;
            goto out;
    }
    if (reclaim && !locks_in_grace()) {
            ret = nlm_lck_denied_grace_period;
            goto out;
    }
    
  I've come to this conclusion because of the 'lockd: server in grace
  period'.  The failing host has been up for several days, and on both
  machines /proc/sys/fs/nfs/nlm_grace_period is 0.

Any help on this would be greatly appreciated, including where to go
next.  If you require any more info let me know.  Thanks for your time.

Malc



[574991.066444] lockd: get host 192.168.200.187	                                                                    [293744.611248] lockd: get host itchy
[574991.066452] lockd: get host 192.168.200.187	                                                                    [293744.611253] lockd: get host itchy
[574991.066459] lockd: nsm_monitor(192.168.200.187)	                                                                [293744.611258] lockd: nsm_monitor(itchy)
[574991.069694] lockd: xdr_dec_stat_res status 0 state 5	
[574991.069704] lockd: call procedure 2 on 192.168.200.187	                                                        [293744.611262] lockd: call procedure 2 on itchy
[574991.069707] lockd: nlm_bind_host 192.168.200.187 (192.168.200.187)	                                            [293744.611264] lockd: nlm_bind_host itchy (172.16.95.10)
[574991.069950] lockd: request from 192.168.200.187, port=897	                                                      [293744.611305] lockd: request from 172.16.95.10, port=755
[574991.069957] lockd: LOCK          called	                                                                        [293744.611313] lockd: LOCK          called
[574991.069959] lockd: nlmsvc_lookup_host(host='debian', vers=4, proto=tcp)	                                        [293744.611316] lockd: nlmsvc_lookup_host(host='itchy', vers=4, proto=tcp)
	                                                                                                                  [293744.611321] lockd: get host itchy
[574991.069963] lockd: nlm_lookup_host created host 192.168.200.187	                                                [293744.611323] lockd: nlm_lookup_host found host itchy (172.16.95.10)
[574991.069965] lockd: nsm_monitor(192.168.200.187)	                                                                [293744.611326] lockd: nsm_monitor(itchy)
[574991.069968] lockd: nlm_lookup_file (01070001 00029c11 00000000 4d467ad5 49423ea4 e25c57a1 19207193 00029c23)	  [293744.611330] lockd: nlm_lookup_file (01070001 0003da31 00000000 97fe8af7 994c3d1e 44abb885 3e24dab0 0003da5b)
[574991.069973] lockd: creating file for (01070001 00029c11 00000000 4d467ad5 49423ea4 e25c57a1 19207193 00029c23)	[293744.611335] lockd: creating file for (01070001 0003da31 00000000 97fe8af7 994c3d1e 44abb885 3e24dab0 0003da5b)
[574991.069985] lockd: found file ffff880122c87800 (count 0)	                                                      [293744.611347] lockd: found file ffff880429d90400 (count 0)
[574991.069989] lockd: nlmsvc_lock(sda2/171043, ty=1, pi=0, 0-9223372036854775807, bl=1)	                          [293744.611351] lockd: nlmsvc_lock(md0/252507, ty=1, pi=7, 0-9223372036854775807, bl=1)
[574991.069993] lockd: nlmsvc_lookup_block f=ffff880122c87800 pd=0 0-9223372036854775807 ty=1	                      [293744.611355] lockd: nlmsvc_lookup_block f=ffff880429d90400 pd=7 0-9223372036854775807 ty=1
[574991.069996] lockd: get host 192.168.200.187	                                                                    [293744.611359] lockd: get host itchy
[574991.069999] lockd: created block ffff8801249a8200...	                                                          [293744.611363] lockd: created block ffff8803fa388b00...
[574991.070003] lockd: vfs_lock_file returned 0	
[574991.070005] lockd: freeing block ffff8801249a8200...	                                                          [293744.611366] lockd: freeing block ffff8803fa388b00...
[574991.070007] lockd: release host 192.168.200.187	                                                                [293744.611369] lockd: release host itchy
[574991.070009] lockd: nlm_release_file(ffff880122c87800, ct = 2)	                                                  [293744.611372] lockd: nlm_release_file(ffff880429d90400, ct = 2)
[574991.070011] lockd: nlmsvc_lock returned 0	                                                                      [293744.611375] lockd: nlmsvc_lock returned 67108864
[574991.070013] lockd: LOCK         status 0	                                                                      [293744.611377] lockd: LOCK         status 4
[574991.070014] lockd: release host 192.168.200.187	                                                                [293744.611379] lockd: release host itchy
[574991.070016] lockd: nlm_release_file(ffff880122c87800, ct = 1)	                                                  [293744.611381] lockd: nlm_release_file(ffff880429d90400, ct = 1)
[574991.070063] lockd: server returns status 0	
[574991.070072] lockd: release host 192.168.200.187	
[574991.070077] lockd: clnt proc returns 0	
[574991.070917] lockd: get host 192.168.200.187	
[574991.070920] lockd: get host 192.168.200.187	
[574991.070923] lockd: release host 192.168.200.187	
[574991.070925] lockd: release host 192.168.200.187	
[574991.070927] lockd: clnt proc returns 0	
[574991.070975] lockd: get host 192.168.200.187	
[574991.070978] lockd: get host 192.168.200.187	
[574991.070980] lockd: release host 192.168.200.187	
[574991.070982] lockd: release host 192.168.200.187	
[574991.070983] lockd: clnt proc returns 0	
[574991.070985] lockd: get host 192.168.200.187	
[574991.070988] lockd: call procedure 4 on 192.168.200.187 (async)	
[574991.070990] lockd: nlm_bind_host 192.168.200.187 (192.168.200.187)	
[574991.071014] lockd: request from 192.168.200.187, port=897	
[574991.071018] lockd: UNLOCK        called	
[574991.071020] lockd: nlmsvc_lookup_host(host='debian', vers=4, proto=tcp)	
[574991.071023] lockd: get host 192.168.200.187	
[574991.071024] lockd: nlm_lookup_host found host 192.168.200.187 (192.168.200.187)	
[574991.071028] lockd: nlm_lookup_file (01070001 00029c11 00000000 4d467ad5 49423ea4 e25c57a1 19207193 00029c23)	
[574991.071031] lockd: found file ffff880122c87800 (count 0)	
[574991.071034] lockd: nlmsvc_unlock(sda2/171043, pi=0, 0-9223372036854775807)	
[574991.071037] lockd: nlmsvc_cancel(sda2/171043, pi=0, 0-9223372036854775807)	
[574991.071040] lockd: nlmsvc_lookup_block f=ffff880122c87800 pd=0 0-9223372036854775807 ty=2	
[574991.071043] lockd: UNLOCK        status 0	
[574991.071045] lockd: release host 192.168.200.187	
[574991.071047] lockd: nlm_release_file(ffff880122c87800, ct = 1)	
[574991.071049] lockd: closing file sda2/171043	                                                                    [293744.611384] lockd: closing file md0/252507
[574991.071074] lockd: release host 192.168.200.187	                                                                [293744.611419] lockd: server in grace period
[574991.071076] lockd: release host 192.168.200.187	
[574991.071078] lockd: clnt proc returns 0	
[574991.117705] lockd: release host 192.168.200.187	
