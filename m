Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6317 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757257Ab3HMTUb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 15:20:31 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7DJKUXc026450
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 15:20:31 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-64.rdu.redhat.com [10.13.145.64])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r7DJKU69012107
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 15:20:30 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id r7DJKU57021419
	for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 15:20:30 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id r7DJKTA2021418
	for linux-nfs@vger.kernel.org; Tue, 13 Aug 2013 15:20:29 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 0/4] Improve nfsmount.conf configuration parsing.
Date: Tue, 13 Aug 2013 15:20:25 -0400
Message-Id: <1376421629-21382-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The parsing of the nfsmount.conf configuration file has various issues.

Here's an example config file I've been testing with:

# cat /etc/nfsmount.conf
[ NFSMount_Global_Options ]
	Acl=False
	Ac=False
	Timeo=600
	Background=True

[ Server "nfs.smayhew.test" ]
	Sec=krb5p
	Nfsvers=4
	Acl=True
	Ac=True
	Timeo=300
	Sloppy=True
	Foreground=True

[ Server "rhel7alpha2.smayhew.test" ]
	Sec=krb5i
	Nfsvers=4

[ Server "rhel6u2.smayhew.test" ]
	Nfsvers=4	

[ Server "rhel5u8.smayhew.test" ]
	Nfsvers=3

[ Server "rhel4u8.smayhew.test" ]
	Nfsvers=3

[ MountPoint "/mnt/nfs" ]
	Timeo=150
	Background=False
	Ac=False
	Sloppy=False

I then mount a filesystem using:

# mount nfs.smayhew.test:/export /mnt/nfs
  
# mount | grep smayhew
nfs.smayhew.test:/export on /mnt/nfs type nfs
(rw,timeo=600,bg,sec=krb5p,nfsvers=4,acl,ac,timeo=300,sloppy,fg,sec=krb5p,nfsvers=4,nfsvers=4,nfsvers=4,nfsvers=4,addr=192.168.122.179,clientaddr=192.168.122.202)
# grep smayhew /proc/mounts
nfs.smayhew.test:/export/ /mnt/nfs nfs4
rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=300,retrans=2,sec=krb5p,clientaddr=192.168.122.202,minorversion=0,local_lock=none,addr=192.168.122.179
0 0

In the output of mount (no arguments) as well as /etc/mtab,
1. nfsvers=4 is shown four times
2. sec=krb5p is shown twice
3. both fg and bg is shown
4. timeo appears twice

In /proc/mounts we can see that we have the wrong value for timeo (it should be
150).

In newer distros where /etc/mtab is a symlink to /proc/mounts, you're unlikely
to see most of these issues unless you're watching the mount command with
something like systemtap, e.g.

# stap -e 'probe syscall.mount { printf("%s %s\n", probefunc(),
# kernel_string($data)) }'
sys_mount
timeo=600,bg,sec=krb5p,nfsvers=4,acl,ac,timeo=300,sloppy,fg,sec=krb5p,nfsvers=4,nfsvers=4,nfsvers=4,nfsvers=4,addr=192.168.122.179,clientaddr=192.168.122.202

Regardless, rather than sending a slew of mount options and letting the kernel
sort it out, we can do a better job of parsing them on the front end.


Scott Mayhew (4):
  mount.nfs: avoid unnecessary duplication of options passed to
    mount(2)
  mount.nfs: avoid sending conflicting mount options
  mount.nfs:  improve handling of MNT_NOARG type options
  mount.nfs:  clean up conf_parse_mntopts()

 support/include/conffile.h |  2 +-
 support/nfs/conffile.c     |  4 ++-
 utils/mount/configfile.c   | 77 +++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 73 insertions(+), 10 deletions(-)

-- 
1.7.11.7

