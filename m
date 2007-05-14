From: Martin Knoblauch <spamtrap@knobisoft.de>
Subject: Re: Strange performance problems between Linux client and
	Sun/Solaris-10 Server with SAM-FS
Date: Mon, 14 May 2007 07:20:29 -0700 (PDT)
Message-ID: <295440.67356.qm@web32605.mail.mud.yahoo.com>
References: <758936.68723.qm@web32601.mail.mud.yahoo.com>
Reply-To: spamtrap@knobisoft.de
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-29170638-1179152429=:67356"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnbPq-0003OD-Ba
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 07:20:46 -0700
Received: from web32605.mail.mud.yahoo.com ([68.142.207.232])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HnbPq-0008CC-Pk
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 07:20:49 -0700
In-Reply-To: <758936.68723.qm@web32601.mail.mud.yahoo.com>
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

--0-29170638-1179152429=:67356
Content-Type: text/plain; charset=iso-8859-1
Content-Id: 
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

--- Martin Knoblauch <knobi@knobisoft.de> wrote:

> Hi,
>=20
>  we are fighting with a strange performance problem when accessing a
> Sun/Solaris-10 server from a Linux NFS client (HP DL380G4, x86_64,
> RHEL4U3 user-space, various kernels from  2.6.9-34.ELsmp up to
> 2.9.21.1).
>=20
>  The underlying FS on the Sun is SAM-FS (4.5.33) which provides HSM
> capabilities. The basic layout is that the "online cache" is
> relatively
> small on "high-speed" FC disks, while the offline data are stored on
> cheapish SATA disks and high-speed tapes.
>=20
>  The problem arises when accessing (reading) a file that is offline
> on
> the Sun. In this case the so-called "stager" brings it back to the
> online-cache first, while the client waits for the data to be
> available.
>=20
>  This works fine (staging speed up-to or larger  50 MB/sec) on:
>=20
> - administrative "stage" request
> - accessing the offline file on the Sun-Server itself
> - accessing the offline file from a Solaris-10 NFS client
>=20
>  When doing the same from the Linux Client performance drops below 10
> MB/sec. Network performance itself looks good when accessing the file
> "online".
>=20
>  One thing that looks different when doing tcpdump/snoop traces
> between
> the systems is that in the Linux/Solaris case the client seems to
> send
> more READ3 requests (factor > 3) that the Server acknowledges (both
> in
> the online and offline case). In the Solaris/Solaris case the number
> of
> requests and acknowledgements is about the same.
>=20
>  The remote filesystem is mounted NFS3/TCP with the following
> parameters:
>=20
> xxxx:/net/xxxx/fs03 on /net/xxxx/fs03 type nfs
>
(rw,hard,intr,bg,nfsvers=3D3,proto=3Dtcp,timeo=3D600,rsize=3D32768,wsize=3D=
32768,addr=3Dyy.yy.yy.yy)
>=20
>  We are already talking to the Sun people, but they cannot reproduce.
> So I put my hope for some insight on this list.
>=20
> Cheers
> Martin
> PS: Please CC me on replies, as I am only getting the digest
>=20
>=20
> ------------------------------------------------------
> Martin Knoblauch
> email: k n o b i AT knobisoft DOT de
> www:   http://www.knobisoft.de
>=20
Hmm,

 not sure whether I should feel stupid. Inspecting the tcpdump log
(snippet attached), I see a lot of "reply ERR 1448" packets coming from
the Sun. Which of course could explain a few things.

 But - how to proceed from here? The error counters on both side of the
network are clean. On the Linux side we have BCM5704 NICs with the
"tg3" driver.

Cheers
Martin

------------------------------------------------------
Martin Knoblauch
email: k n o b i AT knobisoft DOT de
www:   http://www.knobisoft.de
--0-29170638-1179152429=:67356
Content-Type: text/plain; name="nfs3.err.txt"
Content-Description: 1538256531-nfs3.err.txt
Content-Disposition: inline; filename="nfs3.err.txt"

12:11:03.138304 IP (tos 0x0, ttl  64, id 53794, offset 0, flags [DF], proto: TCP (6), length: 168) 160.50.204.58.2430784801 > 160.50.118.37.2049: 116 access fh 4432,48722/2 001f
12:11:03.138814 IP (tos 0x0, ttl  61, id 42964, offset 0, flags [DF], proto: TCP (6), length: 176) 160.50.118.37.2049 > 160.50.204.58.2430784801: reply ok 124 access attr: DIR 755 ids 0/1 sz 4096 c 0003
12:11:03.138844 IP (tos 0x0, ttl  64, id 53795, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0xd050 (correct), ack 707676671 win 250 <nop,nop,timestamp 1096055 40958631>
12:11:03.138892 IP (tos 0x0, ttl  64, id 53796, offset 0, flags [DF], proto: TCP (6), length: 176) 160.50.204.58.2447562017 > 160.50.118.37.2049: 124 lookup fh 4432,48722/2 "solver"
12:11:03.147317 IP (tos 0x0, ttl  61, id 42965, offset 0, flags [DF], proto: TCP (6), length: 296) 160.50.118.37.2049 > 160.50.204.58.2447562017: reply ok 244 lookup fh 4432,48722/1064 DIR 750 ids 35917/31235 sz 12288
12:11:03.147381 IP (tos 0x0, ttl  64, id 53797, offset 0, flags [DF], proto: TCP (6), length: 168) 160.50.204.58.2464339233 > 160.50.118.37.2049: 116 access fh 4432,48722/1064 001f
12:11:03.147858 IP (tos 0x0, ttl  61, id 42966, offset 0, flags [DF], proto: TCP (6), length: 176) 160.50.118.37.2049 > 160.50.204.58.2464339233: reply ok 124 access attr: DIR 750 ids 35917/31235 sz 12288 c 001f
12:11:03.147888 IP (tos 0x0, ttl  64, id 53798, offset 0, flags [DF], proto: TCP (6), length: 172) 160.50.204.58.2481116449 > 160.50.118.37.2049: 120 lookup fh 4432,48722/1064 "199"
12:11:03.148347 IP (tos 0x0, ttl  61, id 42967, offset 0, flags [DF], proto: TCP (6), length: 296) 160.50.118.37.2049 > 160.50.204.58.2481116449: reply ok 244 lookup fh 4432,48722/1611 DIR 750 ids 35917/31235 sz 8192
12:11:03.148375 IP (tos 0x0, ttl  64, id 53799, offset 0, flags [DF], proto: TCP (6), length: 168) 160.50.204.58.2497893665 > 160.50.118.37.2049: 116 access fh 4432,48722/1611 001f
12:11:03.148775 IP (tos 0x0, ttl  61, id 42968, offset 0, flags [DF], proto: TCP (6), length: 176) 160.50.118.37.2049 > 160.50.204.58.2497893665: reply ok 124 access attr: DIR 750 ids 35917/31235 sz 8192 c 001f
12:11:03.148804 IP (tos 0x0, ttl  64, id 53800, offset 0, flags [DF], proto: TCP (6), length: 172) 160.50.204.58.2514670881 > 160.50.118.37.2049: 120 lookup fh 4432,48722/1611 "181"
12:11:03.149253 IP (tos 0x0, ttl  61, id 42969, offset 0, flags [DF], proto: TCP (6), length: 296) 160.50.118.37.2049 > 160.50.204.58.2514670881: reply ok 244 lookup fh 4432,48722/429936 DIR 750 ids 35917/31235 sz 4096
12:11:03.149284 IP (tos 0x0, ttl  64, id 53801, offset 0, flags [DF], proto: TCP (6), length: 168) 160.50.204.58.2531448097 > 160.50.118.37.2049: 116 access fh 4432,48722/429936 001f
12:11:03.149711 IP (tos 0x0, ttl  61, id 42970, offset 0, flags [DF], proto: TCP (6), length: 176) 160.50.118.37.2049 > 160.50.204.58.2531448097: reply ok 124 access attr: DIR 750 ids 35917/31235 sz 4096 c 001f
12:11:03.149736 IP (tos 0x0, ttl  64, id 53802, offset 0, flags [DF], proto: TCP (6), length: 172) 160.50.204.58.2548225313 > 160.50.118.37.2049: 120 lookup fh 4432,48722/429936 "119"
12:11:03.150172 IP (tos 0x0, ttl  61, id 42971, offset 0, flags [DF], proto: TCP (6), length: 296) 160.50.118.37.2049 > 160.50.204.58.2548225313: reply ok 244 lookup fh 4432,48722/803367 DIR 750 ids 35917/31235 sz 4096
12:11:03.150198 IP (tos 0x0, ttl  64, id 53803, offset 0, flags [DF], proto: TCP (6), length: 168) 160.50.204.58.2565002529 > 160.50.118.37.2049: 116 access fh 4432,48722/803367 001f
12:11:03.150644 IP (tos 0x0, ttl  61, id 42972, offset 0, flags [DF], proto: TCP (6), length: 176) 160.50.118.37.2049 > 160.50.204.58.2565002529: reply ok 124 access attr: DIR 750 ids 35917/31235 sz 4096 c 001f
12:11:03.150672 IP (tos 0x0, ttl  64, id 53804, offset 0, flags [DF], proto: TCP (6), length: 188) 160.50.204.58.2581779745 > 160.50.118.37.2049: 136 lookup fh 4432,48722/803367 "29840699ResultData"
12:11:03.151095 IP (tos 0x0, ttl  61, id 42973, offset 0, flags [DF], proto: TCP (6), length: 296) 160.50.118.37.2049 > 160.50.204.58.2581779745: reply ok 244 lookup fh 4432,48722/325801 DIR 750 ids 35917/31235 sz 4096
12:11:03.151120 IP (tos 0x0, ttl  64, id 53805, offset 0, flags [DF], proto: TCP (6), length: 168) 160.50.204.58.2598556961 > 160.50.118.37.2049: 116 access fh 4432,48722/325801 001f
12:11:03.151548 IP (tos 0x0, ttl  61, id 42974, offset 0, flags [DF], proto: TCP (6), length: 176) 160.50.118.37.2049 > 160.50.204.58.2598556961: reply ok 124 access attr: DIR 750 ids 35917/31235 sz 4096 c 001f
12:11:03.151573 IP (tos 0x0, ttl  64, id 53806, offset 0, flags [DF], proto: TCP (6), length: 196) 160.50.204.58.2615334177 > 160.50.118.37.2049: 144 lookup fh 4432,48722/325801 "f02vbg4_si02v079_incl.odb"
12:11:03.152028 IP (tos 0x0, ttl  61, id 42975, offset 0, flags [DF], proto: TCP (6), length: 296) 160.50.118.37.2049 > 160.50.204.58.2615334177: reply ok 244 lookup fh 4432,48722/212221 REG 640 ids 35917/31235 sz 7842215416
12:11:03.152088 IP (tos 0x0, ttl  64, id 53807, offset 0, flags [DF], proto: TCP (6), length: 164) 160.50.204.58.2632111393 > 160.50.118.37.2049: 112 getattr fh 4432,48722/212221
12:11:03.152485 IP (tos 0x0, ttl  61, id 42976, offset 0, flags [DF], proto: TCP (6), length: 168) 160.50.118.37.2049 > 160.50.204.58.2632111393: reply ok 116 getattr REG 640 ids 35917/31235 sz 7842215416
12:11:03.152510 IP (tos 0x0, ttl  64, id 53808, offset 0, flags [DF], proto: TCP (6), length: 168) 160.50.204.58.2648888609 > 160.50.118.37.2049: 116 access fh 4432,48722/212221 002d
12:11:03.152918 IP (tos 0x0, ttl  61, id 42977, offset 0, flags [DF], proto: TCP (6), length: 176) 160.50.118.37.2049 > 160.50.204.58.2648888609: reply ok 124 access attr: REG 640 ids 35917/31235 sz 7842215416 c 000d
12:11:03.152994 IP (tos 0x0, ttl  64, id 53809, offset 0, flags [DF], proto: TCP (6), length: 176) 160.50.204.58.2665665825 > 160.50.118.37.2049: 124 read fh 4432,48722/212221 16384 bytes @ 0
12:11:03.200649 IP (tos 0x0, ttl  61, id 42978, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.2665665825: reply ok 1448 read REG 640 ids 35917/31235 sz 7842215416 16384 bytes
12:11:03.201001 IP (tos 0x0, ttl  61, id 42979, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.1087840768: reply ok 1448
12:11:03.201008 IP (tos 0x0, ttl  64, id 53810, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0xb3c2 (correct), ack 5221 win 632 <nop,nop,timestamp 1096061 40958637>
12:11:03.201038 IP (tos 0x0, ttl  61, id 42980, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.1084227584: reply ERR 1448
12:11:03.201069 IP (tos 0x0, ttl  61, id 42981, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.1082130432: reply ERR 1448
12:11:03.201073 IP (tos 0x0, ttl  64, id 53811, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0xa7bd (correct), ack 8117 win 813 <nop,nop,timestamp 1096061 40958637>
12:11:03.201107 IP (tos 0x0, ttl  61, id 42982, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ERR 1448
12:11:03.201156 IP (tos 0x0, ttl  61, id 42983, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.201160 IP (tos 0x0, ttl  64, id 53812, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x9bb8 (correct), ack 11013 win 994 <nop,nop,timestamp 1096061 40958637>
12:11:03.201201 IP (tos 0x0, ttl  61, id 42984, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.201321 IP (tos 0x0, ttl  61, id 42985, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.201325 IP (tos 0x0, ttl  64, id 53813, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x8fb3 (correct), ack 13909 win 1175 <nop,nop,timestamp 1096061 40958637>
12:11:03.201366 IP (tos 0x0, ttl  61, id 42986, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.1090741696: reply ok 1448
12:11:03.201442 IP (tos 0x0, ttl  61, id 42987, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.1076887552: reply ERR 1448
12:11:03.201446 IP (tos 0x0, ttl  64, id 53814, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x83ae (correct), ack 16805 win 1356 <nop,nop,timestamp 1096061 40958637>
12:11:03.201489 IP (tos 0x0, ttl  61, id 42988, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.1077411840: reply ERR 1448
12:11:03.201496 IP (tos 0x0, ttl  61, id 42989, offset 0, flags [DF], proto: TCP (6), length: 640) 160.50.118.37.2049 > 160.50.204.58.1: reply ok 588
12:11:03.201499 IP (tos 0x0, ttl  64, id 53815, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x7b05 (correct), ack 18841 win 1537 <nop,nop,timestamp 1096061 40958637>
12:11:03.201590 IP (tos 0x0, ttl  64, id 53816, offset 0, flags [DF], proto: TCP (6), length: 176) 160.50.204.58.2682443041 > 160.50.118.37.2049: 124 read fh 4432,48722/212221 32768 bytes @ 16384
12:11:03.201605 IP (tos 0x0, ttl  64, id 53817, offset 0, flags [DF], proto: TCP (6), length: 176) 160.50.204.58.2699220257 > 160.50.118.37.2049: 124 read fh 4432,48722/212221 32768 bytes @ 49152
12:11:03.201686 IP (tos 0x0, ttl  64, id 53818, offset 0, flags [DF], proto: TCP (6), length: 176) 160.50.204.58.2715997473 > 160.50.118.37.2049: 124 read fh 4432,48722/212221 32768 bytes @ 81920
12:11:03.202083 IP (tos 0x0, ttl  61, id 42990, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.118.37.2049 > 160.50.204.58.799: ., cksum 0xbfbd (correct), ack 1944 win 49232 <nop,nop,timestamp 40958637 1096061>
12:11:03.202092 IP (tos 0x0, ttl  64, id 53819, offset 0, flags [DF], proto: TCP (6), length: 424) 160.50.204.58.2732774689 > 160.50.118.37.2049: 372 read fh 4432,48722/212221 32768 bytes @ 114688
12:11:03.202419 IP (tos 0x0, ttl  61, id 42991, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.2682443041: reply ok 1448 read REG 640 ids 35917/31235 sz 7842215416 32768 bytes
12:11:03.202463 IP (tos 0x0, ttl  61, id 42992, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.1083662336: reply ERR 1448
12:11:03.202467 IP (tos 0x0, ttl  64, id 53820, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x6c18 (correct), ack 21737 win 1718 <nop,nop,timestamp 1096061 40958637>
12:11:03.202486 IP (tos 0x0, ttl  61, id 42993, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ERR 1448
12:11:03.202505 IP (tos 0x0, ttl  61, id 42994, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.2863643582: reply ERR 1448
12:11:03.202509 IP (tos 0x0, ttl  64, id 53821, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x6013 (correct), ack 24633 win 1899 <nop,nop,timestamp 1096061 40958637>
12:11:03.202656 IP (tos 0x0, ttl  61, id 42995, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.202741 IP (tos 0x0, ttl  61, id 42996, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.202745 IP (tos 0x0, ttl  64, id 53822, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x545b (correct), ack 27529 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.202750 IP (tos 0x0, ttl  61, id 42997, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.202755 IP (tos 0x0, ttl  61, id 42998, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.202758 IP (tos 0x0, ttl  64, id 53823, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x490b (correct), ack 30425 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.202761 IP (tos 0x0, ttl  61, id 42999, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.202765 IP (tos 0x0, ttl  61, id 43000, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.202768 IP (tos 0x0, ttl  64, id 53824, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x3dbb (correct), ack 33321 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.202785 IP (tos 0x0, ttl  61, id 43001, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.17: reply ERR 1448
12:11:03.202846 IP (tos 0x0, ttl  61, id 43002, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.202850 IP (tos 0x0, ttl  64, id 53825, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x326b (correct), ack 36217 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.202855 IP (tos 0x0, ttl  61, id 43003, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.202859 IP (tos 0x0, ttl  61, id 43004, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.1: reply ok 1448
12:11:03.202861 IP (tos 0x0, ttl  64, id 53826, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x271b (correct), ack 39113 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.202865 IP (tos 0x0, ttl  61, id 43005, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.112: reply ERR 1448
12:11:03.202903 IP (tos 0x0, ttl  61, id 43006, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.202907 IP (tos 0x0, ttl  64, id 53827, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x1bcb (correct), ack 42009 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.202912 IP (tos 0x0, ttl  61, id 43007, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.1768910336: reply ERR 1448
12:11:03.202942 IP (tos 0x0, ttl  61, id 43008, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.18: reply ERR 1448
12:11:03.202946 IP (tos 0x0, ttl  64, id 53828, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x107b (correct), ack 44905 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.202978 IP (tos 0x0, ttl  61, id 43009, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.538976288: reply ERR 1448
12:11:03.202984 IP (tos 0x0, ttl  61, id 43010, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.1920230261: reply ERR 1448
12:11:03.202987 IP (tos 0x0, ttl  64, id 53829, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0x052b (correct), ack 47801 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.203098 IP (tos 0x0, ttl  61, id 43011, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.538976288: reply ERR 1448
12:11:03.203126 IP (tos 0x0, ttl  61, id 43012, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.10: reply ERR 1448
12:11:03.203130 IP (tos 0x0, ttl  64, id 53830, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0xf9da (correct), ack 50697 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.203135 IP (tos 0x0, ttl  61, id 43013, offset 0, flags [DF], proto: TCP (6), length: 1096) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1044
12:11:03.203176 IP (tos 0x0, ttl  61, id 43014, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.2699220257: reply ok 1448 read REG 640 ids 35917/31235 sz 7842215416 32768 bytes
12:11:03.203181 IP (tos 0x0, ttl  64, id 53831, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0xf01e (correct), ack 53189 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.203218 IP (tos 0x0, ttl  61, id 43015, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.203250 IP (tos 0x0, ttl  61, id 43016, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.203255 IP (tos 0x0, ttl  64, id 53832, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0xe4ce (correct), ack 56085 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.203278 IP (tos 0x0, ttl  61, id 43017, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.203298 IP (tos 0x0, ttl  61, id 43018, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ERR 1448
12:11:03.203304 IP (tos 0x0, ttl  64, id 53833, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0xd97e (correct), ack 58981 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.203334 IP (tos 0x0, ttl  61, id 43019, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.203368 IP (tos 0x0, ttl  61, id 43020, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448
12:11:03.203373 IP (tos 0x0, ttl  64, id 53834, offset 0, flags [DF], proto: TCP (6), length: 52) 160.50.204.58.799 > 160.50.118.37.2049: ., cksum 0xce2e (correct), ack 61877 win 2003 <nop,nop,timestamp 1096061 40958637>
12:11:03.203407 IP (tos 0x0, ttl  61, id 43021, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.153: reply ERR 1448
12:11:03.203444 IP (tos 0x0, ttl  61, id 43022, offset 0, flags [DF], proto: TCP (6), length: 1500) 160.50.118.37.2049 > 160.50.204.58.0: reply ok 1448

--0-29170638-1179152429=:67356
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--0-29170638-1179152429=:67356
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--0-29170638-1179152429=:67356--
