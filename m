From: Risto Bell <reb-+wT8y+m8/X5BDgjK7y7TUQ@public.gmane.org>
Subject: Linux 'quota -v' in 2.6.18 fails, unless nosharecache mount option
 is used.
Date: Thu, 10 Sep 2009 15:33:55 -0700
Message-ID: <4AA97ED3.9000007@cypress.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.cypress.com ([157.95.67.5]:61907 "EHLO ns2.cypress.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751304AbZIJWrH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Sep 2009 18:47:07 -0400
Received: from corpmail.cypress.com (corpmail [157.95.1.2])
	by ns2.cypress.com (8.12.10/8.12.10) with ESMTP id n8AMo6Ho029803
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2009 15:50:06 -0700 (PDT)
Received: from cobweb.mis.cypress.com (cobweb.mis.cypress.com [172.16.2.5])
	by corpmail.cypress.com (8.12.10/8.12.10) with ESMTP id n8AMXwes007610
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2009 15:33:58 -0700 (PDT)
Received: from meson.design.cypress.com (meson.design.cypress.com [172.17.2.36])
	by cobweb.mis.cypress.com (8.12.11/8.12.11) with ESMTP id n8AMXtvG011895
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2009 15:33:56 -0700 (PDT)
Received: from mopar.design.cypress.com (mopar [172.17.14.88])
	by meson.design.cypress.com (8.9.3+Sun/8.9.3) with ESMTP id PAA04177
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2009 15:33:55 -0700 (PDT)
Received: from mopar.design.cypress.com (localhost [127.0.0.1])
	by mopar.design.cypress.com (8.13.8/8.13.8) with ESMTP id n8AMXtcI009889
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2009 15:33:55 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Summary:
Linux 'quota -v' in 2.6.18 fails, unless nosharecache mount option is used.
stat (and mountpoint -d) show devices for mounts are same.

problem - Other mounts are shown, with separate/unrelated usage and quota
limits, if those were mounted first; these unrelated mounts appear to suppress
the other mounts where both usage and quota limits are unique.

This is much worse than "Usual Confusion" of quota reporting first mount
of same disk, under a different client dir, or a different server subdir.
Since a zero usage mount is reported, while non-zero usage mounts suppressed.

Perhaps quota and autofs are blameless. But kernel/mount is to blame by
(without nosharecache) assigning same device numbers to mounts of unique
partitions. The quota problem could be merely side-effect of a device number
bug, or it may need to be made intelligent to overcome the device numbering.
Something seems too optimized, doing too much collapsing, for its own good.

Thanks for any help/input on this issue.

What works:
   solaris8
   linux 2.6.18 with nosharecache (unique devices per mount)
   linux 2.4.21 (unique devices per mount)
What fails:
   linux 2.6.18 withOut nosharecache (same device per mount)

Details/examples:

Am only in position to test using NetApp mounts, and the host and volume
numbers of the confused mounts are the same, while the partitions and subdirs
are unique. All mounts are rw,vers=3,tcp,hard.

Three partitions mounted from same NetApp, two users. Same are compared on
2.4.21, 2.6.18 with nosharecache, 2.6.18 withOut nosharecache.
	
WORKS (2.4.21):

# uname -sr
Linux 2.4.21-37.ELhugemem

nfs-utils-1.0.6-42EL
redhat-config-nfs-1.0.13-6
autofs-4.1.3-154
mount-2.11y-31.10
quota-3.10-7

# quota -v user2
Disk quotas for user user2 (uid 2050):
      Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
napp1:/vol/vol8/part-v4-01/one
                       0  512000  512000               0  4294967295 4294967295
napp1:/vol/vol8/part-v4-03/three
                       0  17179869180 17179869180               0  4294967295 4294967295
napp1:/vol/vol8/part-v4-02/two
                    1168  102400  102400             123  4294967295 4294967295

# quota -v user1
Disk quotas for user user1 (uid 2064):
      Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
napp1:/vol/vol8/part-v4-01/one
                  309796  512000  512000            5371  4294967295 4294967295
napp1:/vol/vol8/part-v4-03/three
                 7905332  17179869180 17179869180          282879  4294967295 4294967295
napp1:/vol/vol8/part-v4-02/two
                       0  102400  102400               0  4294967295 4294967295

# df -h
Filesystem            Size  Used Avail Use% Mounted on
napp1:/vol/vol8/part-v4-01/one
                        41G   36G  5.0G  88% /h/one
napp1:/vol/vol8/part-v4-02/two
                        18G   13G  4.7G  74% /h/two
napp1:/vol/vol8/part-v4-03/three
                       199G  193G  5.7G  98% /h/three
# stat /h/one/. /h/two/. /h/three/. | grep -i device
Device: 10h/16d Inode: 10577033    Links: 145
Device: 1fh/31d Inode: 3422150     Links: 18
Device: 11h/17d Inode: 10560711    Links: 27

Also WORKS (2.6.18 but WITH "nosharecache" mount-nfs option):

# uname -sr
Linux 2.6.18-92.1.22.el5
# tail -2 /etc/sysconfig/autofs
OPTIONS="-O nosharecache"
#

system-config-nfs-1.3.23-1.el5
sblim-cmpi-nfsv4-test-1.0.12-31.el5
autofs-5.0.1-0.rc2.102
nfs4-acl-tools-0.3.1-1.el5.1
nfs-utils-1.0.9-40.el5
sblim-cmpi-nfsv3-test-1.0.14-31.el5
sblim-cmpi-nfsv3-1.0.14-31.el5
nfs-utils-lib-1.0.8-7.2.z2
sblim-cmpi-nfsv4-1.0.12-31.el5
quota-3.13-1.2.5.el5

# df -h
Filesystem            Size  Used Avail Use% Mounted on
napp1:/vol/vol8/part-v4-01/one
                        41G   36G  5.0G  88% /h/one
napp1:/vol/vol8/part-v4-02/two
                        18G   13G  4.7G  74% /h/two
napp1:/vol/vol8/part-v4-03/three
                       199G  193G  5.7G  98% /h/three

# stat /h/one/. /h/two/. /h/three/. | grep -i device
Device: 2bh/43d Inode: 10577033    Links: 145
Device: 2dh/45d Inode: 3422150     Links: 18
Device: 25h/37d Inode: 10560711    Links: 27

# quota -v user1
napp1:/vol/vol8/part-v4-03/three
                 7905332  17179869180 17179869180          282879  4294967295 4294967295
napp1:/vol/vol8/part-v4-01/one
                  309796  512000  512000            5371  4294967295 4294967295
napp1:/vol/vol8/part-v4-02/two
                       0  102400  102400               0  4294967295 4294967295
# quota -v user2
napp1:/vol/vol8/part-v4-03/three
                       0  17179869180 17179869180               0  4294967295 4294967295
napp1:/vol/vol8/part-v4-01/one
                       0  512000  512000               0  4294967295 4294967295
napp1:/vol/vol8/part-v4-02/two
                    1168  102400  102400             123  4294967295 4294967295

FAILS (2.6.18 WITHOUT nosharecache mount-nfs option):

# uname -sr
Linux 2.6.18-92.1.22.el5

# grep OPTIONS /etc/sysconfig/autofs
# APPEND_OPTIONS - append to global options instead of replace.
#APPEND_OPTIONS="yes"
#OPTIONS=""

# df -h
Filesystem            Size  Used Avail Use% Mounted on
napp1:/vol/vol8/part-v4-03/three
                       199G  193G  5.7G  98% /h/three
napp1:/vol/vol8/part-v4-01/one
                        41G   36G  5.0G  88% /h/one
napp1:/vol/vol8/part-v4-02/two
                        18G   13G  4.7G  74% /h/two

# stat /h/one/. /h/two/. /h/three/. | grep -i device
Device: 24h/36d Inode: 10577033    Links: 145
Device: 24h/36d Inode: 3422150     Links: 18
Device: 24h/36d Inode: 10560711    Links: 27

# quota -v user2
Disk quotas for user user2 (uid 2050):
      Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
napp1:/vol/vol8/part-v4-03/three
                       0  17179869180 17179869180               0  4294967295 4294967295

# quota -v user1
Disk quotas for user user1 (uid 2064):
      Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
napp1:/vol/vol8/part-v4-03/three
                 7905332  17179869180 17179869180          282879  4294967295 4294967295
