Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56579 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753105Ab2IYKKi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Sep 2012 06:10:38 -0400
Date: Tue, 25 Sep 2012 12:10:31 +0200
From: Karel Zak <kzak@redhat.com>
To: chenditang <chendt.fnst@cn.fujitsu.com>
Cc: util-linux@vger.kernel.org, linux-nfs@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [QUESTION]about libmount library performance problems
Message-ID: <20120925101031.GB22639@x2.net.home>
References: <505FBE77.8030802@cn.fujitsu.com>
 <5061076C.2080707@cn.fujitsu.com>
 <506110BB.2070408@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <506110BB.2070408@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 25, 2012 at 10:02:35AM +0800, chenditang wrote:
> I have 1 question which need confirm.
> 
>   in the RHEL7.0alpha version
> 	nfs-utils-1.2.5-3.el7.x86_64  --> use mount_libmount.c
> 	util-linux-2.20.1-2.el7.x86_64
>   when umount a NFS directory, the mnt_table_parse_mtab() function will merge user options(/run/mount/utab) 
> into mountinfo(/proc/self/mountinfo)from kernel. if the mount number is large, leading to umount a directory
> time-consuming. the complexity of the algorithm is O(n(n+1)/2).

 Yes, maybe we can somehow improve the file format and the algorithm,
 suggestions?

>     but in the old version(RHEL6.3GA/nfs-utils-1.2.3-26.el6.x86_64(use mount.c)), only according to the parameters of umount command, 
> find the corresponding record in the /etc/mtab file

 But we don't have mtab file in RHEL7 anymore, so we have to store the
 userspace specific mount options somewhere... (/run/mount/utab).  The
 solution is to minimize number of information we have to maintain in
 userspace.

 Unfortunately it seems that for example on my system we duplicate the
 information:

      utab:  retrans=20,addr=192.168.111.1

 mountinfo:  rw,vers=3,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,
             retrans=20,sec=sys,mountaddr=192.168.111.1,mountvers=3,mountport=39755,
             mountproto=udp,local_lock=none,addr=192.168.111.1

 (see retrans= and addr=)

 Maybe we can detect this situation and don't store duplicate options
 in userspace. The question is what happen with retrans= and addr=
 after remount. If I good remember there was any reason to maintain
 these stuff in userspace. Chuck?

>   Question)*:* merg the tow file are necessary for umount a dir?

 I guess nfs umount needs the addr= info.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
