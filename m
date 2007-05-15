From: Roger Heflin <rheflin@atipa.com>
Subject: Apparent Deadlock with nfsd/jfs on 2.6.21.1 under bonnie.
Date: Tue, 15 May 2007 09:08:25 -0500
Message-ID: <4649BED9.6090207@atipa.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020505010704090908050700"
To: Linux-Kernel <linux-kernel@vger.kernel.org>,
	NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hnxhb-000356-I9
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 07:08:35 -0700
Received: from 125.14.124.24.cm.sunflower.com ([24.124.14.125]
	helo=mail.atipa.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HnxhY-0004rR-4P
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 07:08:38 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------020505010704090908050700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

Running 2.6.21.1 (FC6 Dist), with a RHEL client (client
appears to not be having issues) I am getting what I believe
is a deadlock on the server end.    This is with JFS and
NFSD, I have not tested yet with a non-JFS filesystem,
though our customer indicated that they have duplicated it with
the ext3 filesystem.

The basic setup is:
fiber channel array -> qlogic fiber card -> /dev/sdx ->
LVM stripe -> jfs -> nfs.

Running bonnie on a NFS share has apparently produced a
deadlock.   I have ran bonnie several times without having
any issues, I don't believe this is a HW issue, we have a
couple of other machines configured with slightly different
HW and are also able to duplicate this problem on those
machines.  There are no abnormal messages in dmesg or
in the messages file.

After having the apparent deadlock I started a dd of a on
the deadlocked filesystem and according to vmstat 1 that was
actually working, I then did a "mkdir junk" on the deadlocked
filesystem and that apparently put the cat into a permanent
"D" state.   I will include the sysrq -t from before the cat/mkdir
and after the cat/mkdir.

I believe I can duplicate this again, and other than the processes
going into the "D" state everything else seems to work.   Other
filesytems appear to be functional, I can still login to the
machine.

Right now the machine is in the deadlocked state, and I will
wait for any suggestions of more data to collect or other tests
to try.

Here is the ps -axu list:

USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  10304   680 ?        Ss   May14   0:00 init 
[3]
root         2  0.0  0.0      0     0 ?        S    May14   0:00 
[migration/0]
root         3  0.0  0.0      0     0 ?        SN   May14   0:00 
[ksoftirqd/0]
root         4  0.0  0.0      0     0 ?        S    May14   0:00 
[watchdog/0]
root         5  0.0  0.0      0     0 ?        S    May14   0:00 
[migration/1]
root         6  0.0  0.0      0     0 ?        SN   May14   0:00 
[ksoftirqd/1]
root         7  0.0  0.0      0     0 ?        S    May14   0:00 
[watchdog/1]
root         8  0.0  0.0      0     0 ?        S    May14   0:00 
[migration/2]
root         9  0.0  0.0      0     0 ?        SN   May14   0:00 
[ksoftirqd/2]
root        10  0.0  0.0      0     0 ?        S    May14   0:00 
[watchdog/2]
root        11  0.0  0.0      0     0 ?        S    May14   0:00 
[migration/3]
root        12  0.1  0.0      0     0 ?        SN   May14   1:21 
[ksoftirqd/3]
root        13  0.0  0.0      0     0 ?        S    May14   0:00 
[watchdog/3]
root        14  0.0  0.0      0     0 ?        S<   May14   0:00 [events/0]
root        15  0.0  0.0      0     0 ?        S<   May14   0:00 [events/1]
root        16  0.0  0.0      0     0 ?        S<   May14   0:00 [events/2]
root        17  0.0  0.0      0     0 ?        S<   May14   0:00 [events/3]
root        18  0.0  0.0      0     0 ?        S<   May14   0:00 [khelper]
root        19  0.0  0.0      0     0 ?        S<   May14   0:00 [kthread]
root        59  0.0  0.0      0     0 ?        S<   May14   0:00 [kblockd/0]
root        60  0.0  0.0      0     0 ?        S<   May14   0:00 [kblockd/1]
root        61  0.0  0.0      0     0 ?        S<   May14   0:00 [kblockd/2]
root        62  0.0  0.0      0     0 ?        S<   May14   0:00 [kblockd/3]
root        63  0.0  0.0      0     0 ?        S<   May14   0:00 [kacpid]
root       235  0.0  0.0      0     0 ?        S<   May14   0:00 [cqueue/0]
root       236  0.0  0.0      0     0 ?        S<   May14   0:00 [cqueue/1]
root       237  0.0  0.0      0     0 ?        S<   May14   0:00 [cqueue/2]
root       238  0.0  0.0      0     0 ?        S<   May14   0:00 [cqueue/3]
root       239  0.0  0.0      0     0 ?        S<   May14   0:00 
[ksuspend_usbd]
root       242  0.0  0.0      0     0 ?        S<   May14   0:00 [khubd]
root       244  0.0  0.0      0     0 ?        S<   May14   0:00 [kseriod]
root       298  0.0  0.0      0     0 ?        S    May14   0:00 [pdflush]
root       299  0.0  0.0      0     0 ?        D    May14   0:36 [pdflush]
root       300  0.0  0.0      0     0 ?        S<   May14   0:25 [kswapd0]
root       301  0.0  0.0      0     0 ?        S<   May14   0:20 [kswapd1]
root       302  0.0  0.0      0     0 ?        S<   May14   0:00 [aio/0]
root       303  0.0  0.0      0     0 ?        S<   May14   0:00 [aio/1]
root       304  0.0  0.0      0     0 ?        S<   May14   0:00 [aio/2]
root       305  0.0  0.0      0     0 ?        S<   May14   0:00 [aio/3]
root       461  0.0  0.0      0     0 ?        S<   May14   0:00 [kpsmoused]
root       520  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_eh_0]
root       536  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_eh_1]
root       537  0.0  0.0      0     0 ?        S<   May14   0:00 
[qla2xxx_1_dpc]
root       538  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_wq_1]
root       539  0.0  0.0      0     0 ?        S<   May14   0:00 [fc_wq_1]
root       540  0.0  0.0      0     0 ?        S<   May14   0:00 [fc_dl_1]
root       541  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_eh_2]
root       542  0.0  0.0      0     0 ?        S<   May14   0:00 
[qla2xxx_2_dpc]
root       543  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_wq_2]
root       544  0.0  0.0      0     0 ?        S<   May14   0:00 [fc_wq_2]
root       545  0.0  0.0      0     0 ?        S<   May14   0:00 [fc_dl_2]
root       546  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_eh_3]
root       547  0.0  0.0      0     0 ?        S<   May14   0:00 
[qla2xxx_3_dpc]
root       548  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_wq_3]
root       549  0.0  0.0      0     0 ?        S<   May14   0:00 [fc_wq_3]
root       550  0.0  0.0      0     0 ?        S<   May14   0:00 [fc_dl_3]
root       551  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_eh_4]
root       552  0.0  0.0      0     0 ?        S<   May14   0:00 
[qla2xxx_4_dpc]
root       553  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_wq_4]
root       554  0.0  0.0      0     0 ?        S<   May14   0:00 [fc_wq_4]
root       555  0.0  0.0      0     0 ?        S<   May14   0:00 [fc_dl_4]
root       556  0.0  0.0      0     0 ?        S<   May14   0:00 [kjournald]
root       583  0.0  0.0      0     0 ?        S<   May14   0:00 [kauditd]
root       617  0.0  0.0  12564   704 ?        S<s  May14   0:03 
/sbin/udevd -d
root      1220  0.0  0.0      0     0 ?        S<   May14   0:00 [khpsbpkt]
root      1271  0.0  0.0      0     0 ?        S<   May14   0:00 
[knodemgrd_0]
root      1364  0.0  0.0      0     0 ?        S<   May14   0:00 [ata/0]
root      1365  0.0  0.0      0     0 ?        S<   May14   0:00 [ata/1]
root      1366  0.0  0.0      0     0 ?        S<   May14   0:00 [ata/2]
root      1367  0.0  0.0      0     0 ?        S<   May14   0:00 [ata/3]
root      1368  0.0  0.0      0     0 ?        S<   May14   0:00 [ata_aux]
root      1675  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_eh_5]
root      1677  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_eh_6]
root      2076  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_eh_7]
root      2077  0.0  0.0      0     0 ?        S<   May14   0:00 [scsi_eh_8]
root      2515  0.0  0.0      0     0 ?        S<   May14   0:00 [kmpathd/0]
root      2516  0.0  0.0      0     0 ?        S<   May14   0:00 [kmpathd/1]
root      2517  0.0  0.0      0     0 ?        S<   May14   0:00 [kmpathd/2]
root      2518  0.0  0.0      0     0 ?        S<   May14   0:00 [kmpathd/3]
root      2533  0.0  0.0      0     0 ?        S<   May14   0:00 [kmirrord]
root      2571  0.0  0.0      0     0 ?        S<   May14   0:02 [jfsIO]
root      2572  0.0  0.0      0     0 ?        S<   May14   0:30 [jfsCommit]
root      2573  0.0  0.0      0     0 ?        S<   May14   0:32 [jfsCommit]
root      2574  0.0  0.0      0     0 ?        S<   May14   0:30 [jfsCommit]
root      2575  0.0  0.0      0     0 ?        S<   May14   0:31 [jfsCommit]
root      2576  0.0  0.0      0     0 ?        S<   May14   0:00 [jfsSync]
root      2578  0.0  0.0      0     0 ?        S<   May14   0:00 [kjournald]
root      2580  0.0  0.0      0     0 ?        S<   May14   0:00 [kjournald]
root      2582  0.0  0.0      0     0 ?        S<   May14   0:01 [kjournald]
root      2712  0.0  0.0      0     0 ?        S<   May14   0:00 
[kondemand/0]
root      2713  0.0  0.0      0     0 ?        S<   May14   0:00 
[kondemand/1]
root      2714  0.0  0.0      0     0 ?        S<   May14   0:00 
[kondemand/2]
root      2715  0.0  0.0      0     0 ?        S<   May14   0:00 
[kondemand/3]
root      3260  0.0  0.0   6700   888 ?        Ss   May14   0:00 
/sbin/dhclient -1 -q -lf /var/lib/dhclient/dhcli
ent-eth1.leases -pf /var/run/dhclient-eth1.pid eth1
root      3374  0.0  0.0   5868   604 ?        Ss   May14   0:01 syslogd 
-m 0
root      3377  0.0  0.0   3760   448 ?        Ss   May14   0:00 klogd -x
root      3393  0.0  0.0   6436   332 ?        Ss   May14   0:22 irqbalance
rpc       3428  0.0  0.0   8008   632 ?        Ss   May14   0:00 portmap
root      3453  0.0  0.0  10100   784 ?        Ss   May14   0:00 rpc.statd
dbus      3481  0.0  0.0  25452   780 ?        Ss   May14   0:00 
dbus-daemon --system
root      3518  0.0  0.0   8472   480 ?        Ss   May14   0:00 
/usr/bin/hidd --server
root      3535  0.0  0.0   3760   556 ?        Ss   May14   0:00 
/usr/sbin/acpid
root      3553  0.0  0.0  44288  1076 ?        Ss   May14   0:00 
/usr/sbin/sshd
root      3679  0.0  0.0  42004   720 ?        Ss   May14   0:00 rpc.idmapd
root      3694  0.0  0.0  73876  1124 ?        Ss   May14   0:00 crond
root      3709  0.0  0.0  18672   460 ?        Ss   May14   0:00 
/usr/sbin/atd
68        3724  0.0  0.0  27240  4600 ?        Ss   May14   0:02 hald
root      3725  0.0  0.0  17384   952 ?        S    May14   0:00 hald-runner
68        3790  0.0  0.0  12264   792 ?        S    May14   0:00 
hald-addon-keyboard: listening on /dev/input/eve
nt1
68        3797  0.0  0.0  12264   800 ?        S    May14   0:00 
hald-addon-acpi: listening on acpid socket /var/
run/acpid.socket
root      3798  0.0  0.0  19484   900 ?        S    May14   0:00 
/usr/libexec/hald-addon-cpufreq
68        3799  0.0  0.0  12268   796 ?        S    May14   0:00 
hald-addon-keyboard: listening on /dev/input/eve
nt4
68        3802  0.0  0.0  12268   796 ?        S    May14   0:00 
hald-addon-keyboard: listening on /dev/input/eve
nt3
root      3812  0.0  0.0  10168   636 ?        S    May14   0:05 
hald-addon-storage: polling /dev/hda
root      3876  0.0  0.0   4040   384 ?        S    May14   0:00 
/usr/sbin/smartd -q never
root      3879  0.0  0.0   3748   464 tty1     Ss+  May14   0:00 
/sbin/mingetty tty1
root      3880  0.0  0.0   3748   464 tty2     Ss+  May14   0:00 
/sbin/mingetty tty2
root      3881  0.0  0.0   3752   468 tty3     Ss+  May14   0:00 
/sbin/mingetty tty3
root      3882  0.0  0.0   3752   468 tty4     Ss+  May14   0:00 
/sbin/mingetty tty4
root      3883  0.0  0.0   3752   468 tty5     Ss+  May14   0:00 
/sbin/mingetty tty5
root      3884  0.0  0.0   3752   468 tty6     Ss+  May14   0:00 
/sbin/mingetty tty6
root      3943  0.0  0.0  80308  3244 ?        Ss   May14   0:00 sshd: 
root@pts/0
root      3945  0.0  0.0  65136  1588 pts/0    Ss   May14   0:00 -bash
root      4049  0.0  0.0  66444   280 ?        Ss   May14   0:00 rpc.rquotad
root      4052  0.0  0.0      0     0 ?        S    May14   0:00 [lockd]
root      4053  0.0  0.0      0     0 ?        S<   May14   0:00 [rpciod/0]
root      4054  0.0  0.0      0     0 ?        S<   May14   0:00 [rpciod/1]
root      4055  0.0  0.0      0     0 ?        S<   May14   0:00 [rpciod/2]
root      4056  0.0  0.0      0     0 ?        S<   May14   0:00 [rpciod/3]
root      4057  0.0  0.0      0     0 ?        S<   May14   0:00 [nfsd4]
root      4058  0.6  0.0      0     0 ?        D    May14   5:48 [nfsd]
root      4059  0.6  0.0      0     0 ?        D    May14   5:39 [nfsd]
root      4060  0.6  0.0      0     0 ?        D    May14   5:42 [nfsd]
root      4061  0.6  0.0      0     0 ?        D    May14   5:48 [nfsd]
root      4062  0.5  0.0      0     0 ?        D    May14   5:28 [nfsd]
root      4063  0.6  0.0      0     0 ?        D    May14   5:46 [nfsd]
root      4064  0.5  0.0      0     0 ?        D    May14   5:31 [nfsd]
root      4065  0.5  0.0      0     0 ?        D    May14   5:24 [nfsd]
root      4068  0.0  0.0  14372   876 ?        Ss   May14   0:00 rpc.mountd
root      4862  3.1  0.0  57984   460 pts/0    D    05:32   0:14 cat 
/test/Bonnie.25846.051 /test/Bonnie.25846.05
2 /test/Bonnie.25846.053 /test/Bonnie.25846.054
root      4864  0.0  0.0  64524   612 pts/0    D+   05:32   0:00 mkdir junk
root      4865  0.0  0.0  80308  3240 ?        Ss   05:33   0:00 sshd: 
root@pts/1
root      4867  0.0  0.0  65136  1588 pts/1    Ss   05:33   0:00 -bash
root      4892  0.0  0.0  64680   956 pts/1    R+   05:40   0:00 ps -axuww
root      4893  0.0  0.0  60104   656 pts/1    S+   05:40   0:00 more


--------------020505010704090908050700
Content-Type: text/plain;
 name="messages_nfs_hang.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="messages_nfs_hang.txt"

May 14 14:05:39 vault1 kernel: Linux version 2.6.21.1 (root@vault1) (gcc version 4.1.1 20070105 (Red Hat 4.1.1-51)) #1 SMP Tue May 8 17:55:41 EDT 2007
May 14 14:05:39 vault1 kernel: Command line: ro root=LABEL=/ elevator=deadline
May 14 14:05:39 vault1 kernel: BIOS-provided physical RAM map:
May 14 14:05:39 vault1 kernel:  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
May 14 14:05:39 vault1 kernel:  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
May 14 14:05:39 vault1 kernel:  BIOS-e820: 00000000000e8000 - 0000000000100000 (reserved)
May 14 14:05:39 vault1 kernel:  BIOS-e820: 0000000000100000 - 00000000bffd0000 (usable)
May 14 14:05:39 vault1 kernel:  BIOS-e820: 00000000bffd0000 - 00000000bffde000 (ACPI data)
May 14 14:05:39 vault1 kernel:  BIOS-e820: 00000000bffde000 - 00000000c0000000 (ACPI NVS)
May 14 14:05:39 vault1 kernel:  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
May 14 14:05:39 vault1 kernel:  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
May 14 14:05:39 vault1 kernel:  BIOS-e820: 00000000ff700000 - 0000000100000000 (reserved)
May 14 14:05:39 vault1 kernel:  BIOS-e820: 0000000100000000 - 0000000231000000 (usable)
May 14 14:05:39 vault1 kernel: end_pfn_map = 2297856
May 14 14:05:39 vault1 kernel: DMI 2.3 present.
May 14 14:05:39 vault1 kernel: ACPI: RSDP 000FA370, 0014 (r0 ACPIAM)
May 14 14:05:39 vault1 kernel: ACPI: RSDT BFFD0000, 0034 (r1 A M I  OEMRSDT   2000627 MSFT       97)
May 14 14:05:39 vault1 kernel: ACPI: FACP BFFD0200, 0084 (r2 A M I  OEMFACP   2000627 MSFT       97)
May 14 14:05:39 vault1 kernel: ACPI: DSDT BFFD0420, 5BB6 (r1  1HDC8 1HDC8003        3 INTL  2002026)
May 14 14:05:39 vault1 kernel: ACPI: FACS BFFDE000, 0040
May 14 14:05:39 vault1 kernel: ACPI: APIC BFFD0390, 0090 (r1 A M I  OEMAPIC   2000627 MSFT       97)
May 14 14:05:39 vault1 kernel: ACPI: OEMB BFFDE040, 0063 (r1 A M I  AMI_OEM   2000627 MSFT       97)
May 14 14:05:39 vault1 kernel: ACPI: SRAT BFFD5FE0, 0110 (r1 A M I  OEMSRAT   2000627 MSFT       97)
May 14 14:05:39 vault1 kernel: SRAT: PXM 0 -> APIC 0 -> Node 0
May 14 14:05:39 vault1 kernel: SRAT: PXM 0 -> APIC 1 -> Node 0
May 14 14:05:39 vault1 kernel: SRAT: PXM 1 -> APIC 2 -> Node 1
May 14 14:05:39 vault1 kernel: SRAT: PXM 1 -> APIC 3 -> Node 1
May 14 14:05:39 vault1 kernel: SRAT: Node 0 PXM 0 100000-c0000000
May 14 14:05:39 vault1 kernel: SRAT: Node 1 PXM 1 131000000-231000000
May 14 14:05:39 vault1 kernel: SRAT: Node 0 PXM 0 100000-131000000
May 14 14:05:39 vault1 kernel: SRAT: Node 0 PXM 0 0-131000000
May 14 14:05:39 vault1 kernel: Bootmem setup node 0 0000000000000000-0000000131000000
May 14 14:05:39 vault1 kernel: Bootmem setup node 1 0000000131000000-0000000231000000
May 14 14:05:39 vault1 kernel: Zone PFN ranges:
May 14 14:05:39 vault1 kernel:   DMA             0 ->     4096
May 14 14:05:39 vault1 kernel:   DMA32        4096 ->  1048576
May 14 14:05:39 vault1 kernel:   Normal    1048576 ->  2297856
May 14 14:05:39 vault1 kernel: early_node_map[4] active PFN ranges
May 14 14:05:39 vault1 kernel:     0:        0 ->      159
May 14 14:05:39 vault1 kernel:     0:      256 ->   786384
May 14 14:05:39 vault1 kernel:     0:  1048576 ->  1249280
May 14 14:05:39 vault1 kernel:     1:  1249280 ->  2297856
May 14 14:05:40 vault1 kernel: Nvidia board detected. Ignoring ACPI timer override.
May 14 14:05:40 vault1 kernel: If you got timer trouble try acpi_use_timer_override
May 14 14:05:40 vault1 kernel: ACPI: PM-Timer IO Port: 0x4008
May 14 14:05:40 vault1 kernel: ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
May 14 14:05:40 vault1 kernel: Processor #0 (Bootup-CPU)
May 14 14:05:40 vault1 kernel: ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
May 14 14:05:40 vault1 kernel: Processor #1
May 14 14:05:40 vault1 kernel: ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
May 14 14:05:40 vault1 kernel: Processor #2
May 14 14:05:40 vault1 kernel: ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
May 14 14:05:40 vault1 kernel: Processor #3
May 14 14:05:40 vault1 kernel: ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
May 14 14:05:40 vault1 rpc.statd[3453]: Version 1.0.10 Starting
May 14 14:05:40 vault1 kernel: IOAPIC[0]: apic_id 4, address 0xfec00000, GSI 0-23
May 14 14:05:40 vault1 kernel: ACPI: IOAPIC (id[0x05] address[0xfeafe000] gsi_base[24])
May 14 14:05:40 vault1 kernel: IOAPIC[1]: apic_id 5, address 0xfeafe000, GSI 24-47
May 14 14:05:40 vault1 kernel: ACPI: IOAPIC (id[0x09] address[0xfe6fe000] gsi_base[80])
May 14 14:05:40 vault1 kernel: IOAPIC[2]: apic_id 9, address 0xfe6fe000, GSI 80-86
May 14 14:05:40 vault1 kernel: ACPI: IOAPIC (id[0x0a] address[0xfe6ff000] gsi_base[87])
May 14 14:05:40 vault1 kernel: IOAPIC[3]: apic_id 10, address 0xfe6ff000, GSI 87-93
May 14 14:05:40 vault1 kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
May 14 14:05:40 vault1 kernel: ACPI: BIOS IRQ0 pin2 override ignored.
May 14 14:05:40 vault1 kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
May 14 14:05:40 vault1 rpc.statd[3453]: statd running as root. chown /var/lib/nfs/statd/sm to choose different user 
May 14 14:05:40 vault1 kernel: Setting APIC routing to physical flat
May 14 14:05:40 vault1 kernel: Using ACPI (MADT) for SMP configuration information
May 14 14:05:40 vault1 kernel: Nosave address range: 000000000009f000 - 00000000000a0000
May 14 14:05:40 vault1 kernel: Nosave address range: 00000000000a0000 - 00000000000e8000
May 14 14:05:40 vault1 kernel: Nosave address range: 00000000000e8000 - 0000000000100000
May 14 14:05:40 vault1 kernel: Nosave address range: 00000000bffd0000 - 00000000bffde000
May 14 14:05:40 vault1 kernel: Nosave address range: 00000000bffde000 - 00000000c0000000
May 14 14:05:40 vault1 kernel: Nosave address range: 00000000c0000000 - 00000000fec00000
May 14 14:05:40 vault1 kernel: Nosave address range: 00000000fec00000 - 00000000fec01000
May 14 14:05:40 vault1 kernel: Nosave address range: 00000000fec01000 - 00000000fee00000
May 14 14:05:40 vault1 kernel: Nosave address range: 00000000fee00000 - 00000000fee01000
May 14 14:05:40 vault1 kernel: Nosave address range: 00000000fee01000 - 00000000ff700000
May 14 14:05:40 vault1 kernel: Nosave address range: 00000000ff700000 - 0000000100000000
May 14 14:05:40 vault1 kernel: Allocating PCI resources starting at c4000000 (gap: c0000000:3ec00000)
May 14 14:05:40 vault1 kernel: SMP: Allowing 4 CPUs, 0 hotplug CPUs
May 14 14:05:40 vault1 kernel: PERCPU: Allocating 44544 bytes of per cpu data
May 14 14:05:40 vault1 kernel: Built 2 zonelists.  Total pages: 1983833
May 14 14:05:40 vault1 kernel: Kernel command line: ro root=LABEL=/ elevator=deadline
May 14 14:05:40 vault1 kernel: Initializing CPU#0
May 14 14:05:40 vault1 kernel: PID hash table entries: 4096 (order: 12, 32768 bytes)
May 14 14:05:40 vault1 kernel: time.c: Detected 2400.028 MHz processor.
May 14 14:05:40 vault1 kernel: Console: colour VGA+ 80x25
May 14 14:05:40 vault1 kernel: Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
May 14 14:05:40 vault1 kernel: ... MAX_LOCKDEP_SUBCLASSES:    8
May 14 14:05:40 vault1 kernel: ... MAX_LOCK_DEPTH:          30
May 14 14:05:40 vault1 kernel: ... MAX_LOCKDEP_KEYS:        2048
May 14 14:05:40 vault1 kernel: ... CLASSHASH_SIZE:           1024
May 14 14:05:40 vault1 kernel: ... MAX_LOCKDEP_ENTRIES:     8192
May 14 14:05:40 vault1 kernel: ... MAX_LOCKDEP_CHAINS:      16384
May 14 14:05:41 vault1 kernel: ... CHAINHASH_SIZE:          8192
May 14 14:05:41 vault1 kernel:  memory used by lock dependency info: 1648 kB
May 14 14:05:41 vault1 kernel:  per task-struct memory footprint: 1680 bytes
May 14 14:05:41 vault1 kernel: Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
May 14 14:05:41 vault1 kernel: Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
May 14 14:05:41 vault1 kernel: Checking aperture...
May 14 14:05:41 vault1 kernel: CPU 0: aperture @ 9280000000 size 32 MB
May 14 14:05:41 vault1 kernel: Aperture too small (32 MB)
May 14 14:05:41 vault1 hidd[3518]: Bluetooth HID daemon
May 14 14:05:41 vault1 kernel: No AGP bridge found
May 14 14:05:41 vault1 kernel: Your BIOS doesn't leave a aperture memory hole
May 14 14:05:41 vault1 kernel: Please enable the IOMMU option in the BIOS setup
May 14 14:05:41 vault1 kernel: This costs you 64 MB of RAM
May 14 14:05:41 vault1 kernel: Mapping aperture over 65536 KB of RAM @ 8000000
May 14 14:05:41 vault1 kernel: Memory: 7875072k/9191424k available (2463k kernel code, 267196k reserved, 1519k data, 328k init)
May 14 14:05:41 vault1 kernel: Calibrating delay using timer specific routine.. 4802.07 BogoMIPS (lpj=2401037)
May 14 14:05:41 vault1 kernel: Security Framework v1.0.0 initialized
May 14 14:05:41 vault1 kernel: SELinux:  Initializing.
May 14 14:05:41 vault1 kernel: selinux_register_security:  Registering secondary module capability
May 14 14:05:41 vault1 kernel: Capability LSM initialized as secondary
May 14 14:05:41 vault1 kernel: Mount-cache hash table entries: 256
May 14 14:05:41 vault1 kernel: CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
May 14 14:05:41 vault1 kernel: CPU: L2 Cache: 1024K (64 bytes/line)
May 14 14:05:41 vault1 kernel: CPU 0/0 -> Node 0
May 14 14:05:41 vault1 kernel: CPU: Physical Processor ID: 0
May 14 14:05:41 vault1 kernel: CPU: Processor Core ID: 0
May 14 14:05:41 vault1 kernel: lockdep: not fixing up alternatives.
May 14 14:05:41 vault1 kernel: ACPI: Core revision 20070126
May 14 14:05:41 vault1 kernel: Using local APIC timer interrupts.
May 14 14:05:41 vault1 kernel: result 12500157
May 14 14:05:41 vault1 kernel: Detected 12.500 MHz APIC timer.
May 14 14:05:41 vault1 kernel: lockdep: not fixing up alternatives.
May 14 14:05:41 vault1 kernel: Booting processor 1/4 APIC 0x1
May 14 14:05:41 vault1 kernel: Initializing CPU#1
May 14 14:05:41 vault1 kernel: Calibrating delay using timer specific routine.. 4799.35 BogoMIPS (lpj=2399678)
May 14 14:05:41 vault1 kernel: CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
May 14 14:05:41 vault1 kernel: CPU: L2 Cache: 1024K (64 bytes/line)
May 14 14:05:41 vault1 kernel: CPU 1/1 -> Node 0
May 14 14:05:41 vault1 kernel: CPU: Physical Processor ID: 0
May 14 14:05:41 vault1 kernel: CPU: Processor Core ID: 1
May 14 14:05:41 vault1 kernel: Dual Core AMD Opteron(tm) Processor 280 stepping 02
May 14 14:05:41 vault1 kernel: lockdep: not fixing up alternatives.
May 14 14:05:41 vault1 kernel: Booting processor 2/4 APIC 0x2
May 14 14:05:41 vault1 kernel: Initializing CPU#2
May 14 14:05:41 vault1 kernel: Calibrating delay using timer specific routine.. 4799.28 BogoMIPS (lpj=2399642)
May 14 14:05:41 vault1 kernel: CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
May 14 14:05:41 vault1 kernel: CPU: L2 Cache: 1024K (64 bytes/line)
May 14 14:05:42 vault1 kernel: CPU 2/2 -> Node 1
May 14 14:05:42 vault1 kernel: CPU: Physical Processor ID: 1
May 14 14:05:42 vault1 kernel: CPU: Processor Core ID: 0
May 14 14:05:42 vault1 kernel: Dual Core AMD Opteron(tm) Processor 280 stepping 02
May 14 14:05:42 vault1 kernel: lockdep: not fixing up alternatives.
May 14 14:05:42 vault1 kernel: Booting processor 3/4 APIC 0x3
May 14 14:05:42 vault1 kernel: Initializing CPU#3
May 14 14:05:42 vault1 kernel: Calibrating delay using timer specific routine.. 4799.30 BogoMIPS (lpj=2399652)
May 14 14:05:42 vault1 kernel: CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
May 14 14:05:42 vault1 kernel: CPU: L2 Cache: 1024K (64 bytes/line)
May 14 14:05:42 vault1 kernel: CPU 3/3 -> Node 1
May 14 14:05:42 vault1 kernel: CPU: Physical Processor ID: 1
May 14 14:05:42 vault1 kernel: CPU: Processor Core ID: 1
May 14 14:05:42 vault1 kernel: Dual Core AMD Opteron(tm) Processor 280 stepping 02
May 14 14:05:42 vault1 kernel: Brought up 4 CPUs
May 14 14:05:42 vault1 kernel: migration_cost=361,469
May 14 14:05:42 vault1 kernel: NET: Registered protocol family 16
May 14 14:05:42 vault1 kernel: ACPI: bus type pci registered
May 14 14:05:42 vault1 kernel: PCI: Using configuration type 1
May 14 14:05:42 vault1 kernel: ACPI: Interpreter enabled
May 14 14:05:42 vault1 kernel: ACPI: (supports S0 S1 S3 S4 S5)
May 14 14:05:42 vault1 kernel: ACPI: Using IOAPIC for interrupt routing
May 14 14:05:42 vault1 kernel: ACPI: PCI Root Bridge [PCI0] (0000:00)
May 14 14:05:42 vault1 kernel: PCI: Transparent bridge - 0000:00:09.0
May 14 14:05:42 vault1 kernel: ACPI: PCI Root Bridge [PCIC] (0000:04)
May 14 14:05:42 vault1 kernel: ACPI: PCI Root Bridge [PCIB] (0000:80)
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LNKA] (IRQs 16 17 18 19) *10
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LNKB] (IRQs 16 17 18 19) *9
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LNKC] (IRQs 16 17 18 19) *9
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LNKD] (IRQs 16 17 18 19) *9
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LNKE] (IRQs 16 17 18 19) *0, disabled.
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LUS0] (IRQs 20 21 22) *9
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LUS1] (IRQs 20 21 22) *0, disabled.
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LUS2] (IRQs 20 21 22) *9
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LKLN] (IRQs 20 21 22) *11
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LAUI] (IRQs 20 21 22) *9
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LKMO] (IRQs 20 21 22) *0, disabled.
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LKSM] (IRQs 20 21 22) *0, disabled.
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LTID] (IRQs 20 21 22) *9
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LTIE] (IRQs 20 21 22) *5
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LATA] (IRQs 20 21 22) *14
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LN2A] (IRQs 40 41 42 43) *0, disabled.
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LN2B] (IRQs 40 41 42 43) *0, disabled.
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LN2C] (IRQs 40 41 42 43) *0, disabled.
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LN2D] (IRQs 40 41 42 43) *0, disabled.
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LK2N] (IRQs 44 45 46 47) *0, disabled.
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LT3D] (IRQs 44 45 46 47) *0, disabled.
May 14 14:05:42 vault1 kernel: ACPI: PCI Interrupt Link [LT2E] (IRQs 44 45 46 47) *0, disabled.
May 14 14:05:42 vault1 kernel: Linux Plug and Play Support v0.97 (c) Adam Belay
May 14 14:05:42 vault1 kernel: pnp: PnP ACPI init
May 14 14:05:42 vault1 kernel: pnp: PnP ACPI: found 17 devices
May 14 14:05:43 vault1 kernel: usbcore: registered new interface driver usbfs
May 14 14:05:43 vault1 kernel: usbcore: registered new interface driver hub
May 14 14:05:43 vault1 kernel: usbcore: registered new device driver usb
May 14 14:05:43 vault1 kernel: PCI: Using ACPI for IRQ routing
May 14 14:05:43 vault1 kernel: PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
May 14 14:05:43 vault1 kernel: NetLabel: Initializing
May 14 14:05:43 vault1 kernel: NetLabel:  domain hash size = 128
May 14 14:05:43 vault1 kernel: NetLabel:  protocols = UNLABELED CIPSOv4
May 14 14:05:43 vault1 kernel: NetLabel:  unlabeled traffic allowed by default
May 14 14:05:43 vault1 kernel: PCI-DMA: Disabling AGP.
May 14 14:05:43 vault1 kernel: PCI-DMA: aperture base @ 8000000 size 65536 KB
May 14 14:05:43 vault1 kernel: PCI-DMA: using GART IOMMU.
May 14 14:05:43 vault1 kernel: PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
May 14 14:05:43 vault1 kernel: pnp: 00:09: iomem range 0xffb80000-0xfffffffe could not be reserved
May 14 14:05:43 vault1 kernel: pnp: 00:09: iomem range 0xdfefc000-0xdfefcfff has been reserved
May 14 14:05:43 vault1 kernel: pnp: 00:09: iomem range 0xdfefd000-0xdfefd3ff has been reserved
May 14 14:05:43 vault1 kernel: pnp: 00:09: iomem range 0xdfefe000-0xdfefe3ff has been reserved
May 14 14:05:43 vault1 kernel: pnp: 00:0a: iomem range 0xfec00000-0xfec00fff could not be reserved
May 14 14:05:43 vault1 kernel: pnp: 00:0a: iomem range 0xfee00000-0xfeefffff could not be reserved
May 14 14:05:43 vault1 kernel: pnp: 00:0c: ioport range 0x680-0x6ff has been reserved
May 14 14:05:43 vault1 kernel: pnp: 00:0c: ioport range 0x295-0x296 has been reserved
May 14 14:05:43 vault1 kernel: pnp: 00:0c: ioport range 0x778-0x77f has been reserved
May 14 14:05:43 vault1 kernel: pnp: 00:0c: ioport range 0xb78-0xb7f has been reserved
May 14 14:05:43 vault1 kernel: pnp: 00:0c: ioport range 0xf78-0xf7f has been reserved
May 14 14:05:43 vault1 kernel: pnp: 00:0d: iomem range 0xe0000000-0xefffffff has been reserved
May 14 14:05:43 vault1 kernel: pnp: 00:0e: iomem range 0x0-0x9ffff could not be reserved
May 14 14:05:43 vault1 kernel: pnp: 00:0e: iomem range 0xc0000-0xdffff has been reserved
May 14 14:05:43 vault1 kernel: pnp: 00:0e: iomem range 0xe0000-0xfffff could not be reserved
May 14 14:05:43 vault1 kernel: pnp: 00:0e: iomem range 0x100000-0xbfffffff could not be reserved
May 14 14:05:43 vault1 kernel: PCI: Bridge: 0000:00:09.0
May 14 14:05:43 vault1 kernel:   IO window: 9000-9fff
May 14 14:05:43 vault1 kernel:   MEM window: fa000000-fc0fffff
May 14 14:05:43 vault1 kernel: Time: acpi_pm clocksource has been installed.
May 14 14:05:43 vault1 kernel:   PREFETCH window: c4000000-c40fffff
May 14 14:05:43 vault1 kernel: PCI: Bridge: 0000:00:0d.0
May 14 14:05:43 vault1 kernel:   IO window: disabled.
May 14 14:05:43 vault1 kernel:   MEM window: disabled.
May 14 14:05:43 vault1 kernel:   PREFETCH window: disabled.
May 14 14:05:43 vault1 kernel: PCI: Bridge: 0000:00:0e.0
May 14 14:05:43 vault1 kernel:   IO window: disabled.
May 14 14:05:44 vault1 kernel:   MEM window: f9d00000-f9ffffff
May 14 14:05:44 vault1 kernel:   PREFETCH window: fc200000-fe1fffff
May 14 14:05:44 vault1 kernel: PCI: Bridge: 0000:04:01.0
May 14 14:05:44 vault1 kernel:   IO window: disabled.
May 14 14:05:44 vault1 kernel:   MEM window: fe500000-fe5fffff
May 14 14:05:44 vault1 kernel:   PREFETCH window: fe700000-fe7fffff
May 14 14:05:44 vault1 kernel: PCI: Bridge: 0000:05:01.0
May 14 14:05:44 vault1 kernel:   IO window: e000-efff
May 14 14:05:44 vault1 kernel:   MEM window: fe300000-fe4fffff
May 14 14:05:44 vault1 kernel:   PREFETCH window: disabled.
May 14 14:05:44 vault1 kernel: PCI: Bridge: 0000:04:02.0
May 14 14:05:44 vault1 kernel:   IO window: e000-efff
May 14 14:05:44 vault1 kernel:   MEM window: fe300000-fe4fffff
May 14 14:05:44 vault1 kernel:   PREFETCH window: disabled.
May 14 14:05:44 vault1 kernel: PCI: Bridge: 0000:80:0d.0
May 14 14:05:44 vault1 kernel:   IO window: disabled.
May 14 14:05:44 vault1 kernel:   MEM window: disabled.
May 14 14:05:44 vault1 kernel:   PREFETCH window: disabled.
May 14 14:05:44 vault1 kernel: PCI: Bridge: 0000:81:00.0
May 14 14:05:44 vault1 kernel:   IO window: disabled.
May 14 14:05:44 vault1 kernel:   MEM window: fe900000-fe9fffff
May 14 14:05:44 vault1 kernel:   PREFETCH window: disabled.
May 14 14:05:44 vault1 kernel: PCI: Bridge: 0000:80:0e.0
May 14 14:05:44 vault1 kernel:   IO window: disabled.
May 14 14:05:44 vault1 kernel:   MEM window: fe900000-fe9fffff
May 14 14:05:44 vault1 kernel:   PREFETCH window: disabled.
May 14 14:05:44 vault1 kernel: NET: Registered protocol family 2
May 14 14:05:44 vault1 kernel: IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
May 14 14:05:44 vault1 kernel: TCP established hash table entries: 65536 (order: 10, 4194304 bytes)
May 14 14:05:44 vault1 kernel: TCP bind hash table entries: 65536 (order: 9, 3670016 bytes)
May 14 14:05:44 vault1 kernel: TCP: Hash tables configured (established 65536 bind 65536)
May 14 14:05:44 vault1 kernel: TCP reno registered
May 14 14:05:44 vault1 kernel: checking if image is initramfs... it is
May 14 14:05:44 vault1 kernel: Freeing initrd memory: 1592k freed
May 14 14:05:44 vault1 kernel: audit: initializing netlink socket (disabled)
May 14 14:05:44 vault1 kernel: audit(1179151443.002:1): initialized
May 14 14:05:44 vault1 kernel: Total HugeTLB memory allocated, 0
May 14 14:05:44 vault1 kernel: VFS: Disk quotas dquot_6.5.1
May 14 14:05:44 vault1 kernel: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
May 14 14:05:44 vault1 kernel: io scheduler noop registered
May 14 14:05:44 vault1 kernel: io scheduler anticipatory registered
May 14 14:05:44 vault1 kernel: io scheduler deadline registered (default)
May 14 14:05:44 vault1 kernel: io scheduler cfq registered
May 14 14:05:44 vault1 kernel: PCI: Found disabled HT MSI Mapping on 0000:00:0d.0
May 14 14:05:44 vault1 kernel: PCI: Found enabled HT MSI Mapping on 0000:00:00.0
May 14 14:05:44 vault1 kernel: PCI: Found disabled HT MSI Mapping on 0000:00:0e.0
May 14 14:05:44 vault1 kernel: PCI: Found enabled HT MSI Mapping on 0000:00:00.0
May 14 14:05:44 vault1 kernel: PCI: Found disabled HT MSI Mapping on 0000:80:0d.0
May 14 14:05:44 vault1 kernel: PCI: Found disabled HT MSI Mapping on 0000:80:00.0
May 14 14:05:44 vault1 kernel: PCI: MSI quirk detected. MSI disabled on chipset 0000:80:0d.0.
May 14 14:05:44 vault1 kernel: PCI: Found disabled HT MSI Mapping on 0000:80:0e.0
May 14 14:05:44 vault1 kernel: PCI: Found disabled HT MSI Mapping on 0000:80:00.0
May 14 14:05:44 vault1 kernel: PCI: MSI quirk detected. MSI disabled on chipset 0000:80:0e.0.
May 14 14:05:44 vault1 kernel: assign_interrupt_mode Found MSI capability
May 14 14:05:45 vault1 last message repeated 3 times
May 14 14:05:45 vault1 kernel: pci_hotplug: PCI Hot Plug PCI Core version: 0.5
May 14 14:05:45 vault1 kernel: Real Time Clock Driver v1.12ac
May 14 14:05:45 vault1 kernel: Non-volatile memory driver v1.2
May 14 14:05:45 vault1 kernel: Linux agpgart interface v0.102 (c) Dave Jones
May 14 14:05:45 vault1 kernel: Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
May 14 14:05:45 vault1 kernel: serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
May 14 14:05:45 vault1 kernel: serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
May 14 14:05:45 vault1 kernel: 00:05: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
May 14 14:05:45 vault1 kernel: 00:06: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
May 14 14:05:45 vault1 kernel: RAMDISK driver initialized: 16 RAM disks of 16384K size 4096 blocksize
May 14 14:05:45 vault1 kernel: input: Macintosh mouse button emulation as /class/input/input0
May 14 14:05:45 vault1 kernel: Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
May 14 14:05:45 vault1 kernel: ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
May 14 14:05:45 vault1 kernel: NFORCE-CK804: IDE controller at PCI slot 0000:00:06.0
May 14 14:05:45 vault1 kernel: NFORCE-CK804: chipset revision 242
May 14 14:05:45 vault1 kernel: NFORCE-CK804: not 100% native mode: will probe irqs later
May 14 14:05:45 vault1 kernel: NFORCE-CK804: 0000:00:06.0 (rev f2) UDMA133 controller
May 14 14:05:45 vault1 kernel:     ide0: BM-DMA at 0x3000-0x3007, BIOS settings: hda:DMA, hdb:DMA
May 14 14:05:45 vault1 kernel:     ide1: BM-DMA at 0x3008-0x300f, BIOS settings: hdc:DMA, hdd:DMA
May 14 14:05:45 vault1 kernel: hda: DVDR PX-750A, ATAPI CD/DVD-ROM drive
May 14 14:05:45 vault1 kernel: ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
May 14 14:05:45 vault1 kernel: ide-floppy driver 0.99.newide
May 14 14:05:45 vault1 kernel: usbcore: registered new interface driver libusual
May 14 14:05:45 vault1 kernel: usbcore: registered new interface driver hiddev
May 14 14:05:45 vault1 kernel: usbcore: registered new interface driver usbhid
May 14 14:05:45 vault1 kernel: drivers/usb/input/hid-core.c: v2.6:USB HID core driver
May 14 14:05:45 vault1 kernel: PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
May 14 14:05:45 vault1 kernel: PNP: PS/2 controller doesn't have AUX irq; using default 12
May 14 14:05:45 vault1 kernel: serio: i8042 KBD port at 0x60,0x64 irq 1
May 14 14:05:45 vault1 kernel: serio: i8042 AUX port at 0x60,0x64 irq 12
May 14 14:05:45 vault1 kernel: mice: PS/2 mouse device common for all mice
May 14 14:05:45 vault1 kernel: input: AT Translated Set 2 keyboard as /class/input/input1
May 14 14:05:45 vault1 kernel: input: AT Translated Set 2 keyboard as /class/input/input2
May 14 14:05:45 vault1 kernel: TCP bic registered
May 14 14:05:45 vault1 kernel: Initializing XFRM netlink socket
May 14 14:05:45 vault1 kernel: NET: Registered protocol family 1
May 14 14:05:45 vault1 kernel: NET: Registered protocol family 17
May 14 14:05:45 vault1 kernel: powernow-k8: Found 4 Dual Core AMD Opteron(tm) Processor 280 processors (version 2.00.00)
May 14 14:05:45 vault1 kernel: powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
May 14 14:05:45 vault1 kernel: powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
May 14 14:05:45 vault1 kernel: powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
May 14 14:05:45 vault1 kernel: powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
May 14 14:05:45 vault1 kernel: powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
May 14 14:05:45 vault1 kernel: powernow-k8:    0 : fid 0x10 (2400 MHz), vid 0x8
May 14 14:05:45 vault1 kernel: powernow-k8:    1 : fid 0xe (2200 MHz), vid 0xa
May 14 14:05:45 vault1 kernel: powernow-k8:    2 : fid 0xc (2000 MHz), vid 0xc
May 14 14:05:45 vault1 kernel: powernow-k8:    3 : fid 0xa (1800 MHz), vid 0xe
May 14 14:05:45 vault1 kernel: powernow-k8:    4 : fid 0x2 (1000 MHz), vid 0x12
May 14 14:05:45 vault1 kernel: Freeing unused kernel memory: 328k freed
May 14 14:05:45 vault1 kernel: Write protecting the kernel read-only data: 1101k
May 14 14:05:46 vault1 kernel: USB Universal Host Controller Interface driver v3.0
May 14 14:05:46 vault1 kernel: ACPI: PCI Interrupt Link [LUS0] enabled at IRQ 22
May 14 14:05:46 vault1 kernel: ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [LUS0] -> GSI 22 (level, low) -> IRQ 22
May 14 14:05:46 vault1 kernel: ohci_hcd 0000:00:02.0: OHCI Host Controller
May 14 14:05:46 vault1 kernel: ohci_hcd 0000:00:02.0: new USB bus registered, assigned bus number 1
May 14 14:05:46 vault1 kernel: ohci_hcd 0000:00:02.0: irq 22, io mem 0xfc1fb000
May 14 14:05:46 vault1 kernel: usb usb1: configuration #1 chosen from 1 choice
May 14 14:05:46 vault1 kernel: hub 1-0:1.0: USB hub found
May 14 14:05:46 vault1 kernel: hub 1-0:1.0: 10 ports detected
May 14 14:05:46 vault1 kernel: ACPI: PCI Interrupt Link [LUS2] enabled at IRQ 21
May 14 14:05:46 vault1 kernel: ACPI: PCI Interrupt 0000:00:02.1[B] -> Link [LUS2] -> GSI 21 (level, low) -> IRQ 21
May 14 14:05:46 vault1 kernel: ehci_hcd 0000:00:02.1: EHCI Host Controller
May 14 14:05:46 vault1 kernel: ehci_hcd 0000:00:02.1: new USB bus registered, assigned bus number 2
May 14 14:05:46 vault1 kernel: ehci_hcd 0000:00:02.1: debug port 1
May 14 14:05:46 vault1 kernel: ehci_hcd 0000:00:02.1: irq 21, io mem 0xfc1e0000
May 14 14:05:46 vault1 kernel: ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
May 14 14:05:46 vault1 kernel: usb usb2: configuration #1 chosen from 1 choice
May 14 14:05:46 vault1 kernel: hub 2-0:1.0: USB hub found
May 14 14:05:46 vault1 kernel: hub 2-0:1.0: 10 ports detected
May 14 14:05:46 vault1 kernel: megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
May 14 14:05:46 vault1 kernel: SCSI subsystem initialized
May 14 14:05:46 vault1 kernel: megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
May 14 14:05:46 vault1 kernel: megaraid: probe new device 0x1000:0x1960:0x1000:0x0520: bus 7:slot 1:func 0
May 14 14:05:46 vault1 kernel: ACPI: PCI Interrupt 0000:07:01.0[A] -> GSI 82 (level, low) -> IRQ 82
May 14 14:05:46 vault1 kernel: megaraid: fw version:[1L45] bios version:[G121]
May 14 14:05:46 vault1 kernel: scsi0 : LSI Logic MegaRAID driver
May 14 14:05:46 vault1 kernel: scsi[0]: scanning scsi channel 0 [Phy 0] for non-raid devices
May 14 14:05:46 vault1 kernel: scsi 0:0:8:0: Processor         SUPER    GEM359 REV001    1.09 PQ: 0 ANSI: 2
May 14 14:05:46 vault1 kernel: scsi[0]: scanning scsi channel 1 [virtual] for logical drives
May 14 14:05:46 vault1 kernel: scsi 0:1:0:0: Direct-Access     MegaRAID LD 0 RAID1   69G 1L45 PQ: 0 ANSI: 2
May 14 14:05:46 vault1 kernel: SCSI device sda: 142577664 512-byte hdwr sectors (73000 MB)
May 14 14:05:46 vault1 kernel: sda: Write Protect is off
May 14 14:05:46 vault1 kernel: sda: asking for cache data failed
May 14 14:05:46 vault1 kernel: sda: assuming drive cache: write through
May 14 14:05:46 vault1 kernel: SCSI device sda: 142577664 512-byte hdwr sectors (73000 MB)
May 14 14:05:46 vault1 kernel: sda: Write Protect is off
May 14 14:05:46 vault1 kernel: sda: asking for cache data failed
May 14 14:05:46 vault1 kernel: sda: assuming drive cache: write through
May 14 14:05:46 vault1 kernel:  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 sda8 >
May 14 14:05:46 vault1 kernel: sd 0:1:0:0: Attached scsi disk sda
May 14 14:05:46 vault1 kernel: scsi 0:1:1:0: Direct-Access     MegaRAID LD 1 RAID0   69G 1L45 PQ: 0 ANSI: 2
May 14 14:05:46 vault1 kernel: SCSI device sdb: 142577664 512-byte hdwr sectors (73000 MB)
May 14 14:05:46 vault1 kernel: sdb: Write Protect is off
May 14 14:05:46 vault1 kernel: sdb: asking for cache data failed
May 14 14:05:46 vault1 kernel: sdb: assuming drive cache: write through
May 14 14:05:46 vault1 kernel: SCSI device sdb: 142577664 512-byte hdwr sectors (73000 MB)
May 14 14:05:46 vault1 kernel: sdb: Write Protect is off
May 14 14:05:46 vault1 kernel: sdb: asking for cache data failed
May 14 14:05:46 vault1 kernel: sdb: assuming drive cache: write through
May 14 14:05:46 vault1 kernel:  sdb: sdb1
May 14 14:05:46 vault1 kernel:  sdb1: <solaris: [s0] sdb5 [s1] sdb6 [s2] sdb7 [s4] sdb8 [s7] sdb9 >
May 14 14:05:46 vault1 kernel: sd 0:1:1:0: Attached scsi disk sdb
May 14 14:05:46 vault1 kernel: shpchp: HPC vendor_id 1022 device_id 7458 ss_vid 0 ss_did 0
May 14 14:05:46 vault1 kernel: shpchp: shpc_init: cannot reserve MMIO region
May 14 14:05:46 vault1 kernel: shpchp: HPC vendor_id 1022 device_id 7458 ss_vid 0 ss_did 0
May 14 14:05:46 vault1 kernel: shpchp: shpc_init: cannot reserve MMIO region
May 14 14:05:46 vault1 kernel: shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
May 14 14:05:46 vault1 kernel: QLogic Fibre Channel HBA Driver
May 14 14:05:46 vault1 kernel: ACPI: PCI Interrupt 0000:06:04.0[A] -> GSI 87 (level, low) -> IRQ 87
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.0: Found an ISP2312, irq 87, iobase 0xffffc20000020000
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.0: Configuring PCI space...
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.0: Configure NVRAM parameters...
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.0: Verifying loaded RISC code...
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.0: Firmware image unavailable.
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.0: Firmware images can be retrieved from: ftp://ftp.qlogic.com/outgoing/linux/firmware/.
May 14 14:05:46 vault1 kernel: scsi1 : qla2xxx
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.0: Parity error -- HCCR=74a0, Dumping firmware!
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.0: No buffer available for dump!!!
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.0: 
May 14 14:05:46 vault1 kernel:  QLogic Fibre Channel HBA Driver: 8.01.07-k5
May 14 14:05:46 vault1 kernel:   QLogic QLA2344 - 133MHz PCI-X to 2Gb FC, Quad Channel
May 14 14:05:46 vault1 kernel:   ISP2312: PCI-X (133 MHz) @ 0000:06:04.0 hdma+, host#=1, fw=0.00.00 (0)
May 14 14:05:46 vault1 kernel: ACPI: PCI Interrupt 0000:06:04.1[B] -> GSI 88 (level, low) -> IRQ 88
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.1: Found an ISP2312, irq 88, iobase 0xffffc20000022000
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.1: Configuring PCI space...
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.1: Configure NVRAM parameters...
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.1: Verifying loaded RISC code...
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.1: Firmware image unavailable.
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.1: Firmware images can be retrieved from: ftp://ftp.qlogic.com/outgoing/linux/firmware/.
May 14 14:05:46 vault1 kernel: scsi2 : qla2xxx
May 14 14:05:46 vault1 kernel: qla2xxx 0000:06:04.1: Parity error -- HCCR=74a0, Dumping firmware!
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:04.1: No buffer available for dump!!!
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:04.1: 
May 14 14:05:47 vault1 kernel:  QLogic Fibre Channel HBA Driver: 8.01.07-k5
May 14 14:05:47 vault1 kernel:   QLogic QLA2344 - 133MHz PCI-X to 2Gb FC, Quad Channel
May 14 14:05:47 vault1 kernel:   ISP2312: PCI-X (133 MHz) @ 0000:06:04.1 hdma+, host#=2, fw=0.00.00 (0)
May 14 14:05:47 vault1 kernel: ACPI: PCI Interrupt 0000:06:06.0[A] -> GSI 89 (level, low) -> IRQ 89
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.0: Found an ISP2312, irq 89, iobase 0xffffc20000024000
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.0: Configuring PCI space...
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.0: Configure NVRAM parameters...
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.0: Verifying loaded RISC code...
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.0: Firmware image unavailable.
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.0: Firmware images can be retrieved from: ftp://ftp.qlogic.com/outgoing/linux/firmware/.
May 14 14:05:47 vault1 kernel: scsi3 : qla2xxx
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:04.0: Mailbox command timeout occured. Issuing ISP abort.
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:04.0: Performing ISP error recovery - ha= ffff810130e5c750.
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.0: Parity error -- HCCR=74a0, Dumping firmware!
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.0: No buffer available for dump!!!
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.0: 
May 14 14:05:47 vault1 kernel:  QLogic Fibre Channel HBA Driver: 8.01.07-k5
May 14 14:05:47 vault1 kernel:   QLogic QLA2344 - 133MHz PCI-X to 2Gb FC, Quad Channel
May 14 14:05:47 vault1 kernel:   ISP2312: PCI-X (133 MHz) @ 0000:06:06.0 hdma+, host#=3, fw=0.00.00 (0)
May 14 14:05:47 vault1 kernel: ACPI: PCI Interrupt 0000:06:06.1[B] -> GSI 90 (level, low) -> IRQ 90
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.1: Found an ISP2312, irq 90, iobase 0xffffc20000026000
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.1: Configuring PCI space...
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.1: Configure NVRAM parameters...
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.1: Verifying loaded RISC code...
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:04.0: Firmware image unavailable.
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:04.0: Firmware images can be retrieved from: ftp://ftp.qlogic.com/outgoing/linux/firmware/.
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:04.0: qla2x00_abort_isp: **** FAILED ****
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:04.0: Performing ISP error recovery - ha= ffff810130e5c750.
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:04.1: Mailbox command timeout occured. Issuing ISP abort.
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:04.1: Performing ISP error recovery - ha= ffff810130fc4750.
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.1: Firmware image unavailable.
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.1: Firmware images can be retrieved from: ftp://ftp.qlogic.com/outgoing/linux/firmware/.
May 14 14:05:47 vault1 kernel: scsi4 : qla2xxx
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.1: Parity error -- HCCR=74a0, Dumping firmware!
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.1: No buffer available for dump!!!
May 14 14:05:47 vault1 kernel: qla2xxx 0000:06:06.1: 
May 14 14:05:47 vault1 kernel:  QLogic Fibre Channel HBA Driver: 8.01.07-k5
May 14 14:05:47 vault1 kernel:   QLogic QLA2344 - 133MHz PCI-X to 2Gb FC, Quad Channel
May 14 14:05:47 vault1 kernel:   ISP2312: PCI-X (133 MHz) @ 0000:06:06.1 hdma+, host#=4, fw=0.00.00 (0)
May 14 14:05:47 vault1 kernel: kjournald starting.  Commit interval 5 seconds
May 14 14:05:47 vault1 kernel: EXT3-fs: mounted filesystem with ordered data mode.
May 14 14:05:47 vault1 kernel: SELinux:  Disabled at runtime.
May 14 14:05:47 vault1 kernel: audit(1179151517.943:2): selinux=0 auid=4294967295
May 14 14:05:47 vault1 kernel: parport: PnPBIOS parport detected.
May 14 14:05:47 vault1 kernel: parport0: PC-style at 0x378, irq 7 [PCSPP]
May 14 14:05:47 vault1 kernel: hda: ATAPI 40X DVD-ROM DVD-R-RAM CD-R/RW drive, 2048kB Cache, UDMA(66)
May 14 14:05:47 vault1 kernel: Uniform CD-ROM driver Revision: 3.20
May 14 14:05:47 vault1 kernel: ACPI: PCI Interrupt Link [LN2A] enabled at IRQ 43
May 14 14:05:47 vault1 kernel: ACPI: PCI Interrupt 0000:82:02.0[A] -> Link [LN2A] -> GSI 43 (level, low) -> IRQ 43
May 14 14:05:47 vault1 kernel: forcedeth.c: Reverse Engineered nForce ethernet driver. Version 0.60.
May 14 14:05:47 vault1 kernel: ACPI: PCI Interrupt Link [LKLN] enabled at IRQ 20
May 14 14:05:47 vault1 kernel: ACPI: PCI Interrupt 0000:00:0a.0[A] -> Link [LKLN] -> GSI 20 (level, low) -> IRQ 20
May 14 14:05:47 vault1 kernel: forcedeth: using HIGHDMA
May 14 14:05:47 vault1 kernel: ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[43]  MMIO=[fe9ff800-fe9fffff]  Max Packet=[4096]  IR/IT contexts=[4/8]
May 14 14:05:47 vault1 kernel: input: PC Speaker as /class/input/input3
May 14 14:05:47 vault1 kernel: ck804xrom ck804xrom_init_one(): Unable to register resource 0x00000000ffc00000-0x00000000ffffffff - kernel bug?
May 14 14:05:48 vault1 kernel: Found: SST 49LF080A
May 14 14:05:48 vault1 kernel: ck804xrom @fff00000: Found 1 x8 devices at 0x0 in 8-bit bank
May 14 14:05:48 vault1 kernel: qla2xxx 0000:06:04.0: Allocated (412 KB) for firmware dump...
May 14 14:05:48 vault1 kernel: qla2xxx 0000:06:04.1: Allocated (412 KB) for firmware dump...
May 14 14:05:48 vault1 kernel: number of JEDEC chips: 1
May 14 14:05:48 vault1 kernel: cfi_cmdset_0002: Disabling erase-suspend-program due to code brokenness.
May 14 14:05:48 vault1 kernel: scsi 0:0:8:0: Attached scsi generic sg0 type 3
May 14 14:05:48 vault1 kernel: sd 0:1:0:0: Attached scsi generic sg1 type 0
May 14 14:05:48 vault1 kernel: sd 0:1:1:0: Attached scsi generic sg2 type 0
May 14 14:05:48 vault1 kernel: Floppy drive(s): fd0 is 1.44M
May 14 14:05:48 vault1 kernel: eth0: forcedeth.c: subsystem: 015d9:1211 bound to 0000:00:0a.0
May 14 14:05:48 vault1 kernel: ACPI: PCI Interrupt Link [LK2N] enabled at IRQ 47
May 14 14:05:48 vault1 kernel: ACPI: PCI Interrupt 0000:80:0a.0[A] -> Link [LK2N] -> GSI 47 (level, low) -> IRQ 47
May 14 14:05:48 vault1 kernel: forcedeth: using HIGHDMA
May 14 14:05:48 vault1 kernel: i2c_adapter i2c-0: nForce2 SMBus adapter at 0x4c00
May 14 14:05:48 vault1 kernel: i2c_adapter i2c-1: nForce2 SMBus adapter at 0x4c40
May 14 14:05:48 vault1 kernel: ACPI: PCI Interrupt Link [LTID] enabled at IRQ 22
May 14 14:05:48 vault1 kernel: ACPI: PCI Interrupt 0000:00:07.0[A] -> Link [LTID] -> GSI 22 (level, low) -> IRQ 22
May 14 14:05:48 vault1 kernel: sata_nv 0000:00:07.0: Using ADMA mode
May 14 14:05:48 vault1 kernel: ata1: SATA max UDMA/133 cmd 0xffffc20000054480 ctl 0xffffc200000544a0 bmdma 0x000000000001c800 irq 22
May 14 14:05:48 vault1 kernel: ata2: SATA max UDMA/133 cmd 0xffffc20000054580 ctl 0xffffc200000545a0 bmdma 0x000000000001c808 irq 22
May 14 14:05:48 vault1 kernel: scsi5 : sata_nv
May 14 14:05:48 vault1 kernel: FDC 0 is a post-1991 82077
May 14 14:05:48 vault1 kernel: ata1: SATA link down (SStatus 0 SControl 300)
May 14 14:05:48 vault1 kernel: scsi6 : sata_nv
May 14 14:05:48 vault1 kernel: eth1: forcedeth.c: subsystem: 015d9:1211 bound to 0000:80:0a.0
May 14 14:05:48 vault1 kernel: qla2xxx 0000:06:06.0: Mailbox command timeout occured. Issuing ISP abort.
May 14 14:05:48 vault1 kernel: qla2xxx 0000:06:06.0: Performing ISP error recovery - ha= ffff810130fbc750.
May 14 14:05:48 vault1 kernel: ata2: SATA link down (SStatus 0 SControl 300)
May 14 14:05:48 vault1 kernel: ACPI: PCI Interrupt Link [LTIE] enabled at IRQ 21
May 14 14:05:48 vault1 kernel: ACPI: PCI Interrupt 0000:00:08.0[A] -> Link [LTIE] -> GSI 21 (level, low) -> IRQ 21
May 14 14:05:48 vault1 kernel: sata_nv 0000:00:08.0: Using ADMA mode
May 14 14:05:48 vault1 kernel: ata3: SATA max UDMA/133 cmd 0xffffc20000056480 ctl 0xffffc200000564a0 bmdma 0x000000000001b400 irq 21
May 14 14:05:48 vault1 kernel: ata4: SATA max UDMA/133 cmd 0xffffc20000056580 ctl 0xffffc200000565a0 bmdma 0x000000000001b408 irq 21
May 14 14:05:48 vault1 kernel: scsi7 : sata_nv
May 14 14:05:48 vault1 kernel: qla2xxx 0000:06:06.0: Allocated (412 KB) for firmware dump...
May 14 14:05:48 vault1 kernel: ata3: SATA link down (SStatus 0 SControl 300)
May 14 14:05:48 vault1 kernel: scsi8 : sata_nv
May 14 14:05:48 vault1 kernel: ata4: SATA link down (SStatus 0 SControl 300)
May 14 14:05:48 vault1 kernel: ACPI: PCI Interrupt Link [LAUI] enabled at IRQ 20
May 14 14:05:48 vault1 kernel: ACPI: PCI Interrupt 0000:00:04.0[A] -> Link [LAUI] -> GSI 20 (level, low) -> IRQ 20
May 14 14:05:48 vault1 kernel: qla2xxx 0000:06:06.0: LIP reset occured (f8f7).
May 14 14:05:48 vault1 kernel: qla2xxx 0000:06:06.0: LIP occured (f8f7).
May 14 14:05:48 vault1 kernel: qla2xxx 0000:06:06.0: LOOP UP detected (2 Gbps).
May 14 14:05:48 vault1 kernel: scsi 3:0:0:0: Direct-Access     YI-16SAE FC               66a. PQ: 0 ANSI: 5
May 14 14:05:48 vault1 kernel: SCSI device sdc: 1283080192 512-byte hdwr sectors (656937 MB)
May 14 14:05:48 vault1 kernel: sdc: Write Protect is off
May 14 14:05:48 vault1 kernel: SCSI device sdc: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
May 14 14:05:48 vault1 kernel: SCSI device sdc: 1283080192 512-byte hdwr sectors (656937 MB)
May 14 14:05:48 vault1 kernel: sdc: Write Protect is off
May 14 14:05:48 vault1 kernel: SCSI device sdc: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
May 14 14:05:48 vault1 kernel:  sdc: unknown partition table
May 14 14:05:48 vault1 kernel: sd 3:0:0:0: Attached scsi disk sdc
May 14 14:05:49 vault1 kernel: sd 3:0:0:0: Attached scsi generic sg3 type 0
May 14 14:05:49 vault1 kernel: scsi 3:0:0:1: Direct-Access     YI-16SAE FC               66a. PQ: 0 ANSI: 5
May 14 14:05:49 vault1 kernel: SCSI device sdd: 620380160 512-byte hdwr sectors (317635 MB)
May 14 14:05:49 vault1 kernel: sdd: Write Protect is off
May 14 14:05:49 vault1 kernel: SCSI device sdd: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
May 14 14:05:49 vault1 kernel: SCSI device sdd: 620380160 512-byte hdwr sectors (317635 MB)
May 14 14:05:49 vault1 kernel: sdd: Write Protect is off
May 14 14:05:49 vault1 kernel: SCSI device sdd: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
May 14 14:05:49 vault1 kernel:  sdd: unknown partition table
May 14 14:05:49 vault1 kernel: sd 3:0:0:1: Attached scsi disk sdd
May 14 14:05:49 vault1 kernel: sd 3:0:0:1: Attached scsi generic sg4 type 0
May 14 14:05:49 vault1 kernel: intel8x0_measure_ac97_clock: measured 51408 usecs
May 14 14:05:49 vault1 kernel: intel8x0: clocking to 46853
May 14 14:05:49 vault1 kernel: lp0: using parport0 (interrupt-driven).
May 14 14:05:49 vault1 kernel: lp0: console ready
May 14 14:05:49 vault1 kernel: input: Power Button (FF) as /class/input/input4
May 14 14:05:49 vault1 kernel: ACPI: Power Button (FF) [PWRF]
May 14 14:05:49 vault1 kernel: input: Power Button (CM) as /class/input/input5
May 14 14:05:49 vault1 kernel: ACPI: Power Button (CM) [PWRB]
May 14 14:05:49 vault1 kernel: No dock devices found.
May 14 14:05:49 vault1 kernel: ibm_acpi: ec object not found
May 14 14:05:49 vault1 kernel: md: Autodetecting RAID arrays.
May 14 14:05:49 vault1 kernel: md: autorun ...
May 14 14:05:49 vault1 kernel: md: ... autorun DONE.
May 14 14:05:49 vault1 kernel: device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-devel@redhat.com
May 14 14:05:49 vault1 kernel: device-mapper: multipath: version 1.0.5 loaded
May 14 14:05:49 vault1 kernel: EXT3 FS on sda3, internal journal
May 14 14:05:49 vault1 kernel: JFS: nTxBlock = 8192, nTxLock = 65536
May 14 14:05:49 vault1 kernel: kjournald starting.  Commit interval 5 seconds
May 14 14:05:49 vault1 kernel: EXT3 FS on sda7, internal journal
May 14 14:05:49 vault1 kernel: EXT3-fs: mounted filesystem with ordered data mode.
May 14 14:05:49 vault1 kernel: kjournald starting.  Commit interval 5 seconds
May 14 14:05:49 vault1 kernel: EXT3 FS on sda5, internal journal
May 14 14:05:49 vault1 kernel: EXT3-fs: mounted filesystem with ordered data mode.
May 14 14:05:49 vault1 kernel: kjournald starting.  Commit interval 5 seconds
May 14 14:05:49 vault1 kernel: EXT3 FS on sda6, internal journal
May 14 14:05:49 vault1 kernel: EXT3-fs: mounted filesystem with ordered data mode.
May 14 14:05:49 vault1 kernel: Adding 8385920k swap on /dev/sda2.  Priority:-1 extents:1 across:8385920k
May 14 14:05:49 vault1 kernel: NET: Registered protocol family 10
May 14 14:05:49 vault1 kernel: lo: Disabled Privacy Extensions
May 14 14:05:49 vault1 kernel: Mobile IPv6
May 14 14:05:49 vault1 kernel: eth0: no link during initialization.
May 14 14:05:49 vault1 kernel: ADDRCONF(NETDEV_UP): eth0: link is not ready
May 14 14:05:49 vault1 kernel: Bluetooth: Core ver 2.11
May 14 14:05:49 vault1 kernel: NET: Registered protocol family 31
May 14 14:05:49 vault1 kernel: Bluetooth: HCI device and connection manager initialized
May 14 14:05:49 vault1 kernel: Bluetooth: HCI socket layer initialized
May 14 14:05:49 vault1 kernel: Bluetooth: L2CAP ver 2.8
May 14 14:05:49 vault1 kernel: Bluetooth: L2CAP socket layer initialized
May 14 14:05:49 vault1 kernel: Bluetooth: HIDP (Human Interface Emulation) ver 1.2
May 14 14:05:49 vault1 kernel: qla2xxx 0000:06:04.1: Cable is unplugged...
May 14 14:05:49 vault1 kernel: qla2xxx 0000:06:04.0: Cable is unplugged...
May 14 14:05:49 vault1 kernel: Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
May 14 14:05:49 vault1 kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
May 14 14:05:49 vault1 kernel: NFSD: starting 90-second grace period
May 14 14:05:49 vault1 kernel: qla2xxx 0000:06:06.1: Mailbox command timeout occured. Issuing ISP abort.
May 14 14:05:49 vault1 kernel: qla2xxx 0000:06:06.1: Performing ISP error recovery - ha= ffff810130a70750.
May 14 14:05:49 vault1 kernel: qla2xxx 0000:06:06.1: Allocated (412 KB) for firmware dump...
May 14 14:05:50 vault1 kernel: qla2xxx 0000:06:06.1: LIP reset occured (f8f7).
May 14 14:05:50 vault1 kernel: qla2xxx 0000:06:06.1: LIP occured (f8f7).
May 14 14:05:50 vault1 kernel: qla2xxx 0000:06:06.1: LOOP UP detected (2 Gbps).
May 14 14:05:50 vault1 kernel: scsi 4:0:0:0: Direct-Access     YI-16SAE FC               606a PQ: 1 ANSI: 5
May 14 14:05:50 vault1 kernel: scsi 4:0:0:0: Attached scsi generic sg5 type 0
May 14 14:05:50 vault1 kernel: scsi 4:0:0:1: Direct-Access     YI-16SAE FC               66a. PQ: 0 ANSI: 5
May 14 14:05:50 vault1 kernel: SCSI device sde: 775471104 512-byte hdwr sectors (397041 MB)
May 14 14:05:50 vault1 kernel: sde: Write Protect is off
May 14 14:05:50 vault1 kernel: SCSI device sde: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
May 14 14:05:50 vault1 kernel: SCSI device sde: 775471104 512-byte hdwr sectors (397041 MB)
May 14 14:05:50 vault1 kernel: sde: Write Protect is off
May 14 14:05:50 vault1 kernel: SCSI device sde: write cache: enabled, read cache: enabled, doesn't support DPO or FUA
May 14 14:05:50 vault1 kernel:  sde: unknown partition table
May 14 14:05:50 vault1 kernel: sd 4:0:0:1: Attached scsi disk sde
May 14 14:05:50 vault1 kernel: sd 4:0:0:1: Attached scsi generic sg6 type 0
May 14 14:05:51 vault1 smartd[3874]: smartd version 5.36 [x86_64-redhat-linux-gnu] Copyright (C) 2002-6 Bruce Allen 
May 14 14:05:51 vault1 smartd[3874]: Home page is http://smartmontools.sourceforge.net/  
May 14 14:05:51 vault1 smartd[3874]: Opened configuration file /etc/smartd.conf 
May 14 14:05:51 vault1 smartd[3874]: Configuration file /etc/smartd.conf parsed. 
May 14 14:05:51 vault1 smartd[3874]: Device: /dev/sde, opened 
May 14 14:05:51 vault1 smartd[3874]: Device: /dev/sde, is SMART capable. Adding to "monitor" list. 
May 14 14:05:51 vault1 smartd[3874]: Device: /dev/sdc, opened 
May 14 14:05:51 vault1 smartd[3874]: Device: /dev/sdc, is SMART capable. Adding to "monitor" list. 
May 14 14:05:51 vault1 smartd[3874]: Device: /dev/sdd, opened 
May 14 14:05:51 vault1 smartd[3874]: Device: /dev/sdd, is SMART capable. Adding to "monitor" list. 
May 14 14:05:51 vault1 smartd[3874]: Monitoring 0 ATA and 3 SCSI devices 
May 14 14:05:51 vault1 smartd[3876]: smartd has fork()ed into background mode. New PID=3876. 
May 14 14:08:11 vault1 mountd[3644]: Caught signal 15, un-registering and exiting.
May 14 14:08:15 vault1 kernel: nfsd: last server has exited
May 14 14:08:15 vault1 kernel: nfsd: unexporting all filesystems
May 14 14:08:15 vault1 kernel: RPC: failed to contact portmap (errno -5).
May 14 14:08:16 vault1 kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
May 14 14:08:16 vault1 kernel: NFSD: starting 90-second grace period
May 14 14:08:45 vault1 mountd[4068]: authenticated mount request from 172.19.1.247:941 for /test (/test)
May 14 16:34:15 vault1 dhclient: DHCPREQUEST on eth1 to 172.19.100.1 port 67
May 14 16:34:15 vault1 dhclient: DHCPACK from 172.19.100.1
May 14 16:34:15 vault1 dhclient: bound to 172.19.1.241 -- renewal in 9293 seconds.
May 14 19:09:07 vault1 dhclient: DHCPREQUEST on eth1 to 172.19.100.1 port 67
May 14 19:09:08 vault1 dhclient: DHCPACK from 172.19.100.1
May 14 19:09:08 vault1 dhclient: bound to 172.19.1.241 -- renewal in 8182 seconds.
May 14 21:25:30 vault1 dhclient: DHCPREQUEST on eth1 to 172.19.100.1 port 67
May 14 21:25:30 vault1 dhclient: DHCPACK from 172.19.100.1
May 14 21:25:30 vault1 dhclient: bound to 172.19.1.241 -- renewal in 8851 seconds.
May 14 23:53:00 vault1 dhclient: DHCPREQUEST on eth1 to 172.19.100.1 port 67
May 14 23:53:01 vault1 dhclient: DHCPACK from 172.19.100.1
May 14 23:53:01 vault1 dhclient: bound to 172.19.1.241 -- renewal in 9286 seconds.
May 15 02:27:46 vault1 dhclient: DHCPREQUEST on eth1 to 172.19.100.1 port 67
May 15 02:27:47 vault1 dhclient: DHCPACK from 172.19.100.1
May 15 02:27:47 vault1 dhclient: bound to 172.19.1.241 -- renewal in 10425 seconds.
May 15 05:21:32 vault1 dhclient: DHCPREQUEST on eth1 to 172.19.100.1 port 67
May 15 05:21:32 vault1 dhclient: DHCPACK from 172.19.100.1
May 15 05:21:32 vault1 dhclient: bound to 172.19.1.241 -- renewal in 9545 seconds.
May 15 05:27:25 vault1 kernel: SysRq : Show State
May 15 05:27:25 vault1 kernel: 
May 15 05:27:25 vault1 kernel:                                  free                        sibling
May 15 05:27:25 vault1 kernel:   task                 PC        stack   pid father child younger older
May 15 05:27:25 vault1 kernel: init          S ffff810230f85a98     0     1      0 (NOTLB)
May 15 05:27:25 vault1 kernel:  ffff810136ba3a18 0000000000000046 0000000000000000 ffff810130c70040
May 15 05:27:25 vault1 kernel:  ffff810130c70040 ffffffff802638fc 000000000000000a ffff810130c70040
May 15 05:27:25 vault1 kernel:  ffffffff8058a6e0 000000000000932c ffff810130c70248 0000000080733000
May 15 05:27:25 vault1 kernel: Call Trace:
May 15 05:27:25 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:25 vault1 kernel:  [<ffffffff80261790>] schedule_timeout+0x8a/0xad
May 15 05:27:25 vault1 kernel:  [<ffffffff802913d9>] process_timeout+0x0/0x5
May 15 05:27:25 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:27:26 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:26 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:26 vault1 kernel:  [<ffffffff80209596>] __d_lookup+0x77/0x110
May 15 05:27:26 vault1 kernel: e+0x13/0x34
May 15 05:27:26 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:26 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:26 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:26 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:26 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:26 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:26 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:26 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:26 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:26 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:26 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:26 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:26 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:26 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:26 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:26 vault1 kernel: 
May 15 05:27:26 vault1 kernel: kblockd/3     S ffff810130b704b8     0    62     19 (L-TLB)
May 15 05:27:26 vault1 kernel:  ffff810230f93ea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:26 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff810230f3f080
May 15 05:27:26 vault1 kernel:  ffff81022fd6e0c0 000000000000660c ffff810230f3f288 0000000330f3f080
May 15 05:27:26 vault1 kernel: Call Trace:
May 15 05:27:26 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:26 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:26 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:26 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:26 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:26 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:26 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:26 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:26 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:26 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:26 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:26 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:26 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:26 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:26 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:26 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:26 vault1 kernel: 
May 15 05:27:26 vault1 kernel: kacpid        S ffffffff8058a280     0    63     19 (L-TLB)
May 15 05:27:26 vault1 kernel:  ffff810230f99ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:26 vault1 kernel:  0000000000000000 0000000000000000 0000000000000005 ffff810230f3e0c0
May 15 05:27:26 vault1 kernel:  ffff810136be9080 0000000000000cfb ffff810230f3e2c8 0000000230f3e0c0
May 15 05:27:26 vault1 kernel: Call Trace:
May 15 05:27:26 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:26 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:26 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:26 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:26 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:26 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:26 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:26 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:26 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:26 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:26 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:26 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:27 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:27 vault1 kernel: 
May 15 05:27:27 vault1 kernel: cqueue/0      S ffffffff8058a280     0   235     19 (L-TLB)
May 15 05:27:27 vault1 kernel:  ffff810230e99ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:27 vault1 kernel:  0000000000000000 0000000000000000 0000000000000006 ffff810230f550c0
May 15 05:27:27 vault1 kernel:  ffffffff8058a6e0 0000000000001ba6 ffff810230f552c8 0000000030f550c0
May 15 05:27:27 vault1 kernel: Call Trace:
May 15 05:27:27 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:27 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:27 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:27 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:27 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:27 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:27 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:27 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:27 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:27 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:27 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:27 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:27 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:27 vault1 kernel: 
May 15 05:27:27 vault1 kernel: cqueue/1      S ffffffff8058a280     0   236     19 (L-TLB)
May 15 05:27:27 vault1 kernel:  ffff810230e87ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:27 vault1 kernel:  0000000000000000 0000000000000000 0000000000000005 ffff810230f4b040
May 15 05:27:27 vault1 kernel:  ffff810136b92040 0000000000001a77 ffff810230f4b248 0000000130f4b040
May 15 05:27:27 vault1 kernel: Call Trace:
May 15 05:27:27 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:27 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:27 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:27 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:27 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:27 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:27 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:27 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:27 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:27 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:27 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:27 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:27 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:27 vault1 kernel: 
May 15 05:27:27 vault1 kernel: cqueue/2      S ffffffff8058a280     0   237     19 (L-TLB)
May 15 05:27:27 vault1 kernel:  ffff810230e95ea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:27 vault1 kernel:  0000000000000000 0000000000000000 0000000000000006 ffff810230f4a080
May 15 05:27:27 vault1 kernel:  ffff810130a13080 0000000000001361 ffff810230f4a288 0000000230f4a080
May 15 05:27:27 vault1 kernel: Call Trace:
May 15 05:27:27 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:27 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:27 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:27 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:27 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:27 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:27 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:27 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:27 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:27 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:27 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:27 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:27 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:27 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:27 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:27 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:27 vault1 kernel: 
May 15 05:27:27 vault1 kernel: cqueue/3      S ffffffff8058a280     0   238     19 (L-TLB)
May 15 05:27:27 vault1 kernel:  ffff810230e97ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:27 vault1 kernel:  0000000000000000 0000000000000000 0000000000000005 ffff810230f44040
May 15 05:27:27 vault1 kernel:  ffff810230c4c0c0 00000000000014a6 ffff810230f44248 0000000330f44040
May 15 05:27:27 vault1 kernel: Call Trace:
May 15 05:27:27 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:27 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:27 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:27 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:27 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:27 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:27 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:27 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:27 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:27 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:27 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:27 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:27 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:27 vault1 kernel: 
May 15 05:27:27 vault1 kernel: ksuspend_usbd S ffffffff8058a280     0   239     19 (L-TLB)
May 15 05:27:27 vault1 kernel:  ffff810230eb9ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:27 vault1 kernel:  0000000000000000 0000000000000000 0000000000000006 ffff810230f450c0
May 15 05:27:27 vault1 kernel:  ffff810136be9080 0000000000001012 ffff810230f452c8 0000000230f450c0
May 15 05:27:27 vault1 kernel: Call Trace:
May 15 05:27:27 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:27 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:27 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:27 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:27 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:28 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:28 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:28 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:28 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:28 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:28 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:28 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:28 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:28 vault1 kernel: 
May 15 05:27:28 vault1 kernel: khubd         S ffff810130b71638     0   242     19 (L-TLB)
May 15 05:27:28 vault1 kernel:  ffff8102309c1e20 0000000000000046 0000000000000000 0000000000000000
May 15 05:27:28 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff810230f4d080
May 15 05:27:28 vault1 kernel:  ffff810136be9080 0000000000011d07 ffff810230f4d288 0000000230f4d080
May 15 05:27:28 vault1 kernel: Call Trace:
May 15 05:27:28 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:28 vault1 kernel:  [<ffffffff803d6dc8>] hub_thread+0xac0/0xb3c
May 15 05:27:28 vault1 kernel:  [<ffffffff80260f58>] thread_return+0x88/0x12a
May 15 05:27:28 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:28 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:28 vault1 kernel:  [<ffffffff803d6308>] hub_thread+0x0/0xb3c
May 15 05:27:28 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:28 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:28 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:28 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:28 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:28 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:28 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:28 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:28 vault1 kernel: 
May 15 05:27:28 vault1 kernel: kseriod       S ffffffff8058a280     0   244     19 (L-TLB)
May 15 05:27:28 vault1 kernel:  ffff8102309c7ec0 0000000000000046 0000000000000000 0000000000000000
May 15 05:27:28 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff810230f610c0
May 15 05:27:28 vault1 kernel:  ffffffff8058a6e0 0000000000005165 ffff810230f612c8 0000000030f610c0
May 15 05:27:28 vault1 kernel: Call Trace:
May 15 05:27:28 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:28 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:28 vault1 kernel:  [<ffffffff803eaaea>] serio_thread+0x2a5/0x2f8
May 15 05:27:28 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:28 vault1 kernel:  [<ffffffff803ea845>] serio_thread+0x0/0x2f8
May 15 05:27:28 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:28 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:28 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:28 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:28 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:28 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:28 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:28 vault1 kernel: 
May 15 05:27:28 vault1 kernel: pdflush       S ffff810230f84058     0   298     19 (L-TLB)
May 15 05:27:28 vault1 kernel:  ffff8102308f1ed0 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:27:28 vault1 kernel:  0000000180598080 0000000000000002 000000000000000a ffff810230f20080
May 15 05:27:28 vault1 kernel:  ffff810136be9080 0000000000004416 ffff810230f20288 0000000200000000
May 15 05:27:28 vault1 kernel: Call Trace:
May 15 05:27:28 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:28 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:28 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:28 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:28 vault1 kernel:  [<ffffffff80254d52>] pdflush+0x0/0x1e7
May 15 05:27:28 vault1 kernel:  [<ffffffff80254e21>] pdflush+0xcf/0x1e7
May 15 05:27:28 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:28 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:28 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:28 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:28 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:28 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:28 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:28 vault1 kernel: 
May 15 05:27:28 vault1 kernel: pdflush       D ffff810230f84058     0   299     19 (L-TLB)
May 15 05:27:28 vault1 kernel:  ffff8102308f3a20 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:27:28 vault1 kernel:  000000018020c209 0000000000000002 000000000000000a ffff810230f1f0c0
May 15 05:27:28 vault1 kernel:  ffff810136be9080 00000000000024d0 ffff810230f1f2c8 0000000200000001
May 15 05:27:28 vault1 kernel: Call Trace:
May 15 05:27:28 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:28 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:28 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:28 vault1 kernel:  [<ffffffff80262fa6>] __down_write_nested+0x7e/0x96
May 15 05:27:28 vault1 kernel:  [<ffffffff8832253a>] :jfs:jfs_get_block+0x45/0x237
May 15 05:27:28 vault1 kernel:  [<ffffffff8021c67c>] generic_make_request+0x207/0x21e
May 15 05:27:28 vault1 kernel:  [<ffffffff802e9478>] __mpage_writepage+0x1f5/0x55d
May 15 05:27:28 vault1 kernel:  [<ffffffff883224f5>] :jfs:jfs_get_block+0x0/0x237
May 15 05:27:28 vault1 kernel:  [<ffffffff802638bb>] _read_unlock_irq+0x24/0x27
May 15 05:27:28 vault1 kernel:  [<ffffffff802c0835>] dec_zone_page_state+0x33/0x3a
May 15 05:27:28 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:28 vault1 kernel:  [<ffffffff802c0835>] dec_zone_page_state+0x33/0x3a
May 15 05:27:28 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:28 vault1 kernel:  [<ffffffff8021d493>] mpage_writepages+0x228/0x375
May 15 05:27:28 vault1 kernel:  [<ffffffff883220bb>] :jfs:jfs_writepage+0x0/0xf
May 15 05:27:29 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:29 vault1 kernel:  [<ffffffff883224f5>] :jfs:jfs_get_block+0x0/0x237
May 15 05:27:29 vault1 kernel:  [<ffffffff802593b8>] do_writepages+0x23/0x30
May 15 05:27:29 vault1 kernel:  [<ffffffff80230487>] __writeback_single_inode+0x1c0/0x338
May 15 05:27:29 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:29 vault1 kernel:  [<ffffffff80263584>] _read_unlock+0x17/0x20
May 15 05:27:29 vault1 kernel:  [<ffffffff80221c26>] sync_sb_inodes+0x1a6/0x267
May 15 05:27:29 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:29 vault1 kernel:  [<ffffffff8024f304>] writeback_inodes+0x95/0xee
May 15 05:27:29 vault1 kernel:  [<ffffffff802be735>] wb_kupdate+0x9e/0x112
May 15 05:27:29 vault1 kernel:  [<ffffffff80254d52>] pdflush+0x0/0x1e7
May 15 05:27:29 vault1 kernel:  [<ffffffff80254d52>] pdflush+0x0/0x1e7
May 15 05:27:29 vault1 kernel:  [<ffffffff80254e8e>] pdflush+0x13c/0x1e7
May 15 05:27:29 vault1 kernel:  [<ffffffff802be697>] wb_kupdate+0x0/0x112
May 15 05:27:29 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:29 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:29 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:29 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:29 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:29 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:29 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:29 vault1 kernel: 
May 15 05:27:29 vault1 kernel: kswapd0       S ffff810230f85a98     0   300     19 (L-TLB)
May 15 05:27:29 vault1 kernel:  ffff8102308f5e20 0000000000000046 0000000000000000 0000000000000000
May 15 05:27:29 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff810230f1e040
May 15 05:27:29 vault1 kernel:  ffffffff8058a6e0 00000000000a49df ffff810230f1e248 0000000030f1e040
May 15 05:27:29 vault1 kernel: Call Trace:
May 15 05:27:29 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:29 vault1 kernel:  [<ffffffff802560c6>] kswapd+0xea/0x469
May 15 05:27:29 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:29 vault1 kernel:  [<ffffffff80255fdc>] kswapd+0x0/0x469
May 15 05:27:29 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:29 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:29 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:29 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:29 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:29 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:29 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:29 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:29 vault1 kernel: 
May 15 05:27:29 vault1 kernel: kswapd1       S ffff81012eb76538     0   301     19 (L-TLB)
May 15 05:27:29 vault1 kernel:  ffff8102308f7e20 0000000000000046 0000000000000000 0000000000000000
May 15 05:27:29 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff810230f1d080
May 15 05:27:29 vault1 kernel:  ffff810136be9080 00000000000a7777 ffff810230f1d288 0000000230f1d080
May 15 05:27:29 vault1 kernel: Call Trace:
May 15 05:27:29 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:29 vault1 kernel:  [<ffffffff802560c6>] kswapd+0xea/0x469
May 15 05:27:29 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:29 vault1 kernel:  [<ffffffff80255fdc>] kswapd+0x0/0x469
May 15 05:27:29 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:29 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:29 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:29 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:29 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:29 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:29 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:29 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:29 vault1 kernel: 
May 15 05:27:29 vault1 kernel: aio/0         S ffffffff8058a280     0   302     19 (L-TLB)
May 15 05:27:29 vault1 kernel:  ffff8102308f9ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:29 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff810230f1c0c0
May 15 05:27:29 vault1 kernel:  ffffffff8058a6e0 00000000000016fc ffff810230f1c2c8 0000000030f1c0c0
May 15 05:27:29 vault1 kernel: Call Trace:
May 15 05:27:29 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:29 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:29 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:29 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:29 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:29 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:29 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:29 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:29 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:29 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:29 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:29 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:29 vault1 kernel: 
May 15 05:27:29 vault1 kernel: aio/1         S ffffffff8058a280     0   303     19 (L-TLB)
May 15 05:27:29 vault1 kernel:  ffff8102308fbea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:29 vault1 kernel:  0000000000000000 0000000000000000 0000000000000006 ffff810230f1b040
May 15 05:27:29 vault1 kernel:  ffff810136b92040 0000000000001bb0 ffff810230f1b248 0000000130f1b040
May 15 05:27:29 vault1 kernel: Call Trace:
May 15 05:27:29 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:29 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:29 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:29 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:30 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:30 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:30 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:30 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:30 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:30 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:30 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:30 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:30 vault1 kernel: 
May 15 05:27:30 vault1 kernel: aio/2         S ffffffff8058a280     0   304     19 (L-TLB)
May 15 05:27:30 vault1 kernel:  ffff8102308fdea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:30 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff810230f19080
May 15 05:27:30 vault1 kernel:  ffff810130a13080 0000000000001be7 ffff810230f19288 0000000230f19080
May 15 05:27:30 vault1 kernel: Call Trace:
May 15 05:27:30 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:30 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:30 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:30 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:30 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:30 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:30 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:30 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:30 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:30 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:30 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:30 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:30 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:30 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:30 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:30 vault1 kernel: 
May 15 05:27:30 vault1 kernel: aio/3         S ffffffff8058a280     0   305     19 (L-TLB)
May 15 05:27:30 vault1 kernel:  ffff8102308c1ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:30 vault1 kernel:  0000000000000000 0000000000000000 0000000000000008 ffff810230f32080
May 15 05:27:30 vault1 kernel:  ffff810230c4c0c0 0000000000001498 ffff810230f32288 0000000330f32080
May 15 05:27:30 vault1 kernel: Call Trace:
May 15 05:27:30 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:30 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:30 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:30 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:30 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:30 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:30 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:30 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:30 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:30 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:30 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:30 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:30 vault1 kernel: 
May 15 05:27:30 vault1 kernel: kpsmoused     S ffffffff8058a280     0   461     19 (L-TLB)
May 15 05:27:30 vault1 kernel:  ffff810130b5dea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:30 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130f640c0
May 15 05:27:30 vault1 kernel:  ffffffff8058a6e0 0000000000000fc7 ffff810130f642c8 0000000030f640c0
May 15 05:27:30 vault1 kernel: Call Trace:
May 15 05:27:30 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:30 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:30 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:30 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:30 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:30 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:30 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:30 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:30 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:30 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:30 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:30 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:30 vault1 kernel: 
May 15 05:27:30 vault1 kernel: scsi_eh_0     S ffff810130b71638     0   520     19 (L-TLB)
May 15 05:27:30 vault1 kernel:  ffff810130203e70 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:30 vault1 kernel:  0000000000000000 0000000000000046 0000000000000004 ffff8101309050c0
May 15 05:27:30 vault1 kernel:  ffff810136be9080 00000000000009fd ffff8101309052c8 0000000280263894
May 15 05:27:30 vault1 kernel: Call Trace:
May 15 05:27:30 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:30 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:30 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:27:30 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:27:30 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:30 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:30 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:30 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:30 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:30 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:30 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:30 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:30 vault1 kernel: 
May 15 05:27:30 vault1 kernel: scsi_eh_1     S ffff810130b71638     0   536     19 (L-TLB)
May 15 05:27:30 vault1 kernel:  ffff81013029de70 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:30 vault1 kernel:  0000000000000000 0000000000000046 0000000000000006 ffff81013007e0c0
May 15 05:27:30 vault1 kernel:  ffff810136be9080 00000000000006ce ffff81013007e2c8 0000000280263894
May 15 05:27:30 vault1 kernel: Call Trace:
May 15 05:27:31 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:31 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:31 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:27:31 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:27:31 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:31 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:31 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:31 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:31 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:31 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:31 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:31 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:31 vault1 kernel: 
May 15 05:27:31 vault1 kernel: qla2xxx_1_dpc S ffff810230e444f8     0   537     19 (L-TLB)
May 15 05:27:31 vault1 kernel:  ffff810130f75ee0 0000000000000046 0000000000000000 ffffffff802913d9
May 15 05:27:31 vault1 kernel:  ffff810130e5c7e8 ffff810130917040 000000000000000a ffff810130917040
May 15 05:27:31 vault1 kernel:  ffff810136b92040 00000000000008a0 ffff810130917248 000000018029fe09
May 15 05:27:31 vault1 kernel: Call Trace:
May 15 05:27:31 vault1 kernel:  [<ffffffff802913d9>] process_timeout+0x0/0x5
May 15 05:27:31 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:31 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:27:31 vault1 kernel:  [<ffffffff880ba348>] :qla2xxx:qla2x00_do_dpc+0x39/0x439
May 15 05:27:31 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:31 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:27:31 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:31 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:31 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:31 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:31 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:31 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:31 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:31 vault1 kernel: 
May 15 05:27:31 vault1 kernel: scsi_wq_1     S ffff810130b71638     0   538     19 (L-TLB)
May 15 05:27:31 vault1 kernel:  ffff810130f73ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:31 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130ff8040
May 15 05:27:31 vault1 kernel:  ffff810136be9080 00000000000014b7 ffff810130ff8248 0000000230ff8040
May 15 05:27:31 vault1 kernel: Call Trace:
May 15 05:27:31 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:31 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:31 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:31 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:31 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:31 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:31 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:31 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:31 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:31 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:31 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:31 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:31 vault1 kernel: 
May 15 05:27:31 vault1 kernel: fc_wq_1       S ffff810130b71638     0   539     19 (L-TLB)
May 15 05:27:31 vault1 kernel:  ffff810130fafea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:31 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130fff080
May 15 05:27:31 vault1 kernel:  ffff810136be9080 00000000000012d2 ffff810130fff288 0000000230fff080
May 15 05:27:31 vault1 kernel: Call Trace:
May 15 05:27:31 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:31 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:31 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:31 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:31 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:31 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:31 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:31 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:31 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:31 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:31 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:31 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:31 vault1 kernel: 
May 15 05:27:31 vault1 kernel: fc_dl_1       S ffff810130b71a98     0   540     19 (L-TLB)
May 15 05:27:31 vault1 kernel:  ffff810130137ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:31 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff81013007f0c0
May 15 05:27:31 vault1 kernel:  ffffffff8058a6e0 0000000000001268 ffff81013007f2c8 000000003007f0c0
May 15 05:27:31 vault1 kernel: Call Trace:
May 15 05:27:31 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:31 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:31 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:31 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:31 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:31 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:31 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:31 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:31 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:31 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:31 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:31 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:31 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:31 vault1 kernel: 
May 15 05:27:31 vault1 kernel: scsi_eh_2     S ffff810130b71638     0   541     19 (L-TLB)
May 15 05:27:32 vault1 kernel:  ffff81013091de70 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:32 vault1 kernel:  0000000000000000 0000000000000046 0000000000000009 ffff810130c5a040
May 15 05:27:32 vault1 kernel:  ffff810136be9080 00000000000007e9 ffff810130c5a248 0000000280263894
May 15 05:27:32 vault1 kernel: Call Trace:
May 15 05:27:32 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:32 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:32 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:27:32 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:27:32 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:32 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:32 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:32 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:32 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:32 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:32 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:32 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:32 vault1 kernel: 
May 15 05:27:32 vault1 kernel: qla2xxx_2_dpc S ffff810230e444f8     0   542     19 (L-TLB)
May 15 05:27:32 vault1 kernel:  ffff810130fcbee0 0000000000000046 0000000000000000 ffff810130be1080
May 15 05:27:32 vault1 kernel:  ffff810130be1080 ffffffff802638fc 000000000000000a ffff810130be1080
May 15 05:27:32 vault1 kernel:  ffff810136b92040 0000000000000604 ffff810130be1288 00000001880ba30f
May 15 05:27:32 vault1 kernel: Call Trace:
May 15 05:27:32 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:32 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:27:32 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:32 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:27:32 vault1 kernel:  [<ffffffff880ba348>] :qla2xxx:qla2x00_do_dpc+0x39/0x439
May 15 05:27:32 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:32 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:27:32 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:32 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:32 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:32 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:32 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:32 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:32 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:32 vault1 kernel: 
May 15 05:27:32 vault1 kernel: scsi_wq_2     S ffff810130b71638     0   543     19 (L-TLB)
May 15 05:27:32 vault1 kernel:  ffff810130911ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:32 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff8101308170c0
May 15 05:27:32 vault1 kernel:  ffff810136be9080 0000000000001242 ffff8101308172c8 00000002308170c0
May 15 05:27:32 vault1 kernel: Call Trace:
May 15 05:27:32 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:32 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:32 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:32 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:32 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:32 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:32 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:32 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:32 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:32 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:32 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:32 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:32 vault1 kernel: 
May 15 05:27:32 vault1 kernel: fc_wq_2       S ffff810130b71638     0   544     19 (L-TLB)
May 15 05:27:32 vault1 kernel:  ffff810130fc1ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:32 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130852040
May 15 05:27:32 vault1 kernel:  ffff810136be9080 0000000000000fdf ffff810130852248 0000000230852040
May 15 05:27:32 vault1 kernel: Call Trace:
May 15 05:27:32 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:32 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:32 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:32 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:32 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:32 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:32 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:32 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:32 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:32 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:32 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:32 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:32 vault1 kernel: 
May 15 05:27:32 vault1 kernel: fc_dl_2       S ffff810130b71638     0   545     19 (L-TLB)
May 15 05:27:32 vault1 kernel:  ffff81013009dea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:32 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130853080
May 15 05:27:32 vault1 kernel:  ffff810136be9080 00000000000011d4 ffff810130853288 0000000230853080
May 15 05:27:32 vault1 kernel: Call Trace:
May 15 05:27:32 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:32 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:32 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:32 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:32 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:32 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:32 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:32 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:32 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:32 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:33 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:33 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:33 vault1 kernel: 
May 15 05:27:33 vault1 kernel: scsi_eh_3     S ffff810130b71638     0   546     19 (L-TLB)
May 15 05:27:33 vault1 kernel:  ffff8101308e5e70 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:33 vault1 kernel:  0000000000000000 0000000000000046 0000000000000009 ffff81013081c0c0
May 15 05:27:33 vault1 kernel:  ffff810136be9080 000000000000074f ffff81013081c2c8 0000000280263894
May 15 05:27:33 vault1 kernel: Call Trace:
May 15 05:27:33 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:33 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:33 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:27:33 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:27:33 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:33 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:33 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:33 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:33 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:33 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:33 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:33 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:33 vault1 kernel: 
May 15 05:27:33 vault1 kernel: qla2xxx_3_dpc S ffff81012fe02998     0   547     19 (L-TLB)
May 15 05:27:33 vault1 kernel:  ffff8101309f7ee0 0000000000000046 0000000000000000 ffff810130843040
May 15 05:27:33 vault1 kernel:  ffff810130843040 ffffffff802638fc 000000000000000a ffff810130843040
May 15 05:27:33 vault1 kernel:  ffff810136b92040 0000000000006120 ffff810130843248 00000001880ba30f
May 15 05:27:33 vault1 kernel: Call Trace:
May 15 05:27:33 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:33 vault1 kernel:  [<ffffffff880bcb27>] :qla2xxx:qla2x00_fw_ready+0x84/0x1a2
May 15 05:27:33 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:27:33 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:33 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:27:33 vault1 kernel:  [<ffffffff880ba348>] :qla2xxx:qla2x00_do_dpc+0x39/0x439
May 15 05:27:33 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:33 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:27:33 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:33 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:33 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:33 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:33 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:33 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:33 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:33 vault1 kernel: 
May 15 05:27:33 vault1 kernel: scsi_wq_3     S ffff810230f851d8     0   548     19 (L-TLB)
May 15 05:27:33 vault1 kernel:  ffff8101309e9ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:33 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff810130be5080
May 15 05:27:33 vault1 kernel:  ffffffff8058a6e0 0000000000042b71 ffff810130be5288 0000000030be5080
May 15 05:27:33 vault1 kernel: Call Trace:
May 15 05:27:33 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:33 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:33 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:33 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:33 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:33 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:33 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:33 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:33 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:33 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:33 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:33 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:33 vault1 kernel: 
May 15 05:27:33 vault1 kernel: fc_wq_3       S ffff810130b71638     0   549     19 (L-TLB)
May 15 05:27:33 vault1 kernel:  ffff810130293ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:33 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff8101300810c0
May 15 05:27:33 vault1 kernel:  ffff810136be9080 0000000000001055 ffff8101300812c8 00000002300810c0
May 15 05:27:33 vault1 kernel: Call Trace:
May 15 05:27:33 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:33 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:33 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:33 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:33 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:33 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:33 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:33 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:33 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:33 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:33 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:33 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:33 vault1 kernel: 
May 15 05:27:33 vault1 kernel: fc_dl_3       S ffff810130b71638     0   550     19 (L-TLB)
May 15 05:27:33 vault1 kernel:  ffff810130909ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:33 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff81013011d040
May 15 05:27:33 vault1 kernel:  ffff810136be9080 0000000000001376 ffff81013011d248 000000023011d040
May 15 05:27:33 vault1 kernel: Call Trace:
May 15 05:27:33 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:33 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:33 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:33 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:33 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:33 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:33 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:34 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:34 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:34 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:34 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:34 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:34 vault1 kernel: 
May 15 05:27:34 vault1 kernel: scsi_eh_4     S ffff810130b71638     0   551     19 (L-TLB)
May 15 05:27:34 vault1 kernel:  ffff810130915e70 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:34 vault1 kernel:  0000000000000000 0000000000000046 0000000000000009 ffff81013008b080
May 15 05:27:34 vault1 kernel:  ffff810136be9080 000000000000086b ffff81013008b288 0000000280263894
May 15 05:27:34 vault1 kernel: Call Trace:
May 15 05:27:34 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:34 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:34 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:27:34 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:27:34 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:34 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:34 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:34 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:34 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:34 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:34 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:34 vault1 kernel: 
May 15 05:27:34 vault1 kernel: qla2xxx_4_dpc S ffff81012f451218     0   552     19 (L-TLB)
May 15 05:27:34 vault1 kernel:  ffff81013014bee0 0000000000000046 0000000000000000 ffff8101300740c0
May 15 05:27:34 vault1 kernel:  ffff8101300740c0 ffffffff802638fc 000000000000000a ffff8101300740c0
May 15 05:27:34 vault1 kernel:  ffff81012f4f3040 0000000000008a77 ffff8101300742c8 00000000880ba30f
May 15 05:27:34 vault1 kernel: Call Trace:
May 15 05:27:34 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:34 vault1 kernel:  [<ffffffff880bcb27>] :qla2xxx:qla2x00_fw_ready+0x84/0x1a2
May 15 05:27:34 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:27:34 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:34 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:27:34 vault1 kernel:  [<ffffffff880ba348>] :qla2xxx:qla2x00_do_dpc+0x39/0x439
May 15 05:27:34 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:34 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:27:34 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:34 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:34 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:34 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:34 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:34 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:34 vault1 kernel: 
May 15 05:27:34 vault1 kernel: scsi_wq_4     S ffff81012f451218     0   553     19 (L-TLB)
May 15 05:27:34 vault1 kernel:  ffff81013016dea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:34 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff8101301e2040
May 15 05:27:34 vault1 kernel:  ffff81012eea1080 00000000000671cb ffff8101301e2248 00000000301e2040
May 15 05:27:34 vault1 kernel: Call Trace:
May 15 05:27:34 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:34 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:34 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:34 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:34 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:34 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:34 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:34 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:34 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:34 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:34 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:34 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:34 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:34 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:34 vault1 kernel: 
May 15 05:27:34 vault1 kernel: fc_wq_4       S ffff810130b71638     0   554     19 (L-TLB)
May 15 05:27:34 vault1 kernel:  ffff810130099ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:34 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130185080
May 15 05:27:34 vault1 kernel:  ffff810136be9080 0000000000000fd3 ffff810130185288 0000000230185080
May 15 05:27:34 vault1 kernel: Call Trace:
May 15 05:27:34 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:34 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:34 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:34 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:34 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:34 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:34 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:34 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:34 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:34 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:34 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:34 vault1 kernel: 
May 15 05:27:34 vault1 kernel: fc_dl_4       S ffff810130b71638     0   555     19 (L-TLB)
May 15 05:27:34 vault1 kernel:  ffff81013009bea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:34 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff8101301840c0
May 15 05:27:34 vault1 kernel:  ffff810136be9080 0000000000001084 ffff8101301842c8 00000002301840c0
May 15 05:27:34 vault1 kernel: Call Trace:
May 15 05:27:34 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:34 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:34 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:34 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:34 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:34 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:34 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:34 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:34 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:34 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:34 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:34 vault1 kernel: 
May 15 05:27:35 vault1 kernel: kjournald     S ffff810230f84058     0   556     19 (L-TLB)
May 15 05:27:35 vault1 kernel:  ffff81013017bec0 0000000000000046 0000000000000000 0000000000000000
May 15 05:27:35 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff810130168040
May 15 05:27:35 vault1 kernel:  ffff810136b92040 0000000000002d62 ffff810130168248 000000018029fc0f
May 15 05:27:35 vault1 kernel: Call Trace:
May 15 05:27:35 vault1 kernel:  [<ffffffff880279be>] :jbd:kjournald+0x18e/0x21d
May 15 05:27:35 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:35 vault1 kernel:  [<ffffffff880279c3>] :jbd:kjournald+0x193/0x21d
May 15 05:27:35 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:35 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:35 vault1 kernel:  [<ffffffff88027830>] :jbd:kjournald+0x0/0x21d
May 15 05:27:35 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:35 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:35 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:35 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:35 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:35 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:35 vault1 kernel: 
May 15 05:27:35 vault1 kernel: kauditd       S ffff81012f8576f8     0   583     19 (L-TLB)
May 15 05:27:35 vault1 kernel:  ffff810130117ec0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:35 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff81012fd850c0
May 15 05:27:35 vault1 kernel:  ffff81012ff09040 0000000000007ed7 ffff81012fd852c8 000000002fd850c0
May 15 05:27:35 vault1 kernel: Call Trace:
May 15 05:27:35 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:35 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:35 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:35 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:35 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:35 vault1 kernel:  [<ffffffff802b2b39>] kauditd_thread+0x111/0x148
May 15 05:27:35 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:35 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:35 vault1 kernel:  [<ffffffff802b2a28>] kauditd_thread+0x0/0x148
May 15 05:27:35 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:35 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:35 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:35 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:35 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:35 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:35 vault1 kernel: 
May 15 05:27:35 vault1 kernel: udevd         S ffff81012f856e38     0   617      1 (NOTLB)
May 15 05:27:35 vault1 kernel:  ffff810130acba18 0000000000000046 0000000000000000 0000000000000046
May 15 05:27:35 vault1 kernel:  ffffffff802ea6a4 ffff81013025a7b8 0000000000000005 ffff81013025a080
May 15 05:27:35 vault1 kernel:  ffffffff8058a6e0 0000000000024d6c ffff81013025a288 0000000080262123
May 15 05:27:35 vault1 kernel: Call Trace:
May 15 05:27:35 vault1 kernel:  [<ffffffff802ea6a4>] inotify_poll+0x31/0x56
May 15 05:27:35 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:35 vault1 kernel:  [<ffffffff802ea6c2>] inotify_poll+0x4f/0x56
May 15 05:27:35 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:27:35 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:35 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:35 vault1 last message repeated 3 times
May 15 05:27:35 vault1 kernel:  [<ffffffff8023e153>] lookup_mnt+0x19/0x4c
May 15 05:27:35 vault1 kernel:  [<ffffffff8023e17e>] lookup_mnt+0x44/0x4c
May 15 05:27:35 vault1 kernel:  [<ffffffff8020d542>] dput+0x3c/0x12b
May 15 05:27:35 vault1 kernel:  [<ffffffff80219f0b>] __follow_mount+0x26/0x7b
May 15 05:27:35 vault1 kernel:  [<ffffffff8020cff9>] do_lookup+0x63/0x1ae
May 15 05:27:35 vault1 kernel:  [<ffffffff802119b8>] do_wp_page+0x5af/0x60b
May 15 05:27:35 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:27:35 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:27:35 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:35 vault1 kernel:  [<ffffffff8023bee1>] remove_wait_queue+0x10/0x2c
May 15 05:27:35 vault1 kernel:  [<ffffffff8023bee1>] remove_wait_queue+0x10/0x2c
May 15 05:27:35 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:35 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:35 vault1 kernel:  [<ffffffff80216aff>] sys_select+0xc1/0x183
May 15 05:27:35 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:35 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:35 vault1 kernel: 
May 15 05:27:35 vault1 kernel: khpsbpkt      S ffff81012f856e38     0  1220     19 (L-TLB)
May 15 05:27:35 vault1 kernel:  ffff81012f317f00 0000000000000046 ffffffff80246747 0000000000000002
May 15 05:27:35 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012f7f0040
May 15 05:27:35 vault1 kernel:  ffff81013025a080 0000000000001ce5 ffff81012f7f0248 0000000230191d30
May 15 05:27:35 vault1 kernel: Call Trace:
May 15 05:27:35 vault1 kernel:  [<ffffffff80246747>] skb_dequeue+0x13/0x50
May 15 05:27:35 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:36 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:36 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:36 vault1 kernel:  [<ffffffff8811e239>] :ieee1394:hpsbpkt_thread+0x0/0x8d
May 15 05:27:36 vault1 kernel:  [<ffffffff8811e2a9>] :ieee1394:hpsbpkt_thread+0x70/0x8d
May 15 05:27:36 vault1 kernel:  [<ffffffff8811e239>] :ieee1394:hpsbpkt_thread+0x0/0x8d
May 15 05:27:36 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:36 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:36 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:36 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:36 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:36 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:36 vault1 kernel: 
May 15 05:27:36 vault1 kernel: knodemgrd_0   S ffff810130b71638     0  1271     19 (L-TLB)
May 15 05:27:36 vault1 kernel:  ffff81012f21be70 0000000000000046 ffff810130d82080 ffffffff80261ece
May 15 05:27:36 vault1 kernel:  0000000000000246 ffff810230d3bc88 0000000000000009 ffff810130d82080
May 15 05:27:36 vault1 kernel:  ffff81012f3dc040 0000000000098704 ffff810130d82288 0000000080261ece
May 15 05:27:36 vault1 kernel: Call Trace:
May 15 05:27:36 vault1 kernel:  [<ffffffff80261ece>] __mutex_unlock_slowpath+0x128/0x133
May 15 05:27:36 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:36 vault1 kernel:  [<ffffffff88122d00>] :ieee1394:nodemgr_host_thread+0x87/0xa58
May 15 05:27:36 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:36 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:36 vault1 kernel:  [<ffffffff88122c79>] :ieee1394:nodemgr_host_thread+0x0/0xa58
May 15 05:27:36 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:36 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:36 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:36 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:36 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:36 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:36 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:36 vault1 kernel: 
May 15 05:27:36 vault1 kernel: ata/0         S ffff810230f85a98     0  1364     19 (L-TLB)
May 15 05:27:36 vault1 kernel:  ffff81012eba9ea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:36 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff81012f6d2080
May 15 05:27:36 vault1 kernel:  ffff810130a13080 0000000000001a45 ffff81012f6d2288 000000002f6d2080
May 15 05:27:36 vault1 kernel: Call Trace:
May 15 05:27:36 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:36 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:36 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:36 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:36 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:36 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:36 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:36 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:36 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:36 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:36 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:36 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:36 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:36 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:36 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:36 vault1 kernel: 
May 15 05:27:36 vault1 kernel: ata/1         S ffff81012f856e38     0  1365     19 (L-TLB)
May 15 05:27:36 vault1 kernel:  ffff81012ebabea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:36 vault1 kernel:  0000000000000000 0000000000000000 0000000000000006 ffff81012f791040
May 15 05:27:36 vault1 kernel:  ffff81013025a080 000000000000208c ffff81012f791248 000000012f791040
May 15 05:27:36 vault1 kernel: Call Trace:
May 15 05:27:36 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:36 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:36 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:36 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:36 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:36 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:36 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:36 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:36 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:36 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:36 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:36 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:36 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:36 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:36 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:36 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:36 vault1 kernel: 
May 15 05:27:36 vault1 kernel: ata/2         S ffff810230f84058     0  1366     19 (L-TLB)
May 15 05:27:36 vault1 kernel:  ffff81012ebafea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:36 vault1 kernel:  0000000000000000 0000000000000000 0000000000000006 ffff81012f46e080
May 15 05:27:36 vault1 kernel:  ffff81012fac80c0 000000000000267d ffff81012f46e288 000000022f46e080
May 15 05:27:36 vault1 kernel: Call Trace:
May 15 05:27:36 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:36 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:36 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:36 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:36 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:36 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:36 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:36 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:36 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:36 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:36 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:36 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:36 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:36 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:36 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:36 vault1 kernel: 
May 15 05:27:36 vault1 kernel: ata/3         S ffff81012f5bd6b8     0  1367     19 (L-TLB)
May 15 05:27:36 vault1 kernel:  ffff81012faf9ea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:36 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff81012f0950c0
May 15 05:27:36 vault1 kernel:  ffff8101308a9080 00000000000021a6 ffff81012f0952c8 000000032f0950c0
May 15 05:27:36 vault1 kernel: Call Trace:
May 15 05:27:36 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:36 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:36 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:36 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:36 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:37 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:37 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:37 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:37 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:37 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:37 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:37 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:37 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:37 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:37 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:37 vault1 kernel: 
May 15 05:27:37 vault1 kernel: ata_aux       S ffff810130840058     0  1368     19 (L-TLB)
May 15 05:27:37 vault1 kernel:  ffff81012ebb1ea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:37 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff81012f501040
May 15 05:27:37 vault1 kernel:  ffff81012f871040 0000000000001202 ffff81012f501248 000000002f501040
May 15 05:27:37 vault1 kernel: Call Trace:
May 15 05:27:37 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:37 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:37 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:37 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:37 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:37 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:37 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:37 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:37 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:37 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:37 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:37 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:37 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:37 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:37 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:37 vault1 kernel: 
May 15 05:27:37 vault1 kernel: scsi_eh_5     S ffff810130840918     0  1675     19 (L-TLB)
May 15 05:27:37 vault1 kernel:  ffff81012e7b1e70 0000000000000046 ffff81012f0b4040 ffffffff802638fc
May 15 05:27:37 vault1 kernel:  ffff81012f898000 0000000000000000 0000000000000003 ffff81012f0b4040
May 15 05:27:37 vault1 kernel:  ffff810230d72080 0000000000015241 ffff81012f0b4248 0000000100000282
May 15 05:27:37 vault1 kernel: Call Trace:
May 15 05:27:37 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:37 vault1 kernel:  [<ffffffff88060287>] :scsi_mod:__scsi_iterate_devices+0x5c/0x75
May 15 05:27:37 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:37 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:27:37 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:37 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:37 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:27:37 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:37 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:37 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:37 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:37 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:37 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:37 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:37 vault1 kernel: 
May 15 05:27:37 vault1 kernel: scsi_eh_6     S ffff81012eb76998     0  1677     19 (L-TLB)
May 15 05:27:37 vault1 kernel:  ffff81012e2cfe70 0000000000000046 ffff81012fdea0c0 ffffffff802638fc
May 15 05:27:37 vault1 kernel:  ffff81012ff60000 0000000000000000 0000000000000006 ffff81012fdea0c0
May 15 05:27:37 vault1 kernel:  ffff81012f7dc0c0 00000000000060c6 ffff81012fdea2c8 0000000000000282
May 15 05:27:37 vault1 kernel: Call Trace:
May 15 05:27:37 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:37 vault1 kernel:  [<ffffffff88060287>] :scsi_mod:__scsi_iterate_devices+0x5c/0x75
May 15 05:27:37 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:37 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:27:37 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:37 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:37 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:27:37 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:37 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:37 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:37 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:37 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:37 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:37 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:37 vault1 kernel: 
May 15 05:27:37 vault1 kernel: scsi_eh_7     S ffff81022fe50e38     0  2076     19 (L-TLB)
May 15 05:27:37 vault1 kernel:  ffff81012df47e70 0000000000000046 ffff81012efdc040 ffffffff802638fc
May 15 05:27:37 vault1 kernel:  ffff81012df20000 0000000000000000 0000000000000005 ffff81012efdc040
May 15 05:27:37 vault1 kernel:  ffff81012f7dc0c0 0000000000005d45 ffff81012efdc248 0000000000000282
May 15 05:27:37 vault1 kernel: Call Trace:
May 15 05:27:37 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:37 vault1 kernel:  [<ffffffff88060287>] :scsi_mod:__scsi_iterate_devices+0x5c/0x75
May 15 05:27:37 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:38 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:27:38 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:38 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:38 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:27:38 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:38 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:38 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:38 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:38 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:38 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:38 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:38 vault1 kernel: 
May 15 05:27:38 vault1 kernel: scsi_eh_8     S ffff8102300764b8     0  2077     19 (L-TLB)
May 15 05:27:38 vault1 kernel:  ffff81012df1fe70 0000000000000046 ffff81012eea30c0 ffffffff802638fc
May 15 05:27:38 vault1 kernel:  ffff81012e5e4000 0000000000000000 0000000000000008 ffff81012eea30c0
May 15 05:27:38 vault1 kernel:  ffff81012f7dc0c0 0000000000004d90 ffff81012eea32c8 0000000000000282
May 15 05:27:38 vault1 kernel: Call Trace:
May 15 05:27:38 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:38 vault1 kernel:  [<ffffffff88060287>] :scsi_mod:__scsi_iterate_devices+0x5c/0x75
May 15 05:27:38 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:38 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:27:38 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:38 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:38 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:27:38 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:38 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:38 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:38 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:38 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:38 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:38 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:38 vault1 kernel: 
May 15 05:27:38 vault1 kernel: kmpathd/0     S ffff810230cee998     0  2515     19 (L-TLB)
May 15 05:27:38 vault1 kernel:  ffff81012d897ea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:38 vault1 kernel:  0000000000000000 0000000000000000 0000000000000001 ffff81012f70f040
May 15 05:27:38 vault1 kernel:  ffff810130a13080 0000000000000d99 ffff81012f70f248 000000002f70f040
May 15 05:27:38 vault1 kernel: Call Trace:
May 15 05:27:38 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:38 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:38 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:38 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:38 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:38 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:38 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:38 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:38 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:38 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:38 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:38 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:38 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:38 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:38 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:38 vault1 kernel: 
May 15 05:27:38 vault1 kernel: kmpathd/1     S ffff810230f85a98     0  2516     19 (L-TLB)
May 15 05:27:38 vault1 kernel:  ffff81012d899ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:38 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff810130f6a0c0
May 15 05:27:38 vault1 kernel:  ffff810136b92040 0000000000001abe ffff810130f6a2c8 0000000130f6a0c0
May 15 05:27:38 vault1 kernel: Call Trace:
May 15 05:27:38 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:38 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:38 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:38 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:38 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:38 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:38 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:38 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:38 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:38 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:38 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:38 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:38 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:38 vault1 kernel: 
May 15 05:27:38 vault1 kernel: kmpathd/2     S ffff81012f856e38     0  2517     19 (L-TLB)
May 15 05:27:38 vault1 kernel:  ffff81012d89bea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:38 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff8101308a9080
May 15 05:27:38 vault1 kernel:  ffff81013025a080 0000000000002088 ffff8101308a9288 00000002308a9080
May 15 05:27:38 vault1 kernel: Call Trace:
May 15 05:27:38 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:38 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:38 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:38 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:38 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:38 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:38 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:39 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:39 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:39 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:39 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:39 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:39 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:39 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:39 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:39 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:39 vault1 kernel: 
May 15 05:27:39 vault1 kernel: kmpathd/3     S ffff810230cee998     0  2518     19 (L-TLB)
May 15 05:27:39 vault1 kernel:  ffff81012d89dea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:39 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012f2030c0
May 15 05:27:39 vault1 kernel:  ffff810230c4c0c0 0000000000003006 ffff81012f2032c8 000000032f2030c0
May 15 05:27:39 vault1 kernel: Call Trace:
May 15 05:27:39 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:39 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:39 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:39 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:39 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:39 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:39 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:39 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:39 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:39 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:39 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:39 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:39 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:39 vault1 kernel: 
May 15 05:27:39 vault1 kernel: kmirrord      S ffff810230d4f6f8     0  2533     19 (L-TLB)
May 15 05:27:39 vault1 kernel:  ffff81012dfd9ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:39 vault1 kernel:  0000000000000000 0000000000000000 0000000000000001 ffff810130ee0080
May 15 05:27:39 vault1 kernel:  ffff810230c4c0c0 00000000000019d6 ffff810130ee0288 0000000330ee0080
May 15 05:27:39 vault1 kernel: Call Trace:
May 15 05:27:39 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:39 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:39 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:39 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:39 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:39 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:39 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:39 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:39 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:39 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:39 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:39 vault1 kernel: 
May 15 05:27:39 vault1 kernel: jfsIO         S ffff810130b704b8     0  2571     19 (L-TLB)
May 15 05:27:39 vault1 kernel:  ffff81012c877f00 0000000000000046 0000000000000000 0000000000000001
May 15 05:27:39 vault1 kernel:  ffff81012c876000 ffff8101b644cd00 000000000000000a ffff810130dba0c0
May 15 05:27:39 vault1 kernel:  ffff810230c4c0c0 000000000006370c ffff810130dba2c8 0000000300000001
May 15 05:27:39 vault1 kernel: Call Trace:
May 15 05:27:39 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:39 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:39 vault1 kernel:  [<ffffffff88338385>] :jfs:jfsIOWait+0x0/0x96
May 15 05:27:39 vault1 kernel:  [<ffffffff883383fe>] :jfs:jfsIOWait+0x79/0x96
May 15 05:27:39 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:39 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:39 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:39 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:39 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:39 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:39 vault1 kernel: 
May 15 05:27:39 vault1 kernel: jfsCommit     S ffff810230f84058     0  2572     19 (L-TLB)
May 15 05:27:39 vault1 kernel:  ffff81012c879eb0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:39 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012f22d080
May 15 05:27:39 vault1 kernel:  ffff810136be9080 0000000000000776 ffff81012f22d288 000000022f22d080
May 15 05:27:39 vault1 kernel: Call Trace:
May 15 05:27:39 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:39 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:39 vault1 kernel:  [<ffffffff8833b108>] :jfs:jfs_lazycommit+0x1d9/0x212
May 15 05:27:39 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:39 vault1 kernel:  [<ffffffff8833af2f>] :jfs:jfs_lazycommit+0x0/0x212
May 15 05:27:39 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:39 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:39 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:39 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:39 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:39 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:39 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:39 vault1 kernel: 
May 15 05:27:39 vault1 kernel: jfsCommit     S ffff810230f84058     0  2573     19 (L-TLB)
May 15 05:27:39 vault1 kernel:  ffff81012c87beb0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:39 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012f722080
May 15 05:27:39 vault1 kernel:  ffff81012f6be0c0 000000000000bbdd ffff81012f722288 000000022f722080
May 15 05:27:39 vault1 kernel: Call Trace:
May 15 05:27:39 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:39 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:39 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:39 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:39 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:39 vault1 kernel:  [<ffffffff8833b108>] :jfs:jfs_lazycommit+0x1d9/0x212
May 15 05:27:39 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:39 vault1 kernel:  [<ffffffff8833af2f>] :jfs:jfs_lazycommit+0x0/0x212
May 15 05:27:40 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:40 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:40 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:40 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:40 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:40 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:40 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:40 vault1 kernel: 
May 15 05:27:40 vault1 kernel: jfsCommit     S ffff810230f84058     0  2574     19 (L-TLB)
May 15 05:27:40 vault1 kernel:  ffff81012c87deb0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:40 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff810130dda080
May 15 05:27:40 vault1 kernel:  ffff81012f22d080 0000000000000976 ffff810130dda288 0000000230dda080
May 15 05:27:40 vault1 kernel: Call Trace:
May 15 05:27:40 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:40 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:40 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:40 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:40 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:40 vault1 kernel:  [<ffffffff8833b108>] :jfs:jfs_lazycommit+0x1d9/0x212
May 15 05:27:40 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:40 vault1 kernel:  [<ffffffff8833af2f>] :jfs:jfs_lazycommit+0x0/0x212
May 15 05:27:40 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:40 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:40 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:40 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:40 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:40 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:40 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:40 vault1 kernel: 
May 15 05:27:40 vault1 kernel: jfsCommit     S ffff810230f84058     0  2575     19 (L-TLB)
May 15 05:27:40 vault1 kernel:  ffff81012c87feb0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:40 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012f6be0c0
May 15 05:27:40 vault1 kernel:  ffff810130dda080 0000000000000a3e ffff81012f6be2c8 000000022f6be0c0
May 15 05:27:40 vault1 kernel: Call Trace:
May 15 05:27:40 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:40 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:40 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:40 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:40 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:40 vault1 kernel:  [<ffffffff8833b108>] :jfs:jfs_lazycommit+0x1d9/0x212
May 15 05:27:40 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:40 vault1 kernel:  [<ffffffff8833af2f>] :jfs:jfs_lazycommit+0x0/0x212
May 15 05:27:40 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:40 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:40 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:40 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:40 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:40 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:40 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:40 vault1 kernel: 
May 15 05:27:40 vault1 kernel: jfsSync       S ffff81012f856e38     0  2576     19 (L-TLB)
May 15 05:27:40 vault1 kernel:  ffff81012c881ee0 0000000000000046 0000000000000000 ffff81012ef5a040
May 15 05:27:40 vault1 kernel:  00000000000001a9 0000000000000001 0000000000000008 ffff81012ef5a040
May 15 05:27:40 vault1 kernel:  ffff810136be9080 00000000000122f8 ffff81012ef5a248 0000000200000246
May 15 05:27:40 vault1 kernel: Call Trace:
May 15 05:27:40 vault1 kernel:  [<ffffffff8833a8e3>] :jfs:jfs_sync+0x181/0x1ac
May 15 05:27:40 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:40 vault1 kernel:  [<ffffffff8833a762>] :jfs:jfs_sync+0x0/0x1ac
May 15 05:27:40 vault1 kernel:  [<ffffffff8833a8e8>] :jfs:jfs_sync+0x186/0x1ac
May 15 05:27:40 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:40 vault1 kernel:  [<ffffffff8833a762>] :jfs:jfs_sync+0x0/0x1ac
May 15 05:27:40 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:40 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:40 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:40 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:40 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:40 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:40 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:40 vault1 kernel: 
May 15 05:27:40 vault1 kernel: kjournald     S ffff810230e444f8     0  2578     19 (L-TLB)
May 15 05:27:40 vault1 kernel:  ffff81012d563ec0 0000000000000046 0000000000000000 0000000000000000
May 15 05:27:40 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff81012f871040
May 15 05:27:40 vault1 kernel:  ffff810136b92040 0000000000001be6 ffff81012f871248 000000018029fc0f
May 15 05:27:40 vault1 kernel: Call Trace:
May 15 05:27:41 vault1 kernel:  [<ffffffff880279be>] :jbd:kjournald+0x18e/0x21d
May 15 05:27:41 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:41 vault1 kernel:  [<ffffffff880279c3>] :jbd:kjournald+0x193/0x21d
May 15 05:27:41 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:41 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:41 vault1 kernel:  [<ffffffff88027830>] :jbd:kjournald+0x0/0x21d
May 15 05:27:41 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:41 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:41 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:41 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:41 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:41 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:41 vault1 kernel: 
May 15 05:27:41 vault1 kernel: kjournald     S ffff810230f84058     0  2580     19 (L-TLB)
May 15 05:27:41 vault1 kernel:  ffff81012d3cdec0 0000000000000046 0000000000000000 0000000000000000
May 15 05:27:41 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff81012fac80c0
May 15 05:27:41 vault1 kernel:  ffff810136b92040 0000000000002f6b ffff81012fac82c8 000000018029fc0f
May 15 05:27:41 vault1 kernel: Call Trace:
May 15 05:27:41 vault1 kernel:  [<ffffffff880279be>] :jbd:kjournald+0x18e/0x21d
May 15 05:27:41 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:41 vault1 kernel:  [<ffffffff880279c3>] :jbd:kjournald+0x193/0x21d
May 15 05:27:41 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:41 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:41 vault1 kernel:  [<ffffffff88027830>] :jbd:kjournald+0x0/0x21d
May 15 05:27:41 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:41 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:41 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:41 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:41 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:41 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:41 vault1 kernel: 
May 15 05:27:41 vault1 kernel: kondemand/0   S ffff81012f450db8     0  2712     19 (L-TLB)
May 15 05:27:41 vault1 kernel:  ffff81012d509ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:41 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012e9e5040
May 15 05:27:41 vault1 kernel:  ffffffff8058a6e0 000000000000101c ffff81012e9e5248 000000002e9e5040
May 15 05:27:41 vault1 kernel: Call Trace:
May 15 05:27:41 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:41 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:41 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:41 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:41 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:41 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:41 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:41 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:41 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:41 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:41 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:41 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:41 vault1 kernel: 
May 15 05:27:41 vault1 kernel: kondemand/1   S ffff81012f450db8     0  2713     19 (L-TLB)
May 15 05:27:41 vault1 kernel:  ffff81012c68fea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:41 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff81012f238040
May 15 05:27:41 vault1 kernel:  ffff810136b92040 00000000000021a8 ffff81012f238248 000000012f238040
May 15 05:27:41 vault1 kernel: Call Trace:
May 15 05:27:41 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:41 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:41 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:41 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:41 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:41 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:41 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:41 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:41 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:41 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:41 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:41 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:41 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:41 vault1 kernel: 
May 15 05:27:41 vault1 kernel: kondemand/2   S ffff81012eb76998     0  2714     19 (L-TLB)
May 15 05:27:41 vault1 kernel:  ffff81012c595ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:41 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff8101301b8080
May 15 05:27:41 vault1 kernel:  ffff810136be9080 0000000000000d81 ffff8101301b8288 00000002301b8080
May 15 05:27:41 vault1 kernel: Call Trace:
May 15 05:27:41 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:41 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:41 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:41 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:41 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:41 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:41 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:41 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:41 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:41 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:41 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:41 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:41 vault1 kernel: 
May 15 05:27:41 vault1 kernel: kondemand/3   S ffff81012f856e38     0  2715     19 (L-TLB)
May 15 05:27:41 vault1 kernel:  ffff81012c599ea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:41 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff81012e46b0c0
May 15 05:27:41 vault1 kernel:  ffff81013025a080 0000000000002efb ffff81012e46b2c8 000000032e46b0c0
May 15 05:27:41 vault1 kernel: Call Trace:
May 15 05:27:41 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:41 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:41 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:41 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:41 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:41 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:42 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:42 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:42 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:42 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:42 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:42 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:42 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:42 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:42 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:42 vault1 kernel: 
May 15 05:27:42 vault1 kernel: dhclient      S ffff81012eb77b18     0  3260      1 (NOTLB)
May 15 05:27:42 vault1 kernel:  ffff810130dfba18 0000000000000046 0000000000000000 ffff81012f3b0040
May 15 05:27:42 vault1 kernel:  ffff81012f3b0040 ffffffff802638fc 000000000000000a ffff81012f3b0040
May 15 05:27:42 vault1 kernel:  ffff810136b92040 00000000000022f6 ffff81012f3b0248 0000000130c84000
May 15 05:27:42 vault1 kernel: Call Trace:
May 15 05:27:42 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:42 vault1 kernel:  [<ffffffff80261790>] schedule_timeout+0x8a/0xad
May 15 05:27:42 vault1 kernel:  [<ffffffff802913d9>] process_timeout+0x0/0x5
May 15 05:27:42 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:27:42 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:42 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:42 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:42 vault1 kernel:  [<ffffffff802078c3>] kmem_cache_free+0x257/0x267
May 15 05:27:42 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:42 vault1 kernel:  [<ffffffff804435a0>] udp_recvmsg+0x1ee/0x270
May 15 05:27:42 vault1 kernel:  [<ffffffff80232600>] sock_common_recvmsg+0x30/0x45
May 15 05:27:42 vault1 kernel:  [<ffffffff80230bc6>] sock_recvmsg+0xf8/0x117
May 15 05:27:42 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:42 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:27:42 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:27:42 vault1 kernel:  [<ffffffff8040bc77>] move_addr_to_user+0x5d/0x78
May 15 05:27:42 vault1 kernel:  [<ffffffff8022c605>] sys_recvfrom+0x104/0x130
May 15 05:27:42 vault1 kernel:  [<ffffffff80216b98>] sys_select+0x15a/0x183
May 15 05:27:42 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:42 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:42 vault1 kernel: 
May 15 05:27:42 vault1 kernel: syslogd       D ffff81012fe03b18     0  3374      1 (NOTLB)
May 15 05:27:42 vault1 kernel:  ffff81012bd7fd88 0000000000000046 0000000000000000 0000000000000000
May 15 05:27:42 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff81012f0670c0
May 15 05:27:42 vault1 kernel:  ffff8101301b70c0 0000000000019980 ffff81012f0672c8 000000008029fc0f
May 15 05:27:42 vault1 kernel: Call Trace:
May 15 05:27:42 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:42 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:42 vault1 kernel:  [<ffffffff88026c13>] :jbd:log_wait_commit+0xa4/0xf7
May 15 05:27:42 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:42 vault1 kernel:  [<ffffffff88021730>] :jbd:journal_stop+0x1e5/0x21a
May 15 05:27:42 vault1 kernel:  [<ffffffff802304c1>] __writeback_single_inode+0x1fa/0x338
May 15 05:27:42 vault1 kernel:  [<ffffffff802e2073>] sync_inode+0x19/0x39
May 15 05:27:42 vault1 kernel:  [<ffffffff802e2073>] sync_inode+0x19/0x39
May 15 05:27:42 vault1 kernel:  [<ffffffff802e207e>] sync_inode+0x24/0x39
May 15 05:27:42 vault1 kernel:  [<ffffffff88037332>] :ext3:ext3_sync_file+0xb2/0xc4
May 15 05:27:42 vault1 kernel:  [<ffffffff8024e527>] do_fsync+0x52/0xa4
May 15 05:27:42 vault1 kernel:  [<ffffffff802e4478>] __do_fsync+0x23/0x36
May 15 05:27:42 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:42 vault1 kernel: 
May 15 05:27:42 vault1 kernel: klogd         S ffff81012f450db8     0  3377      1 (NOTLB)
May 15 05:27:42 vault1 kernel:  ffff810127185be8 0000000000000046 0000000000000000 ffff8101301b70c0
May 15 05:27:42 vault1 kernel:  0000000000000001 ffffffff802a0de5 0000000000000009 ffff8101301b70c0
May 15 05:27:42 vault1 kernel:  ffffffff8058a6e0 00000000000038ca ffff8101301b72c8 0000000000000002
May 15 05:27:42 vault1 kernel: Call Trace:
May 15 05:27:42 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:42 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:42 vault1 kernel:  [<ffffffff80460f4b>] unix_wait_for_peer+0x86/0xb0
May 15 05:27:42 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:42 vault1 kernel:  [<ffffffff804614fb>] unix_dgram_sendmsg+0x3d3/0x4cd
May 15 05:27:42 vault1 kernel:  [<ffffffff802638bb>] _read_unlock_irq+0x24/0x27
May 15 05:27:42 vault1 kernel:  [<ffffffff8024671c>] sock_aio_write+0x110/0x128
May 15 05:27:42 vault1 kernel:  [<ffffffff80218507>] do_sync_write+0xc9/0x10c
May 15 05:27:42 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:42 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:42 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:42 vault1 kernel:  [<ffffffff80216cda>] vfs_write+0xe1/0x177
May 15 05:27:42 vault1 kernel:  [<ffffffff802176bf>] sys_write+0x45/0x6e
May 15 05:27:42 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:42 vault1 kernel: 
May 15 05:27:42 vault1 kernel: irqbalance    S ffff81012fe020d8     0  3393      1 (NOTLB)
May 15 05:27:42 vault1 kernel:  ffff81012bd75eb8 0000000000000046 0000000000000000 ffffffff802638fc
May 15 05:27:42 vault1 kernel:  ffff8100062e79f8 ffff8100062e79f0 0000000000000007 ffff81012eea00c0
May 15 05:27:42 vault1 kernel:  ffff810136b92040 00000000001ab791 ffff81012eea02c8 0000000100000292
May 15 05:27:42 vault1 kernel: Call Trace:
May 15 05:27:42 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:42 vault1 kernel:  [<ffffffff8023c6d0>] hrtimer_start+0xfd/0x110
May 15 05:27:42 vault1 kernel:  [<ffffffff802626ef>] do_nanosleep+0x46/0x77
May 15 05:27:42 vault1 kernel:  [<ffffffff80258b18>] hrtimer_nanosleep+0x58/0x11e
May 15 05:27:42 vault1 kernel:  [<ffffffff8029c17e>] hrtimer_wakeup+0x0/0x22
May 15 05:27:42 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:42 vault1 kernel:  [<ffffffff80252bb1>] sys_nanosleep+0x4c/0x62
May 15 05:27:42 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:42 vault1 kernel: 
May 15 05:27:42 vault1 kernel: portmap       S ffff810130b70058     0  3428      1 (NOTLB)
May 15 05:27:42 vault1 kernel:  ffff81012c6bdb28 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:27:43 vault1 kernel:  0000000180248a3b 0000000000000002 000000000000000a ffff8101309f4080
May 15 05:27:43 vault1 kernel:  ffff810136b92040 000000000001dcc0 ffff8101309f4288 0000000100000000
May 15 05:27:43 vault1 kernel: Call Trace:
May 15 05:27:43 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:43 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:43 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:43 vault1 kernel:  [<ffffffff80213f07>] tcp_poll+0x1f/0x133
May 15 05:27:43 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:27:43 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:43 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:43 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:43 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:43 vault1 kernel:  [<ffffffff8029ff51>] debug_check_no_locks_freed+0x11d/0x129
May 15 05:27:43 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:43 vault1 kernel:  [<ffffffff8020b848>] free_hot_cold_page+0x184/0x190
May 15 05:27:43 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:43 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:43 vault1 kernel:  [<ffffffff8040b777>] sys_sendmsg+0x217/0x28a
May 15 05:27:43 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:43 vault1 kernel:  [<ffffffff8023089b>] __up_write+0x27/0xf2
May 15 05:27:43 vault1 kernel:  [<ffffffff8023089b>] __up_write+0x27/0xf2
May 15 05:27:43 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:43 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:27:43 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:43 vault1 kernel: 
May 15 05:27:43 vault1 kernel: rpc.statd     S ffff810130b70918     0  3453      1 (NOTLB)
May 15 05:27:43 vault1 kernel:  ffff81012b387a18 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:27:43 vault1 kernel:  0000000180248a3b 0000000000000002 0000000000000006 ffff81013017c040
May 15 05:27:43 vault1 kernel:  ffffffff8058a6e0 000000000000295e ffff81013017c248 0000000000000000
May 15 05:27:43 vault1 kernel: Call Trace:
May 15 05:27:43 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:43 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:43 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:43 vault1 kernel:  [<ffffffff80213f07>] tcp_poll+0x1f/0x133
May 15 05:27:43 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:27:43 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:43 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:43 vault1 last message repeated 2 times
May 15 05:27:43 vault1 kernel:  [<ffffffff80263584>] _read_unlock+0x17/0x20
May 15 05:27:43 vault1 kernel:  [<ffffffff8046155d>] unix_dgram_sendmsg+0x435/0x4cd
May 15 05:27:43 vault1 kernel:  [<ffffffff8020d542>] dput+0x3c/0x12b
May 15 05:27:43 vault1 kernel:  [<ffffffff802530fc>] sock_sendmsg+0xea/0x107
May 15 05:27:43 vault1 kernel:  [<ffffffff8020ed97>] link_path_walk+0xce/0xe0
May 15 05:27:43 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:43 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:27:43 vault1 kernel:  [<ffffffff8022d806>] mntput_no_expire+0x1c/0x96
May 15 05:27:43 vault1 kernel:  [<ffffffff8040ba92>] sys_sendto+0x128/0x151
May 15 05:27:43 vault1 kernel:  [<ffffffff80216aff>] sys_select+0xc1/0x183
May 15 05:27:43 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:43 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:43 vault1 kernel: 
May 15 05:27:43 vault1 kernel: dbus-daemon   S ffff81012eb760d8     0  3481      1 (NOTLB)
May 15 05:27:43 vault1 kernel:  ffff81012b4d7b28 0000000000000046 0000000000000000 ffff81012f7dc0c0
May 15 05:27:43 vault1 kernel:  0000000000000000 ffffffff802a0de5 000000000000000a ffff81012f7dc0c0
May 15 05:27:43 vault1 kernel:  ffffffff8058a6e0 0000000000000a36 ffff81012f7dc2c8 0000000000000002
May 15 05:27:43 vault1 kernel: Call Trace:
May 15 05:27:43 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:43 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:43 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:27:43 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:43 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:43 vault1 last message repeated 2 times
May 15 05:27:43 vault1 kernel:  [<ffffffff8024671c>] sock_aio_write+0x110/0x128
May 15 05:27:43 vault1 kernel:  [<ffffffff8024660c>] sock_aio_write+0x0/0x128
May 15 05:27:43 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:27:43 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:43 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:43 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:43 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:43 vault1 kernel:  [<ffffffff802d3dfa>] do_readv_writev+0x199/0x1ae
May 15 05:27:43 vault1 kernel:  [<ffffffff8020d542>] dput+0x3c/0x12b
May 15 05:27:43 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:43 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:27:43 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:43 vault1 kernel: 
May 15 05:27:43 vault1 kernel: hidd          S ffff81012e41c9d8     0  3518      1 (NOTLB)
May 15 05:27:43 vault1 kernel:  ffff81012b439ad8 0000000000000046 0000000000000000 ffff81012eea2040
May 15 05:27:43 vault1 kernel:  0000000000000000 ffffffff802a0de5 0000000000000001 ffff81012eea2040
May 15 05:27:43 vault1 kernel:  ffffffff8058a6e0 00000000000085b1 ffff81012eea2248 0000000000000002
May 15 05:27:43 vault1 kernel: Call Trace:
May 15 05:27:43 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:44 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:44 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:27:44 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:44 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:44 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:44 vault1 kernel:  [<ffffffff80263584>] _read_unlock+0x17/0x20
May 15 05:27:44 vault1 kernel:  [<ffffffff8046155d>] unix_dgram_sendmsg+0x435/0x4cd
May 15 05:27:44 vault1 kernel:  [<ffffffff8020d542>] dput+0x3c/0x12b
May 15 05:27:44 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:44 vault1 kernel:  [<ffffffff802078e8>] find_get_page+0x15/0x4b
May 15 05:27:44 vault1 kernel:  [<ffffffff802638bb>] _read_unlock_irq+0x24/0x27
May 15 05:27:44 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:44 vault1 kernel:  [<ffffffff80208c1f>] __handle_mm_fault+0x3cf/0xccf
May 15 05:27:44 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:44 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:27:44 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:44 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:44 vault1 kernel:  [<ffffffff8021e12c>] sigprocmask+0x28/0xc1
May 15 05:27:44 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:44 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:44 vault1 kernel:  [<ffffffff802d861f>] sys_ppoll+0xf1/0x1ff
May 15 05:27:44 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:44 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:44 vault1 kernel: 
May 15 05:27:44 vault1 kernel: acpid         S ffff81012f8569d8     0  3535      1 (NOTLB)
May 15 05:27:44 vault1 kernel:  ffff81012b4e5b28 0000000000000046 0000000000000612 ffff81012e53b080
May 15 05:27:44 vault1 kernel:  0000000000000000 ffffffff802a0de5 0000000000000007 ffff81012e53b080
May 15 05:27:44 vault1 kernel:  ffff8102300e9040 000000000001ef10 ffff81012e53b288 0000000000000002
May 15 05:27:44 vault1 kernel: Call Trace:
May 15 05:27:44 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:44 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:44 vault1 kernel:  [<ffffffff88021755>] :jbd:journal_stop+0x20a/0x21a
May 15 05:27:44 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:44 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:27:44 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:44 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:44 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:44 vault1 kernel:  [<ffffffff8020e533>] current_fs_time+0x3b/0x40
May 15 05:27:44 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:44 vault1 kernel:  [<ffffffff80216881>] __generic_file_aio_write_nolock+0x378/0x3eb
May 15 05:27:44 vault1 kernel:  [<ffffffff80262123>] __mutex_lock_slowpath+0x245/0x25b
May 15 05:27:44 vault1 kernel:  [<ffffffff80261ece>] __mutex_unlock_slowpath+0x128/0x133
May 15 05:27:44 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:44 vault1 kernel:  [<ffffffff802224af>] generic_file_aio_write+0x6c/0xc1
May 15 05:27:44 vault1 kernel:  [<ffffffff88037192>] :ext3:ext3_file_write+0x16/0x94
May 15 05:27:44 vault1 kernel:  [<ffffffff80218507>] do_sync_write+0xc9/0x10c
May 15 05:27:44 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:44 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:44 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:44 vault1 kernel:  [<ffffffff8040bfa2>] sys_accept+0x19e/0x1fb
May 15 05:27:44 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:44 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:27:44 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:44 vault1 kernel: 
May 15 05:27:44 vault1 kernel: sshd          S ffff81012ec1da98     0  3553      1 (NOTLB)
May 15 05:27:44 vault1 kernel:  ffff81012739da18 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:27:44 vault1 kernel:  000000018023bee1 0000000000000002 0000000000000007 ffff81012ff09040
May 15 05:27:44 vault1 kernel:  ffff810136b92040 00000000000044e3 ffff81012ff09248 0000000100000000
May 15 05:27:44 vault1 kernel: Call Trace:
May 15 05:27:44 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:44 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:44 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:44 vault1 kernel:  [<ffffffff80213f07>] tcp_poll+0x1f/0x133
May 15 05:27:44 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:27:44 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:44 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:44 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:44 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:44 vault1 kernel:  [<ffffffff802133c4>] sock_def_readable+0x18/0x6c
May 15 05:27:44 vault1 kernel:  [<ffffffff802133c4>] sock_def_readable+0x18/0x6c
May 15 05:27:44 vault1 kernel:  [<ffffffff8020a6c3>] get_page_from_freelist+0x2ab/0x534
May 15 05:27:44 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:44 vault1 kernel:  [<ffffffff8020a6c3>] get_page_from_freelist+0x2ab/0x534
May 15 05:27:44 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:44 vault1 kernel:  [<ffffffff802c070d>] zone_statistics+0x3f/0x60
May 15 05:27:44 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:44 vault1 kernel:  [<ffffffff802118a0>] do_wp_page+0x497/0x60b
May 15 05:27:44 vault1 kernel:  [<ffffffff80211a03>] do_wp_page+0x5fa/0x60b
May 15 05:27:44 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:27:44 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:44 vault1 kernel:  [<ffffffff8020c6a9>] _atomic_dec_and_lock+0x39/0x58
May 15 05:27:44 vault1 kernel:  [<ffffffff80212fc9>] poison_obj+0x26/0x2f
May 15 05:27:44 vault1 kernel:  [<ffffffff802078c3>] kmem_cache_free+0x257/0x267
May 15 05:27:44 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:44 vault1 kernel:  [<ffffffff80216aff>] sys_select+0xc1/0x183
May 15 05:27:44 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:44 vault1 kernel:  [<ffffffff80239ba9>] generic_drop_inode+0x0/0x15c
May 15 05:27:45 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:45 vault1 kernel: 
May 15 05:27:45 vault1 kernel: rpc.idmapd    S ffff810130b704b8     0  3679      1 (NOTLB)
May 15 05:27:45 vault1 kernel:  ffff8101267a1e78 0000000000000046 0000000000000000 ffff81012f5ba0c0
May 15 05:27:45 vault1 kernel:  ffff81012f5ba0c0 ffffffff802638fc 000000000000000a ffff81012f5ba0c0
May 15 05:27:45 vault1 kernel:  ffff810136b92040 0000000000004042 ffff81012f5ba2c8 0000000130c84000
May 15 05:27:45 vault1 kernel: Call Trace:
May 15 05:27:45 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:45 vault1 kernel:  [<ffffffff80261790>] schedule_timeout+0x8a/0xad
May 15 05:27:45 vault1 kernel:  [<ffffffff802913d9>] process_timeout+0x0/0x5
May 15 05:27:45 vault1 kernel:  [<ffffffff802ead19>] sys_epoll_wait+0x193/0x426
May 15 05:27:45 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:45 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:45 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:45 vault1 kernel: 
May 15 05:27:45 vault1 kernel: crond         S ffff81012f0bbb58     0  3694      1 (NOTLB)
May 15 05:27:45 vault1 kernel:  ffff810125d63eb8 0000000000000046 0000000000000000 ffffffff802638fc
May 15 05:27:45 vault1 kernel:  ffff8100062e79f8 ffff8100062e79f0 0000000000000009 ffff81012e84d080
May 15 05:27:45 vault1 kernel:  ffff810136b92040 0000000000006656 ffff81012e84d288 0000000100000292
May 15 05:27:45 vault1 kernel: Call Trace:
May 15 05:27:45 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:45 vault1 kernel:  [<ffffffff8023c6d0>] hrtimer_start+0xfd/0x110
May 15 05:27:45 vault1 kernel:  [<ffffffff802626ef>] do_nanosleep+0x46/0x77
May 15 05:27:45 vault1 kernel:  [<ffffffff80258b18>] hrtimer_nanosleep+0x58/0x11e
May 15 05:27:45 vault1 kernel:  [<ffffffff8029c17e>] hrtimer_wakeup+0x0/0x22
May 15 05:27:45 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:45 vault1 kernel:  [<ffffffff80252bb1>] sys_nanosleep+0x4c/0x62
May 15 05:27:45 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:45 vault1 kernel: 
May 15 05:27:45 vault1 kernel: atd           S ffff81012f451678     0  3709      1 (NOTLB)
May 15 05:27:45 vault1 kernel:  ffff810126653eb8 0000000000000046 0000000000000000 ffffffff802638fc
May 15 05:27:45 vault1 kernel:  ffff8100062e79f8 ffff8100062e79f0 0000000000000007 ffff81012f0050c0
May 15 05:27:45 vault1 kernel:  ffff810136b92040 00000000000166a6 ffff81012f0052c8 0000000100000292
May 15 05:27:45 vault1 kernel: Call Trace:
May 15 05:27:45 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:45 vault1 kernel:  [<ffffffff8023c6d0>] hrtimer_start+0xfd/0x110
May 15 05:27:45 vault1 kernel:  [<ffffffff802626ef>] do_nanosleep+0x46/0x77
May 15 05:27:45 vault1 kernel:  [<ffffffff80258b18>] hrtimer_nanosleep+0x58/0x11e
May 15 05:27:45 vault1 kernel:  [<ffffffff8029c17e>] hrtimer_wakeup+0x0/0x22
May 15 05:27:45 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:45 vault1 kernel:  [<ffffffff80252bb1>] sys_nanosleep+0x4c/0x62
May 15 05:27:45 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:45 vault1 kernel: 
May 15 05:27:45 vault1 kernel: hald          S ffff81012f451218     0  3724      1 (NOTLB)
May 15 05:27:45 vault1 kernel:  ffff810125dfbb28 0000000000000046 0000000000000000 ffff81012f4f3040
May 15 05:27:45 vault1 kernel:  ffff81012f4f3040 ffffffff802638fc 000000000000000a ffff81012f4f3040
May 15 05:27:45 vault1 kernel:  ffff810136b92040 0000000000053fac ffff81012f4f3248 0000000130c84000
May 15 05:27:45 vault1 kernel: Call Trace:
May 15 05:27:45 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:45 vault1 kernel:  [<ffffffff80261790>] schedule_timeout+0x8a/0xad
May 15 05:27:45 vault1 kernel:  [<ffffffff802913d9>] process_timeout+0x0/0x5
May 15 05:27:45 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:27:45 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:45 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:45 vault1 last message repeated 9 times
May 15 05:27:45 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:45 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:45 vault1 kernel:  [<ffffffff8028dc04>] _local_bh_enable+0xbb/0xd0
May 15 05:27:45 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:45 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:27:45 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:45 vault1 kernel: 
May 15 05:27:45 vault1 kernel: hald-runner   S ffff8102303edb18     0  3725   3724 (NOTLB)
May 15 05:27:45 vault1 kernel:  ffff810230d6bb28 0000000000000046 0000000000000000 ffff8102300e9040
May 15 05:27:45 vault1 kernel:  0000000000000000 ffffffff802a0de5 0000000000000001 ffff8102300e9040
May 15 05:27:45 vault1 kernel:  ffffffff8058a6e0 000000000000076b ffff8102300e9248 0000000000000002
May 15 05:27:45 vault1 kernel: Call Trace:
May 15 05:27:45 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:45 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:45 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:27:45 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:45 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:45 vault1 kernel:  [<ffffffff8024671c>] sock_aio_write+0x110/0x128
May 15 05:27:45 vault1 kernel:  [<ffffffff8026212e>] __mutex_lock_slowpath+0x250/0x25b
May 15 05:27:45 vault1 kernel:  [<ffffffff8024660c>] sock_aio_write+0x0/0x128
May 15 05:27:45 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:27:45 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:45 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:45 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:45 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:45 vault1 kernel:  [<ffffffff802d3dfa>] do_readv_writev+0x199/0x1ae
May 15 05:27:45 vault1 kernel:  [<ffffffff80229266>] do_wait+0x9a7/0xa75
May 15 05:27:45 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:45 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:27:45 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:45 vault1 kernel: 
May 15 05:27:45 vault1 kernel: hald-addon-ke S ffff810130840058     0  3790   3725 (NOTLB)
May 15 05:27:45 vault1 kernel:  ffff810125a6fea8 0000000000000046 0000000000000000 0000000000000000
May 15 05:27:45 vault1 kernel:  0000000000000000 0000000000000046 0000000000000007 ffff81012f209080
May 15 05:27:45 vault1 kernel:  ffffffff8058a6e0 000000000008f29f ffff81012f209288 000000002f209080
May 15 05:27:45 vault1 kernel: Call Trace:
May 15 05:27:45 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:45 vault1 kernel:  [<ffffffff803f1497>] evdev_read+0x112/0x235
May 15 05:27:46 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:46 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:46 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:27:46 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:27:46 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:46 vault1 kernel: 
May 15 05:27:46 vault1 kernel: hald-addon-ac S ffff810230e44098     0  3797   3725 (NOTLB)
May 15 05:27:46 vault1 kernel:  ffff810125b4bbe8 0000000000000046 0000000000000612 ffff8101308d4040
May 15 05:27:46 vault1 kernel:  0000000000000001 ffffffff802a0de5 0000000000000008 ffff8101308d4040
May 15 05:27:46 vault1 kernel:  ffff81012e53b080 000000000005f23b ffff8101308d4248 0000000000000002
May 15 05:27:46 vault1 kernel: Call Trace:
May 15 05:27:46 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:46 vault1 kernel:  [<ffffffff8023ad89>] prepare_to_wait+0x1b/0x5c
May 15 05:27:46 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:46 vault1 kernel:  [<ffffffff80249a11>] unix_stream_recvmsg+0x233/0x548
May 15 05:27:46 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:46 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:46 vault1 kernel:  [<ffffffff8040ae7a>] sock_aio_read+0x10c/0x124
May 15 05:27:46 vault1 kernel:  [<ffffffff8020cf53>] do_sync_read+0xc9/0x10c
May 15 05:27:46 vault1 kernel:  [<ffffffff8046210a>] unix_stream_connect+0x389/0x3ff
May 15 05:27:46 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:46 vault1 kernel:  [<ffffffff8020e38c>] do_mmap_pgoff+0x65d/0x7c9
May 15 05:27:46 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:46 vault1 kernel:  [<ffffffff8020b5b0>] vfs_read+0xde/0x173
May 15 05:27:46 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:27:46 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:46 vault1 kernel: 
May 15 05:27:46 vault1 kernel: hald-addon-cp S ffff81012ec1cd78     0  3798   3725 (NOTLB)
May 15 05:27:46 vault1 kernel:  ffff810125ba9b28 0000000000000046 0000000000000000 ffff81012f3dc040
May 15 05:27:46 vault1 kernel:  0000000000000000 ffffffff802a0de5 0000000000000003 ffff81012f3dc040
May 15 05:27:46 vault1 kernel:  ffffffff8058a6e0 0000000000034e85 ffff81012f3dc248 0000000000000002
May 15 05:27:46 vault1 kernel: Call Trace:
May 15 05:27:46 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:46 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:46 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:27:46 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:46 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:46 vault1 kernel:  [<ffffffff80249bf3>] unix_stream_recvmsg+0x415/0x548
May 15 05:27:46 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:46 vault1 kernel:  [<ffffffff802078e8>] find_get_page+0x15/0x4b
May 15 05:27:46 vault1 kernel:  [<ffffffff802638bb>] _read_unlock_irq+0x24/0x27
May 15 05:27:46 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:46 vault1 kernel:  [<ffffffff80208c1f>] __handle_mm_fault+0x3cf/0xccf
May 15 05:27:46 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:46 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:27:46 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:27:46 vault1 kernel:  [<ffffffff80208d64>] __handle_mm_fault+0x514/0xccf
May 15 05:27:46 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:46 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:46 vault1 kernel:  [<ffffffff80265bc5>] do_page_fault+0x490/0x7cf
May 15 05:27:46 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:46 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:27:46 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:46 vault1 kernel: 
May 15 05:27:46 vault1 kernel: hald-addon-ke S ffff81012f856118     0  3799   3725 (NOTLB)
May 15 05:27:46 vault1 kernel:  ffff810125be9ea8 0000000000000046 0000000000000000 0000000000000000
May 15 05:27:46 vault1 kernel:  0000000000000000 0000000000000046 0000000000000001 ffff81012f7ef0c0
May 15 05:27:46 vault1 kernel:  ffff810136b92040 0000000000069995 ffff81012f7ef2c8 000000012f7ef0c0
May 15 05:27:46 vault1 kernel: Call Trace:
May 15 05:27:46 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:46 vault1 kernel:  [<ffffffff803f1497>] evdev_read+0x112/0x235
May 15 05:27:46 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:46 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:46 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:27:46 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:27:46 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:46 vault1 kernel: 
May 15 05:27:46 vault1 kernel: hald-addon-ke S ffff810230cee0d8     0  3802   3725 (NOTLB)
May 15 05:27:46 vault1 kernel:  ffff8101259a3ea8 0000000000000046 0000000000000000 0000000000000000
May 15 05:27:46 vault1 kernel:  0000000000000000 0000000000000046 0000000000000001 ffff810130097040
May 15 05:27:46 vault1 kernel:  ffff810230c4c0c0 00000000000a3b0d ffff810130097248 0000000330097040
May 15 05:27:47 vault1 kernel: Call Trace:
May 15 05:27:47 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:47 vault1 kernel:  [<ffffffff803f1497>] evdev_read+0x112/0x235
May 15 05:27:47 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:47 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:47 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:27:47 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:27:47 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:47 vault1 kernel: 
May 15 05:27:47 vault1 kernel: hald-addon-st S ffff810230e444f8     0  3812   3725 (NOTLB)
May 15 05:27:47 vault1 kernel:  ffff8101254bdeb8 0000000000000046 0000000000000000 ffffffff802638fc
May 15 05:27:47 vault1 kernel:  ffff8100062e79f8 ffff8100062e79f0 0000000000000009 ffff81012ea19040
May 15 05:27:47 vault1 kernel:  ffff810136b92040 0000000000001a9b ffff81012ea19248 0000000100000292
May 15 05:27:47 vault1 kernel: Call Trace:
May 15 05:27:47 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:47 vault1 kernel:  [<ffffffff8023c6d0>] hrtimer_start+0xfd/0x110
May 15 05:27:47 vault1 kernel:  [<ffffffff802626ef>] do_nanosleep+0x46/0x77
May 15 05:27:47 vault1 kernel:  [<ffffffff80258b18>] hrtimer_nanosleep+0x58/0x11e
May 15 05:27:47 vault1 kernel:  [<ffffffff8029c17e>] hrtimer_wakeup+0x0/0x22
May 15 05:27:47 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:47 vault1 kernel:  [<ffffffff80252bb1>] sys_nanosleep+0x4c/0x62
May 15 05:27:47 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:47 vault1 kernel: 
May 15 05:27:47 vault1 kernel: smartd        S ffff81012ec1c4b8     0  3876      1 (NOTLB)
May 15 05:27:47 vault1 kernel:  ffff81012662beb8 0000000000000046 0000000000000000 ffffffff802638fc
May 15 05:27:47 vault1 kernel:  ffff8100062dcbf8 ffff8100062dcbf0 0000000000000007 ffff81012fdbb040
May 15 05:27:47 vault1 kernel:  ffffffff8058a6e0 0000000000002dd0 ffff81012fdbb248 0000000000000292
May 15 05:27:47 vault1 kernel: Call Trace:
May 15 05:27:47 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:47 vault1 kernel:  [<ffffffff8023c6d0>] hrtimer_start+0xfd/0x110
May 15 05:27:47 vault1 kernel:  [<ffffffff802626ef>] do_nanosleep+0x46/0x77
May 15 05:27:47 vault1 kernel:  [<ffffffff80258b18>] hrtimer_nanosleep+0x58/0x11e
May 15 05:27:47 vault1 kernel:  [<ffffffff8029c17e>] hrtimer_wakeup+0x0/0x22
May 15 05:27:47 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:47 vault1 kernel:  [<ffffffff80252bb1>] sys_nanosleep+0x4c/0x62
May 15 05:27:47 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:47 vault1 kernel: 
May 15 05:27:47 vault1 kernel: mingetty      S ffff81012f0ba578     0  3879      1 (NOTLB)
May 15 05:27:47 vault1 kernel:  ffff810126425dc8 0000000000000046 0000000000000000 ffff81012f9307f0
May 15 05:27:47 vault1 kernel:  0000000000000612 ffff81012f930080 0000000000000007 ffff81012f930080
May 15 05:27:47 vault1 kernel:  ffff81012f342040 0000000000025b03 ffff81012f930288 0000000100000046
May 15 05:27:47 vault1 kernel: Call Trace:
May 15 05:27:47 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:47 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:47 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:47 vault1 kernel:  [<ffffffff8022a7cf>] read_chan+0x384/0x609
May 15 05:27:47 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:47 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:47 vault1 kernel:  [<ffffffff80232d53>] tty_read+0x72/0xc7
May 15 05:27:47 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:27:47 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:27:47 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:47 vault1 kernel: 
May 15 05:27:47 vault1 kernel: mingetty      S ffff81012ec1d638     0  3880      1 (NOTLB)
May 15 05:27:47 vault1 kernel:  ffff8101253a1dc8 0000000000000046 0000000000000002 0000000000000000
May 15 05:27:47 vault1 kernel:  ffff81012f38f7f8 ffff81012f38f0c0 0000000000000006 ffff81012f38f0c0
May 15 05:27:47 vault1 kernel:  ffff81012f930080 00000000001e63ba ffff81012f38f2c8 0000000100000046
May 15 05:27:47 vault1 kernel: Call Trace:
May 15 05:27:47 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:47 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:47 vault1 kernel:  [<ffffffff8022a7cf>] read_chan+0x384/0x609
May 15 05:27:47 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:47 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:47 vault1 kernel:  [<ffffffff80232d53>] tty_read+0x72/0xc7
May 15 05:27:47 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:27:47 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:27:47 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:47 vault1 kernel: 
May 15 05:27:47 vault1 kernel: mingetty      S ffff81012e41d298     0  3881      1 (NOTLB)
May 15 05:27:47 vault1 kernel:  ffff810125223dc8 0000000000000046 0000000000000000 ffff81012f3427b0
May 15 05:27:47 vault1 kernel:  0000000000000612 ffff81012f342040 0000000000000005 ffff81012f342040
May 15 05:27:47 vault1 kernel:  ffff81012f9940c0 000000000016c887 ffff81012f342248 0000000100000046
May 15 05:27:47 vault1 kernel: Call Trace:
May 15 05:27:47 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:47 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:47 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:47 vault1 kernel:  [<ffffffff8022a7cf>] read_chan+0x384/0x609
May 15 05:27:47 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:47 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:47 vault1 kernel:  [<ffffffff80232d53>] tty_read+0x72/0xc7
May 15 05:27:47 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:27:47 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:27:47 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:47 vault1 kernel: 
May 15 05:27:48 vault1 kernel: mingetty      S ffff81012effedb8     0  3882      1 (NOTLB)
May 15 05:27:48 vault1 kernel:  ffff810125453dc8 0000000000000046 0000000000000000 ffff81012f994830
May 15 05:27:48 vault1 kernel:  0000000000000612 ffff81012f9940c0 0000000000000004 ffff81012f9940c0
May 15 05:27:48 vault1 kernel:  ffff8101308d20c0 00000000000032cb ffff81012f9942c8 0000000100000046
May 15 05:27:48 vault1 kernel: Call Trace:
May 15 05:27:48 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:48 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:48 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:48 vault1 kernel:  [<ffffffff8022a7cf>] read_chan+0x384/0x609
May 15 05:27:48 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:48 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:48 vault1 kernel:  [<ffffffff80232d53>] tty_read+0x72/0xc7
May 15 05:27:48 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:27:48 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:27:48 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:48 vault1 kernel: 
May 15 05:27:48 vault1 kernel: mingetty      S ffff81012f5bd258     0  3883      1 (NOTLB)
May 15 05:27:48 vault1 kernel:  ffff81012d1bfdc8 0000000000000046 0000000000000000 ffff8101308d2830
May 15 05:27:48 vault1 kernel:  0000000000000612 ffff8101308d20c0 0000000000000003 ffff8101308d20c0
May 15 05:27:48 vault1 kernel:  ffff81013006d0c0 00000000000c79ab ffff8101308d22c8 0000000100000046
May 15 05:27:48 vault1 kernel: Call Trace:
May 15 05:27:48 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:48 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:48 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:48 vault1 kernel:  [<ffffffff8022a7cf>] read_chan+0x384/0x609
May 15 05:27:48 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:48 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:48 vault1 kernel:  [<ffffffff80232d53>] tty_read+0x72/0xc7
May 15 05:27:48 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:27:48 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:27:48 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:48 vault1 kernel: 
May 15 05:27:48 vault1 kernel: mingetty      S ffff81012f5bd6b8     0  3884      1 (NOTLB)
May 15 05:27:48 vault1 kernel:  ffff810125513dc8 0000000000000046 0000000000000000 ffff81013006d830
May 15 05:27:48 vault1 kernel:  0000000000000612 ffff81013006d0c0 0000000000000002 ffff81013006d0c0
May 15 05:27:48 vault1 kernel:  ffff810136b92040 000000000012884d ffff81013006d2c8 0000000100000046
May 15 05:27:48 vault1 kernel: Call Trace:
May 15 05:27:48 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:48 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:48 vault1 kernel:  [<ffffffff8022a7cf>] read_chan+0x384/0x609
May 15 05:27:48 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:48 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:48 vault1 kernel:  [<ffffffff80232d53>] tty_read+0x72/0xc7
May 15 05:27:48 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:27:48 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:27:48 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:48 vault1 kernel: 
May 15 05:27:48 vault1 kernel: sshd          S ffff810230f84058     0  3943   3553 (NOTLB)
May 15 05:27:48 vault1 kernel:  ffff8101256b9a18 0000000000000046 0000000000000000 0000000000000046
May 15 05:27:48 vault1 kernel:  ffffffff8022edfd 0000000000000046 000000000000000a ffff810127218080
May 15 05:27:48 vault1 kernel:  ffff810125ab70c0 000000000000a175 ffff810127218288 0000000127218080
May 15 05:27:48 vault1 kernel: Call Trace:
May 15 05:27:48 vault1 kernel:  [<ffffffff8022edfd>] __wake_up+0x22/0x4e
May 15 05:27:48 vault1 kernel:  [<ffffffff8023a80a>] tty_ldisc_deref+0x62/0x75
May 15 05:27:48 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:48 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:48 vault1 kernel:  [<ffffffff80226c98>] tty_poll+0x5f/0x6d
May 15 05:27:48 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:27:48 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:48 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:48 vault1 last message repeated 3 times
May 15 05:27:48 vault1 kernel:  [<ffffffff802313cd>] release_sock+0x2f/0xd6
May 15 05:27:48 vault1 kernel:  [<ffffffff8028de66>] local_bh_enable_ip+0xe4/0xea
May 15 05:27:48 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:48 vault1 kernel:  [<ffffffff80227651>] tcp_sendmsg+0x9ab/0xab5
May 15 05:27:48 vault1 last message repeated 2 times
May 15 05:27:48 vault1 kernel:  [<ffffffff8024671c>] sock_aio_write+0x110/0x128
May 15 05:27:48 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:48 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:27:48 vault1 kernel:  [<ffffffff80218507>] do_sync_write+0xc9/0x10c
May 15 05:27:48 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:48 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:48 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:48 vault1 kernel:  [<ffffffff80216aff>] sys_select+0xc1/0x183
May 15 05:27:48 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:48 vault1 kernel:  [<ffffffff80227651>] tcp_sendmsg+0x9ab/0xab5
May 15 05:27:48 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:48 vault1 kernel: 
May 15 05:27:48 vault1 kernel: rpc.rquotad   S ffff81012f0ba118     0  4049      1 (NOTLB)
May 15 05:27:48 vault1 kernel:  ffff81012c6b5b28 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:27:49 vault1 kernel:  0000000180248a3b 0000000000000002 0000000000000001 ffff81012f00f080
May 15 05:27:49 vault1 kernel:  ffff810136be9080 00000000000360c4 ffff81012f00f288 0000000200000000
May 15 05:27:49 vault1 kernel: Call Trace:
May 15 05:27:49 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:49 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:49 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:49 vault1 kernel:  [<ffffffff80213f07>] tcp_poll+0x1f/0x133
May 15 05:27:49 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:27:49 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:49 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:49 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:49 vault1 kernel:  [<ffffffff8020a6c3>] get_page_from_freelist+0x2ab/0x534
May 15 05:27:49 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:49 vault1 kernel:  [<ffffffff8020a6c3>] get_page_from_freelist+0x2ab/0x534
May 15 05:27:49 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:49 vault1 kernel:  [<ffffffff802078e8>] find_get_page+0x15/0x4b
May 15 05:27:49 vault1 kernel:  [<ffffffff802638bb>] _read_unlock_irq+0x24/0x27
May 15 05:27:49 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:49 vault1 kernel:  [<ffffffff80208c1f>] __handle_mm_fault+0x3cf/0xccf
May 15 05:27:49 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:49 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:27:49 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:27:49 vault1 kernel:  [<ffffffff80208d64>] __handle_mm_fault+0x514/0xccf
May 15 05:27:49 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:49 vault1 kernel:  [<ffffffff80265bc5>] do_page_fault+0x490/0x7cf
May 15 05:27:49 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:49 vault1 kernel:  [<ffffffff8021e472>] sys_close+0x2b/0xd1
May 15 05:27:49 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:49 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:27:49 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:49 vault1 kernel: 
May 15 05:27:49 vault1 kernel: lockd         S ffff81022eda4958     0  4052      1 (L-TLB)
May 15 05:27:49 vault1 kernel:  ffff81022ff83e10 0000000000000046 0000000000000000 ffff81022f5c07f0
May 15 05:27:49 vault1 kernel:  0000000000000612 ffff81022f5c0080 0000000000000001 ffff81022f5c0080
May 15 05:27:49 vault1 kernel:  ffffffff8058a6e0 00000000000041f8 ffff81022f5c0288 0000000000000046
May 15 05:27:49 vault1 kernel: Call Trace:
May 15 05:27:49 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:49 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:49 vault1 kernel:  [<ffffffff883de24e>] :sunrpc:svc_recv+0x2b5/0x44f
May 15 05:27:49 vault1 kernel:  [<ffffffff883de257>] :sunrpc:svc_recv+0x2be/0x44f
May 15 05:27:49 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:49 vault1 kernel:  [<ffffffff8840b556>] :lockd:lockd+0x139/0x263
May 15 05:27:49 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:49 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:49 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:49 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:49 vault1 kernel:  [<ffffffff802078c3>] kmem_cache_free+0x257/0x267
May 15 05:27:49 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:49 vault1 kernel:  [<ffffffff8840b41d>] :lockd:lockd+0x0/0x263
May 15 05:27:49 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:49 vault1 kernel: 
May 15 05:27:49 vault1 kernel: rpciod/0      S ffff81022eda4958     0  4053     19 (L-TLB)
May 15 05:27:49 vault1 kernel:  ffff810124befea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:27:49 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130851080
May 15 05:27:49 vault1 kernel:  ffff81012f485080 0000000000000b30 ffff810130851288 0000000030851080
May 15 05:27:49 vault1 kernel: Call Trace:
May 15 05:27:49 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:27:49 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:49 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:49 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:49 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:49 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:49 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:49 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:49 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:49 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:49 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:49 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:49 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:49 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:49 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:49 vault1 kernel: 
May 15 05:27:49 vault1 kernel: rpciod/1      S ffff810130b71a98     0  4054     19 (L-TLB)
May 15 05:27:49 vault1 kernel:  ffff810124bc3ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:49 vault1 kernel:  0000000000000000 0000000000000000 0000000000000008 ffff81012f485080
May 15 05:27:49 vault1 kernel:  ffff810136b92040 0000000000001672 ffff81012f485288 000000012f485080
May 15 05:27:49 vault1 kernel: Call Trace:
May 15 05:27:49 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:49 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:49 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:49 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:49 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:49 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:49 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:49 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:49 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:49 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:50 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:50 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:50 vault1 kernel: 
May 15 05:27:50 vault1 kernel: rpciod/2      S ffff810130b70058     0  4055     19 (L-TLB)
May 15 05:27:50 vault1 kernel:  ffff810124c43ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:50 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012552e040
May 15 05:27:50 vault1 kernel:  ffff810136be9080 0000000000001a1e ffff81012552e248 000000022552e040
May 15 05:27:50 vault1 kernel: Call Trace:
May 15 05:27:50 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:50 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:50 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:50 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:50 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:50 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:50 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:50 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:50 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:50 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:50 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:50 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:50 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:50 vault1 kernel: 
May 15 05:27:50 vault1 kernel: rpciod/3      S ffff81022eda4958     0  4056     19 (L-TLB)
May 15 05:27:50 vault1 kernel:  ffff8101249edea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:50 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff8101252b5040
May 15 05:27:50 vault1 kernel:  ffff810230c4c0c0 00000000000019be ffff8101252b5248 00000003252b5040
May 15 05:27:50 vault1 kernel: Call Trace:
May 15 05:27:50 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:50 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:50 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:50 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:50 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:50 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:50 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:50 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:50 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:50 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:50 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:27:50 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:50 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:50 vault1 kernel: 
May 15 05:27:50 vault1 kernel: nfsd4         S ffff81012eb76998     0  4057     19 (L-TLB)
May 15 05:27:50 vault1 kernel:  ffff810124bffea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:50 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff810130eae0c0
May 15 05:27:50 vault1 kernel:  ffff810136be9080 00000000000018fd ffff810130eae2c8 0000000230eae0c0
May 15 05:27:50 vault1 kernel: Call Trace:
May 15 05:27:50 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:50 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:27:50 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:27:50 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:27:50 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:50 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:50 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:27:50 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:50 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:50 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:50 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:27:50 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:50 vault1 kernel: 
May 15 05:27:50 vault1 kernel: nfsd          D ffff810230f85a98     0  4058      1 (L-TLB)
May 15 05:27:50 vault1 kernel:  ffff81022ff77420 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:50 vault1 kernel:  0000000000000000 0000000000000046 0000000000000009 ffff81022fa12040
May 15 05:27:50 vault1 kernel:  ffffffff8058a6e0 00000000006928e3 ffff81022fa12248 000000002fa12858
May 15 05:27:50 vault1 kernel: Call Trace:
May 15 05:27:50 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:50 vault1 kernel:  [<ffffffff802616cf>] io_schedule+0x3f/0x67
May 15 05:27:50 vault1 kernel:  [<ffffffff8833680a>] :jfs:lbmAllocate+0x8a/0x114
May 15 05:27:50 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:50 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:50 vault1 kernel:  [<ffffffff8833723a>] :jfs:lmNextPage+0xea/0x127
May 15 05:27:50 vault1 kernel:  [<ffffffff88337508>] :jfs:lmWriteRecord+0x291/0x2d1
May 15 05:27:50 vault1 kernel:  [<ffffffff88338340>] :jfs:lmLog+0x125/0x16a
May 15 05:27:50 vault1 kernel:  [<ffffffff8833a17b>] :jfs:txCommit+0xcdd/0xef2
May 15 05:27:50 vault1 kernel:  [<ffffffff80262123>] __mutex_lock_slowpath+0x245/0x25b
May 15 05:27:50 vault1 kernel:  [<ffffffff88322175>] :jfs:jfs_commit_inode+0xab/0xf5
May 15 05:27:50 vault1 kernel:  [<ffffffff88335683>] :jfs:extAlloc+0x3ce/0x423
May 15 05:27:50 vault1 kernel:  [<ffffffff8832265c>] :jfs:jfs_get_block+0x167/0x237
May 15 05:27:50 vault1 kernel:  [<ffffffff802e5c6c>] nobh_prepare_write+0xd3/0x458
May 15 05:27:50 vault1 kernel:  [<ffffffff883224f5>] :jfs:jfs_get_block+0x0/0x237
May 15 05:27:50 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:50 vault1 kernel:  [<ffffffff8020c722>] add_to_page_cache+0x2d/0x8c
May 15 05:27:50 vault1 kernel:  [<ffffffff80263540>] _write_unlock_irq+0x24/0x27
May 15 05:27:50 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:51 vault1 kernel:  [<ffffffff80263540>] _write_unlock_irq+0x24/0x27
May 15 05:27:51 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:51 vault1 kernel:  [<ffffffff80263540>] _write_unlock_irq+0x24/0x27
May 15 05:27:51 vault1 kernel:  [<ffffffff80210354>] generic_file_buffered_write+0x27b/0x77b
May 15 05:27:51 vault1 kernel:  [<ffffffff8020e533>] current_fs_time+0x3b/0x40
May 15 05:27:51 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:51 vault1 kernel:  [<ffffffff80216881>] __generic_file_aio_write_nolock+0x378/0x3eb
May 15 05:27:51 vault1 kernel:  [<ffffffff80262123>] __mutex_lock_slowpath+0x245/0x25b
May 15 05:27:51 vault1 kernel:  [<ffffffff8026212e>] __mutex_lock_slowpath+0x250/0x25b
May 15 05:27:51 vault1 kernel:  [<ffffffff802224a4>] generic_file_aio_write+0x61/0xc1
May 15 05:27:51 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:27:51 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:27:51 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:51 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:51 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:27:51 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:51 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:27:51 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:27:51 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:27:51 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:51 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:51 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:51 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:27:51 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:27:51 vault1 kernel:  [<ffffffff883e29af>] :sunrpc:sunrpc_cache_lookup+0x30/0x131
May 15 05:27:51 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:27:51 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:27:51 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:27:51 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:27:51 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:27:51 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:27:51 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:51 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:51 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:51 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:51 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:27:51 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:51 vault1 kernel: 
May 15 05:27:51 vault1 kernel: nfsd          D ffff810230e444f8     0  4059      1 (L-TLB)
May 15 05:27:51 vault1 kernel:  ffff81022f7b5520 0000000000000046 0000000000000000 0000000000000002
May 15 05:27:51 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff81022fd6e0c0
May 15 05:27:51 vault1 kernel:  ffff810136b92040 000000000001166f ffff81022fd6e2c8 0000000100000046
May 15 05:27:51 vault1 kernel: Call Trace:
May 15 05:27:51 vault1 kernel:  [<ffffffff802616cf>] io_schedule+0x3f/0x67
May 15 05:27:51 vault1 kernel:  [<ffffffff88338540>] :jfs:lmGroupCommit+0x125/0x177
May 15 05:27:51 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:51 vault1 kernel:  [<ffffffff8833a1eb>] :jfs:txCommit+0xd4d/0xef2
May 15 05:27:51 vault1 kernel:  [<ffffffff80262123>] __mutex_lock_slowpath+0x245/0x25b
May 15 05:27:51 vault1 kernel:  [<ffffffff88322175>] :jfs:jfs_commit_inode+0xab/0xf5
May 15 05:27:51 vault1 kernel:  [<ffffffff88335683>] :jfs:extAlloc+0x3ce/0x423
May 15 05:27:51 vault1 kernel:  [<ffffffff8832265c>] :jfs:jfs_get_block+0x167/0x237
May 15 05:27:51 vault1 kernel:  [<ffffffff802e5c6c>] nobh_prepare_write+0xd3/0x458
May 15 05:27:51 vault1 kernel:  [<ffffffff883224f5>] :jfs:jfs_get_block+0x0/0x237
May 15 05:27:51 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:51 vault1 kernel:  [<ffffffff8020c722>] add_to_page_cache+0x2d/0x8c
May 15 05:27:51 vault1 kernel:  [<ffffffff80263540>] _write_unlock_irq+0x24/0x27
May 15 05:27:51 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:51 vault1 kernel:  [<ffffffff80263540>] _write_unlock_irq+0x24/0x27
May 15 05:27:51 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:51 vault1 kernel:  [<ffffffff80263540>] _write_unlock_irq+0x24/0x27
May 15 05:27:51 vault1 kernel:  [<ffffffff80210354>] generic_file_buffered_write+0x27b/0x77b
May 15 05:27:51 vault1 kernel:  [<ffffffff8020e533>] current_fs_time+0x3b/0x40
May 15 05:27:51 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:51 vault1 kernel:  [<ffffffff80216881>] __generic_file_aio_write_nolock+0x378/0x3eb
May 15 05:27:51 vault1 kernel:  [<ffffffff80262123>] __mutex_lock_slowpath+0x245/0x25b
May 15 05:27:51 vault1 kernel:  [<ffffffff8026212e>] __mutex_lock_slowpath+0x250/0x25b
May 15 05:27:51 vault1 kernel:  [<ffffffff802224a4>] generic_file_aio_write+0x61/0xc1
May 15 05:27:51 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:27:51 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:27:51 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:51 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:51 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:27:51 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:51 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:27:51 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:27:51 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:27:51 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:51 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:51 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:51 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:27:51 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:27:51 vault1 kernel:  [<ffffffff883e29af>] :sunrpc:sunrpc_cache_lookup+0x30/0x131
May 15 05:27:51 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:27:51 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:27:51 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:27:52 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:27:52 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:27:52 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:27:52 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:52 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:52 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:52 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:52 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:27:52 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:52 vault1 kernel: 
May 15 05:27:52 vault1 kernel: nfsd          D ffff810230e444f8     0  4060      1 (L-TLB)
May 15 05:27:52 vault1 kernel:  ffff8102302aba60 0000000000000046 0000000000000000 ffff81022fd3b040
May 15 05:27:52 vault1 kernel:  0000000000000001 ffffffff802a0de5 000000000000000a ffff81022fd3b040
May 15 05:27:52 vault1 kernel:  ffff810136b92040 000000000025e9d4 ffff81022fd3b248 000000012fd3b7b0
May 15 05:27:52 vault1 kernel: Call Trace:
May 15 05:27:52 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:52 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:52 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:27:52 vault1 kernel:  [<ffffffff8024e63b>] d_find_alias+0x3a/0x42
May 15 05:27:52 vault1 kernel:  [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:52 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:27:52 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:27:52 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:52 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:52 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:27:52 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:52 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:27:52 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:27:52 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:27:52 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:52 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:52 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:52 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:27:52 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:27:52 vault1 kernel:  [<ffffffff883e29af>] :sunrpc:sunrpc_cache_lookup+0x30/0x131
May 15 05:27:52 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:27:52 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:27:52 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:27:52 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:27:52 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:27:52 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:27:52 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:52 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:52 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:52 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:52 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:27:52 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:52 vault1 kernel: 
May 15 05:27:52 vault1 kernel: nfsd          D ffff810230f84058     0  4061      1 (L-TLB)
May 15 05:27:52 vault1 kernel:  ffff81022f37fa60 0000000000000046 0000000000000000 ffff81022f726080
May 15 05:27:52 vault1 kernel:  0000000000000001 ffffffff802a0de5 0000000000000009 ffff81022f726080
May 15 05:27:52 vault1 kernel:  ffff810136be9080 00000000000302d3 ffff81022f726288 000000022f7267f0
May 15 05:27:52 vault1 kernel: Call Trace:
May 15 05:27:52 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:52 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:52 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:27:52 vault1 kernel:  [<ffffffff8024e63b>] d_find_alias+0x3a/0x42
May 15 05:27:52 vault1 kernel:  [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:52 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:27:52 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:27:52 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:52 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:52 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:27:52 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:52 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:27:52 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:27:52 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:27:52 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:52 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:52 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:52 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:27:52 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:27:52 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:27:52 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:27:52 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:27:52 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:27:52 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:27:52 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:27:52 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:52 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:52 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:52 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:52 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:27:52 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:52 vault1 kernel: 
May 15 05:27:52 vault1 kernel: nfsd          D ffff810230f85a98     0  4062      1 (L-TLB)
May 15 05:27:52 vault1 kernel:  ffff81022f42ba60 0000000000000046 000000000000052b ffff81022f5760c0
May 15 05:27:52 vault1 kernel:  0000000000000001 ffffffff802a0de5 000000000000000a ffff81022f5760c0
May 15 05:27:52 vault1 kernel:  ffff81022f1930c0 0000000000022d38 ffff81022f5762c8 000000002f576830
May 15 05:27:53 vault1 kernel: Call Trace:
May 15 05:27:53 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:53 vault1 kernel:  [<ffffffff80262019>] __mutex_lock_slowpath+0x13b/0x25b
May 15 05:27:53 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:53 vault1 kernel:  [<ffffffff80262019>] __mutex_lock_slowpath+0x13b/0x25b
May 15 05:27:53 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:27:53 vault1 kernel:  [<ffffffff8024e63b>] d_find_alias+0x3a/0x42
May 15 05:27:53 vault1 kernel:  [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:53 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:27:53 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:27:53 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:53 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:53 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:27:53 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:53 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:27:53 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:27:53 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:27:53 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:53 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:53 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:53 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:27:53 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:27:53 vault1 kernel:  [<ffffffff883e29af>] :sunrpc:sunrpc_cache_lookup+0x30/0x131
May 15 05:27:53 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:27:53 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:27:53 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:27:53 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:27:53 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:27:53 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:27:53 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:53 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:53 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:53 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:53 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:27:53 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:53 vault1 kernel: 
May 15 05:27:53 vault1 kernel: nfsd          D ffff810230f85a98     0  4063      1 (L-TLB)
May 15 05:27:53 vault1 kernel:  ffff81022fb05a60 0000000000000046 0000000000000000 ffff81022f615040
May 15 05:27:53 vault1 kernel:  0000000000000001 ffffffff802a0de5 000000000000000a ffff81022f615040
May 15 05:27:53 vault1 kernel:  ffffffff8058a6e0 00000000001cf979 ffff81022f615248 000000002f6157b0
May 15 05:27:53 vault1 kernel: Call Trace:
May 15 05:27:53 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:53 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:53 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:27:53 vault1 kernel:  [<ffffffff8024e63b>] d_find_alias+0x3a/0x42
May 15 05:27:53 vault1 kernel:  [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:53 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:27:53 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:27:53 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:53 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:53 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:27:53 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:53 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:27:53 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:27:53 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:27:53 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:53 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:53 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:53 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:27:53 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:27:53 vault1 kernel:  [<ffffffff883e29af>] :sunrpc:sunrpc_cache_lookup+0x30/0x131
May 15 05:27:53 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:27:53 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:27:53 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:27:53 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:27:53 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:27:53 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:27:53 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:53 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:53 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:53 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:53 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:27:53 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:53 vault1 kernel: 
May 15 05:27:53 vault1 kernel: nfsd          D ffff810130b704b8     0  4064      1 (L-TLB)
May 15 05:27:53 vault1 kernel:  ffff81022f0c1a60 0000000000000046 0000000000000000 ffff81022fa2c080
May 15 05:27:53 vault1 kernel:  0000000000000001 ffffffff802a0de5 0000000000000009 ffff81022fa2c080
May 15 05:27:53 vault1 kernel:  ffff810230c4c0c0 000000000001d4dc ffff81022fa2c288 000000032fa2c7f0
May 15 05:27:53 vault1 kernel: Call Trace:
May 15 05:27:53 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:54 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:54 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:27:54 vault1 kernel:  [<ffffffff8024e63b>] d_find_alias+0x3a/0x42
May 15 05:27:54 vault1 kernel:  [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:54 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:27:54 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:27:54 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:54 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:54 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:27:54 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:54 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:27:54 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:27:54 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:27:54 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:54 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:54 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:54 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:27:54 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:27:54 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:27:54 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:27:54 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:27:54 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:27:54 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:27:54 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:27:54 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:54 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:54 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:27:54 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:54 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:27:54 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:54 vault1 kernel: 
May 15 05:27:54 vault1 kernel: nfsd          D ffff810230f85a98     0  4065      1 (L-TLB)
May 15 05:27:54 vault1 kernel:  ffff81022f19da60 0000000000000046 0000000000000000 ffff81022f1930c0
May 15 05:27:54 vault1 kernel:  0000000000000001 ffffffff802a0de5 000000000000000a ffff81022f1930c0
May 15 05:27:54 vault1 kernel:  ffffffff8058a6e0 0000000000018984 ffff81022f1932c8 000000002f193830
May 15 05:27:54 vault1 kernel: Call Trace:
May 15 05:27:54 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:54 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:54 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:27:54 vault1 kernel:  [<ffffffff8024e63b>] d_find_alias+0x3a/0x42
May 15 05:27:54 vault1 kernel:  [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:54 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:27:54 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:27:54 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:54 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:27:54 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:27:54 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:27:54 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:27:54 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:27:54 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:27:54 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:54 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:54 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:27:54 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:27:54 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:27:54 vault1 kernel:  [<ffffffff883e29af>] :sunrpc:sunrpc_cache_lookup+0x30/0x131
May 15 05:27:54 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:27:54 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:27:54 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:27:54 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:27:54 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:27:54 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:27:54 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:54 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:27:54 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:27:54 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:27:54 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:27:54 vault1 kernel: 
May 15 05:27:54 vault1 kernel: rpc.mountd    S ffff81012f0ba9d8     0  4068      1 (NOTLB)
May 15 05:27:54 vault1 kernel:  ffff810124c41a18 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:27:54 vault1 kernel:  0000000180248a3b 0000000000000002 0000000000000009 ffff81012efa30c0
May 15 05:27:54 vault1 kernel:  ffff810136b92040 000000000001006a ffff81012efa32c8 0000000100000000
May 15 05:27:54 vault1 kernel: Call Trace:
May 15 05:27:54 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:54 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:27:54 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:27:54 vault1 kernel:  [<ffffffff80213f07>] tcp_poll+0x1f/0x133
May 15 05:27:54 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:27:54 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:27:54 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:27:55 vault1 last message repeated 4 times
May 15 05:27:55 vault1 kernel:  [<ffffffff8020b406>] kfree+0x1a8/0x274
May 15 05:27:55 vault1 kernel:  [<ffffffff8020b4c4>] kfree+0x266/0x274
May 15 05:27:55 vault1 kernel:  [<ffffffff8020b4c4>] kfree+0x266/0x274
May 15 05:27:55 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:55 vault1 kernel:  [<ffffffff883e158b>] :sunrpc:cache_clean+0x12/0x208
May 15 05:27:55 vault1 kernel:  [<ffffffff8020b4c4>] kfree+0x266/0x274
May 15 05:27:55 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:27:55 vault1 kernel:  [<ffffffff8020b4c4>] kfree+0x266/0x274
May 15 05:27:55 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:55 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:27:55 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:55 vault1 kernel:  [<ffffffff883e2363>] :sunrpc:cache_write+0x45/0xc0
May 15 05:27:55 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:27:55 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:55 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:27:55 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:27:55 vault1 kernel:  [<ffffffff80216aff>] sys_select+0xc1/0x183
May 15 05:27:55 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:27:55 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:27:55 vault1 kernel: 
May 15 05:27:55 vault1 kernel: 
May 15 05:27:55 vault1 kernel: Showing all locks held in the system:
May 15 05:27:55 vault1 kernel: 2 locks held by pdflush/299:
May 15 05:27:55 vault1 kernel:  #0:  (&type->s_umount_key#20){----}, at: [<ffffffff8024f2e2>] writeback_inodes+0x73/0xee
May 15 05:27:55 vault1 kernel:  #1:  (&jfs_ip->rdwrlock#2){----}, at: [<ffffffff8832253a>] jfs_get_block+0x45/0x237 [jfs]
May 15 05:27:55 vault1 kernel: 1 lock held by syslogd/3374:
May 15 05:27:55 vault1 kernel:  #0:  (&inode->i_mutex){--..}, at: [<ffffffff8024e516>] do_fsync+0x41/0xa4
May 15 05:27:55 vault1 kernel: 1 lock held by mingetty/3879:
May 15 05:27:55 vault1 kernel:  #0:  (&tty->atomic_read_lock){--..}, at: [<ffffffff8022a64c>] read_chan+0x201/0x609
May 15 05:27:55 vault1 kernel: 1 lock held by mingetty/3880:
May 15 05:27:55 vault1 kernel:  #0:  (&tty->atomic_read_lock){--..}, at: [<ffffffff8022a64c>] read_chan+0x201/0x609
May 15 05:27:55 vault1 kernel: 1 lock held by mingetty/3881:
May 15 05:27:55 vault1 kernel:  #0:  (&tty->atomic_read_lock){--..}, at: [<ffffffff8022a64c>] read_chan+0x201/0x609
May 15 05:27:55 vault1 kernel: 1 lock held by mingetty/3882:
May 15 05:27:55 vault1 kernel:  #0:  (&tty->atomic_read_lock){--..}, at: [<ffffffff8022a64c>] read_chan+0x201/0x609
May 15 05:27:55 vault1 kernel: 1 lock held by mingetty/3883:
May 15 05:27:55 vault1 kernel:  #0:  (&tty->atomic_read_lock){--..}, at: [<ffffffff8022a64c>] read_chan+0x201/0x609
May 15 05:27:55 vault1 kernel: 1 lock held by mingetty/3884:
May 15 05:27:55 vault1 kernel:  #0:  (&tty->atomic_read_lock){--..}, at: [<ffffffff8022a64c>] read_chan+0x201/0x609
May 15 05:27:55 vault1 kernel: 2 locks held by bash/3945:
May 15 05:27:55 vault1 kernel:  #0:  (sysrq_key_table_lock){....}, at: [<ffffffff80395b2a>] __handle_sysrq+0x22/0x128
May 15 05:27:55 vault1 kernel:  #1:  (tasklist_lock){..-?}, at: [<ffffffff8029ebd4>] debug_show_all_locks+0x3e/0x152
May 15 05:27:55 vault1 kernel: 5 locks held by nfsd/4058:
May 15 05:27:55 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:27:55 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:55 vault1 kernel:  #2:  (&jfs_ip->rdwrlock#2){----}, at: [<ffffffff8832253a>] jfs_get_block+0x45/0x237 [jfs]
May 15 05:27:55 vault1 kernel:  #3:  (&jfs_ip->commit_mutex){--..}, at: [<ffffffff88322126>] jfs_commit_inode+0x5c/0xf5 [jfs]
May 15 05:27:55 vault1 kernel:  #4:  (&(log)->loglock){--..}, at: [<ffffffff8833824a>] lmLog+0x2f/0x16a [jfs]
May 15 05:27:55 vault1 kernel: 4 locks held by nfsd/4059:
May 15 05:27:55 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:27:55 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:55 vault1 kernel:  #2:  (&jfs_ip->rdwrlock#2){----}, at: [<ffffffff8832253a>] jfs_get_block+0x45/0x237 [jfs]
May 15 05:27:55 vault1 kernel:  #3:  (&jfs_ip->commit_mutex){--..}, at: [<ffffffff88322126>] jfs_commit_inode+0x5c/0xf5 [jfs]
May 15 05:27:55 vault1 kernel: 2 locks held by nfsd/4060:
May 15 05:27:55 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:27:55 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:55 vault1 kernel: 2 locks held by nfsd/4061:
May 15 05:27:55 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:27:55 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:55 vault1 kernel: 2 locks held by nfsd/4062:
May 15 05:27:55 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:27:55 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:55 vault1 kernel: 2 locks held by nfsd/4063:
May 15 05:27:55 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:27:55 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:55 vault1 kernel: 2 locks held by nfsd/4064:
May 15 05:27:55 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:27:55 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:55 vault1 kernel: 2 locks held by nfsd/4065:
May 15 05:27:55 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:27:55 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:27:55 vault1 kernel: 
May 15 05:27:55 vault1 kernel: =============================================
May 15 05:27:55 vault1 kernel: 
May 15 05:33:53 vault1 kernel: SysRq : Show State
May 15 05:33:53 vault1 kernel: 
May 15 05:33:53 vault1 kernel:                                  free                        sibling
May 15 05:33:53 vault1 kernel:   task                 PC        stack   pid father child younger older
May 15 05:33:53 vault1 kernel: init          S ffff810230f85a98     0     1      0 (NOTLB)
May 15 05:33:53 vault1 kernel:  ffff810136ba3a18 0000000000000046 0000000000000000 ffff810130c70040
May 15 05:33:53 vault1 kernel:  ffff810130c70040 ffffffff802638fc 000000000000000a ffff810130c70040
May 15 05:33:53 vault1 kernel:  ffffffff8058a6e0 0000000000009ac3 ffff810130c70248 0000000080733000
May 15 05:33:53 vault1 kernel: Call Trace:
May 15 05:33:53 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:53 vault1 kernel:  [<ffffffff80261790>] schedule_timeout+0x8a/0xad
May 15 05:33:53 vault1 kernel:  [<ffffffff802913d9>] process_timeout+0x0/0x5
May 15 05:33:53 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:33:53 vault1 kernel: ventd_create_kthread+0x0/0x6d
May 15 05:33:53 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:33:53 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:53 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:53 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:53 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:53 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:33:53 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:53 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:53 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:53 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:53 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:53 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:53 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:53 vault1 kernel: 
May 15 05:33:53 vault1 kernel: cqueue/3      S ffffffff8058a280     0   238     19 (L-TLB)
May 15 05:33:53 vault1 kernel:  ffff810230e97ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:53 vault1 kernel:  0000000000000000 0000000000000000 0000000000000005 ffff810230f44040
May 15 05:33:53 vault1 kernel:  ffff810230c4c0c0 00000000000014a6 ffff810230f44248 0000000330f44040
May 15 05:33:53 vault1 kernel: Call Trace:
May 15 05:33:53 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:53 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:53 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:53 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:53 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:53 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:33:53 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:53 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:53 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:53 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:53 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:53 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:53 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:54 vault1 kernel: 
May 15 05:33:54 vault1 kernel: ksuspend_usbd S ffffffff8058a280     0   239     19 (L-TLB)
May 15 05:33:54 vault1 kernel:  ffff810230eb9ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:54 vault1 kernel:  0000000000000000 0000000000000000 0000000000000006 ffff810230f450c0
May 15 05:33:54 vault1 kernel:  ffff810136be9080 0000000000001012 ffff810230f452c8 0000000230f450c0
May 15 05:33:54 vault1 kernel: Call Trace:
May 15 05:33:54 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:54 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:54 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:54 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:54 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:54 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:33:54 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:54 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:54 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:54 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:54 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:54 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:54 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:54 vault1 kernel: 
May 15 05:33:54 vault1 kernel: khubd         S ffff810130b71638     0   242     19 (L-TLB)
May 15 05:33:54 vault1 kernel:  ffff8102309c1e20 0000000000000046 0000000000000000 0000000000000000
May 15 05:33:54 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff810230f4d080
May 15 05:33:54 vault1 kernel:  ffff810136be9080 0000000000011d07 ffff810230f4d288 0000000230f4d080
May 15 05:33:54 vault1 kernel: Call Trace:
May 15 05:33:54 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:54 vault1 kernel:  [<ffffffff803d6dc8>] hub_thread+0xac0/0xb3c
May 15 05:33:54 vault1 kernel:  [<ffffffff80260f58>] thread_return+0x88/0x12a
May 15 05:33:54 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:33:54 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:54 vault1 kernel:  [<ffffffff803d6308>] hub_thread+0x0/0xb3c
May 15 05:33:54 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:54 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:54 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:54 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:54 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:54 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:54 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:54 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:54 vault1 kernel: 
May 15 05:33:54 vault1 kernel: kseriod       S ffffffff8058a280     0   244     19 (L-TLB)
May 15 05:33:54 vault1 kernel:  ffff8102309c7ec0 0000000000000046 0000000000000000 0000000000000000
May 15 05:33:54 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff810230f610c0
May 15 05:33:54 vault1 kernel:  ffffffff8058a6e0 0000000000005165 ffff810230f612c8 0000000030f610c0
May 15 05:33:54 vault1 kernel: Call Trace:
May 15 05:33:54 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:54 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:54 vault1 kernel:  [<ffffffff803eaaea>] serio_thread+0x2a5/0x2f8
May 15 05:33:54 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:33:54 vault1 kernel:  [<ffffffff803ea845>] serio_thread+0x0/0x2f8
May 15 05:33:54 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:54 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:54 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:54 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:54 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:54 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:54 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:54 vault1 kernel: 
May 15 05:33:54 vault1 kernel: pdflush       S ffff810230f84058     0   298     19 (L-TLB)
May 15 05:33:54 vault1 kernel:  ffff8102308f1ed0 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:33:54 vault1 kernel:  0000000180598080 0000000000000002 000000000000000a ffff810230f20080
May 15 05:33:54 vault1 kernel:  ffff810136be9080 0000000000004416 ffff810230f20288 0000000200000000
May 15 05:33:54 vault1 kernel: Call Trace:
May 15 05:33:54 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:33:54 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:54 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:54 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:54 vault1 kernel:  [<ffffffff80254d52>] pdflush+0x0/0x1e7
May 15 05:33:54 vault1 kernel:  [<ffffffff80254e21>] pdflush+0xcf/0x1e7
May 15 05:33:54 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:54 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:54 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:54 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:54 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:54 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:54 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:54 vault1 kernel: 
May 15 05:33:54 vault1 kernel: pdflush       D ffff810230f84058     0   299     19 (L-TLB)
May 15 05:33:54 vault1 kernel:  ffff8102308f3a20 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:33:54 vault1 kernel:  000000018020c209 0000000000000002 000000000000000a ffff810230f1f0c0
May 15 05:33:54 vault1 kernel:  ffff810136be9080 00000000000024d0 ffff810230f1f2c8 0000000200000001
May 15 05:33:54 vault1 kernel: Call Trace:
May 15 05:33:54 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:33:54 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:33:54 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:54 vault1 kernel:  [<ffffffff80262fa6>] __down_write_nested+0x7e/0x96
May 15 05:33:54 vault1 kernel:  [<ffffffff8832253a>] :jfs:jfs_get_block+0x45/0x237
May 15 05:33:55 vault1 kernel:  [<ffffffff8021c67c>] generic_make_request+0x207/0x21e
May 15 05:33:55 vault1 kernel:  [<ffffffff802e9478>] __mpage_writepage+0x1f5/0x55d
May 15 05:33:55 vault1 kernel:  [<ffffffff883224f5>] :jfs:jfs_get_block+0x0/0x237
May 15 05:33:55 vault1 kernel:  [<ffffffff802638bb>] _read_unlock_irq+0x24/0x27
May 15 05:33:55 vault1 kernel:  [<ffffffff802c0835>] dec_zone_page_state+0x33/0x3a
May 15 05:33:55 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:33:55 vault1 kernel:  [<ffffffff802c0835>] dec_zone_page_state+0x33/0x3a
May 15 05:33:55 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:33:55 vault1 kernel:  [<ffffffff8021d493>] mpage_writepages+0x228/0x375
May 15 05:33:55 vault1 kernel:  [<ffffffff883220bb>] :jfs:jfs_writepage+0x0/0xf
May 15 05:33:55 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:33:55 vault1 kernel:  [<ffffffff883224f5>] :jfs:jfs_get_block+0x0/0x237
May 15 05:33:55 vault1 kernel:  [<ffffffff802593b8>] do_writepages+0x23/0x30
May 15 05:33:55 vault1 kernel:  [<ffffffff80230487>] __writeback_single_inode+0x1c0/0x338
May 15 05:33:55 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:55 vault1 kernel:  [<ffffffff80263584>] _read_unlock+0x17/0x20
May 15 05:33:55 vault1 kernel:  [<ffffffff80221c26>] sync_sb_inodes+0x1a6/0x267
May 15 05:33:55 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:55 vault1 kernel:  [<ffffffff8024f304>] writeback_inodes+0x95/0xee
May 15 05:33:55 vault1 kernel:  [<ffffffff802be735>] wb_kupdate+0x9e/0x112
May 15 05:33:55 vault1 kernel:  [<ffffffff80254d52>] pdflush+0x0/0x1e7
May 15 05:33:55 vault1 kernel:  [<ffffffff80254d52>] pdflush+0x0/0x1e7
May 15 05:33:55 vault1 kernel:  [<ffffffff80254e8e>] pdflush+0x13c/0x1e7
May 15 05:33:55 vault1 kernel:  [<ffffffff802be697>] wb_kupdate+0x0/0x112
May 15 05:33:55 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:55 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:55 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:55 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:55 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:55 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:55 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:55 vault1 kernel: 
May 15 05:33:55 vault1 kernel: kswapd0       S ffff810230e444f8     0   300     19 (L-TLB)
May 15 05:33:55 vault1 kernel:  ffff8102308f5e20 0000000000000046 0000000000000000 0000000000000000
May 15 05:33:55 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff810230f1e040
May 15 05:33:55 vault1 kernel:  ffffffff8058a6e0 00000000000a6796 ffff810230f1e248 0000000030f1e040
May 15 05:33:55 vault1 kernel: Call Trace:
May 15 05:33:55 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:55 vault1 kernel:  [<ffffffff802560c6>] kswapd+0xea/0x469
May 15 05:33:55 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:33:55 vault1 kernel:  [<ffffffff80255fdc>] kswapd+0x0/0x469
May 15 05:33:55 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:55 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:55 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:55 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:55 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:55 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:55 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:55 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:55 vault1 kernel: 
May 15 05:33:55 vault1 kernel: kswapd1       S ffff81012f857b58     0   301     19 (L-TLB)
May 15 05:33:55 vault1 kernel:  ffff8102308f7e20 0000000000000046 0000000000000000 0000000000000000
May 15 05:33:55 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff810230f1d080
May 15 05:33:55 vault1 kernel:  ffff810136be9080 00000000000a9722 ffff810230f1d288 0000000230f1d080
May 15 05:33:55 vault1 kernel: Call Trace:
May 15 05:33:55 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:55 vault1 kernel:  [<ffffffff802560c6>] kswapd+0xea/0x469
May 15 05:33:55 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:33:55 vault1 kernel:  [<ffffffff80255fdc>] kswapd+0x0/0x469
May 15 05:33:55 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:55 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:55 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:55 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:55 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:55 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:55 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:55 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:55 vault1 kernel: 
May 15 05:33:55 vault1 kernel: aio/0         S ffffffff8058a280     0   302     19 (L-TLB)
May 15 05:33:55 vault1 kernel:  ffff8102308f9ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:55 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff810230f1c0c0
May 15 05:33:55 vault1 kernel:  ffffffff8058a6e0 00000000000016fc ffff810230f1c2c8 0000000030f1c0c0
May 15 05:33:55 vault1 kernel: Call Trace:
May 15 05:33:55 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:55 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:55 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:55 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:55 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:55 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:55 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:55 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:55 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:55 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:55 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:55 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:55 vault1 kernel: 
May 15 05:33:55 vault1 kernel: aio/1         S ffffffff8058a280     0   303     19 (L-TLB)
May 15 05:33:55 vault1 kernel:  ffff8102308fbea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:56 vault1 kernel:  0000000000000000 0000000000000000 0000000000000006 ffff810230f1b040
May 15 05:33:56 vault1 kernel:  ffff810136b92040 0000000000001bb0 ffff810230f1b248 0000000130f1b040
May 15 05:33:56 vault1 kernel: Call Trace:
May 15 05:33:56 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:56 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:56 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:56 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:56 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:56 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:56 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:56 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:56 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:56 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:56 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:56 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:56 vault1 kernel: 
May 15 05:33:56 vault1 kernel: aio/2         S ffffffff8058a280     0   304     19 (L-TLB)
May 15 05:33:56 vault1 kernel:  ffff8102308fdea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:33:56 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff810230f19080
May 15 05:33:56 vault1 kernel:  ffff810130a13080 0000000000001be7 ffff810230f19288 0000000230f19080
May 15 05:33:56 vault1 kernel: Call Trace:
May 15 05:33:56 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:33:56 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:56 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:56 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:33:56 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:56 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:56 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:56 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:56 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:56 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:56 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:56 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:56 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:56 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:56 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:56 vault1 kernel: 
May 15 05:33:56 vault1 kernel: aio/3         S ffffffff8058a280     0   305     19 (L-TLB)
May 15 05:33:56 vault1 kernel:  ffff8102308c1ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:56 vault1 kernel:  0000000000000000 0000000000000000 0000000000000008 ffff810230f32080
May 15 05:33:56 vault1 kernel:  ffff810230c4c0c0 0000000000001498 ffff810230f32288 0000000330f32080
May 15 05:33:56 vault1 kernel: Call Trace:
May 15 05:33:56 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:56 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:56 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:56 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:56 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:56 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:56 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:56 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:56 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:56 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:56 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:56 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:56 vault1 kernel: 
May 15 05:33:56 vault1 kernel: kpsmoused     S ffffffff8058a280     0   461     19 (L-TLB)
May 15 05:33:56 vault1 kernel:  ffff810130b5dea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:56 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130f640c0
May 15 05:33:56 vault1 kernel:  ffffffff8058a6e0 0000000000000fc7 ffff810130f642c8 0000000030f640c0
May 15 05:33:56 vault1 kernel: Call Trace:
May 15 05:33:56 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:56 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:56 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:56 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:56 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:56 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:33:56 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:56 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:56 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:56 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:56 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:56 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:56 vault1 kernel: 
May 15 05:33:56 vault1 kernel: scsi_eh_0     S ffff810130b71638     0   520     19 (L-TLB)
May 15 05:33:56 vault1 kernel:  ffff810130203e70 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:56 vault1 kernel:  0000000000000000 0000000000000046 0000000000000004 ffff8101309050c0
May 15 05:33:56 vault1 kernel:  ffff810136be9080 00000000000009fd ffff8101309052c8 0000000280263894
May 15 05:33:56 vault1 kernel: Call Trace:
May 15 05:33:56 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:33:56 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:56 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:33:56 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:33:56 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:56 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:56 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:56 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:56 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:56 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:57 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:57 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:57 vault1 kernel: 
May 15 05:33:57 vault1 kernel: scsi_eh_1     S ffff810130b71638     0   536     19 (L-TLB)
May 15 05:33:57 vault1 kernel:  ffff81013029de70 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:57 vault1 kernel:  0000000000000000 0000000000000046 0000000000000006 ffff81013007e0c0
May 15 05:33:57 vault1 kernel:  ffff810136be9080 00000000000006ce ffff81013007e2c8 0000000280263894
May 15 05:33:57 vault1 kernel: Call Trace:
May 15 05:33:57 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:33:57 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:57 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:33:57 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:33:57 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:57 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:57 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:57 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:57 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:57 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:57 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:57 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:57 vault1 kernel: 
May 15 05:33:57 vault1 kernel: qla2xxx_1_dpc S ffff810230e444f8     0   537     19 (L-TLB)
May 15 05:33:57 vault1 kernel:  ffff810130f75ee0 0000000000000046 0000000000000000 ffffffff802913d9
May 15 05:33:57 vault1 kernel:  ffff810130e5c7e8 ffff810130917040 000000000000000a ffff810130917040
May 15 05:33:57 vault1 kernel:  ffff810136b92040 00000000000008a0 ffff810130917248 000000018029fe09
May 15 05:33:57 vault1 kernel: Call Trace:
May 15 05:33:57 vault1 kernel:  [<ffffffff802913d9>] process_timeout+0x0/0x5
May 15 05:33:57 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:57 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:33:57 vault1 kernel:  [<ffffffff880ba348>] :qla2xxx:qla2x00_do_dpc+0x39/0x439
May 15 05:33:57 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:57 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:33:57 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:57 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:57 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:57 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:57 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:57 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:57 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:57 vault1 kernel: 
May 15 05:33:57 vault1 kernel: scsi_wq_1     S ffff810130b71638     0   538     19 (L-TLB)
May 15 05:33:57 vault1 kernel:  ffff810130f73ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:57 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130ff8040
May 15 05:33:57 vault1 kernel:  ffff810136be9080 00000000000014b7 ffff810130ff8248 0000000230ff8040
May 15 05:33:57 vault1 kernel: Call Trace:
May 15 05:33:57 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:57 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:57 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:57 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:57 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:57 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:57 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:57 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:57 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:57 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:57 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:57 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:57 vault1 kernel: 
May 15 05:33:57 vault1 kernel: fc_wq_1       S ffff810130b71638     0   539     19 (L-TLB)
May 15 05:33:57 vault1 kernel:  ffff810130fafea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:57 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130fff080
May 15 05:33:57 vault1 kernel:  ffff810136be9080 00000000000012d2 ffff810130fff288 0000000230fff080
May 15 05:33:57 vault1 kernel: Call Trace:
May 15 05:33:57 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:57 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:57 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:57 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:57 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:57 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:57 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:57 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:57 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:57 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:57 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:57 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:57 vault1 kernel: 
May 15 05:33:57 vault1 kernel: fc_dl_1       S ffff810130b71a98     0   540     19 (L-TLB)
May 15 05:33:57 vault1 kernel:  ffff810130137ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:57 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff81013007f0c0
May 15 05:33:57 vault1 kernel:  ffffffff8058a6e0 0000000000001268 ffff81013007f2c8 000000003007f0c0
May 15 05:33:58 vault1 kernel: Call Trace:
May 15 05:33:58 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:58 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:58 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:58 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:58 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:58 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:33:58 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:58 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:58 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:58 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:58 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:58 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:58 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:58 vault1 kernel: 
May 15 05:33:58 vault1 kernel: scsi_eh_2     S ffff810130b71638     0   541     19 (L-TLB)
May 15 05:33:58 vault1 kernel:  ffff81013091de70 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:58 vault1 kernel:  0000000000000000 0000000000000046 0000000000000009 ffff810130c5a040
May 15 05:33:58 vault1 kernel:  ffff810136be9080 00000000000007e9 ffff810130c5a248 0000000280263894
May 15 05:33:58 vault1 kernel: Call Trace:
May 15 05:33:58 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:33:58 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:58 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:33:58 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:33:58 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:58 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:58 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:58 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:58 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:58 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:58 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:58 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:58 vault1 kernel: 
May 15 05:33:58 vault1 kernel: qla2xxx_2_dpc S ffff810230e444f8     0   542     19 (L-TLB)
May 15 05:33:58 vault1 kernel:  ffff810130fcbee0 0000000000000046 0000000000000000 ffff810130be1080
May 15 05:33:58 vault1 kernel:  ffff810130be1080 ffffffff802638fc 000000000000000a ffff810130be1080
May 15 05:33:58 vault1 kernel:  ffff810136b92040 0000000000000604 ffff810130be1288 00000001880ba30f
May 15 05:33:58 vault1 kernel: Call Trace:
May 15 05:33:58 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:58 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:33:58 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:58 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:33:58 vault1 kernel:  [<ffffffff880ba348>] :qla2xxx:qla2x00_do_dpc+0x39/0x439
May 15 05:33:58 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:58 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:33:58 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:58 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:58 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:58 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:58 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:58 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:58 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:58 vault1 kernel: 
May 15 05:33:58 vault1 kernel: scsi_wq_2     S ffff810130b71638     0   543     19 (L-TLB)
May 15 05:33:58 vault1 kernel:  ffff810130911ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:58 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff8101308170c0
May 15 05:33:58 vault1 kernel:  ffff810136be9080 0000000000001242 ffff8101308172c8 00000002308170c0
May 15 05:33:58 vault1 kernel: Call Trace:
May 15 05:33:58 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:58 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:58 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:58 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:58 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:58 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:58 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:58 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:58 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:58 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:58 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:58 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:58 vault1 kernel: 
May 15 05:33:58 vault1 kernel: fc_wq_2       S ffff810130b71638     0   544     19 (L-TLB)
May 15 05:33:58 vault1 kernel:  ffff810130fc1ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:58 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130852040
May 15 05:33:58 vault1 kernel:  ffff810136be9080 0000000000000fdf ffff810130852248 0000000230852040
May 15 05:33:58 vault1 kernel: Call Trace:
May 15 05:33:58 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:58 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:58 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:58 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:58 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:58 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:58 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:58 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:58 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:58 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:58 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:58 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:58 vault1 kernel: 
May 15 05:33:58 vault1 kernel: fc_dl_2       S ffff810130b71638     0   545     19 (L-TLB)
May 15 05:33:58 vault1 kernel:  ffff81013009dea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:58 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130853080
May 15 05:33:58 vault1 kernel:  ffff810136be9080 00000000000011d4 ffff810130853288 0000000230853080
May 15 05:33:59 vault1 kernel: Call Trace:
May 15 05:33:59 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:59 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:59 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:59 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:59 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:59 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:59 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:59 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:59 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:59 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:59 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:59 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:59 vault1 kernel: 
May 15 05:33:59 vault1 kernel: scsi_eh_3     S ffff810130b71638     0   546     19 (L-TLB)
May 15 05:33:59 vault1 kernel:  ffff8101308e5e70 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:59 vault1 kernel:  0000000000000000 0000000000000046 0000000000000009 ffff81013081c0c0
May 15 05:33:59 vault1 kernel:  ffff810136be9080 000000000000074f ffff81013081c2c8 0000000280263894
May 15 05:33:59 vault1 kernel: Call Trace:
May 15 05:33:59 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:33:59 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:59 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:33:59 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:33:59 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:59 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:59 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:59 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:59 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:59 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:59 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:59 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:59 vault1 kernel: 
May 15 05:33:59 vault1 kernel: qla2xxx_3_dpc S ffff81012fe02998     0   547     19 (L-TLB)
May 15 05:33:59 vault1 kernel:  ffff8101309f7ee0 0000000000000046 0000000000000000 ffff810130843040
May 15 05:33:59 vault1 kernel:  ffff810130843040 ffffffff802638fc 000000000000000a ffff810130843040
May 15 05:33:59 vault1 kernel:  ffff810136b92040 0000000000006120 ffff810130843248 00000001880ba30f
May 15 05:33:59 vault1 kernel: Call Trace:
May 15 05:33:59 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:59 vault1 kernel:  [<ffffffff880bcb27>] :qla2xxx:qla2x00_fw_ready+0x84/0x1a2
May 15 05:33:59 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:33:59 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:59 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:33:59 vault1 kernel:  [<ffffffff880ba348>] :qla2xxx:qla2x00_do_dpc+0x39/0x439
May 15 05:33:59 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:59 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:33:59 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:59 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:59 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:59 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:59 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:59 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:59 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:59 vault1 kernel: 
May 15 05:33:59 vault1 kernel: scsi_wq_3     S ffff810230f851d8     0   548     19 (L-TLB)
May 15 05:33:59 vault1 kernel:  ffff8101309e9ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:59 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff810130be5080
May 15 05:33:59 vault1 kernel:  ffffffff8058a6e0 0000000000042b71 ffff810130be5288 0000000030be5080
May 15 05:33:59 vault1 kernel: Call Trace:
May 15 05:33:59 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:59 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:59 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:59 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:59 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:59 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:59 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:59 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:59 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:59 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:59 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:33:59 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:33:59 vault1 kernel: 
May 15 05:33:59 vault1 kernel: fc_wq_3       S ffff810130b71638     0   549     19 (L-TLB)
May 15 05:33:59 vault1 kernel:  ffff810130293ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:33:59 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff8101300810c0
May 15 05:33:59 vault1 kernel:  ffff810136be9080 0000000000001055 ffff8101300812c8 00000002300810c0
May 15 05:33:59 vault1 kernel: Call Trace:
May 15 05:33:59 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:33:59 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:33:59 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:33:59 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:33:59 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:33:59 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:33:59 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:33:59 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:33:59 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:33:59 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:33:59 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:00 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:00 vault1 kernel: 
May 15 05:34:00 vault1 kernel: fc_dl_3       S ffff810130b71638     0   550     19 (L-TLB)
May 15 05:34:00 vault1 kernel:  ffff810130909ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:00 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff81013011d040
May 15 05:34:00 vault1 kernel:  ffff810136be9080 0000000000001376 ffff81013011d248 000000023011d040
May 15 05:34:00 vault1 kernel: Call Trace:
May 15 05:34:00 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:00 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:00 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:00 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:00 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:00 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:00 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:00 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:00 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:00 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:34:00 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:00 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:00 vault1 kernel: 
May 15 05:34:00 vault1 kernel: scsi_eh_4     S ffff810130b71638     0   551     19 (L-TLB)
May 15 05:34:00 vault1 kernel:  ffff810130915e70 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:00 vault1 kernel:  0000000000000000 0000000000000046 0000000000000009 ffff81013008b080
May 15 05:34:00 vault1 kernel:  ffff810136be9080 000000000000086b ffff81013008b288 0000000280263894
May 15 05:34:00 vault1 kernel: Call Trace:
May 15 05:34:00 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:00 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:00 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:34:00 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:34:00 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:00 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:00 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:00 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:00 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:00 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:00 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:00 vault1 kernel: 
May 15 05:34:00 vault1 kernel: qla2xxx_4_dpc S ffff81012f451218     0   552     19 (L-TLB)
May 15 05:34:00 vault1 kernel:  ffff81013014bee0 0000000000000046 0000000000000000 ffff8101300740c0
May 15 05:34:00 vault1 kernel:  ffff8101300740c0 ffffffff802638fc 000000000000000a ffff8101300740c0
May 15 05:34:00 vault1 kernel:  ffff81012f4f3040 0000000000008a77 ffff8101300742c8 00000000880ba30f
May 15 05:34:00 vault1 kernel: Call Trace:
May 15 05:34:00 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:00 vault1 kernel:  [<ffffffff880bcb27>] :qla2xxx:qla2x00_fw_ready+0x84/0x1a2
May 15 05:34:00 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:34:00 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:00 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:34:00 vault1 kernel:  [<ffffffff880ba348>] :qla2xxx:qla2x00_do_dpc+0x39/0x439
May 15 05:34:00 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:00 vault1 kernel:  [<ffffffff880ba30f>] :qla2xxx:qla2x00_do_dpc+0x0/0x439
May 15 05:34:00 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:00 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:00 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:00 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:00 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:00 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:00 vault1 kernel: 
May 15 05:34:00 vault1 kernel: scsi_wq_4     S ffff81012f451218     0   553     19 (L-TLB)
May 15 05:34:00 vault1 kernel:  ffff81013016dea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:00 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff8101301e2040
May 15 05:34:00 vault1 kernel:  ffff81012eea1080 00000000000671cb ffff8101301e2248 00000000301e2040
May 15 05:34:00 vault1 kernel: Call Trace:
May 15 05:34:00 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:00 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:00 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:00 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:00 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:00 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:00 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:00 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:00 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:00 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:00 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:00 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:00 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:00 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:00 vault1 kernel: 
May 15 05:34:00 vault1 kernel: fc_wq_4       S ffff810130b71638     0   554     19 (L-TLB)
May 15 05:34:00 vault1 kernel:  ffff810130099ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:00 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130185080
May 15 05:34:01 vault1 kernel:  ffff810136be9080 0000000000000fd3 ffff810130185288 0000000230185080
May 15 05:34:01 vault1 kernel: Call Trace:
May 15 05:34:01 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:01 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:01 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:01 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:01 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:01 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:01 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:01 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:01 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:01 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:01 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:01 vault1 kernel: 
May 15 05:34:01 vault1 kernel: fc_dl_4       S ffff810130b71638     0   555     19 (L-TLB)
May 15 05:34:01 vault1 kernel:  ffff81013009bea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:01 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff8101301840c0
May 15 05:34:01 vault1 kernel:  ffff810136be9080 0000000000001084 ffff8101301842c8 00000002301840c0
May 15 05:34:01 vault1 kernel: Call Trace:
May 15 05:34:01 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:01 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:01 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:01 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:01 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:01 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:01 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:01 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:01 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:01 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:01 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:01 vault1 kernel: 
May 15 05:34:01 vault1 kernel: kjournald     S ffff810230e45678     0   556     19 (L-TLB)
May 15 05:34:01 vault1 kernel:  ffff81013017bec0 0000000000000046 0000000000000000 0000000000000000
May 15 05:34:01 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff810130168040
May 15 05:34:01 vault1 kernel:  ffff810125693040 00000000000061ad ffff810130168248 000000018029fc0f
May 15 05:34:01 vault1 kernel: Call Trace:
May 15 05:34:01 vault1 kernel:  [<ffffffff880279be>] :jbd:kjournald+0x18e/0x21d
May 15 05:34:01 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:01 vault1 kernel:  [<ffffffff880279c3>] :jbd:kjournald+0x193/0x21d
May 15 05:34:01 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:01 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:01 vault1 kernel:  [<ffffffff88027830>] :jbd:kjournald+0x0/0x21d
May 15 05:34:01 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:01 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:01 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:01 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:01 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:01 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:01 vault1 kernel: 
May 15 05:34:01 vault1 kernel: kauditd       S ffff81012f8576f8     0   583     19 (L-TLB)
May 15 05:34:01 vault1 kernel:  ffff810130117ec0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:01 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff81012fd850c0
May 15 05:34:01 vault1 kernel:  ffff81012ff09040 0000000000007ed7 ffff81012fd852c8 000000002fd850c0
May 15 05:34:01 vault1 kernel: Call Trace:
May 15 05:34:01 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:01 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:01 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:01 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:01 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:01 vault1 kernel:  [<ffffffff802b2b39>] kauditd_thread+0x111/0x148
May 15 05:34:01 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:01 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:01 vault1 kernel:  [<ffffffff802b2a28>] kauditd_thread+0x0/0x148
May 15 05:34:01 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:01 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:01 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:01 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:01 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:01 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:01 vault1 kernel: 
May 15 05:34:01 vault1 kernel: udevd         S ffff81012f856e38     0   617      1 (NOTLB)
May 15 05:34:01 vault1 kernel:  ffff810130acba18 0000000000000046 0000000000000000 0000000000000046
May 15 05:34:01 vault1 kernel:  ffffffff802ea6a4 ffff81013025a7b8 0000000000000005 ffff81013025a080
May 15 05:34:01 vault1 kernel:  ffffffff8058a6e0 0000000000024d6c ffff81013025a288 0000000080262123
May 15 05:34:01 vault1 kernel: Call Trace:
May 15 05:34:01 vault1 kernel:  [<ffffffff802ea6a4>] inotify_poll+0x31/0x56
May 15 05:34:01 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:01 vault1 kernel:  [<ffffffff802ea6c2>] inotify_poll+0x4f/0x56
May 15 05:34:01 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:34:01 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:01 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:01 vault1 last message repeated 3 times
May 15 05:34:01 vault1 kernel:  [<ffffffff8023e153>] lookup_mnt+0x19/0x4c
May 15 05:34:01 vault1 kernel:  [<ffffffff8023e17e>] lookup_mnt+0x44/0x4c
May 15 05:34:02 vault1 kernel:  [<ffffffff8020d542>] dput+0x3c/0x12b
May 15 05:34:02 vault1 kernel:  [<ffffffff80219f0b>] __follow_mount+0x26/0x7b
May 15 05:34:02 vault1 kernel:  [<ffffffff8020cff9>] do_lookup+0x63/0x1ae
May 15 05:34:02 vault1 kernel:  [<ffffffff802119b8>] do_wp_page+0x5af/0x60b
May 15 05:34:02 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:34:02 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:34:02 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:02 vault1 kernel:  [<ffffffff8023bee1>] remove_wait_queue+0x10/0x2c
May 15 05:34:02 vault1 kernel:  [<ffffffff8023bee1>] remove_wait_queue+0x10/0x2c
May 15 05:34:02 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:02 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:02 vault1 kernel:  [<ffffffff80216aff>] sys_select+0xc1/0x183
May 15 05:34:02 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:02 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:02 vault1 kernel: 
May 15 05:34:02 vault1 kernel: khpsbpkt      S ffff81012f856e38     0  1220     19 (L-TLB)
May 15 05:34:02 vault1 kernel:  ffff81012f317f00 0000000000000046 ffffffff80246747 0000000000000002
May 15 05:34:02 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012f7f0040
May 15 05:34:02 vault1 kernel:  ffff81013025a080 0000000000001ce5 ffff81012f7f0248 0000000230191d30
May 15 05:34:02 vault1 kernel: Call Trace:
May 15 05:34:02 vault1 kernel:  [<ffffffff80246747>] skb_dequeue+0x13/0x50
May 15 05:34:02 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:02 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:02 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:02 vault1 kernel:  [<ffffffff8811e239>] :ieee1394:hpsbpkt_thread+0x0/0x8d
May 15 05:34:02 vault1 kernel:  [<ffffffff8811e2a9>] :ieee1394:hpsbpkt_thread+0x70/0x8d
May 15 05:34:02 vault1 kernel:  [<ffffffff8811e239>] :ieee1394:hpsbpkt_thread+0x0/0x8d
May 15 05:34:02 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:02 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:02 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:02 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:02 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:02 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:02 vault1 kernel: 
May 15 05:34:02 vault1 kernel: knodemgrd_0   S ffff810130b71638     0  1271     19 (L-TLB)
May 15 05:34:02 vault1 kernel:  ffff81012f21be70 0000000000000046 ffff810130d82080 ffffffff80261ece
May 15 05:34:02 vault1 kernel:  0000000000000246 ffff810230d3bc88 0000000000000009 ffff810130d82080
May 15 05:34:02 vault1 kernel:  ffff81012f3dc040 0000000000098704 ffff810130d82288 0000000080261ece
May 15 05:34:02 vault1 kernel: Call Trace:
May 15 05:34:02 vault1 kernel:  [<ffffffff80261ece>] __mutex_unlock_slowpath+0x128/0x133
May 15 05:34:02 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:02 vault1 kernel:  [<ffffffff88122d00>] :ieee1394:nodemgr_host_thread+0x87/0xa58
May 15 05:34:02 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:02 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:02 vault1 kernel:  [<ffffffff88122c79>] :ieee1394:nodemgr_host_thread+0x0/0xa58
May 15 05:34:02 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:02 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:02 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:02 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:02 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:02 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:02 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:02 vault1 kernel: 
May 15 05:34:02 vault1 kernel: ata/0         S ffff810230f85a98     0  1364     19 (L-TLB)
May 15 05:34:02 vault1 kernel:  ffff81012eba9ea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:02 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff81012f6d2080
May 15 05:34:02 vault1 kernel:  ffff810130a13080 0000000000001a45 ffff81012f6d2288 000000002f6d2080
May 15 05:34:02 vault1 kernel: Call Trace:
May 15 05:34:02 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:02 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:02 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:02 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:02 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:02 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:02 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:02 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:02 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:02 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:02 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:02 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:02 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:02 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:02 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:02 vault1 kernel: 
May 15 05:34:02 vault1 kernel: ata/1         S ffff81012f856e38     0  1365     19 (L-TLB)
May 15 05:34:02 vault1 kernel:  ffff81012ebabea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:02 vault1 kernel:  0000000000000000 0000000000000000 0000000000000006 ffff81012f791040
May 15 05:34:02 vault1 kernel:  ffff81013025a080 000000000000208c ffff81012f791248 000000012f791040
May 15 05:34:02 vault1 kernel: Call Trace:
May 15 05:34:02 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:02 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:02 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:02 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:02 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:02 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:02 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:02 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:02 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:02 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:02 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:02 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:02 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:02 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:02 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:02 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:02 vault1 kernel: 
May 15 05:34:02 vault1 kernel: ata/2         S ffff810230f84058     0  1366     19 (L-TLB)
May 15 05:34:02 vault1 kernel:  ffff81012ebafea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:02 vault1 kernel:  0000000000000000 0000000000000000 0000000000000006 ffff81012f46e080
May 15 05:34:02 vault1 kernel:  ffff81012fac80c0 000000000000267d ffff81012f46e288 000000022f46e080
May 15 05:34:02 vault1 kernel: Call Trace:
May 15 05:34:02 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:03 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:03 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:03 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:03 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:03 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:03 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:03 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:03 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:03 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:03 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:03 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:03 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:03 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:03 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:03 vault1 kernel: 
May 15 05:34:03 vault1 kernel: ata/3         S ffff81012f5bd6b8     0  1367     19 (L-TLB)
May 15 05:34:03 vault1 kernel:  ffff81012faf9ea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:03 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff81012f0950c0
May 15 05:34:03 vault1 kernel:  ffff8101308a9080 00000000000021a6 ffff81012f0952c8 000000032f0950c0
May 15 05:34:03 vault1 kernel: Call Trace:
May 15 05:34:03 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:03 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:03 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:03 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:03 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:03 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:03 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:03 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:03 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:03 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:03 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:03 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:03 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:03 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:03 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:03 vault1 kernel: 
May 15 05:34:03 vault1 kernel: ata_aux       S ffff810130840058     0  1368     19 (L-TLB)
May 15 05:34:03 vault1 kernel:  ffff81012ebb1ea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:03 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff81012f501040
May 15 05:34:03 vault1 kernel:  ffff81012f871040 0000000000001202 ffff81012f501248 000000002f501040
May 15 05:34:03 vault1 kernel: Call Trace:
May 15 05:34:03 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:03 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:03 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:03 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:03 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:03 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:03 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:03 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:03 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:03 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:03 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:03 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:03 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:03 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:03 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:03 vault1 kernel: 
May 15 05:34:03 vault1 kernel: scsi_eh_5     S ffff810130840918     0  1675     19 (L-TLB)
May 15 05:34:03 vault1 kernel:  ffff81012e7b1e70 0000000000000046 ffff81012f0b4040 ffffffff802638fc
May 15 05:34:03 vault1 kernel:  ffff81012f898000 0000000000000000 0000000000000003 ffff81012f0b4040
May 15 05:34:03 vault1 kernel:  ffff810230d72080 0000000000015241 ffff81012f0b4248 0000000100000282
May 15 05:34:03 vault1 kernel: Call Trace:
May 15 05:34:03 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:03 vault1 kernel:  [<ffffffff88060287>] :scsi_mod:__scsi_iterate_devices+0x5c/0x75
May 15 05:34:03 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:03 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:34:03 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:03 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:03 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:34:03 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:03 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:03 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:03 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:03 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:03 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:03 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:03 vault1 kernel: 
May 15 05:34:03 vault1 kernel: scsi_eh_6     S ffff81012eb76998     0  1677     19 (L-TLB)
May 15 05:34:03 vault1 kernel:  ffff81012e2cfe70 0000000000000046 ffff81012fdea0c0 ffffffff802638fc
May 15 05:34:03 vault1 kernel:  ffff81012ff60000 0000000000000000 0000000000000006 ffff81012fdea0c0
May 15 05:34:04 vault1 kernel:  ffff81012f7dc0c0 00000000000060c6 ffff81012fdea2c8 0000000000000282
May 15 05:34:04 vault1 kernel: Call Trace:
May 15 05:34:04 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:04 vault1 kernel:  [<ffffffff88060287>] :scsi_mod:__scsi_iterate_devices+0x5c/0x75
May 15 05:34:04 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:04 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:34:04 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:04 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:04 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:34:04 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:04 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:04 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:04 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:04 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:04 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:04 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:04 vault1 kernel: 
May 15 05:34:04 vault1 kernel: scsi_eh_7     S ffff81022fe50e38     0  2076     19 (L-TLB)
May 15 05:34:04 vault1 kernel:  ffff81012df47e70 0000000000000046 ffff81012efdc040 ffffffff802638fc
May 15 05:34:04 vault1 kernel:  ffff81012df20000 0000000000000000 0000000000000005 ffff81012efdc040
May 15 05:34:04 vault1 kernel:  ffff81012f7dc0c0 0000000000005d45 ffff81012efdc248 0000000000000282
May 15 05:34:04 vault1 kernel: Call Trace:
May 15 05:34:04 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:04 vault1 kernel:  [<ffffffff88060287>] :scsi_mod:__scsi_iterate_devices+0x5c/0x75
May 15 05:34:04 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:04 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:34:04 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:04 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:04 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:34:04 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:04 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:04 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:04 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:04 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:04 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:04 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:04 vault1 kernel: 
May 15 05:34:04 vault1 kernel: scsi_eh_8     S ffff8102300764b8     0  2077     19 (L-TLB)
May 15 05:34:04 vault1 kernel:  ffff81012df1fe70 0000000000000046 ffff81012eea30c0 ffffffff802638fc
May 15 05:34:04 vault1 kernel:  ffff81012e5e4000 0000000000000000 0000000000000008 ffff81012eea30c0
May 15 05:34:04 vault1 kernel:  ffff81012f7dc0c0 0000000000004d90 ffff81012eea32c8 0000000000000282
May 15 05:34:04 vault1 kernel: Call Trace:
May 15 05:34:04 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:04 vault1 kernel:  [<ffffffff88060287>] :scsi_mod:__scsi_iterate_devices+0x5c/0x75
May 15 05:34:04 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:04 vault1 kernel:  [<ffffffff88063f8e>] :scsi_mod:scsi_error_handler+0x6a/0x4dd
May 15 05:34:04 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:04 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:04 vault1 kernel:  [<ffffffff88063f24>] :scsi_mod:scsi_error_handler+0x0/0x4dd
May 15 05:34:04 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:04 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:04 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:04 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:04 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:04 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:04 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:04 vault1 kernel: 
May 15 05:34:04 vault1 kernel: kmpathd/0     S ffff810230cee998     0  2515     19 (L-TLB)
May 15 05:34:04 vault1 kernel:  ffff81012d897ea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:04 vault1 kernel:  0000000000000000 0000000000000000 0000000000000001 ffff81012f70f040
May 15 05:34:04 vault1 kernel:  ffff810130a13080 0000000000000d99 ffff81012f70f248 000000002f70f040
May 15 05:34:04 vault1 kernel: Call Trace:
May 15 05:34:04 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:04 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:04 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:04 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:04 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:04 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:04 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:04 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:04 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:04 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:04 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:04 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:04 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:04 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:04 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:04 vault1 kernel: 
May 15 05:34:04 vault1 kernel: kmpathd/1     S ffff810230f85a98     0  2516     19 (L-TLB)
May 15 05:34:04 vault1 kernel:  ffff81012d899ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:04 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff810130f6a0c0
May 15 05:34:04 vault1 kernel:  ffff810136b92040 0000000000001abe ffff810130f6a2c8 0000000130f6a0c0
May 15 05:34:04 vault1 kernel: Call Trace:
May 15 05:34:04 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:04 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:04 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:04 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:04 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:04 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:04 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:05 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:05 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:05 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:05 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:05 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:05 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:05 vault1 kernel: 
May 15 05:34:05 vault1 kernel: kmpathd/2     S ffff81012f856e38     0  2517     19 (L-TLB)
May 15 05:34:05 vault1 kernel:  ffff81012d89bea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:05 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff8101308a9080
May 15 05:34:05 vault1 kernel:  ffff81013025a080 0000000000002088 ffff8101308a9288 00000002308a9080
May 15 05:34:05 vault1 kernel: Call Trace:
May 15 05:34:05 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:05 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:05 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:05 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:05 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:05 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:05 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:05 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:05 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:05 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:05 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:05 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:05 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:05 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:34:05 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:05 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:05 vault1 kernel: 
May 15 05:34:05 vault1 kernel: kmpathd/3     S ffff810230cee998     0  2518     19 (L-TLB)
May 15 05:34:05 vault1 kernel:  ffff81012d89dea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:05 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012f2030c0
May 15 05:34:05 vault1 kernel:  ffff810230c4c0c0 0000000000003006 ffff81012f2032c8 000000032f2030c0
May 15 05:34:05 vault1 kernel: Call Trace:
May 15 05:34:05 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:05 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:05 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:05 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:05 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:05 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:05 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:05 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:05 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:05 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:05 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:34:05 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:05 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:05 vault1 kernel: 
May 15 05:34:05 vault1 kernel: kmirrord      S ffff810230d4f6f8     0  2533     19 (L-TLB)
May 15 05:34:05 vault1 kernel:  ffff81012dfd9ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:05 vault1 kernel:  0000000000000000 0000000000000000 0000000000000001 ffff810130ee0080
May 15 05:34:05 vault1 kernel:  ffff810230c4c0c0 00000000000019d6 ffff810130ee0288 0000000330ee0080
May 15 05:34:05 vault1 kernel: Call Trace:
May 15 05:34:05 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:05 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:05 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:05 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:05 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:05 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:05 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:05 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:05 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:05 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:05 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:05 vault1 kernel: 
May 15 05:34:05 vault1 kernel: jfsIO         S ffff810130b704b8     0  2571     19 (L-TLB)
May 15 05:34:05 vault1 kernel:  ffff81012c877f00 0000000000000046 0000000000000000 0000000000000001
May 15 05:34:05 vault1 kernel:  ffff81012c876000 ffff8101b644cd00 000000000000000a ffff810130dba0c0
May 15 05:34:05 vault1 kernel:  ffff810230c4c0c0 000000000006370c ffff810130dba2c8 0000000300000001
May 15 05:34:05 vault1 kernel: Call Trace:
May 15 05:34:05 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:05 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:05 vault1 kernel:  [<ffffffff88338385>] :jfs:jfsIOWait+0x0/0x96
May 15 05:34:05 vault1 kernel:  [<ffffffff883383fe>] :jfs:jfsIOWait+0x79/0x96
May 15 05:34:05 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:05 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:05 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:05 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:05 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:05 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:05 vault1 kernel: 
May 15 05:34:05 vault1 kernel: jfsCommit     S ffff810230f84058     0  2572     19 (L-TLB)
May 15 05:34:05 vault1 kernel:  ffff81012c879eb0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:05 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012f22d080
May 15 05:34:05 vault1 kernel:  ffff810136be9080 0000000000000776 ffff81012f22d288 000000022f22d080
May 15 05:34:05 vault1 kernel: Call Trace:
May 15 05:34:05 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:05 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:05 vault1 kernel:  [<ffffffff8833b108>] :jfs:jfs_lazycommit+0x1d9/0x212
May 15 05:34:05 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:05 vault1 kernel:  [<ffffffff8833af2f>] :jfs:jfs_lazycommit+0x0/0x212
May 15 05:34:05 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:05 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:05 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:05 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:05 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:34:05 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:05 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:05 vault1 kernel: 
May 15 05:34:05 vault1 kernel: jfsCommit     S ffff810230f84058     0  2573     19 (L-TLB)
May 15 05:34:06 vault1 kernel:  ffff81012c87beb0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:06 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012f722080
May 15 05:34:06 vault1 kernel:  ffff81012f6be0c0 000000000000bbdd ffff81012f722288 000000022f722080
May 15 05:34:06 vault1 kernel: Call Trace:
May 15 05:34:06 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:06 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:06 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:06 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:06 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:06 vault1 kernel:  [<ffffffff8833b108>] :jfs:jfs_lazycommit+0x1d9/0x212
May 15 05:34:06 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:06 vault1 kernel:  [<ffffffff8833af2f>] :jfs:jfs_lazycommit+0x0/0x212
May 15 05:34:06 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:06 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:06 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:06 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:06 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:34:06 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:06 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:06 vault1 kernel: 
May 15 05:34:06 vault1 kernel: jfsCommit     S ffff810230f84058     0  2574     19 (L-TLB)
May 15 05:34:06 vault1 kernel:  ffff81012c87deb0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:06 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff810130dda080
May 15 05:34:06 vault1 kernel:  ffff81012f22d080 0000000000000976 ffff810130dda288 0000000230dda080
May 15 05:34:06 vault1 kernel: Call Trace:
May 15 05:34:06 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:06 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:06 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:06 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:06 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:06 vault1 kernel:  [<ffffffff8833b108>] :jfs:jfs_lazycommit+0x1d9/0x212
May 15 05:34:06 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:06 vault1 kernel:  [<ffffffff8833af2f>] :jfs:jfs_lazycommit+0x0/0x212
May 15 05:34:06 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:06 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:06 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:06 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:06 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:34:06 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:06 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:06 vault1 kernel: 
May 15 05:34:06 vault1 kernel: jfsCommit     S ffff810230f84058     0  2575     19 (L-TLB)
May 15 05:34:06 vault1 kernel:  ffff81012c87feb0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:06 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012f6be0c0
May 15 05:34:06 vault1 kernel:  ffff810130dda080 0000000000000a3e ffff81012f6be2c8 000000022f6be0c0
May 15 05:34:06 vault1 kernel: Call Trace:
May 15 05:34:06 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:06 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:06 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:06 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:06 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:06 vault1 kernel:  [<ffffffff8833b108>] :jfs:jfs_lazycommit+0x1d9/0x212
May 15 05:34:06 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:06 vault1 kernel:  [<ffffffff8833af2f>] :jfs:jfs_lazycommit+0x0/0x212
May 15 05:34:06 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:06 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:06 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:06 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:06 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:34:06 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:06 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:06 vault1 kernel: 
May 15 05:34:06 vault1 kernel: jfsSync       S ffff81012f856e38     0  2576     19 (L-TLB)
May 15 05:34:06 vault1 kernel:  ffff81012c881ee0 0000000000000046 0000000000000000 ffff81012ef5a040
May 15 05:34:06 vault1 kernel:  00000000000001a9 0000000000000001 0000000000000008 ffff81012ef5a040
May 15 05:34:06 vault1 kernel:  ffff810136be9080 00000000000122f8 ffff81012ef5a248 0000000200000246
May 15 05:34:06 vault1 kernel: Call Trace:
May 15 05:34:06 vault1 kernel:  [<ffffffff8833a8e3>] :jfs:jfs_sync+0x181/0x1ac
May 15 05:34:06 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:06 vault1 kernel:  [<ffffffff8833a762>] :jfs:jfs_sync+0x0/0x1ac
May 15 05:34:06 vault1 kernel:  [<ffffffff8833a8e8>] :jfs:jfs_sync+0x186/0x1ac
May 15 05:34:06 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:06 vault1 kernel:  [<ffffffff8833a762>] :jfs:jfs_sync+0x0/0x1ac
May 15 05:34:06 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:07 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:07 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:07 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:07 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:34:07 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:07 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:07 vault1 kernel: 
May 15 05:34:07 vault1 kernel: kjournald     S ffff810230e444f8     0  2578     19 (L-TLB)
May 15 05:34:07 vault1 kernel:  ffff81012d563ec0 0000000000000046 0000000000000000 0000000000000000
May 15 05:34:07 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff81012f871040
May 15 05:34:07 vault1 kernel:  ffff810136b92040 0000000000001be6 ffff81012f871248 000000018029fc0f
May 15 05:34:07 vault1 kernel: Call Trace:
May 15 05:34:07 vault1 kernel:  [<ffffffff880279be>] :jbd:kjournald+0x18e/0x21d
May 15 05:34:07 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:07 vault1 kernel:  [<ffffffff880279c3>] :jbd:kjournald+0x193/0x21d
May 15 05:34:07 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:07 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:07 vault1 kernel:  [<ffffffff88027830>] :jbd:kjournald+0x0/0x21d
May 15 05:34:07 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:07 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:07 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:07 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:07 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:07 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:07 vault1 kernel: 
May 15 05:34:07 vault1 kernel: kjournald     S ffff810230e45678     0  2580     19 (L-TLB)
May 15 05:34:07 vault1 kernel:  ffff81012d3cdec0 0000000000000046 0000000000000000 0000000000000000
May 15 05:34:07 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff81012fac80c0
May 15 05:34:07 vault1 kernel:  ffff810136b92040 0000000000004e14 ffff81012fac82c8 000000018029fc0f
May 15 05:34:07 vault1 kernel: Call Trace:
May 15 05:34:07 vault1 kernel:  [<ffffffff880279be>] :jbd:kjournald+0x18e/0x21d
May 15 05:34:07 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:07 vault1 kernel:  [<ffffffff880279c3>] :jbd:kjournald+0x193/0x21d
May 15 05:34:07 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:07 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:07 vault1 kernel:  [<ffffffff88027830>] :jbd:kjournald+0x0/0x21d
May 15 05:34:07 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:07 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:07 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:07 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:07 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:07 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:07 vault1 kernel: 
May 15 05:34:07 vault1 kernel: kondemand/0   S ffff810230e444f8     0  2712     19 (L-TLB)
May 15 05:34:07 vault1 kernel:  ffff81012d509ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:07 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012e9e5040
May 15 05:34:07 vault1 kernel:  ffffffff8058a6e0 0000000000001127 ffff81012e9e5248 000000002e9e5040
May 15 05:34:07 vault1 kernel: Call Trace:
May 15 05:34:07 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:07 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:07 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:07 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:07 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:07 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:07 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:07 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:07 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:07 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:07 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:07 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:07 vault1 kernel: 
May 15 05:34:07 vault1 kernel: kondemand/1   S ffff81012f450db8     0  2713     19 (L-TLB)
May 15 05:34:07 vault1 kernel:  ffff81012c68fea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:07 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff81012f238040
May 15 05:34:07 vault1 kernel:  ffff810136b92040 00000000000021a8 ffff81012f238248 000000012f238040
May 15 05:34:07 vault1 kernel: Call Trace:
May 15 05:34:07 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:07 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:07 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:07 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:07 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:07 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:07 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:07 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:07 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:07 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:07 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:07 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:07 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:07 vault1 kernel: 
May 15 05:34:07 vault1 kernel: kondemand/2   S ffff81012f857b58     0  2714     19 (L-TLB)
May 15 05:34:07 vault1 kernel:  ffff81012c595ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:07 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff8101301b8080
May 15 05:34:07 vault1 kernel:  ffff810136be9080 0000000000000fee ffff8101301b8288 00000002301b8080
May 15 05:34:07 vault1 kernel: Call Trace:
May 15 05:34:07 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:07 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:07 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:07 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:07 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:07 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:07 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:07 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:07 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:07 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:08 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:08 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:08 vault1 kernel: 
May 15 05:34:08 vault1 kernel: kondemand/3   S ffff81012f856e38     0  2715     19 (L-TLB)
May 15 05:34:08 vault1 kernel:  ffff81012c599ea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:08 vault1 kernel:  0000000000000000 0000000000000000 0000000000000007 ffff81012e46b0c0
May 15 05:34:08 vault1 kernel:  ffff81013025a080 0000000000002efb ffff81012e46b2c8 000000032e46b0c0
May 15 05:34:08 vault1 kernel: Call Trace:
May 15 05:34:08 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:08 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:08 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:08 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:08 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:08 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:08 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:08 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:08 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:08 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:08 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:08 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:08 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:08 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:08 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:08 vault1 kernel: 
May 15 05:34:08 vault1 kernel: dhclient      S ffff81012eb77b18     0  3260      1 (NOTLB)
May 15 05:34:08 vault1 kernel:  ffff810130dfba18 0000000000000046 0000000000000000 ffff81012f3b0040
May 15 05:34:08 vault1 kernel:  ffff81012f3b0040 ffffffff802638fc 000000000000000a ffff81012f3b0040
May 15 05:34:08 vault1 kernel:  ffff810136b92040 00000000000022f6 ffff81012f3b0248 0000000130c84000
May 15 05:34:08 vault1 kernel: Call Trace:
May 15 05:34:08 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:08 vault1 kernel:  [<ffffffff80261790>] schedule_timeout+0x8a/0xad
May 15 05:34:08 vault1 kernel:  [<ffffffff802913d9>] process_timeout+0x0/0x5
May 15 05:34:08 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:34:08 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:08 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:08 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:08 vault1 kernel:  [<ffffffff802078c3>] kmem_cache_free+0x257/0x267
May 15 05:34:08 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:08 vault1 kernel:  [<ffffffff804435a0>] udp_recvmsg+0x1ee/0x270
May 15 05:34:08 vault1 kernel:  [<ffffffff80232600>] sock_common_recvmsg+0x30/0x45
May 15 05:34:08 vault1 kernel:  [<ffffffff80230bc6>] sock_recvmsg+0xf8/0x117
May 15 05:34:08 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:08 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:34:08 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:34:08 vault1 kernel:  [<ffffffff8040bc77>] move_addr_to_user+0x5d/0x78
May 15 05:34:08 vault1 kernel:  [<ffffffff8022c605>] sys_recvfrom+0x104/0x130
May 15 05:34:08 vault1 kernel:  [<ffffffff80216b98>] sys_select+0x15a/0x183
May 15 05:34:08 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:08 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:08 vault1 kernel: 
May 15 05:34:08 vault1 kernel: syslogd       D ffff81012fe03b18     0  3374      1 (NOTLB)
May 15 05:34:08 vault1 kernel:  ffff81012bd7fd88 0000000000000046 0000000000000000 0000000000000000
May 15 05:34:08 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff81012f0670c0
May 15 05:34:08 vault1 kernel:  ffff8101301b70c0 0000000000020f2a ffff81012f0672c8 000000008029fc0f
May 15 05:34:08 vault1 kernel: Call Trace:
May 15 05:34:08 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:08 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:08 vault1 kernel:  [<ffffffff88026c13>] :jbd:log_wait_commit+0xa4/0xf7
May 15 05:34:08 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:08 vault1 kernel:  [<ffffffff88021730>] :jbd:journal_stop+0x1e5/0x21a
May 15 05:34:08 vault1 kernel:  [<ffffffff802304c1>] __writeback_single_inode+0x1fa/0x338
May 15 05:34:08 vault1 kernel:  [<ffffffff802e2073>] sync_inode+0x19/0x39
May 15 05:34:08 vault1 kernel:  [<ffffffff802e2073>] sync_inode+0x19/0x39
May 15 05:34:08 vault1 kernel:  [<ffffffff802e207e>] sync_inode+0x24/0x39
May 15 05:34:08 vault1 kernel:  [<ffffffff88037332>] :ext3:ext3_sync_file+0xb2/0xc4
May 15 05:34:08 vault1 kernel:  [<ffffffff8024e527>] do_fsync+0x52/0xa4
May 15 05:34:08 vault1 kernel:  [<ffffffff802e4478>] __do_fsync+0x23/0x36
May 15 05:34:08 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:08 vault1 kernel: 
May 15 05:34:08 vault1 kernel: klogd         S ffff81012f450db8     0  3377      1 (NOTLB)
May 15 05:34:08 vault1 kernel:  ffff810127185be8 0000000000000046 0000000000000000 ffff8101301b70c0
May 15 05:34:08 vault1 kernel:  0000000000000001 ffffffff802a0de5 000000000000000a ffff8101301b70c0
May 15 05:34:08 vault1 kernel:  ffffffff8058a6e0 0000000000009e90 ffff8101301b72c8 0000000000000002
May 15 05:34:08 vault1 kernel: Call Trace:
May 15 05:34:08 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:08 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:08 vault1 kernel:  [<ffffffff80460f4b>] unix_wait_for_peer+0x86/0xb0
May 15 05:34:08 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:08 vault1 kernel:  [<ffffffff804614fb>] unix_dgram_sendmsg+0x3d3/0x4cd
May 15 05:34:08 vault1 kernel:  [<ffffffff8024671c>] sock_aio_write+0x110/0x128
May 15 05:34:08 vault1 kernel:  [<ffffffff80260e98>] __sched_text_start+0x928/0x960
May 15 05:34:08 vault1 kernel:  [<ffffffff80218507>] do_sync_write+0xc9/0x10c
May 15 05:34:08 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:08 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:08 vault1 kernel:  [<ffffffff80216cda>] vfs_write+0xe1/0x177
May 15 05:34:08 vault1 kernel:  [<ffffffff802176bf>] sys_write+0x45/0x6e
May 15 05:34:08 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:08 vault1 kernel: 
May 15 05:34:08 vault1 kernel: irqbalance    S ffff81012fe020d8     0  3393      1 (NOTLB)
May 15 05:34:08 vault1 kernel:  ffff81012bd75eb8 0000000000000046 0000000000000000 ffffffff802638fc
May 15 05:34:08 vault1 kernel:  ffff8100062dcbf8 ffff8100062dcbf0 0000000000000007 ffff81012eea00c0
May 15 05:34:09 vault1 kernel:  ffffffff8058a6e0 0000000000202cde ffff81012eea02c8 0000000000000292
May 15 05:34:09 vault1 kernel: Call Trace:
May 15 05:34:09 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:09 vault1 kernel:  [<ffffffff8023c6d0>] hrtimer_start+0xfd/0x110
May 15 05:34:09 vault1 kernel:  [<ffffffff802626ef>] do_nanosleep+0x46/0x77
May 15 05:34:09 vault1 kernel:  [<ffffffff80258b18>] hrtimer_nanosleep+0x58/0x11e
May 15 05:34:09 vault1 kernel:  [<ffffffff8029c17e>] hrtimer_wakeup+0x0/0x22
May 15 05:34:09 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:09 vault1 kernel:  [<ffffffff80252bb1>] sys_nanosleep+0x4c/0x62
May 15 05:34:09 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:09 vault1 kernel: 
May 15 05:34:09 vault1 kernel: portmap       S ffff810130b70058     0  3428      1 (NOTLB)
May 15 05:34:09 vault1 kernel:  ffff81012c6bdb28 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:34:09 vault1 kernel:  0000000180248a3b 0000000000000002 000000000000000a ffff8101309f4080
May 15 05:34:09 vault1 kernel:  ffff810136b92040 000000000001dcc0 ffff8101309f4288 0000000100000000
May 15 05:34:09 vault1 kernel: Call Trace:
May 15 05:34:09 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:09 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:09 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:09 vault1 kernel:  [<ffffffff80213f07>] tcp_poll+0x1f/0x133
May 15 05:34:09 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:34:09 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:09 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:09 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:09 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:09 vault1 kernel:  [<ffffffff8029ff51>] debug_check_no_locks_freed+0x11d/0x129
May 15 05:34:09 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:09 vault1 kernel:  [<ffffffff8020b848>] free_hot_cold_page+0x184/0x190
May 15 05:34:09 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:09 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:09 vault1 kernel:  [<ffffffff8040b777>] sys_sendmsg+0x217/0x28a
May 15 05:34:09 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:09 vault1 kernel:  [<ffffffff8023089b>] __up_write+0x27/0xf2
May 15 05:34:09 vault1 kernel:  [<ffffffff8023089b>] __up_write+0x27/0xf2
May 15 05:34:09 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:09 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:34:09 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:09 vault1 kernel: 
May 15 05:34:09 vault1 kernel: rpc.statd     S ffff810130b70918     0  3453      1 (NOTLB)
May 15 05:34:09 vault1 kernel:  ffff81012b387a18 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:34:09 vault1 kernel:  0000000180248a3b 0000000000000002 0000000000000006 ffff81013017c040
May 15 05:34:09 vault1 kernel:  ffffffff8058a6e0 000000000000295e ffff81013017c248 0000000000000000
May 15 05:34:09 vault1 kernel: Call Trace:
May 15 05:34:09 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:09 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:09 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:09 vault1 kernel:  [<ffffffff80213f07>] tcp_poll+0x1f/0x133
May 15 05:34:09 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:34:09 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:09 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:09 vault1 last message repeated 2 times
May 15 05:34:09 vault1 kernel:  [<ffffffff80263584>] _read_unlock+0x17/0x20
May 15 05:34:09 vault1 kernel:  [<ffffffff8046155d>] unix_dgram_sendmsg+0x435/0x4cd
May 15 05:34:09 vault1 kernel:  [<ffffffff8020d542>] dput+0x3c/0x12b
May 15 05:34:09 vault1 kernel:  [<ffffffff802530fc>] sock_sendmsg+0xea/0x107
May 15 05:34:09 vault1 kernel:  [<ffffffff8020ed97>] link_path_walk+0xce/0xe0
May 15 05:34:09 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:09 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:34:09 vault1 kernel:  [<ffffffff8022d806>] mntput_no_expire+0x1c/0x96
May 15 05:34:09 vault1 kernel:  [<ffffffff8040ba92>] sys_sendto+0x128/0x151
May 15 05:34:09 vault1 kernel:  [<ffffffff80216aff>] sys_select+0xc1/0x183
May 15 05:34:09 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:09 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:09 vault1 kernel: 
May 15 05:34:09 vault1 kernel: dbus-daemon   S ffff81012eb760d8     0  3481      1 (NOTLB)
May 15 05:34:09 vault1 kernel:  ffff81012b4d7b28 0000000000000046 0000000000000000 ffff81012f7dc0c0
May 15 05:34:09 vault1 kernel:  0000000000000000 ffffffff802a0de5 000000000000000a ffff81012f7dc0c0
May 15 05:34:09 vault1 kernel:  ffffffff8058a6e0 0000000000000a36 ffff81012f7dc2c8 0000000000000002
May 15 05:34:09 vault1 kernel: Call Trace:
May 15 05:34:09 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:09 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:09 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:34:09 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:09 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:09 vault1 last message repeated 2 times
May 15 05:34:09 vault1 kernel:  [<ffffffff8024671c>] sock_aio_write+0x110/0x128
May 15 05:34:09 vault1 kernel:  [<ffffffff8024660c>] sock_aio_write+0x0/0x128
May 15 05:34:09 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:34:09 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:09 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:09 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:09 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:09 vault1 kernel:  [<ffffffff802d3dfa>] do_readv_writev+0x199/0x1ae
May 15 05:34:10 vault1 kernel:  [<ffffffff8020d542>] dput+0x3c/0x12b
May 15 05:34:10 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:10 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:34:10 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:10 vault1 kernel: 
May 15 05:34:10 vault1 kernel: hidd          S ffff81012e41c9d8     0  3518      1 (NOTLB)
May 15 05:34:10 vault1 kernel:  ffff81012b439ad8 0000000000000046 0000000000000000 ffff81012eea2040
May 15 05:34:10 vault1 kernel:  0000000000000000 ffffffff802a0de5 0000000000000001 ffff81012eea2040
May 15 05:34:10 vault1 kernel:  ffffffff8058a6e0 00000000000085b1 ffff81012eea2248 0000000000000002
May 15 05:34:10 vault1 kernel: Call Trace:
May 15 05:34:10 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:10 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:10 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:34:10 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:10 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:10 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:10 vault1 kernel:  [<ffffffff80263584>] _read_unlock+0x17/0x20
May 15 05:34:10 vault1 kernel:  [<ffffffff8046155d>] unix_dgram_sendmsg+0x435/0x4cd
May 15 05:34:10 vault1 kernel:  [<ffffffff8020d542>] dput+0x3c/0x12b
May 15 05:34:10 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:10 vault1 kernel:  [<ffffffff802078e8>] find_get_page+0x15/0x4b
May 15 05:34:10 vault1 kernel:  [<ffffffff802638bb>] _read_unlock_irq+0x24/0x27
May 15 05:34:10 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:10 vault1 kernel:  [<ffffffff80208c1f>] __handle_mm_fault+0x3cf/0xccf
May 15 05:34:10 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:10 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:34:10 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:10 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:10 vault1 kernel:  [<ffffffff8021e12c>] sigprocmask+0x28/0xc1
May 15 05:34:10 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:10 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:10 vault1 kernel:  [<ffffffff802d861f>] sys_ppoll+0xf1/0x1ff
May 15 05:34:10 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:10 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:10 vault1 kernel: 
May 15 05:34:10 vault1 kernel: acpid         S ffff81012f8569d8     0  3535      1 (NOTLB)
May 15 05:34:10 vault1 kernel:  ffff81012b4e5b28 0000000000000046 0000000000000612 ffff81012e53b080
May 15 05:34:10 vault1 kernel:  0000000000000000 ffffffff802a0de5 0000000000000007 ffff81012e53b080
May 15 05:34:10 vault1 kernel:  ffff8102300e9040 000000000001ef10 ffff81012e53b288 0000000000000002
May 15 05:34:10 vault1 kernel: Call Trace:
May 15 05:34:10 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:10 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:10 vault1 kernel:  [<ffffffff88021755>] :jbd:journal_stop+0x20a/0x21a
May 15 05:34:10 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:10 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:34:10 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:10 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:10 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:10 vault1 kernel:  [<ffffffff8020e533>] current_fs_time+0x3b/0x40
May 15 05:34:10 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:10 vault1 kernel:  [<ffffffff80216881>] __generic_file_aio_write_nolock+0x378/0x3eb
May 15 05:34:10 vault1 kernel:  [<ffffffff80262123>] __mutex_lock_slowpath+0x245/0x25b
May 15 05:34:10 vault1 kernel:  [<ffffffff80261ece>] __mutex_unlock_slowpath+0x128/0x133
May 15 05:34:10 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:10 vault1 kernel:  [<ffffffff802224af>] generic_file_aio_write+0x6c/0xc1
May 15 05:34:10 vault1 kernel:  [<ffffffff88037192>] :ext3:ext3_file_write+0x16/0x94
May 15 05:34:10 vault1 kernel:  [<ffffffff80218507>] do_sync_write+0xc9/0x10c
May 15 05:34:10 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:10 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:10 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:10 vault1 kernel:  [<ffffffff8040bfa2>] sys_accept+0x19e/0x1fb
May 15 05:34:10 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:10 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:34:10 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:10 vault1 kernel: 
May 15 05:34:10 vault1 kernel: sshd          S ffff81012ec1da98     0  3553      1 (NOTLB)
May 15 05:34:10 vault1 kernel:  ffff81012739da18 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:34:10 vault1 kernel:  000000018023bee1 0000000000000002 0000000000000007 ffff81012ff09040
May 15 05:34:10 vault1 kernel:  ffffffff8058a6e0 0000000000005619 ffff81012ff09248 0000000000000000
May 15 05:34:10 vault1 kernel: Call Trace:
May 15 05:34:10 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:10 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:10 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:10 vault1 kernel:  [<ffffffff80213f07>] tcp_poll+0x1f/0x133
May 15 05:34:10 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:34:10 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:10 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:10 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:10 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:10 vault1 kernel:  [<ffffffff802133c4>] sock_def_readable+0x18/0x6c
May 15 05:34:10 vault1 kernel:  [<ffffffff802133c4>] sock_def_readable+0x18/0x6c
May 15 05:34:10 vault1 kernel:  [<ffffffff8020a6c3>] get_page_from_freelist+0x2ab/0x534
May 15 05:34:10 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:10 vault1 kernel:  [<ffffffff8020a6c3>] get_page_from_freelist+0x2ab/0x534
May 15 05:34:10 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:10 vault1 kernel:  [<ffffffff802c070d>] zone_statistics+0x3f/0x60
May 15 05:34:10 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:10 vault1 kernel:  [<ffffffff802118a0>] do_wp_page+0x497/0x60b
May 15 05:34:10 vault1 kernel:  [<ffffffff80211a03>] do_wp_page+0x5fa/0x60b
May 15 05:34:10 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:34:10 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:10 vault1 kernel:  [<ffffffff8020c6a9>] _atomic_dec_and_lock+0x39/0x58
May 15 05:34:10 vault1 kernel:  [<ffffffff80212fc9>] poison_obj+0x26/0x2f
May 15 05:34:10 vault1 kernel:  [<ffffffff802078c3>] kmem_cache_free+0x257/0x267
May 15 05:34:10 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:10 vault1 kernel:  [<ffffffff80216aff>] sys_select+0xc1/0x183
May 15 05:34:10 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:11 vault1 kernel:  [<ffffffff80239ba9>] generic_drop_inode+0x0/0x15c
May 15 05:34:11 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:11 vault1 kernel: 
May 15 05:34:11 vault1 kernel: rpc.idmapd    S ffff810130b704b8     0  3679      1 (NOTLB)
May 15 05:34:11 vault1 kernel:  ffff8101267a1e78 0000000000000046 0000000000000000 ffff81012f5ba0c0
May 15 05:34:11 vault1 kernel:  ffff81012f5ba0c0 ffffffff802638fc 000000000000000a ffff81012f5ba0c0
May 15 05:34:11 vault1 kernel:  ffff810136b92040 00000000000046db ffff81012f5ba2c8 0000000130c84000
May 15 05:34:11 vault1 kernel: Call Trace:
May 15 05:34:11 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:11 vault1 kernel:  [<ffffffff80261790>] schedule_timeout+0x8a/0xad
May 15 05:34:11 vault1 kernel:  [<ffffffff802913d9>] process_timeout+0x0/0x5
May 15 05:34:11 vault1 kernel:  [<ffffffff802ead19>] sys_epoll_wait+0x193/0x426
May 15 05:34:11 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:11 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:11 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:11 vault1 kernel: 
May 15 05:34:11 vault1 kernel: crond         S ffff81012f0bbb58     0  3694      1 (NOTLB)
May 15 05:34:11 vault1 kernel:  ffff810125d63eb8 0000000000000046 0000000000000000 ffffffff802638fc
May 15 05:34:11 vault1 kernel:  ffff8100062e79f8 ffff8100062e79f0 000000000000000a ffff81012e84d080
May 15 05:34:11 vault1 kernel:  ffff810136b92040 000000000002dd2a ffff81012e84d288 0000000100000292
May 15 05:34:11 vault1 kernel: Call Trace:
May 15 05:34:11 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:11 vault1 kernel:  [<ffffffff8023c6d0>] hrtimer_start+0xfd/0x110
May 15 05:34:11 vault1 kernel:  [<ffffffff802626ef>] do_nanosleep+0x46/0x77
May 15 05:34:11 vault1 kernel:  [<ffffffff80258b18>] hrtimer_nanosleep+0x58/0x11e
May 15 05:34:11 vault1 kernel:  [<ffffffff8029c17e>] hrtimer_wakeup+0x0/0x22
May 15 05:34:11 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:11 vault1 kernel:  [<ffffffff80252bb1>] sys_nanosleep+0x4c/0x62
May 15 05:34:11 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:11 vault1 kernel: 
May 15 05:34:11 vault1 kernel: atd           S ffff81012f451678     0  3709      1 (NOTLB)
May 15 05:34:11 vault1 kernel:  ffff810126653eb8 0000000000000046 0000000000000000 ffffffff802638fc
May 15 05:34:11 vault1 kernel:  ffff8100062e79f8 ffff8100062e79f0 0000000000000007 ffff81012f0050c0
May 15 05:34:11 vault1 kernel:  ffff810136b92040 0000000000018405 ffff81012f0052c8 0000000100000292
May 15 05:34:11 vault1 kernel: Call Trace:
May 15 05:34:11 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:11 vault1 kernel:  [<ffffffff8023c6d0>] hrtimer_start+0xfd/0x110
May 15 05:34:11 vault1 kernel:  [<ffffffff802626ef>] do_nanosleep+0x46/0x77
May 15 05:34:11 vault1 kernel:  [<ffffffff80258b18>] hrtimer_nanosleep+0x58/0x11e
May 15 05:34:11 vault1 kernel:  [<ffffffff8029c17e>] hrtimer_wakeup+0x0/0x22
May 15 05:34:11 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:11 vault1 kernel:  [<ffffffff80252bb1>] sys_nanosleep+0x4c/0x62
May 15 05:34:11 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:11 vault1 kernel: 
May 15 05:34:11 vault1 kernel: hald          S ffff81012f451218     0  3724      1 (NOTLB)
May 15 05:34:11 vault1 kernel:  ffff810125dfbb28 0000000000000046 ffff810130c84018 ffff81012f4f3040
May 15 05:34:11 vault1 kernel:  ffff81012f4f3040 ffffffff802638fc 000000000000000a ffff81012f4f3040
May 15 05:34:11 vault1 kernel:  ffff810125693040 0000000000061014 ffff81012f4f3248 0000000130c84000
May 15 05:34:11 vault1 kernel: Call Trace:
May 15 05:34:11 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:11 vault1 kernel:  [<ffffffff8021d0d9>] __mod_timer+0xa7/0xb5
May 15 05:34:11 vault1 kernel:  [<ffffffff80261790>] schedule_timeout+0x8a/0xad
May 15 05:34:11 vault1 kernel:  [<ffffffff802913d9>] process_timeout+0x0/0x5
May 15 05:34:11 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:34:11 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:11 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:11 vault1 last message repeated 9 times
May 15 05:34:11 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:11 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:11 vault1 kernel:  [<ffffffff8028dc04>] _local_bh_enable+0xbb/0xd0
May 15 05:34:11 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:11 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:34:11 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:11 vault1 kernel: 
May 15 05:34:11 vault1 kernel: hald-runner   S ffff8102303edb18     0  3725   3724 (NOTLB)
May 15 05:34:11 vault1 kernel:  ffff810230d6bb28 0000000000000046 0000000000000000 ffff8102300e9040
May 15 05:34:11 vault1 kernel:  0000000000000000 ffffffff802a0de5 0000000000000001 ffff8102300e9040
May 15 05:34:11 vault1 kernel:  ffffffff8058a6e0 000000000000076b ffff8102300e9248 0000000000000002
May 15 05:34:11 vault1 kernel: Call Trace:
May 15 05:34:11 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:11 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:11 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:34:11 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:11 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:11 vault1 kernel:  [<ffffffff8024671c>] sock_aio_write+0x110/0x128
May 15 05:34:11 vault1 kernel:  [<ffffffff8026212e>] __mutex_lock_slowpath+0x250/0x25b
May 15 05:34:11 vault1 kernel:  [<ffffffff8024660c>] sock_aio_write+0x0/0x128
May 15 05:34:11 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:34:11 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:11 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:11 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:11 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:11 vault1 kernel:  [<ffffffff802d3dfa>] do_readv_writev+0x199/0x1ae
May 15 05:34:11 vault1 kernel:  [<ffffffff80229266>] do_wait+0x9a7/0xa75
May 15 05:34:12 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:12 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:34:12 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:12 vault1 kernel: 
May 15 05:34:12 vault1 kernel: hald-addon-ke S ffff810130840058     0  3790   3725 (NOTLB)
May 15 05:34:12 vault1 kernel:  ffff810125a6fea8 0000000000000046 0000000000000000 0000000000000000
May 15 05:34:12 vault1 kernel:  0000000000000000 0000000000000046 0000000000000007 ffff81012f209080
May 15 05:34:12 vault1 kernel:  ffffffff8058a6e0 000000000008f29f ffff81012f209288 000000002f209080
May 15 05:34:12 vault1 kernel: Call Trace:
May 15 05:34:12 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:12 vault1 kernel:  [<ffffffff803f1497>] evdev_read+0x112/0x235
May 15 05:34:12 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:12 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:12 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:34:12 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:34:12 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:12 vault1 kernel: 
May 15 05:34:12 vault1 kernel: hald-addon-ac S ffff810230e44098     0  3797   3725 (NOTLB)
May 15 05:34:12 vault1 kernel:  ffff810125b4bbe8 0000000000000046 0000000000000612 ffff8101308d4040
May 15 05:34:12 vault1 kernel:  0000000000000001 ffffffff802a0de5 0000000000000008 ffff8101308d4040
May 15 05:34:12 vault1 kernel:  ffff81012e53b080 000000000005f23b ffff8101308d4248 0000000000000002
May 15 05:34:12 vault1 kernel: Call Trace:
May 15 05:34:12 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:12 vault1 kernel:  [<ffffffff8023ad89>] prepare_to_wait+0x1b/0x5c
May 15 05:34:12 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:12 vault1 kernel:  [<ffffffff80249a11>] unix_stream_recvmsg+0x233/0x548
May 15 05:34:12 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:12 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:12 vault1 kernel:  [<ffffffff8040ae7a>] sock_aio_read+0x10c/0x124
May 15 05:34:12 vault1 kernel:  [<ffffffff8020cf53>] do_sync_read+0xc9/0x10c
May 15 05:34:12 vault1 kernel:  [<ffffffff8046210a>] unix_stream_connect+0x389/0x3ff
May 15 05:34:12 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:12 vault1 kernel:  [<ffffffff8020e38c>] do_mmap_pgoff+0x65d/0x7c9
May 15 05:34:12 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:12 vault1 kernel:  [<ffffffff8020b5b0>] vfs_read+0xde/0x173
May 15 05:34:12 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:34:12 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:12 vault1 kernel: 
May 15 05:34:12 vault1 kernel: hald-addon-cp S ffff81012ec1cd78     0  3798   3725 (NOTLB)
May 15 05:34:12 vault1 kernel:  ffff810125ba9b28 0000000000000046 0000000000000000 ffff81012f3dc040
May 15 05:34:12 vault1 kernel:  0000000000000000 ffffffff802a0de5 0000000000000003 ffff81012f3dc040
May 15 05:34:12 vault1 kernel:  ffffffff8058a6e0 0000000000034e85 ffff81012f3dc248 0000000000000002
May 15 05:34:12 vault1 kernel: Call Trace:
May 15 05:34:12 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:12 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:12 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:34:12 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:12 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:12 vault1 kernel:  [<ffffffff80249bf3>] unix_stream_recvmsg+0x415/0x548
May 15 05:34:12 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:12 vault1 kernel:  [<ffffffff802078e8>] find_get_page+0x15/0x4b
May 15 05:34:12 vault1 kernel:  [<ffffffff802638bb>] _read_unlock_irq+0x24/0x27
May 15 05:34:12 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:12 vault1 kernel:  [<ffffffff80208c1f>] __handle_mm_fault+0x3cf/0xccf
May 15 05:34:12 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:12 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:34:12 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:34:12 vault1 kernel:  [<ffffffff80208d64>] __handle_mm_fault+0x514/0xccf
May 15 05:34:12 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:12 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:12 vault1 kernel:  [<ffffffff80265bc5>] do_page_fault+0x490/0x7cf
May 15 05:34:12 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:12 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:34:12 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:12 vault1 kernel: 
May 15 05:34:12 vault1 kernel: hald-addon-ke S ffff81012f856118     0  3799   3725 (NOTLB)
May 15 05:34:12 vault1 kernel:  ffff810125be9ea8 0000000000000046 0000000000000000 0000000000000000
May 15 05:34:12 vault1 kernel:  0000000000000000 0000000000000046 0000000000000001 ffff81012f7ef0c0
May 15 05:34:12 vault1 kernel:  ffff810136b92040 0000000000069995 ffff81012f7ef2c8 000000012f7ef0c0
May 15 05:34:12 vault1 kernel: Call Trace:
May 15 05:34:12 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:12 vault1 kernel:  [<ffffffff803f1497>] evdev_read+0x112/0x235
May 15 05:34:12 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:12 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:12 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:34:12 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:34:12 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:12 vault1 kernel: 
May 15 05:34:12 vault1 kernel: hald-addon-ke S ffff810230cee0d8     0  3802   3725 (NOTLB)
May 15 05:34:12 vault1 kernel:  ffff8101259a3ea8 0000000000000046 0000000000000000 0000000000000000
May 15 05:34:12 vault1 kernel:  0000000000000000 0000000000000046 0000000000000001 ffff810130097040
May 15 05:34:12 vault1 kernel:  ffff810230c4c0c0 00000000000a3b0d ffff810130097248 0000000330097040
May 15 05:34:12 vault1 kernel: Call Trace:
May 15 05:34:12 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:12 vault1 kernel:  [<ffffffff803f1497>] evdev_read+0x112/0x235
May 15 05:34:12 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:13 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:13 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:34:13 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:34:13 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:13 vault1 kernel: 
May 15 05:34:13 vault1 kernel: hald-addon-st S ffff810230e444f8     0  3812   3725 (NOTLB)
May 15 05:34:13 vault1 kernel:  ffff8101254bdeb8 0000000000000046 0000000000000000 ffffffff802638fc
May 15 05:34:13 vault1 kernel:  ffff8100062dcbf8 ffff8100062dcbf0 0000000000000009 ffff81012ea19040
May 15 05:34:13 vault1 kernel:  ffffffff8058a6e0 0000000000001e57 ffff81012ea19248 0000000000000292
May 15 05:34:13 vault1 kernel: Call Trace:
May 15 05:34:13 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:13 vault1 kernel:  [<ffffffff8023c6d0>] hrtimer_start+0xfd/0x110
May 15 05:34:13 vault1 kernel:  [<ffffffff802626ef>] do_nanosleep+0x46/0x77
May 15 05:34:13 vault1 kernel:  [<ffffffff80258b18>] hrtimer_nanosleep+0x58/0x11e
May 15 05:34:13 vault1 kernel:  [<ffffffff8029c17e>] hrtimer_wakeup+0x0/0x22
May 15 05:34:13 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:13 vault1 kernel:  [<ffffffff80252bb1>] sys_nanosleep+0x4c/0x62
May 15 05:34:13 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:13 vault1 kernel: 
May 15 05:34:13 vault1 kernel: smartd        S ffff81012ec1c4b8     0  3876      1 (NOTLB)
May 15 05:34:13 vault1 kernel:  ffff81012662beb8 0000000000000046 0000000000000000 ffffffff802638fc
May 15 05:34:13 vault1 kernel:  ffff8100062dcbf8 ffff8100062dcbf0 0000000000000007 ffff81012fdbb040
May 15 05:34:13 vault1 kernel:  ffffffff8058a6e0 0000000000002dd0 ffff81012fdbb248 0000000000000292
May 15 05:34:13 vault1 kernel: Call Trace:
May 15 05:34:13 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:13 vault1 kernel:  [<ffffffff8023c6d0>] hrtimer_start+0xfd/0x110
May 15 05:34:13 vault1 kernel:  [<ffffffff802626ef>] do_nanosleep+0x46/0x77
May 15 05:34:13 vault1 kernel:  [<ffffffff80258b18>] hrtimer_nanosleep+0x58/0x11e
May 15 05:34:13 vault1 kernel:  [<ffffffff8029c17e>] hrtimer_wakeup+0x0/0x22
May 15 05:34:13 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:13 vault1 kernel:  [<ffffffff80252bb1>] sys_nanosleep+0x4c/0x62
May 15 05:34:13 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:13 vault1 kernel: 
May 15 05:34:13 vault1 kernel: mingetty      S ffff81012f0ba578     0  3879      1 (NOTLB)
May 15 05:34:13 vault1 kernel:  ffff810126425dc8 0000000000000046 0000000000000000 ffff81012f9307f0
May 15 05:34:13 vault1 kernel:  0000000000000612 ffff81012f930080 0000000000000007 ffff81012f930080
May 15 05:34:13 vault1 kernel:  ffff81012f342040 0000000000025b03 ffff81012f930288 0000000100000046
May 15 05:34:13 vault1 kernel: Call Trace:
May 15 05:34:13 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:13 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:13 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:13 vault1 kernel:  [<ffffffff8022a7cf>] read_chan+0x384/0x609
May 15 05:34:13 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:13 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:13 vault1 kernel:  [<ffffffff80232d53>] tty_read+0x72/0xc7
May 15 05:34:13 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:34:13 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:34:13 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:13 vault1 kernel: 
May 15 05:34:13 vault1 kernel: mingetty      S ffff81012ec1d638     0  3880      1 (NOTLB)
May 15 05:34:13 vault1 kernel:  ffff8101253a1dc8 0000000000000046 0000000000000002 0000000000000000
May 15 05:34:13 vault1 kernel:  ffff81012f38f7f8 ffff81012f38f0c0 0000000000000006 ffff81012f38f0c0
May 15 05:34:13 vault1 kernel:  ffff81012f930080 00000000001e63ba ffff81012f38f2c8 0000000100000046
May 15 05:34:13 vault1 kernel: Call Trace:
May 15 05:34:13 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:13 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:13 vault1 kernel:  [<ffffffff8022a7cf>] read_chan+0x384/0x609
May 15 05:34:13 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:13 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:13 vault1 kernel:  [<ffffffff80232d53>] tty_read+0x72/0xc7
May 15 05:34:13 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:34:13 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:34:13 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:13 vault1 kernel: 
May 15 05:34:13 vault1 kernel: mingetty      S ffff81012e41d298     0  3881      1 (NOTLB)
May 15 05:34:13 vault1 kernel:  ffff810125223dc8 0000000000000046 0000000000000000 ffff81012f3427b0
May 15 05:34:13 vault1 kernel:  0000000000000612 ffff81012f342040 0000000000000005 ffff81012f342040
May 15 05:34:13 vault1 kernel:  ffff81012f9940c0 000000000016c887 ffff81012f342248 0000000100000046
May 15 05:34:13 vault1 kernel: Call Trace:
May 15 05:34:13 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:13 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:13 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:13 vault1 kernel:  [<ffffffff8022a7cf>] read_chan+0x384/0x609
May 15 05:34:13 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:13 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:13 vault1 kernel:  [<ffffffff80232d53>] tty_read+0x72/0xc7
May 15 05:34:13 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:34:13 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:34:13 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:13 vault1 kernel: 
May 15 05:34:13 vault1 kernel: mingetty      S ffff81012effedb8     0  3882      1 (NOTLB)
May 15 05:34:13 vault1 kernel:  ffff810125453dc8 0000000000000046 0000000000000000 ffff81012f994830
May 15 05:34:13 vault1 kernel:  0000000000000612 ffff81012f9940c0 0000000000000004 ffff81012f9940c0
May 15 05:34:14 vault1 kernel:  ffff8101308d20c0 00000000000032cb ffff81012f9942c8 0000000100000046
May 15 05:34:14 vault1 kernel: Call Trace:
May 15 05:34:14 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:14 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:14 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:14 vault1 kernel:  [<ffffffff8022a7cf>] read_chan+0x384/0x609
May 15 05:34:14 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:14 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:14 vault1 kernel:  [<ffffffff80232d53>] tty_read+0x72/0xc7
May 15 05:34:14 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:34:14 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:34:14 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:14 vault1 kernel: 
May 15 05:34:14 vault1 kernel: mingetty      S ffff81012f5bd258     0  3883      1 (NOTLB)
May 15 05:34:14 vault1 kernel:  ffff81012d1bfdc8 0000000000000046 0000000000000000 ffff8101308d2830
May 15 05:34:14 vault1 kernel:  0000000000000612 ffff8101308d20c0 0000000000000003 ffff8101308d20c0
May 15 05:34:14 vault1 kernel:  ffff81013006d0c0 00000000000c79ab ffff8101308d22c8 0000000100000046
May 15 05:34:14 vault1 kernel: Call Trace:
May 15 05:34:14 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:14 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:14 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:14 vault1 kernel:  [<ffffffff8022a7cf>] read_chan+0x384/0x609
May 15 05:34:14 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:14 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:14 vault1 kernel:  [<ffffffff80232d53>] tty_read+0x72/0xc7
May 15 05:34:14 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:34:14 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:34:14 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:14 vault1 kernel: 
May 15 05:34:14 vault1 kernel: mingetty      S ffff81012f5bd6b8     0  3884      1 (NOTLB)
May 15 05:34:14 vault1 kernel:  ffff810125513dc8 0000000000000046 0000000000000000 ffff81013006d830
May 15 05:34:14 vault1 kernel:  0000000000000612 ffff81013006d0c0 0000000000000002 ffff81013006d0c0
May 15 05:34:14 vault1 kernel:  ffff810136b92040 000000000012884d ffff81013006d2c8 0000000100000046
May 15 05:34:14 vault1 kernel: Call Trace:
May 15 05:34:14 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:14 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:14 vault1 kernel:  [<ffffffff8022a7cf>] read_chan+0x384/0x609
May 15 05:34:14 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:14 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:14 vault1 kernel:  [<ffffffff80232d53>] tty_read+0x72/0xc7
May 15 05:34:14 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:34:14 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:34:14 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:14 vault1 kernel: 
May 15 05:34:14 vault1 kernel: sshd          S ffff810230f84058     0  3943   3553 (NOTLB)
May 15 05:34:14 vault1 kernel:  ffff8101256b9a18 0000000000000046 0000000000000000 0000000000000046
May 15 05:34:14 vault1 kernel:  ffffffff8022edfd 0000000000000046 000000000000000a ffff810127218080
May 15 05:34:14 vault1 kernel:  ffff810136b92040 0000000000015052 ffff810127218288 0000000127218080
May 15 05:34:14 vault1 kernel: Call Trace:
May 15 05:34:14 vault1 kernel:  [<ffffffff8022edfd>] __wake_up+0x22/0x4e
May 15 05:34:14 vault1 kernel:  [<ffffffff8023a80a>] tty_ldisc_deref+0x62/0x75
May 15 05:34:14 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:14 vault1 kernel:  [<ffffffff80226c98>] tty_poll+0x5f/0x6d
May 15 05:34:14 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:34:14 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:14 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:14 vault1 last message repeated 3 times
May 15 05:34:14 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:14 vault1 kernel:  [<ffffffff8022edfd>] __wake_up+0x22/0x4e
May 15 05:34:14 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:14 vault1 kernel:  [<ffffffff8022edfd>] __wake_up+0x22/0x4e
May 15 05:34:14 vault1 kernel:  [<ffffffff8022edfd>] __wake_up+0x22/0x4e
May 15 05:34:14 vault1 kernel:  [<ffffffff8023a80a>] tty_ldisc_deref+0x62/0x75
May 15 05:34:14 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:14 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:34:14 vault1 kernel:  [<ffffffff8022edfd>] __wake_up+0x22/0x4e
May 15 05:34:14 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:14 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:14 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:14 vault1 kernel:  [<ffffffff80216aff>] sys_select+0xc1/0x183
May 15 05:34:14 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:14 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:14 vault1 kernel: 
May 15 05:34:14 vault1 kernel: bash          S ffff810230e44958     0  3945   3943 (NOTLB)
May 15 05:34:14 vault1 kernel:  ffff81012571bec8 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:34:14 vault1 kernel:  0000000000000000 0000000200000002 0000000000000009 ffff810125ab70c0
May 15 05:34:14 vault1 kernel:  ffffffff8058a6e0 00000000000a8ebb ffff810125ab72c8 0000000000000000
May 15 05:34:14 vault1 kernel: Call Trace:
May 15 05:34:14 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:14 vault1 kernel:  [<ffffffff8022920b>] do_wait+0x94c/0xa75
May 15 05:34:14 vault1 kernel:  [<ffffffff8022922e>] do_wait+0x96f/0xa75
May 15 05:34:14 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:15 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:15 vault1 kernel: 
May 15 05:34:15 vault1 kernel: rpc.rquotad   S ffff81012f0ba118     0  4049      1 (NOTLB)
May 15 05:34:15 vault1 kernel:  ffff81012c6b5b28 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:34:15 vault1 kernel:  0000000180248a3b 0000000000000002 0000000000000001 ffff81012f00f080
May 15 05:34:15 vault1 kernel:  ffff810136be9080 00000000000360c4 ffff81012f00f288 0000000200000000
May 15 05:34:15 vault1 kernel: Call Trace:
May 15 05:34:15 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:15 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:15 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:15 vault1 kernel:  [<ffffffff80213f07>] tcp_poll+0x1f/0x133
May 15 05:34:15 vault1 kernel:  [<ffffffff8022ff1d>] do_sys_poll+0x276/0x35f
May 15 05:34:15 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:15 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:15 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:15 vault1 kernel:  [<ffffffff8020a6c3>] get_page_from_freelist+0x2ab/0x534
May 15 05:34:15 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:15 vault1 kernel:  [<ffffffff8020a6c3>] get_page_from_freelist+0x2ab/0x534
May 15 05:34:15 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:15 vault1 kernel:  [<ffffffff802078e8>] find_get_page+0x15/0x4b
May 15 05:34:15 vault1 kernel:  [<ffffffff802638bb>] _read_unlock_irq+0x24/0x27
May 15 05:34:15 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:15 vault1 kernel:  [<ffffffff80208c1f>] __handle_mm_fault+0x3cf/0xccf
May 15 05:34:15 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:15 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:34:15 vault1 kernel:  [<ffffffff8022307f>] __up_read+0x19/0x7f
May 15 05:34:15 vault1 kernel:  [<ffffffff80208d64>] __handle_mm_fault+0x514/0xccf
May 15 05:34:15 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:15 vault1 kernel:  [<ffffffff80265bc5>] do_page_fault+0x490/0x7cf
May 15 05:34:15 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:15 vault1 kernel:  [<ffffffff8021e472>] sys_close+0x2b/0xd1
May 15 05:34:15 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:15 vault1 kernel:  [<ffffffff8024b1fc>] sys_poll+0x32/0x3b
May 15 05:34:15 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:15 vault1 kernel: 
May 15 05:34:15 vault1 kernel: lockd         S ffff81022eda4958     0  4052      1 (L-TLB)
May 15 05:34:15 vault1 kernel:  ffff81022ff83e10 0000000000000046 0000000000000000 ffff81022f5c07f0
May 15 05:34:15 vault1 kernel:  0000000000000612 ffff81022f5c0080 0000000000000001 ffff81022f5c0080
May 15 05:34:15 vault1 kernel:  ffffffff8058a6e0 00000000000041f8 ffff81022f5c0288 0000000000000046
May 15 05:34:15 vault1 kernel: Call Trace:
May 15 05:34:15 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:15 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:15 vault1 kernel:  [<ffffffff883de24e>] :sunrpc:svc_recv+0x2b5/0x44f
May 15 05:34:15 vault1 kernel:  [<ffffffff883de257>] :sunrpc:svc_recv+0x2be/0x44f
May 15 05:34:15 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:15 vault1 kernel:  [<ffffffff8840b556>] :lockd:lockd+0x139/0x263
May 15 05:34:15 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:15 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:15 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:15 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:15 vault1 kernel:  [<ffffffff802078c3>] kmem_cache_free+0x257/0x267
May 15 05:34:15 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:15 vault1 kernel:  [<ffffffff8840b41d>] :lockd:lockd+0x0/0x263
May 15 05:34:15 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:15 vault1 kernel: 
May 15 05:34:15 vault1 kernel: rpciod/0      S ffff81022eda4958     0  4053     19 (L-TLB)
May 15 05:34:15 vault1 kernel:  ffff810124befea0 0000000000000046 ffffffff80248a3b 0000000000000002
May 15 05:34:15 vault1 kernel:  0000000000000000 0000000000000000 0000000000000009 ffff810130851080
May 15 05:34:15 vault1 kernel:  ffff81012f485080 0000000000000b30 ffff810130851288 0000000030851080
May 15 05:34:15 vault1 kernel: Call Trace:
May 15 05:34:15 vault1 kernel:  [<ffffffff80248a3b>] add_wait_queue+0x13/0x34
May 15 05:34:15 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:15 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:15 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:15 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:15 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:15 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:15 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:15 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:15 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:15 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:15 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:15 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:15 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:15 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:15 vault1 kernel: 
May 15 05:34:15 vault1 kernel: rpciod/1      S ffff810130b71a98     0  4054     19 (L-TLB)
May 15 05:34:15 vault1 kernel:  ffff810124bc3ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:15 vault1 kernel:  0000000000000000 0000000000000000 0000000000000008 ffff81012f485080
May 15 05:34:15 vault1 kernel:  ffff810136b92040 0000000000001672 ffff81012f485288 000000012f485080
May 15 05:34:15 vault1 kernel: Call Trace:
May 15 05:34:15 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:15 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:15 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:15 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:15 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:16 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:16 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:16 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:16 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:16 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:16 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:16 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:16 vault1 kernel: 
May 15 05:34:16 vault1 kernel: rpciod/2      S ffff810130b70058     0  4055     19 (L-TLB)
May 15 05:34:16 vault1 kernel:  ffff810124c43ea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:16 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff81012552e040
May 15 05:34:16 vault1 kernel:  ffff810136be9080 0000000000001a1e ffff81012552e248 000000022552e040
May 15 05:34:16 vault1 kernel: Call Trace:
May 15 05:34:16 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:16 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:16 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:16 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:16 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:16 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:16 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:16 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:16 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:16 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:16 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:34:16 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:16 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:16 vault1 kernel: 
May 15 05:34:16 vault1 kernel: rpciod/3      S ffff81022eda4958     0  4056     19 (L-TLB)
May 15 05:34:16 vault1 kernel:  ffff8101249edea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:16 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff8101252b5040
May 15 05:34:16 vault1 kernel:  ffff810230c4c0c0 00000000000019be ffff8101252b5248 00000003252b5040
May 15 05:34:16 vault1 kernel: Call Trace:
May 15 05:34:16 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:16 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:16 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:16 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:16 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:16 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:16 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:16 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:16 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:16 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:16 vault1 kernel:  [<ffffffff80276ee4>] physflat_send_IPI_mask+0x0/0x82
May 15 05:34:16 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:16 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:16 vault1 kernel: 
May 15 05:34:16 vault1 kernel: nfsd4         S ffff81012f5bc998     0  4057     19 (L-TLB)
May 15 05:34:16 vault1 kernel:  ffff810124bffea0 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:16 vault1 kernel:  0000000000000000 0000000000000000 000000000000000a ffff810130eae0c0
May 15 05:34:16 vault1 kernel:  ffff810136be9080 0000000000001a74 ffff810130eae2c8 0000000230eae0c0
May 15 05:34:16 vault1 kernel: Call Trace:
May 15 05:34:16 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:16 vault1 kernel:  [<ffffffff80299f53>] keventd_create_kthread+0x0/0x6d
May 15 05:34:16 vault1 kernel:  [<ffffffff80248f5b>] worker_thread+0x0/0x150
May 15 05:34:16 vault1 kernel:  [<ffffffff80249045>] worker_thread+0xea/0x150
May 15 05:34:16 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:16 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:16 vault1 kernel:  [<ffffffff8023312e>] kthread+0xd0/0xff
May 15 05:34:16 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:16 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:16 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:16 vault1 kernel:  [<ffffffff8023305e>] kthread+0x0/0xff
May 15 05:34:16 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:16 vault1 kernel: 
May 15 05:34:16 vault1 kernel: nfsd          D ffff810230f85a98     0  4058      1 (L-TLB)
May 15 05:34:16 vault1 kernel:  ffff81022ff77420 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:16 vault1 kernel:  0000000000000000 0000000000000046 0000000000000009 ffff81022fa12040
May 15 05:34:16 vault1 kernel:  ffffffff8058a6e0 00000000006928e3 ffff81022fa12248 000000002fa12858
May 15 05:34:16 vault1 kernel: Call Trace:
May 15 05:34:16 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:16 vault1 kernel:  [<ffffffff802616cf>] io_schedule+0x3f/0x67
May 15 05:34:16 vault1 kernel:  [<ffffffff8833680a>] :jfs:lbmAllocate+0x8a/0x114
May 15 05:34:16 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:16 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:16 vault1 kernel:  [<ffffffff8833723a>] :jfs:lmNextPage+0xea/0x127
May 15 05:34:16 vault1 kernel:  [<ffffffff88337508>] :jfs:lmWriteRecord+0x291/0x2d1
May 15 05:34:16 vault1 kernel:  [<ffffffff88338340>] :jfs:lmLog+0x125/0x16a
May 15 05:34:16 vault1 kernel:  [<ffffffff8833a17b>] :jfs:txCommit+0xcdd/0xef2
May 15 05:34:16 vault1 kernel:  [<ffffffff80262123>] __mutex_lock_slowpath+0x245/0x25b
May 15 05:34:16 vault1 kernel:  [<ffffffff88322175>] :jfs:jfs_commit_inode+0xab/0xf5
May 15 05:34:16 vault1 kernel:  [<ffffffff88335683>] :jfs:extAlloc+0x3ce/0x423
May 15 05:34:16 vault1 kernel:  [<ffffffff8832265c>] :jfs:jfs_get_block+0x167/0x237
May 15 05:34:16 vault1 kernel:  [<ffffffff802e5c6c>] nobh_prepare_write+0xd3/0x458
May 15 05:34:16 vault1 kernel:  [<ffffffff883224f5>] :jfs:jfs_get_block+0x0/0x237
May 15 05:34:16 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:16 vault1 kernel:  [<ffffffff8020c722>] add_to_page_cache+0x2d/0x8c
May 15 05:34:16 vault1 kernel:  [<ffffffff80263540>] _write_unlock_irq+0x24/0x27
May 15 05:34:17 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:17 vault1 kernel:  [<ffffffff80263540>] _write_unlock_irq+0x24/0x27
May 15 05:34:17 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:17 vault1 kernel:  [<ffffffff80263540>] _write_unlock_irq+0x24/0x27
May 15 05:34:17 vault1 kernel:  [<ffffffff80210354>] generic_file_buffered_write+0x27b/0x77b
May 15 05:34:17 vault1 kernel:  [<ffffffff8020e533>] current_fs_time+0x3b/0x40
May 15 05:34:17 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:17 vault1 kernel:  [<ffffffff80216881>] __generic_file_aio_write_nolock+0x378/0x3eb
May 15 05:34:17 vault1 kernel:  [<ffffffff80262123>] __mutex_lock_slowpath+0x245/0x25b
May 15 05:34:17 vault1 kernel:  [<ffffffff8026212e>] __mutex_lock_slowpath+0x250/0x25b
May 15 05:34:17 vault1 kernel:  [<ffffffff802224a4>] generic_file_aio_write+0x61/0xc1
May 15 05:34:17 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:34:17 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:34:17 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:17 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:17 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:34:17 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:17 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:34:17 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:34:17 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:34:17 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:17 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:17 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:17 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:34:17 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:34:17 vault1 kernel:  [<ffffffff883e29af>] :sunrpc:sunrpc_cache_lookup+0x30/0x131
May 15 05:34:17 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:34:17 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:34:17 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:34:17 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:34:17 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:34:17 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:34:17 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:17 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:17 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:17 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:17 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:34:17 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:17 vault1 kernel: 
May 15 05:34:17 vault1 kernel: nfsd          D ffff810230e444f8     0  4059      1 (L-TLB)
May 15 05:34:17 vault1 kernel:  ffff81022f7b5520 0000000000000046 0000000000000000 0000000000000002
May 15 05:34:17 vault1 kernel:  0000000000000000 0000000000000046 000000000000000a ffff81022fd6e0c0
May 15 05:34:17 vault1 kernel:  ffff810136b92040 000000000001166f ffff81022fd6e2c8 0000000100000046
May 15 05:34:17 vault1 kernel: Call Trace:
May 15 05:34:17 vault1 kernel:  [<ffffffff802616cf>] io_schedule+0x3f/0x67
May 15 05:34:17 vault1 kernel:  [<ffffffff88338540>] :jfs:lmGroupCommit+0x125/0x177
May 15 05:34:17 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:17 vault1 kernel:  [<ffffffff8833a1eb>] :jfs:txCommit+0xd4d/0xef2
May 15 05:34:17 vault1 kernel:  [<ffffffff80262123>] __mutex_lock_slowpath+0x245/0x25b
May 15 05:34:17 vault1 kernel:  [<ffffffff88322175>] :jfs:jfs_commit_inode+0xab/0xf5
May 15 05:34:17 vault1 kernel:  [<ffffffff88335683>] :jfs:extAlloc+0x3ce/0x423
May 15 05:34:17 vault1 kernel:  [<ffffffff8832265c>] :jfs:jfs_get_block+0x167/0x237
May 15 05:34:17 vault1 kernel:  [<ffffffff802e5c6c>] nobh_prepare_write+0xd3/0x458
May 15 05:34:17 vault1 kernel:  [<ffffffff883224f5>] :jfs:jfs_get_block+0x0/0x237
May 15 05:34:17 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:17 vault1 kernel:  [<ffffffff8020c722>] add_to_page_cache+0x2d/0x8c
May 15 05:34:17 vault1 kernel:  [<ffffffff80263540>] _write_unlock_irq+0x24/0x27
May 15 05:34:17 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:17 vault1 kernel:  [<ffffffff80263540>] _write_unlock_irq+0x24/0x27
May 15 05:34:17 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:17 vault1 kernel:  [<ffffffff80263540>] _write_unlock_irq+0x24/0x27
May 15 05:34:17 vault1 kernel:  [<ffffffff80210354>] generic_file_buffered_write+0x27b/0x77b
May 15 05:34:17 vault1 kernel:  [<ffffffff8020e533>] current_fs_time+0x3b/0x40
May 15 05:34:17 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:17 vault1 kernel:  [<ffffffff80216881>] __generic_file_aio_write_nolock+0x378/0x3eb
May 15 05:34:17 vault1 kernel:  [<ffffffff80262123>] __mutex_lock_slowpath+0x245/0x25b
May 15 05:34:17 vault1 kernel:  [<ffffffff8026212e>] __mutex_lock_slowpath+0x250/0x25b
May 15 05:34:17 vault1 kernel:  [<ffffffff802224a4>] generic_file_aio_write+0x61/0xc1
May 15 05:34:17 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:34:17 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:34:17 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:17 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:17 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:34:17 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:17 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:34:17 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:34:17 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:34:17 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:17 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:17 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:17 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:34:17 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:34:18 vault1 kernel:  [<ffffffff883e29af>] :sunrpc:sunrpc_cache_lookup+0x30/0x131
May 15 05:34:18 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:34:18 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:34:18 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:34:18 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:34:18 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:34:18 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:34:18 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:18 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:18 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:18 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:18 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:34:18 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:18 vault1 kernel: 
May 15 05:34:18 vault1 kernel: nfsd          D ffff810230e444f8     0  4060      1 (L-TLB)
May 15 05:34:18 vault1 kernel:  ffff8102302aba60 0000000000000046 0000000000000000 ffff81022fd3b040
May 15 05:34:18 vault1 kernel:  0000000000000001 ffffffff802a0de5 000000000000000a ffff81022fd3b040
May 15 05:34:18 vault1 kernel:  ffff810136b92040 000000000025e9d4 ffff81022fd3b248 000000012fd3b7b0
May 15 05:34:18 vault1 kernel: Call Trace:
May 15 05:34:18 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:18 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:18 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:34:18 vault1 kernel:  [<ffffffff8024e63b>] d_find_alias+0x3a/0x42
May 15 05:34:18 vault1 kernel:  [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:18 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:34:18 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:34:18 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:18 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:18 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:34:18 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:18 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:34:18 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:34:18 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:34:18 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:18 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:18 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:18 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:34:18 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:34:18 vault1 kernel:  [<ffffffff883e29af>] :sunrpc:sunrpc_cache_lookup+0x30/0x131
May 15 05:34:18 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:34:18 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:34:18 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:34:18 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:34:18 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:34:18 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:34:18 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:18 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:18 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:18 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:18 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:34:18 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:18 vault1 kernel: 
May 15 05:34:18 vault1 kernel: nfsd          D ffff810230f84058     0  4061      1 (L-TLB)
May 15 05:34:18 vault1 kernel:  ffff81022f37fa60 0000000000000046 0000000000000000 ffff81022f726080
May 15 05:34:18 vault1 kernel:  0000000000000001 ffffffff802a0de5 0000000000000009 ffff81022f726080
May 15 05:34:18 vault1 kernel:  ffff810136be9080 00000000000302d3 ffff81022f726288 000000022f7267f0
May 15 05:34:18 vault1 kernel: Call Trace:
May 15 05:34:18 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:18 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:18 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:34:18 vault1 kernel:  [<ffffffff8024e63b>] d_find_alias+0x3a/0x42
May 15 05:34:18 vault1 kernel:  [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:18 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:34:18 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:34:18 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:18 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:18 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:34:18 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:18 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:34:18 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:34:18 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:34:18 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:18 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:18 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:18 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:34:18 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:34:18 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:34:18 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:34:18 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:34:18 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:34:18 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:34:18 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:34:18 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:18 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:18 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:18 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:18 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:34:18 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:18 vault1 kernel: 
May 15 05:34:19 vault1 kernel: nfsd          D ffff810230f85a98     0  4062      1 (L-TLB)
May 15 05:34:19 vault1 kernel:  ffff81022f42ba60 0000000000000046 000000000000052b ffff81022f5760c0
May 15 05:34:19 vault1 kernel:  0000000000000001 ffffffff802a0de5 000000000000000a ffff81022f5760c0
May 15 05:34:19 vault1 kernel:  ffff81022f1930c0 0000000000022d38 ffff81022f5762c8 000000002f576830
May 15 05:34:19 vault1 kernel: Call Trace:
May 15 05:34:19 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:19 vault1 kernel:  [<ffffffff80262019>] __mutex_lock_slowpath+0x13b/0x25b
May 15 05:34:19 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:19 vault1 kernel:  [<ffffffff80262019>] __mutex_lock_slowpath+0x13b/0x25b
May 15 05:34:19 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:34:19 vault1 kernel:  [<ffffffff8024e63b>] d_find_alias+0x3a/0x42
May 15 05:34:19 vault1 kernel:  [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:19 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:34:19 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:34:19 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:19 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:19 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:34:19 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:19 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:34:19 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:34:19 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:34:19 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:19 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:19 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:19 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:34:19 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:34:19 vault1 kernel:  [<ffffffff883e29af>] :sunrpc:sunrpc_cache_lookup+0x30/0x131
May 15 05:34:19 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:34:19 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:34:19 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:34:19 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:34:19 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:34:19 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:34:19 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:19 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:19 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:19 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:19 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:34:19 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:19 vault1 kernel: 
May 15 05:34:19 vault1 kernel: nfsd          D ffff810230f85a98     0  4063      1 (L-TLB)
May 15 05:34:19 vault1 kernel:  ffff81022fb05a60 0000000000000046 0000000000000000 ffff81022f615040
May 15 05:34:19 vault1 kernel:  0000000000000001 ffffffff802a0de5 000000000000000a ffff81022f615040
May 15 05:34:19 vault1 kernel:  ffffffff8058a6e0 00000000001cf979 ffff81022f615248 000000002f6157b0
May 15 05:34:19 vault1 kernel: Call Trace:
May 15 05:34:19 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:19 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:19 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:34:19 vault1 kernel:  [<ffffffff8024e63b>] d_find_alias+0x3a/0x42
May 15 05:34:19 vault1 kernel:  [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:19 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:34:19 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:34:19 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:19 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:19 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:34:19 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:19 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:34:19 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:34:19 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:34:19 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:19 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:19 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:19 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:34:19 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:34:19 vault1 kernel:  [<ffffffff883e29af>] :sunrpc:sunrpc_cache_lookup+0x30/0x131
May 15 05:34:19 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:34:19 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:34:19 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:34:19 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:34:19 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:34:19 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:34:19 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:19 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:19 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:19 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:19 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:34:19 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:19 vault1 kernel: 
May 15 05:34:19 vault1 kernel: nfsd          D ffff810130b704b8     0  4064      1 (L-TLB)
May 15 05:34:19 vault1 kernel:  ffff81022f0c1a60 0000000000000046 0000000000000000 ffff81022fa2c080
May 15 05:34:19 vault1 kernel:  0000000000000001 ffffffff802a0de5 0000000000000009 ffff81022fa2c080
May 15 05:34:19 vault1 kernel:  ffff810230c4c0c0 000000000001d4dc ffff81022fa2c288 000000032fa2c7f0
May 15 05:34:19 vault1 kernel: Call Trace:
May 15 05:34:19 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:19 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:20 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:34:20 vault1 kernel:  [<ffffffff8024e63b>] d_find_alias+0x3a/0x42
May 15 05:34:20 vault1 kernel:  [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:20 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:34:20 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:34:20 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:20 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:20 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:34:20 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:20 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:34:20 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:34:20 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:34:20 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:20 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:20 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:20 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:34:20 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:34:20 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:34:20 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:34:20 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:34:20 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:34:20 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:34:20 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:34:20 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:20 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:20 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:20 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:20 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:34:20 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:20 vault1 kernel: 
May 15 05:34:20 vault1 kernel: nfsd          D ffff810230f85a98     0  4065      1 (L-TLB)
May 15 05:34:20 vault1 kernel:  ffff81022f19da60 0000000000000046 0000000000000000 ffff81022f1930c0
May 15 05:34:20 vault1 kernel:  0000000000000001 ffffffff802a0de5 000000000000000a ffff81022f1930c0
May 15 05:34:20 vault1 kernel:  ffffffff8058a6e0 0000000000018984 ffff81022f1932c8 000000002f193830
May 15 05:34:20 vault1 kernel: Call Trace:
May 15 05:34:20 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:20 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:20 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:34:20 vault1 kernel:  [<ffffffff8024e63b>] d_find_alias+0x3a/0x42
May 15 05:34:20 vault1 kernel:  [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:20 vault1 kernel:  [<ffffffff80222443>] generic_file_aio_write+0x0/0xc1
May 15 05:34:20 vault1 kernel:  [<ffffffff802d38c7>] do_sync_readv_writev+0xc0/0x107
May 15 05:34:20 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:20 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:20 vault1 kernel:  [<ffffffff8020c870>] cache_alloc_debugcheck_after+0xef/0x139
May 15 05:34:20 vault1 kernel:  [<ffffffff802d3776>] rw_copy_check_uvector+0x4b/0xdc
May 15 05:34:20 vault1 kernel:  [<ffffffff802cf576>] __kmalloc+0x131/0x13d
May 15 05:34:20 vault1 kernel:  [<ffffffff802d3797>] rw_copy_check_uvector+0x6c/0xdc
May 15 05:34:20 vault1 kernel:  [<ffffffff802d3d38>] do_readv_writev+0xd7/0x1ae
May 15 05:34:20 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:20 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:20 vault1 kernel:  [<ffffffff8022400d>] file_move+0x1d/0x49
May 15 05:34:20 vault1 kernel:  [<ffffffff88425c8d>] :nfsd:nfsd_vfs_write+0xe9/0x2dd
May 15 05:34:20 vault1 kernel:  [<ffffffff8021f168>] __dentry_open+0x104/0x1b0
May 15 05:34:20 vault1 kernel:  [<ffffffff883e29af>] :sunrpc:sunrpc_cache_lookup+0x30/0x131
May 15 05:34:20 vault1 kernel:  [<ffffffff88426305>] :nfsd:nfsd_open+0x13c/0x16f
May 15 05:34:20 vault1 kernel:  [<ffffffff8842653b>] :nfsd:nfsd_write+0xc5/0xe2
May 15 05:34:20 vault1 kernel:  [<ffffffff8842d611>] :nfsd:nfsd3_proc_write+0xfb/0x11a
May 15 05:34:20 vault1 kernel:  [<ffffffff88422244>] :nfsd:nfsd_dispatch+0xdd/0x19e
May 15 05:34:20 vault1 kernel:  [<ffffffff883db353>] :sunrpc:svc_process+0x3ea/0x6f3
May 15 05:34:20 vault1 kernel:  [<ffffffff884227fe>] :nfsd:nfsd+0x194/0x2b2
May 15 05:34:20 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:20 vault1 kernel:  [<ffffffff8025cfa8>] child_rip+0xa/0x12
May 15 05:34:20 vault1 kernel:  [<ffffffff8025c6bc>] restore_args+0x0/0x30
May 15 05:34:20 vault1 kernel:  [<ffffffff8842266a>] :nfsd:nfsd+0x0/0x2b2
May 15 05:34:20 vault1 kernel:  [<ffffffff8025cf9e>] child_rip+0x0/0x12
May 15 05:34:20 vault1 kernel: 
May 15 05:34:20 vault1 kernel: rpc.mountd    S ffff81012f0ba9d8     0  4068      1 (NOTLB)
May 15 05:34:20 vault1 kernel:  ffff810124c41a18 0000000000000046 0000000000000000 ffffffff802a0de5
May 15 05:34:20 vault1 kernel:  0000000180248a3b 0000000000000002 0000000000000009 ffff81012efa30c0
May 15 05:34:20 vault1 kernel:  ffff810136b92040 000000000001006a ffff81012efa32c8 0000000100000000
May 15 05:34:20 vault1 kernel: Call Trace:
May 15 05:34:20 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:20 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:20 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:20 vault1 kernel:  [<ffffffff80213f07>] tcp_poll+0x1f/0x133
May 15 05:34:20 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:34:20 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:20 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:20 vault1 last message repeated 4 times
May 15 05:34:20 vault1 kernel:  [<ffffffff8020b406>] kfree+0x1a8/0x274
May 15 05:34:21 vault1 kernel:  [<ffffffff8020b4c4>] kfree+0x266/0x274
May 15 05:34:21 vault1 kernel:  [<ffffffff8020b4c4>] kfree+0x266/0x274
May 15 05:34:21 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:21 vault1 kernel:  [<ffffffff883e158b>] :sunrpc:cache_clean+0x12/0x208
May 15 05:34:21 vault1 kernel:  [<ffffffff8020b4c4>] kfree+0x266/0x274
May 15 05:34:21 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:21 vault1 kernel:  [<ffffffff8020b4c4>] kfree+0x266/0x274
May 15 05:34:21 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:21 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:34:21 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:21 vault1 kernel:  [<ffffffff883e2363>] :sunrpc:cache_write+0x45/0xc0
May 15 05:34:21 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:21 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:21 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:21 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:21 vault1 kernel:  [<ffffffff80216aff>] sys_select+0xc1/0x183
May 15 05:34:21 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:21 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:21 vault1 kernel: 
May 15 05:34:21 vault1 kernel: cat           D ffff810230e45678     0  4862   3945 (NOTLB)
May 15 05:34:21 vault1 kernel:  ffff810124e75bd8 0000000000000046 0000000000000000 0000000000000046
May 15 05:34:21 vault1 kernel:  ffffffff80258fc6 ffff810125693040 0000000000000007 ffff810125693040
May 15 05:34:21 vault1 kernel:  ffff810136b92040 0000000000075674 ffff810125693248 000000018029fe09
May 15 05:34:21 vault1 kernel: Call Trace:
May 15 05:34:21 vault1 kernel:  [<ffffffff80258fc6>] generic_unplug_device+0x18/0x25
May 15 05:34:21 vault1 kernel:  [<ffffffff80263894>] _spin_unlock_irq+0x24/0x27
May 15 05:34:21 vault1 kernel:  [<ffffffff80229a50>] sync_page+0x0/0x45
May 15 05:34:21 vault1 kernel:  [<ffffffff802616cf>] io_schedule+0x3f/0x67
May 15 05:34:21 vault1 kernel:  [<ffffffff80229a91>] sync_page+0x41/0x45
May 15 05:34:21 vault1 kernel:  [<ffffffff80261813>] __wait_on_bit_lock+0x36/0x66
May 15 05:34:21 vault1 kernel:  [<ffffffff80240387>] __lock_page+0x5e/0x64
May 15 05:34:21 vault1 kernel:  [<ffffffff8029a120>] wake_bit_function+0x0/0x23
May 15 05:34:21 vault1 kernel:  [<ffffffff8020c43e>] do_generic_mapping_read+0x1d9/0x40b
May 15 05:34:21 vault1 kernel:  [<ffffffff8020d21f>] file_read_actor+0x0/0x18a
May 15 05:34:21 vault1 kernel:  [<ffffffff8021713c>] generic_file_aio_read+0x15e/0x1a0
May 15 05:34:21 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:21 vault1 kernel:  [<ffffffff8020cf53>] do_sync_read+0xc9/0x10c
May 15 05:34:21 vault1 kernel:  [<ffffffff8029a0f2>] autoremove_wake_function+0x0/0x2e
May 15 05:34:21 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:21 vault1 kernel:  [<ffffffff8020b59d>] vfs_read+0xcb/0x173
May 15 05:34:21 vault1 kernel:  [<ffffffff8020b86d>] fget_light+0x19/0x7b
May 15 05:34:21 vault1 kernel:  [<ffffffff80211fc7>] sys_read+0x45/0x6e
May 15 05:34:21 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:21 vault1 kernel: 
May 15 05:34:21 vault1 kernel: mkdir         D ffff81012e41c118     0  4864   3945 (NOTLB)
May 15 05:34:21 vault1 kernel:  ffff81016c38da18 0000000000000046 0000000000000000 ffff8101716db0c0
May 15 05:34:21 vault1 kernel:  ffff8101716db908 ffffffff802a0de5 0000000000000007 ffff8101716db0c0
May 15 05:34:21 vault1 kernel:  ffff810136b92040 000000000000b5af ffff8101716db2c8 00000001716db910
May 15 05:34:21 vault1 kernel: Call Trace:
May 15 05:34:21 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:21 vault1 kernel:  [<ffffffff8029fc0f>] mark_held_locks+0x4a/0x6c
May 15 05:34:21 vault1 kernel:  [<ffffffff80262021>] __mutex_lock_slowpath+0x143/0x25b
May 15 05:34:21 vault1 kernel:  [<ffffffff88335bd6>] :jfs:release_metapage+0x15b/0x167
May 15 05:34:21 vault1 kernel:  [<ffffffff8833824a>] :jfs:lmLog+0x2f/0x16a
May 15 05:34:21 vault1 kernel:  [<ffffffff883397fc>] :jfs:txCommit+0x35e/0xef2
May 15 05:34:21 vault1 kernel:  [<ffffffff802078c3>] kmem_cache_free+0x257/0x267
May 15 05:34:21 vault1 kernel:  [<ffffffff8832a524>] :jfs:diAllocAG+0x34e/0x9eb
May 15 05:34:21 vault1 kernel:  [<ffffffff8026212e>] __mutex_lock_slowpath+0x250/0x25b
May 15 05:34:21 vault1 kernel:  [<ffffffff8832b4c0>] :jfs:diAlloc+0x5d4/0x728
May 15 05:34:21 vault1 kernel:  [<ffffffff88335028>] :jfs:ialloc+0x59/0x2a1
May 15 05:34:21 vault1 kernel:  [<ffffffff88324138>] :jfs:jfs_mkdir+0x55/0x336
May 15 05:34:21 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:21 vault1 kernel:  [<ffffffff802237ca>] d_alloc+0x170/0x1b8
May 15 05:34:21 vault1 kernel:  [<ffffffff80223807>] d_alloc+0x1ad/0x1b8
May 15 05:34:21 vault1 kernel:  [<ffffffff80223807>] d_alloc+0x1ad/0x1b8
May 15 05:34:21 vault1 kernel:  [<ffffffff802d74ed>] vfs_mkdir+0xdb/0x14b
May 15 05:34:21 vault1 kernel:  [<ffffffff802d79b1>] sys_mkdirat+0x97/0xd8
May 15 05:34:21 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:21 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:21 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:21 vault1 kernel: 
May 15 05:34:21 vault1 kernel: sshd          S ffff810230ceedf8     0  4865   3553 (NOTLB)
May 15 05:34:21 vault1 kernel:  ffff810159291a18 0000000000000046 0000000000000000 0000000000000046
May 15 05:34:21 vault1 kernel:  ffffffff8022edfd 0000000000000046 000000000000000a ffff810158cdf040
May 15 05:34:21 vault1 kernel:  ffff810056f10040 000000000000d67f ffff810158cdf248 0000000158cdf040
May 15 05:34:21 vault1 kernel: Call Trace:
May 15 05:34:21 vault1 kernel:  [<ffffffff8022edfd>] __wake_up+0x22/0x4e
May 15 05:34:21 vault1 kernel:  [<ffffffff8023a80a>] tty_ldisc_deref+0x62/0x75
May 15 05:34:21 vault1 kernel:  [<ffffffff802638fc>] _spin_unlock_irqrestore+0x3e/0x44
May 15 05:34:21 vault1 kernel:  [<ffffffff80261724>] schedule_timeout+0x1e/0xad
May 15 05:34:21 vault1 kernel:  [<ffffffff80226c98>] tty_poll+0x5f/0x6d
May 15 05:34:21 vault1 kernel:  [<ffffffff80211e12>] do_select+0x3fe/0x462
May 15 05:34:21 vault1 kernel:  [<ffffffff8021f267>] __pollwait+0x0/0xe1
May 15 05:34:21 vault1 kernel:  [<ffffffff80287a44>] default_wake_function+0x0/0xe
May 15 05:34:21 vault1 last message repeated 3 times
May 15 05:34:21 vault1 kernel:  [<ffffffff802313cd>] release_sock+0x2f/0xd6
May 15 05:34:21 vault1 kernel:  [<ffffffff8028de66>] local_bh_enable_ip+0xe4/0xea
May 15 05:34:21 vault1 kernel:  [<ffffffff8029fe09>] trace_hardirqs_on+0x124/0x14f
May 15 05:34:21 vault1 kernel:  [<ffffffff80227651>] tcp_sendmsg+0x9ab/0xab5
May 15 05:34:21 vault1 kernel:  [<ffffffff80227651>] tcp_sendmsg+0x9ab/0xab5
May 15 05:34:21 vault1 kernel:  [<ffffffff8024671c>] sock_aio_write+0x110/0x128
May 15 05:34:21 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:21 vault1 kernel:  [<ffffffff802d81fe>] core_sys_select+0x1bb/0x264
May 15 05:34:21 vault1 kernel:  [<ffffffff80218507>] do_sync_write+0xc9/0x10c
May 15 05:34:21 vault1 kernel:  [<ffffffff802a0de5>] __lock_acquire+0xb4a/0xbdf
May 15 05:34:21 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:21 vault1 kernel:  [<ffffffff8020cc19>] dnotify_parent+0x1f/0x6d
May 15 05:34:21 vault1 kernel:  [<ffffffff80216aff>] sys_select+0xc1/0x183
May 15 05:34:21 vault1 kernel:  [<ffffffff80263178>] trace_hardirqs_on_thunk+0x35/0x37
May 15 05:34:21 vault1 kernel:  [<ffffffff8025c11e>] system_call+0x7e/0x83
May 15 05:34:22 vault1 kernel: 
May 15 05:34:22 vault1 kernel: 
May 15 05:34:22 vault1 kernel: Showing all locks held in the system:
May 15 05:34:22 vault1 kernel: 2 locks held by pdflush/299:
May 15 05:34:22 vault1 kernel:  #0:  (&type->s_umount_key#20){----}, at: [<ffffffff8024f2e2>] writeback_inodes+0x73/0xee
May 15 05:34:22 vault1 kernel:  #1:  (&jfs_ip->rdwrlock#2){----}, at: [<ffffffff8832253a>] jfs_get_block+0x45/0x237 [jfs]
May 15 05:34:22 vault1 kernel: 1 lock held by syslogd/3374:
May 15 05:34:22 vault1 kernel:  #0:  (&inode->i_mutex){--..}, at: [<ffffffff8024e516>] do_fsync+0x41/0xa4
May 15 05:34:22 vault1 kernel: 1 lock held by mingetty/3879:
May 15 05:34:22 vault1 kernel:  #0:  (&tty->atomic_read_lock){--..}, at: [<ffffffff8022a64c>] read_chan+0x201/0x609
May 15 05:34:22 vault1 kernel: 1 lock held by mingetty/3880:
May 15 05:34:22 vault1 kernel:  #0:  (&tty->atomic_read_lock){--..}, at: [<ffffffff8022a64c>] read_chan+0x201/0x609
May 15 05:34:22 vault1 kernel: 1 lock held by mingetty/3881:
May 15 05:34:22 vault1 kernel:  #0:  (&tty->atomic_read_lock){--..}, at: [<ffffffff8022a64c>] read_chan+0x201/0x609
May 15 05:34:22 vault1 kernel: 1 lock held by mingetty/3882:
May 15 05:34:22 vault1 kernel:  #0:  (&tty->atomic_read_lock){--..}, at: [<ffffffff8022a64c>] read_chan+0x201/0x609
May 15 05:34:22 vault1 kernel: 1 lock held by mingetty/3883:
May 15 05:34:22 vault1 kernel:  #0:  (&tty->atomic_read_lock){--..}, at: [<ffffffff8022a64c>] read_chan+0x201/0x609
May 15 05:34:22 vault1 kernel: 1 lock held by mingetty/3884:
May 15 05:34:22 vault1 kernel:  #0:  (&tty->atomic_read_lock){--..}, at: [<ffffffff8022a64c>] read_chan+0x201/0x609
May 15 05:34:22 vault1 kernel: 5 locks held by nfsd/4058:
May 15 05:34:22 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:34:22 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:22 vault1 kernel:  #2:  (&jfs_ip->rdwrlock#2){----}, at: [<ffffffff8832253a>] jfs_get_block+0x45/0x237 [jfs]
May 15 05:34:22 vault1 kernel:  #3:  (&jfs_ip->commit_mutex){--..}, at: [<ffffffff88322126>] jfs_commit_inode+0x5c/0xf5 [jfs]
May 15 05:34:22 vault1 kernel:  #4:  (&(log)->loglock){--..}, at: [<ffffffff8833824a>] lmLog+0x2f/0x16a [jfs]
May 15 05:34:22 vault1 kernel: 4 locks held by nfsd/4059:
May 15 05:34:22 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:34:22 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:22 vault1 kernel:  #2:  (&jfs_ip->rdwrlock#2){----}, at: [<ffffffff8832253a>] jfs_get_block+0x45/0x237 [jfs]
May 15 05:34:22 vault1 kernel:  #3:  (&jfs_ip->commit_mutex){--..}, at: [<ffffffff88322126>] jfs_commit_inode+0x5c/0xf5 [jfs]
May 15 05:34:22 vault1 kernel: 2 locks held by nfsd/4060:
May 15 05:34:22 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:34:22 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:22 vault1 kernel: 2 locks held by nfsd/4061:
May 15 05:34:22 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:34:22 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:22 vault1 kernel: 2 locks held by nfsd/4062:
May 15 05:34:22 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:34:22 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:22 vault1 kernel: 2 locks held by nfsd/4063:
May 15 05:34:22 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:34:22 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:22 vault1 kernel: 2 locks held by nfsd/4064:
May 15 05:34:22 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:34:22 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:22 vault1 kernel: 2 locks held by nfsd/4065:
May 15 05:34:22 vault1 kernel:  #0:  (hash_sem){----}, at: [<ffffffff884227e7>] nfsd+0x17d/0x2b2 [nfsd]
May 15 05:34:22 vault1 kernel:  #1:  (&inode->i_mutex){--..}, at: [<ffffffff8022248f>] generic_file_aio_write+0x4c/0xc1
May 15 05:34:22 vault1 kernel: 6 locks held by mkdir/4864:
May 15 05:34:22 vault1 kernel:  #0:  (&inode->i_mutex/1){--..}, at: [<ffffffff80255f09>] lookup_create+0x23/0x84
May 15 05:34:22 vault1 kernel:  #1:  (&(imap->im_aglock[index])){--..}, at: [<ffffffff8832afd8>] diAlloc+0xec/0x728 [jfs]
May 15 05:34:22 vault1 kernel:  #2:  (&imap->im_freelock){--..}, at: [<ffffffff8832a295>] diAllocAG+0xbf/0x9eb [jfs]
May 15 05:34:22 vault1 kernel:  #3:  (&jfs_ip->rdwrlock/1){----}, at: [<ffffffff8832a2ca>] diAllocAG+0xf4/0x9eb [jfs]
May 15 05:34:22 vault1 kernel:  #4:  (&jfs_ip->commit_mutex){--..}, at: [<ffffffff8832a3b8>] diAllocAG+0x1e2/0x9eb [jfs]
May 15 05:34:22 vault1 kernel:  #5:  (&(log)->loglock){--..}, at: [<ffffffff8833824a>] lmLog+0x2f/0x16a [jfs]
May 15 05:34:22 vault1 kernel: 2 locks held by bash/4867:
May 15 05:34:22 vault1 kernel:  #0:  (sysrq_key_table_lock){....}, at: [<ffffffff80395b2a>] __handle_sysrq+0x22/0x128
May 15 05:34:22 vault1 kernel:  #1:  (tasklist_lock){..-?}, at: [<ffffffff8029ebd4>] debug_show_all_locks+0x3e/0x152
May 15 05:34:22 vault1 kernel: 
May 15 05:34:22 vault1 kernel: =============================================
May 15 05:34:22 vault1 kernel: 

--------------020505010704090908050700
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------020505010704090908050700
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020505010704090908050700--
