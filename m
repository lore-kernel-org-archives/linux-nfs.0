From: devzero@web.de
Subject: Re: stale nfs file handle with exported loopback mounts
Date: Tue, 30 Oct 2007 21:05:56 +0100
Message-ID: <2056330190@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
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

> I recommend replacing subtree_check with no_subtree_check, but it
> shouldn't make an important difference in this case.

ok, i leave it as is.

> This should work with nfs-utils 1.1.0 or later.  With earlier releases
> you need to explicitly export the subordinate filesystems too.
> 

mhh - opensuse doesn`t have nfs-utils package, but it has nfs-client-1.1.0-8 which looks like they repackaged nfs-utils 1.1.0

> It is a little odd that the errors are inconsistent.

ok, but only a minor issue, if an issue at all, isn`t it ?

> Can you find any log messages from mountd in syslog?  What do they
> say?

yes, on the client i`m getting :

Jun  3 21:36:01 linux kernel: nfs_update_inode: inode number mismatch
Jun  3 21:36:01 linux kernel: expected (0:11/0x2), got (0:11/0x13881)
Jun  3 21:36:01 linux kernel: nfs_update_inode: inode number mismatch
Jun  3 21:36:01 linux kernel: expected (0:11/0x2), got (0:11/0x13881)
Jun  3 21:36:17 linux kernel: nfs_update_inode: inode number mismatch
Jun  3 21:36:17 linux kernel: expected (0:11/0x2), got (0:11/0x13881)
Jun  3 21:36:17 linux kernel: nfs_update_inode: inode number mismatch
Jun  3 21:36:17 linux kernel: expected (0:11/0x2), got (0:11/0x13881)
Jun  3 21:36:20 linux kernel: nfs_update_inode: inode number mismatch
Jun  3 21:36:20 linux kernel: expected (0:11/0x2), got (0:11/0x13881)
Jun  3 21:36:20 linux kernel: nfs_update_inode: inode number mismatch


no error message on the server:
Oct 26 10:09:31 opensuse103 mountd[4293]: authenticated unmount request from 10.0.0.40:1014 for /mnt (/mnt)
Oct 26 10:10:07 opensuse103 mountd[4293]: authenticated mount request from 10.0.0.40:612 for /mnt (/mnt)
Oct 26 10:10:43 opensuse103 mountd[4293]: authenticated unmount request from 10.0.0.40:623 for /mnt (/mnt)
Oct 26 10:10:52 opensuse103 mountd[4293]: authenticated mount request from 10.0.0.40:624 for /mnt (/mnt)

> Also what does
>    cat /proc/fs/nfsd/exports
> 
> on the server show.

opensuse103:~ # cat /proc/fs/nfsd/exports
# Version 1.1
# Path Client(Flags) # IPs
/mnt/iso1       *(ro,no_root_squash,sync,wdelay,crossmnt,uuid=2c49fef2:ba464293:9b2bf2b8:322ccbcb)
/mnt/iso3       *(ro,no_root_squash,sync,wdelay,crossmnt,uuid=27ae9c67:0b794b36:8b5e9e17:37b569eb)
/mnt    *(ro,no_root_squash,sync,wdelay,crossmnt,uuid=08164ee4:2db141eb:ac961701:49c74396)
/mnt/iso2       *(ro,no_root_squash,sync,wdelay,crossmnt,uuid=2aad6ea5:a05d4441:b94c48e6:e5d9981e)


> Finally, a tcpdump:
> 
>   tcpdump -s 0 -w /tmp/tcpdump port 2049
> 
> while you run the experiment might help.

ah - this seems to give a hint, but i don`t have a clue why the server (10.0.0.30) is telling the client (10.0.0.40) a "RPC Version mismatch".
I also tried  --no-nfs-version 4 for rpc.mountd (setting in /etc/sysconfig/nfs), but this didn`t make a difference.

here is the tcpdump output - i did 

- mount
- ls / ls -la / cd to subdirs

10:15:06.480542 IP 10.0.0.40.0 > 10.0.0.30.2049: 0 null
10:15:06.480572 IP 10.0.0.30.2049 > 10.0.0.40.0: reply ERR 0: RPC Version mismatch (167772160-0)
10:15:06.480765 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 2031114913 win 1460 <nop,nop,timestamp 686128 737918>
10:15:06.480821 IP 10.0.0.40.2079804678 > 10.0.0.30.2049: 108 fsinfo fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C743963CD81908
10:15:06.480833 IP 10.0.0.30.2049 > 10.0.0.40.1022: . ack 108 win 181 <nop,nop,timestamp 737918 686128>
10:15:06.513365 IP 10.0.0.30.2049 > 10.0.0.40.2079804678: reply ok 84 fsinfo rtmax 65536 rtpref 65536 wtmax 65536 wtpref 65536 dtpref 4096
10:15:06.514408 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 85 win 1460 <nop,nop,timestamp 686160 737926>
10:15:06.514902 IP 10.0.0.40.2096581894 > 10.0.0.30.2049: 108 getattr fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C743963CD81908
10:15:06.515256 IP 10.0.0.30.2049 > 10.0.0.40.2096581894: reply ok 116 getattr DIR 40755 ids 0/0 sz 4096
10:15:06.553865 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 201 win 1460 <nop,nop,timestamp 686201 737926>
10:16:03.091784 IP 10.0.0.40.2113359110 > 10.0.0.30.2049: 108 getattr fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439647219C8C
10:16:03.093366 IP 10.0.0.30.2049 > 10.0.0.40.2113359110: reply ok 116 getattr DIR 40755 ids 0/0 sz 4096
10:16:03.096046 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 317 win 1460 <nop,nop,timestamp 743610 752071>
10:16:03.097370 IP 10.0.0.40.2130136326 > 10.0.0.30.2049: 112 access fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C743960000001F 001f
10:16:03.098156 IP 10.0.0.30.2049 > 10.0.0.40.2130136326: reply ok 124 access c 0003
10:16:03.156812 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 441 win 1460 <nop,nop,timestamp 743651 752072>
10:16:08.967804 IP 10.0.0.40.2146913542 > 10.0.0.30.2049: 108 getattr fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439600000000
10:16:08.968305 IP 10.0.0.30.2049 > 10.0.0.40.2146913542: reply ok 116 getattr DIR 40755 ids 0/0 sz 4096
10:16:08.974285 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 557 win 1460 <nop,nop,timestamp 749477 753540>
10:16:08.975739 IP 10.0.0.40.2163690758 > 10.0.0.30.2049: 132 readdirplus fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439600000000 512 bytes @ 0
10:16:08.975985 IP 10.0.0.30.2049 > 10.0.0.40.2163690758: reply ok 1448 readdirplus
10:16:08.976510 IP 10.0.0.30.2049 > 10.0.0.40.1684108288: reply Unknown rpc response code=2021855861 340
10:16:08.982238 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 2345 win 2184 <nop,nop,timestamp 749479 753541>
10:16:08.984415 IP 10.0.0.40.2180467974 > 10.0.0.30.2049: 116 lookup fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439600000004 "iso3"
10:16:08.984931 IP 10.0.0.30.2049 > 10.0.0.40.2180467974: reply ok 232 lookup fh Unknown/0100060027AE9C670B794B368B5E9E1737B569EB0000000100000002000041ED
10:16:09.008819 IP 10.0.0.40.2197245190 > 10.0.0.30.2049: 104 getattr fh Unknown/0100060027AE9C670B794B368B5E9E1737B569EB0000000FDD22CC3C7002F0AC
10:16:09.010946 IP 10.0.0.30.2049 > 10.0.0.40.2197245190: reply ok 188 getattr REG 2 ids 5/0 sz 0
10:16:09.032541 IP 10.0.0.40.2214022406 > 10.0.0.30.2049: 128 getattr fh Unknown/01000702813801000000000008164EE42DB141EBAC96170149C74396E66D0700
10:16:09.033405 IP 10.0.0.30.2049 > 10.0.0.40.2214022406: reply ok 188 getattr REG 1 ids 1/0 sz 0
10:16:09.033490 IP 10.0.0.40.2230799622 > 10.0.0.30.2049: 128 getattr fh Unknown/01000702813801000000000008164EE42DB141EBAC96170149C74396E56D0700
10:16:09.036811 IP 10.0.0.30.2049 > 10.0.0.40.2230799622: reply ok 188 getattr REG 1 ids 1/0 sz 0
10:16:09.037823 IP 10.0.0.40.2247576838 > 10.0.0.30.2049: 108 getattr fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439600000000
10:16:09.039817 IP 10.0.0.30.2049 > 10.0.0.40.2247576838: reply ok 116 getattr DIR 40755 ids 0/0 sz 4096
10:16:09.040423 IP 10.0.0.40.2264354054 > 10.0.0.30.2049: 112 getattr fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C743960000000F
10:16:09.040856 IP 10.0.0.30.2049 > 10.0.0.40.2264354054: reply ok 188 getattr REG 2 ids 5/0 sz 0
10:16:09.041590 IP 10.0.0.40.2281131270 > 10.0.0.30.2049: 116 lookup fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439600000004 "iso2"
10:16:09.041920 IP 10.0.0.30.2049 > 10.0.0.40.2281131270: reply ok 232 lookup fh Unknown/010006002AAD6EA5A05D4441B94C48E6E5D9981E0000000100000002000041ED
10:16:09.049633 IP 10.0.0.40.2297908486 > 10.0.0.30.2049: 104 getattr fh Unknown/010006002AAD6EA5A05D4441B94C48E6E5D9981E0000000F5FDC84454326E193
10:16:09.049781 IP 10.0.0.30.2049 > 10.0.0.40.2297908486: reply ok 188 getattr REG 2 ids 5/0 sz 0
10:16:09.063218 IP 10.0.0.40.2314685702 > 10.0.0.30.2049: 128 getattr fh Unknown/01000702813801000000000008164EE42DB141EBAC96170149C74396E46D0700
10:16:09.072505 IP 10.0.0.30.2049 > 10.0.0.40.2314685702: reply ok 188 getattr REG 1 ids 1/0 sz 0
10:16:09.091698 IP 10.0.0.40.2331462918 > 10.0.0.30.2049: 124 getattr fh Unknown/01000702813801000000000008164EE42DB141EBAC96170149C74396E46D0700
10:16:09.092022 IP 10.0.0.30.2049 > 10.0.0.40.2331462918: reply ok 116 getattr REG 100644 ids 0/0 sz 1048576
10:16:09.128971 IP 10.0.0.40.2348240134 > 10.0.0.30.2049: 128 getattr fh Unknown/01000702813801000000000008164EE42DB141EBAC96170149C74396E36D0700
10:16:09.129304 IP 10.0.0.30.2049 > 10.0.0.40.2348240134: reply ok 188 getattr REG 1 ids 1/0 sz 0
10:16:09.184155 IP 10.0.0.40.2365017350 > 10.0.0.30.2049: 124 getattr fh Unknown/01000702813801000000000008164EE42DB141EBAC96170149C74396E36D0700
10:16:09.184582 IP 10.0.0.30.2049 > 10.0.0.40.2365017350: reply ok 116 getattr REG 100644 ids 0/0 sz 1048576
10:16:09.189234 IP 10.0.0.40.2381794566 > 10.0.0.30.2049: 116 lookup fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439600000004 "iso1"
10:16:09.189435 IP 10.0.0.30.2049 > 10.0.0.40.2381794566: reply ok 232 lookup fh Unknown/010006002C49FEF2BA4642939B2BF2B8322CCBCB0000000100000002000041ED
10:16:09.193476 IP 10.0.0.40.2398571782 > 10.0.0.30.2049: 104 getattr fh Unknown/010006002C49FEF2BA4642939B2BF2B8322CCBCB0000000F58896A884A0C62B7
10:16:09.193652 IP 10.0.0.30.2049 > 10.0.0.40.2398571782: reply ok 188 getattr REG 2 ids 5/0 sz 0
10:16:09.194937 IP 10.0.0.40.2415348998 > 10.0.0.30.2049: 128 getattr fh Unknown/01000702813801000000000008164EE42DB141EBAC96170149C74396E76D0700
10:16:09.195033 IP 10.0.0.30.2049 > 10.0.0.40.2415348998: reply ok 188 getattr REG 1 ids 1/0 sz 0
10:16:09.195230 IP 10.0.0.40.2432126214 > 10.0.0.30.2049: 128 getattr fh Unknown/01000702813801000000000008164EE42DB141EBAC96170149C74396E86D0700
10:16:09.323635 IP 10.0.0.30.2049 > 10.0.0.40.1022: . ack 2572 win 416 <nop,nop,timestamp 753629 749566>
10:16:09.324345 IP 10.0.0.30.2049 > 10.0.0.40.2432126214: reply ok 188 getattr REG 1 ids 1/0 sz 0
10:16:09.341475 IP 10.0.0.40.2448903430 > 10.0.0.30.2049: 128 getattr fh Unknown/01000702813801000000000008164EE42DB141EBAC96170149C74396E26D0700
10:16:09.341524 IP 10.0.0.30.2049 > 10.0.0.40.1022: . ack 2700 win 449 <nop,nop,timestamp 753632 749707>
10:16:09.341928 IP 10.0.0.30.2049 > 10.0.0.40.2448903430: reply ok 188 getattr REG 1 ids 1/0 sz 0
10:16:09.342117 IP 10.0.0.40.2465680646 > 10.0.0.30.2049: 124 getattr fh Unknown/01000702813801000000000008164EE42DB141EBAC96170149C74396E26D0700
10:16:09.343404 IP 10.0.0.30.2049 > 10.0.0.40.2465680646: reply ok 116 getattr REG 100644 ids 0/0 sz 1048576
10:16:09.389316 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 5573 win 2184 <nop,nop,timestamp 749751 753633>
10:16:13.449513 IP 10.0.0.40.2482457862 > 10.0.0.30.2049: 108 getattr fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439647219CB5
10:16:13.449815 IP 10.0.0.30.2049 > 10.0.0.40.2482457862: reply ok 116 getattr DIR 40755 ids 0/0 sz 4096
10:16:13.452344 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 5689 win 2184 <nop,nop,timestamp 753943 754660>
10:16:13.453973 IP 10.0.0.40.2499235078 > 10.0.0.30.2049: 100 getattr fh Unknown/010006002C49FEF2BA4642939B2BF2B8322CCBCB47219C8C0000000047219C8C
10:16:13.454154 IP 10.0.0.30.2049 > 10.0.0.40.2499235078: reply ok 116 getattr DIR 40755 ids 0/0 sz 4096
10:16:13.456194 IP 10.0.0.40.2516012294 > 10.0.0.30.2049: 108 getattr fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439647219C8C
10:16:13.456361 IP 10.0.0.30.2049 > 10.0.0.40.2516012294: reply ok 116 getattr DIR 40755 ids 0/0 sz 4096
10:16:13.458282 IP 10.0.0.40.2532789510 > 10.0.0.30.2049: 116 lookup fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439600000004 "iso1"
10:16:13.458461 IP 10.0.0.30.2049 > 10.0.0.40.2532789510: reply ok 232 lookup fh Unknown/010006002C49FEF2BA4642939B2BF2B8322CCBCB0000000100000002000041ED
10:16:13.510637 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 6153 win 2184 <nop,nop,timestamp 753985 754662>
10:16:14.030110 IP 10.0.0.40.2549566726 > 10.0.0.30.2049: 112 access fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C743960000001F 001f
10:16:14.030927 IP 10.0.0.30.2049 > 10.0.0.40.2549566726: reply ok 124 access c 0003
10:16:14.033436 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 6277 win 2184 <nop,nop,timestamp 754548 754805>
10:16:14.034732 IP 10.0.0.40.2566343942 > 10.0.0.30.2049: 108 getattr fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439600000000
10:16:14.034980 IP 10.0.0.30.2049 > 10.0.0.40.2566343942: reply ok 116 getattr DIR 40755 ids 0/0 sz 4096
10:16:14.037319 IP 10.0.0.40.2583121158 > 10.0.0.30.2049: 112 access fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C743960000001F 001f
10:16:14.037486 IP 10.0.0.30.2049 > 10.0.0.40.2583121158: reply ok 124 access c 0003
10:16:14.040323 IP 10.0.0.40.2599898374 > 10.0.0.30.2049: 132 readdirplus fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439600000000 512 bytes @ 0
10:16:14.040554 IP 10.0.0.30.2049 > 10.0.0.40.2599898374: reply ok 1448 readdirplus
10:16:14.041020 IP 10.0.0.30.2049 > 10.0.0.40.1684108288: reply Unknown rpc response code=2021855861 340
10:16:14.043583 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 8305 win 2908 <nop,nop,timestamp 754550 754808>
10:16:14.045104 IP 10.0.0.40.2616675590 > 10.0.0.30.2049: 112 access fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C743960000001F 001f
10:16:14.045402 IP 10.0.0.30.2049 > 10.0.0.40.2616675590: reply ok 124 access c 0003
10:16:14.047830 IP 10.0.0.40.2633452806 > 10.0.0.30.2049: 112 access fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C743960000001F 001f
10:16:14.048039 IP 10.0.0.30.2049 > 10.0.0.40.2633452806: reply ok 124 access c 0003
10:16:14.099385 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 8553 win 2908 <nop,nop,timestamp 754592 754810>
10:16:14.293714 IP 10.0.0.40.2650230022 > 10.0.0.30.2049: 108 getattr fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C7439600000000
10:16:14.294019 IP 10.0.0.30.2049 > 10.0.0.40.2650230022: reply ok 116 getattr DIR 40755 ids 0/0 sz 4096
10:16:14.297263 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 8669 win 2908 <nop,nop,timestamp 754763 754871>
10:16:14.297272 IP 10.0.0.40.2667007238 > 10.0.0.30.2049: 112 access fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C743960000001F 001f
10:16:14.297466 IP 10.0.0.30.2049 > 10.0.0.40.2667007238: reply ok 124 access c 0003
10:16:14.297586 IP 10.0.0.40.2683784454 > 10.0.0.30.2049: 112 access fh Unknown/01000700813801000000000008164EE42DB141EBAC96170149C743960000001F 001f
10:16:14.297987 IP 10.0.0.30.2049 > 10.0.0.40.2683784454: reply ok 124 access c 0003
10:16:14.301165 IP 10.0.0.40.2700561670 > 10.0.0.30.2049: 104 access fh Unknown/010006002C49FEF2BA4642939B2BF2B8322CCBCB0000001F47219C8C00000000 001f
10:16:14.301405 IP 10.0.0.30.2049 > 10.0.0.40.2700561670: reply ok 124 access c 0003
10:16:14.351229 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 9041 win 2908 <nop,nop,timestamp 754810 754873>
10:16:14.842633 IP 10.0.0.40.2717338886 > 10.0.0.30.2049: 100 getattr fh Unknown/010006002C49FEF2BA4642939B2BF2B8322CCBCB0000000047219C8C00000000
10:16:14.851711 IP 10.0.0.30.2049 > 10.0.0.40.2717338886: reply ok 116 getattr DIR 40755 ids 0/0 sz 4096
10:16:14.856846 IP 10.0.0.40.1022 > 10.0.0.30.2049: . ack 9157 win 2908 <nop,nop,timestamp 755272 755008>


> > does somebody have such setup up and running and can tell his distro / kernel and nfs-utils version ?
> > maybe i change distro then.
> 
> I doubt that it is a distro-specific thing.  As long as you have
> nfs-utils-1.1.0 it should work.  I don't have a 10.3 box
> set up yet, but it works fine on Debian/unstable for me.

ok, will try this on debian.

> Maybe try adding the "no_root_squash" export option.
no difference

> What does "ls -l /export" on the server show?
nothing unusual. no errors, just the dirs/mountpoints

Thanks for your help!

regards
roland


> 
> On Saturday October 27, devzero@web.de wrote:
> > Hello !
> > 
> > with 2.6.22 i`m trying to export loopback mounted iso-images.
> > 
> > this is /etc/exports:
> > 
> > /export *(ro,crossmnt,subtree_check)
> 
> I recommend replacing subtree_check with no_subtree_check, but it
> shouldn't make an important difference in this case.
> 
> 
> This should work with nfs-utils 1.1.0 or later.  With earlier releases
> you need to explicitly export the subordinate filesystems too.
> 
> > 
> > in /export, i have loopback mounted iso-images
> > 
> > after mounting on the client side under /mnt (tried one older and one recent system) , i`m getting:
> > 
> > vmhost:/mnt # ls -la
> > /bin/ls: iso1: Input/output error
> > /bin/ls: iso2  Input/output error
> > /bin/ls: iso3: Input/output error
> > total 10128
> > drwxrwxrwt   18 root root  270336 Oct 26 08:45 .
> > drwxrwxrwt  186 root root   20760 Oct 27 17:45 ..
> > drwxr-xr-x    2 root root   16384 Jan  1  1970 iso1
> > drwxr-xr-x    2 root root   16384 Jan  1  1970 iso2
> > drwxr-xr-x    2 root root   16384 Jan  1  1970 iso3
> > 
> > vmhost:/mnt/iso1 # ls
> > /bin/ls: .: Stale NFS file handle
> > vmhost:/mnt/iso1 # ls -la
> > /bin/ls: .: Input/output error
> 
> It is a little odd that the errors are inconsistent.
> 
> Can you find any log messages from mountd in syslog?  What do they
> say?
> Also what does
>    cat /proc/fs/nfsd/exports
> 
> on the server show.
> 
> Finally, a tcpdump:
> 
>   tcpdump -s 0 -w /tmp/tcpdump port 2049
> 
> while you run the experiment might help.
> 
> > 
> > i`m unsure if i should blame suse here (it`s an opensuse 10.3 box which seems to have nfs-utils 1.1.0)
> > 
> > does somebody have such setup up and running and can tell his distro / kernel and nfs-utils version ?
> > maybe i change distro then.
> 
> I doubt that it is a distro-specific thing.  As long as you have
> nfs-utils-1.1.0 it should work.  I don't have a 10.3 box
> set up yet, but it works fine on Debian/unstable for me.
> 
> Maybe try adding the "no_root_squash" export option.
> What does "ls -l /export" on the server show?
> 
> NeilBrown
> 


_________________________________________________________________________
In 5 Schritten zur eigenen Homepage. Jetzt Domain sichern und gestalten! 
Nur 3,99 EUR/Monat! http://www.maildomain.web.de/?mc=021114


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
