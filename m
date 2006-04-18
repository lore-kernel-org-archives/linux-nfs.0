From: Robinson Tiemuqinke <hahaha_30k@yahoo.com>
Subject: Newbie kernel questions: Failed to mount >=256 mounts for FC4/FC5:
	can't read superblock
Date: Tue, 18 Apr 2006 12:57:36 -0700 (PDT)
Message-ID: <20060418195736.67158.qmail@web36710.mail.mud.yahoo.com>
Reply-To: For users of Fedora Core releases <fedora-list@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <fedora-list-bounces@redhat.com>
To: fedora-list@redhat.com, nfs@lists.sourceforge.net
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/fedora-list>,
	<mailto:fedora-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/fedora-list>
List-Post: <mailto:fedora-list@redhat.com>
List-Help: <mailto:fedora-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/fedora-list>,
	<mailto:fedora-list-request@redhat.com?subject=subscribe>
Sender: fedora-list-bounces@redhat.com
Errors-To: fedora-list-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

Hi,

 Just found there was a problem to mount many mounts
on FC4/FC5: total mounts can not exceed 256.

 We have a bunches of machines/file-systems have to be
mounted at the same time and unfortunately the total
number of mounts exceeds 256.

 The mounting commands and outputs are attached below,
newer stock kernels shows the same symptoms as well.

Please help.

[root@testMaster ~]# for i in `/axample/bin/lsng
testnode-hosts`; do echo ${i}; mount ${i}:/0
/0/ttt/${i}/0; mount ${i}:/1 /0/ttt/${i}/1;  mount
${i}:/2 /0/ttt/${i}/2; mount ${i}:/3 /0/ttt/${i}/3;
done

...
testnode540
testnode541
testnode542
testnode543
mount: testnode543:/1: can't read superblock
mount: testnode543:/2: can't read superblock
mount: testnode543:/3: can't read superblock
testnode544
mount: testnode544:/0: can't read superblock
mount: testnode544:/1: can't read superblock
mount: testnode544:/2: can't read superblock
mount: testnode544:/3: can't read superblock
testnode545
mount: testnode545:/0: can't read superblock
mount: testnode545:/1: can't read superblock
mount: testnode545:/2: can't read superblock
mount: testnode545:/3: can't read superblock
testnode546
mount: testnode546:/0: can't read superblock
mount: testnode546:/1: can't read superblock
mount: testnode546:/2: can't read superblock
mount: testnode546:/3: can't read superblock
testnode547
mount: testnode547:/0: can't read superblock
mount: testnode547:/1: can't read superblock
mount: testnode547:/2: can't read superblock
mount: testnode547:/3: can't read superblock
testnode548
mount: testnode548:/0: can't read superblock
mount: testnode548:/1: can't read superblock
mount: testnode548:/2: can't read superblock
mount: testnode548:/3: can't read superblock
testnode549
...

[root@testMaster ~]# df -k | wc -l
254
[root@testMaster ~]#

[root@testMaster ~]# uname -a
Linux testMaster.example.com 2.6.15-1.1831_FC4smp #1
SMP Tue Feb 7 13:51:52 EST 2006 x86_64 x86_64 x86_64
GNU/Linux
[root@testMaster ~]#





__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20

--=20
fedora-list mailing list
fedora-list@redhat.com
To unsubscribe: https://www.redhat.com/mailman/listinfo/fedora-list
