Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42592 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933806Ab2JXBNi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 21:13:38 -0400
Message-ID: <508740B2.2030401@redhat.com>
Date: Tue, 23 Oct 2012 20:13:22 -0500
From: Eric Sandeen <sandeen@redhat.com>
MIME-Version: 1.0
To: Nix <nix@esperi.org.uk>
CC: "Ted Ts'o" <tytso@mit.edu>, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Bryan Schumaker <bjschuma@netapp.com>, Peng Tao <bergwolf@gmail.com>,
        Trond.Myklebust@netapp.com, gregkh@linuxfoundation.org,
        linux-nfs@vger.kernel.org
Subject: Re: Apparent serious progressive ext4 data corruption bug in 3.6.3
 (and other stable branches?)
References: <87objupjlr.fsf@spindle.srvr.nix> <20121023013343.GB6370@fieldses.org> <87mwzdnuww.fsf@spindle.srvr.nix> <20121023143019.GA3040@fieldses.org> <874nllxi7e.fsf_-_@spindle.srvr.nix> <87pq48nbyz.fsf_-_@spindle.srvr.nix>
In-Reply-To: <87pq48nbyz.fsf_-_@spindle.srvr.nix>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/23/12 3:57 PM, Nix wrote:

<snip>

> (I'd provide more sample errors, but this bug has been eating
> newly-written logs in /var all day, so not much has survived.)
> 
> I rebooted into 3.6.1 rescue mode and fscked everything: lots of
> orphans, block group corruption and cross-linked files. The problems did
> not recur upon booting from 3.6.1 into 3.6.1 again. It is quite clear
> that metadata changes made in 3.6.3 are not making it to disk reliably,
> thus leading to corrupted filesystems marked clean on reboot into other
> kernels: pretty much every file appended to in 3.6.3 loses some or all
> of its appended data, and newly allocated blocks often end up
> cross-linked between multiple files.
> 
> The curious thing is this doesn't affect every filesystem: for a while
> it affected only /var, and now it's affecting only /var and /home. The
> massive writes to the ext4 filesystem mounted on /usr/src seem to have
> gone off without incident: fsck reports no problems.
> 
> 
> The only unusual thing about the filesystems on this machine are that
> they have hardware RAID-5 (using the Areca driver), so I'm mounting with
> 'nobarrier': 

I should have read more.  :(  More questions follow:

* Does the Areca have a battery backed write cache?
* Are you crashing or rebooting cleanly?
* Do you see log recovery messages in the logs for this filesystem?

> the full set of options for all my ext4 filesystems are:
> 
> rw,nosuid,nodev,relatime,journal_checksum,journal_async_commit,nobarrier,quota,
> usrquota,grpquota,commit=30,stripe=16,data=ordered,usrquota,grpquota

ok journal_async_commit is off the reservation a bit; that's really not
tested, and Jan had serious reservations about its safety.

* Can you reproduce this w/o journal_async_commit?

-Eric

> If there's anything I can do to help, I'm happy to do it, once I've
> restored my home directory from backup :(
> 
> 
> tune2fs output for one of the afflicted filesystems (after fscking):
> 
> tune2fs 1.42.2 (9-Apr-2012)
> Filesystem volume name:   home
> Last mounted on:          /home
> Filesystem UUID:          95bd22c2-253c-456f-8e36-b6cfb9ecd4ef
> Filesystem magic number:  0xEF53
> Filesystem revision #:    1 (dynamic)
> Filesystem features:      has_journal ext_attr resize_inode dir_index filetype needs_recovery extent flex_bg sparse_super large_file huge_file uninit_bg dir_nlink extra_isize
> Filesystem flags:         signed_directory_hash
> Default mount options:    (none)
> Filesystem state:         clean
> Errors behavior:          Continue
> Filesystem OS type:       Linux
> Inode count:              3276800
> Block count:              13107200
> Reserved block count:     655360
> Free blocks:              5134852
> Free inodes:              3174777
> First block:              0
> Block size:               4096
> Fragment size:            4096
> Reserved GDT blocks:      20
> Blocks per group:         32768
> Fragments per group:      32768
> Inodes per group:         8192
> Inode blocks per group:   512
> RAID stripe width:        16
> Flex block group size:    64
> Filesystem created:       Tue May 26 21:29:41 2009
> Last mount time:          Tue Oct 23 21:32:07 2012
> Last write time:          Tue Oct 23 21:32:07 2012
> Mount count:              2
> Maximum mount count:      20
> Last checked:             Tue Oct 23 21:22:16 2012
> Check interval:           15552000 (6 months)
> Next check after:         Sun Apr 21 21:22:16 2013
> Lifetime writes:          1092 GB
> Reserved blocks uid:      0 (user root)
> Reserved blocks gid:      0 (group root)
> First inode:              11
> Inode size:               256
> Required extra isize:     28
> Desired extra isize:      28
> Journal inode:            8
> First orphan inode:       1572907
> Default directory hash:   half_md4
> Directory Hash Seed:      a201983d-d8a3-460b-93ca-eb7804b62c23
> Journal backup:           inode blocks
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

