From: Emanuel.Quass@temic.com
Subject: (no subject)
Date: Mon, 27 Jan 2003 15:23:06 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF74631263.0B676C00-ONC1256CBB.00447DC5-C1256CBB.004ECC4B@nbg.temic.de>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 004ECC41C1256CBB_="
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail3.noris.net ([62.128.1.28] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18dA7N-0001fi-00
	for <nfs@lists.sourceforge.net>; Mon, 27 Jan 2003 06:20:09 -0800
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multipart message in MIME format.
--=_alternative 004ECC41C1256CBB_=
Content-Type: text/plain; charset="us-ascii"

Hello,

Can anyone give me some hints please.
I'm having a Linux-Box (in-cat26/PIII 2.4.18-4GB/SuSE 8.0 ) as a CATIA 
Fileserver and a IBM/RS6000 ( in-kom8/aix 4.3.3 ML 9) as a Client both 
connected with 100MB/Full Duplex(e100 driver)!

/etc/exports /etc/filesystems
mountpoint      in-kom8(root_squash,insecure,rw,async) 
in-cat26:/mountpoint    /mountpoint 
(bg,hard,intr,vers=3,proto=udp,rsize=8192,wsize=8192)

During a "ls" I get the following errors: (tcpdump host in-kom8  and  udp 
-s 1024)

14:27:05.316761 arp who-has in-kom5. tell in-cat26.
14:27:05.316892 arp reply in-kom5. is-at 8:0:69:e:ec:f3
14:27:12.977233 in-kom8.781891772 > in-cat26.nfs: 128 getattr fh Unknown/1
14:27:12.977281 in-cat26.nfs > in-kom8.781891772: reply ok 112 getattr REG 
100600 ids 4732/200 sz 0x000000aec  (DF)
14:27:12.977645 in-kom8.781891773 > in-cat26.nfs: 124 lookup fh Unknown/1 
"ls"
14:27:12.977674 in-cat26.nfs > in-kom8.781891773: reply ok 116 lookup 
ERROR: No such file or directory (DF)
14:27:12.981685 in-kom8.781891774 > in-cat26.nfs: 124 lookup fh Unknown/1 
"ls"
14:27:12.981703 in-cat26.nfs > in-kom8.781891774: reply ok 116 lookup 
ERROR: No such file or directory (DF)
14:27:12.986623 in-kom8.781891775 > in-cat26.nfs: 116 getattr fh Unknown/1
14:27:12.986638 in-cat26.nfs > in-kom8.781891775: reply ok 112 getattr DIR 
40755 ids 4732/200 sz 0x0000008b8  (DF)
14:27:51.426006 in-kom8.781891776 > in-cat26.nfs: 1472 write fh Unknown/1 
2800 bytes @ 0x000000000 (frag 8477:1480@0+)
14:27:51.426008 in-kom8.> in-cat26.: (frag 8477:1476@1480)
14:27:51.426312 in-cat26.nfs > in-kom8.781891776: reply ok 136 write 
[|nfs] (DF)
14:27:51.428035 in-kom8.781891777 > in-cat26.nfs: 140 commit fh Unknown/1 
4096 bytes @ 0x000000000
14:27:51.428058 in-cat26.nfs > in-kom8.781891777: reply ok 128 commit (DF)


During a login I get the following errors:
4:34:21.916125 in-kom8.781897917 > in-cat26.nfs: 124 lookup fh Unknown/1 
"df"
14:34:21.916145 in-cat26.nfs > in-kom8.781897917: reply ok 116 lookup 
ERROR: No such file or directory (DF)
14:34:21.916366 in-kom8.781897918 > in-cat26.nfs: 124 lookup fh Unknown/1 
"df"
14:34:21.916385 in-cat26.nfs > in-kom8.781897918: reply ok 116 lookup 
ERROR: No such file or directory (DF)
14:34:21.917741 in-kom8.781897919 > in-cat26.nfs: 124 lookup fh Unknown/1 
"df"
14:34:21.917757 in-cat26.nfs > in-kom8.781897919: reply ok 116 lookup 
ERROR: No such file or directory (DF)
14:34:21.921693 in-kom8.781897920 > in-cat26.nfs: 124 lookup fh Unknown/1 
"df"
14:34:21.921707 in-cat26.nfs > in-kom8.781897920: reply ok 116 lookup 
ERROR: No such file or directory (DF)
14:34:21.928997 in-kom8.781897924 > in-cat26.nfs: 116 fsstat fh Unknown/1
14:34:21.929013 in-cat26.nfs > in-kom8.781897924: reply ok 84 fsstat 
[|nfs] (DF)

Can anyone explain to me why the Client is looking for a file "df" and 
what does "Unknown/1" mean?

Thanks for any help or hints (If you need additional information please 
ask)

        Emanuel
--=_alternative 004ECC41C1256CBB_=
Content-Type: text/html; charset="us-ascii"


<br><font size=2 face="sans-serif">Hello,</font>
<br>
<br><font size=2 face="sans-serif">Can anyone give me some hints please.</font>
<br><font size=2 face="sans-serif">I'm having a Linux-Box (in-cat26/PIII 2.4.18-4GB/SuSE 8.0 ) as a CATIA &nbsp;Fileserver and a IBM/RS6000 ( in-kom8/aix 4.3.3 ML 9) as a Client both connected with 100MB/Full Duplex(e100 driver)!</font>
<br>
<br><font size=2 face="sans-serif">/etc/exports &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /etc/filesystems</font>
<br><font size=2 face="sans-serif">mountpoint &nbsp; &nbsp; &nbsp; &nbsp;in-kom8(root_squash,insecure,rw,async) &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;in-cat26:/mountpoint &nbsp; &nbsp; &nbsp; &nbsp;/mountpoint (bg,hard,intr,vers=3,proto=udp,rsize=8192,wsize=8192)</font>
<br>
<br><font size=2 face="sans-serif">During a &quot;ls&quot; I get the following errors: (tcpdump host in-kom8 &nbsp;and &nbsp;udp -s 1024)</font>
<br>
<br><font size=2 face="sans-serif">14:27:05.316761 arp who-has in-kom5. tell in-cat26.</font>
<br><font size=2 face="sans-serif">14:27:05.316892 arp reply in-kom5. is-at 8:0:69:e:ec:f3</font>
<br><font size=2 face="sans-serif">14:27:12.977233 in-kom8.781891772 &gt; in-cat26.nfs: 128 getattr fh Unknown/1</font>
<br><font size=2 face="sans-serif">14:27:12.977281 in-cat26.nfs &gt; in-kom8.781891772: reply ok 112 getattr REG 100600 ids 4732/200 sz 0x000000aec &nbsp;(DF)</font>
<br><font size=2 face="sans-serif">14:27:12.977645 in-kom8.781891773 &gt; in-cat26.nfs: 124 lookup fh Unknown/1 &quot;ls&quot;</font>
<br><font size=2 face="sans-serif">14:27:12.977674 in-cat26.nfs &gt; in-kom8.781891773: reply ok 116 lookup ERROR: No such file or directory (DF)</font>
<br><font size=2 face="sans-serif">14:27:12.981685 in-kom8.781891774 &gt; in-cat26.nfs: 124 lookup fh Unknown/1 &quot;ls&quot;</font>
<br><font size=2 face="sans-serif">14:27:12.981703 in-cat26.nfs &gt; in-kom8.781891774: reply ok 116 lookup ERROR: No such file or directory (DF)</font>
<br><font size=2 face="sans-serif">14:27:12.986623 in-kom8.781891775 &gt; in-cat26.nfs: 116 getattr fh Unknown/1</font>
<br><font size=2 face="sans-serif">14:27:12.986638 in-cat26.nfs &gt; in-kom8.781891775: reply ok 112 getattr DIR 40755 ids 4732/200 sz 0x0000008b8 &nbsp;(DF)</font>
<br><font size=2 face="sans-serif">14:27:51.426006 in-kom8.781891776 &gt; in-cat26.nfs: 1472 write fh Unknown/1 2800 bytes @ 0x000000000 (frag 8477:1480@0+)</font>
<br><font size=2 face="sans-serif">14:27:51.426008 in-kom8.&gt; in-cat26.: (frag 8477:1476@1480)</font>
<br><font size=2 face="sans-serif">14:27:51.426312 in-cat26.nfs &gt; in-kom8.781891776: reply ok 136 write [|nfs] (DF)</font>
<br><font size=2 face="sans-serif">14:27:51.428035 in-kom8.781891777 &gt; in-cat26.nfs: 140 commit fh Unknown/1 4096 bytes @ 0x000000000</font>
<br><font size=2 face="sans-serif">14:27:51.428058 in-cat26.nfs &gt; in-kom8.781891777: reply ok 128 commit (DF)</font>
<br>
<br>
<br><font size=2 face="sans-serif">During a login I get the following errors:</font>
<br><font size=2 face="sans-serif">4:34:21.916125 in-kom8.781897917 &gt; in-cat26.nfs: 124 lookup fh Unknown/1 &quot;df&quot;</font>
<br><font size=2 face="sans-serif">14:34:21.916145 in-cat26.nfs &gt; in-kom8.781897917: reply ok 116 lookup ERROR: No such file or directory (DF)</font>
<br><font size=2 face="sans-serif">14:34:21.916366 in-kom8.781897918 &gt; in-cat26.nfs: 124 lookup fh Unknown/1 &quot;df&quot;</font>
<br><font size=2 face="sans-serif">14:34:21.916385 in-cat26.nfs &gt; in-kom8.781897918: reply ok 116 lookup ERROR: No such file or directory (DF)</font>
<br><font size=2 face="sans-serif">14:34:21.917741 in-kom8.781897919 &gt; in-cat26.nfs: 124 lookup fh Unknown/1 &quot;df&quot;</font>
<br><font size=2 face="sans-serif">14:34:21.917757 in-cat26.nfs &gt; in-kom8.781897919: reply ok 116 lookup ERROR: No such file or directory (DF)</font>
<br><font size=2 face="sans-serif">14:34:21.921693 in-kom8.781897920 &gt; in-cat26.nfs: 124 lookup fh Unknown/1 &quot;df&quot;</font>
<br><font size=2 face="sans-serif">14:34:21.921707 in-cat26.nfs &gt; in-kom8.781897920: reply ok 116 lookup ERROR: No such file or directory (DF)</font>
<br><font size=2 face="sans-serif">14:34:21.928997 in-kom8.781897924 &gt; in-cat26.nfs: 116 fsstat fh Unknown/1</font>
<br><font size=2 face="sans-serif">14:34:21.929013 in-cat26.nfs &gt; in-kom8.781897924: reply ok 84 fsstat [|nfs] (DF)</font>
<br>
<br><font size=2 face="sans-serif">Can anyone explain to me why the Client is looking for a file &quot;df&quot; and what does &quot;Unknown/1&quot; mean?</font>
<br>
<br><font size=2 face="sans-serif">Thanks for any help or hints (If you need additional information please ask)</font>
<br>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; Emanuel</font>
--=_alternative 004ECC41C1256CBB_=--


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
