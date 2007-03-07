From: Simon Peter <simon.peter@gmx.de>
Subject: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 11:23:47 +0100
Message-ID: <20070307112347.6a40faff.simon.peter@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="Multipart=_Wed__7_Mar_2007_11_23_47_+0100_jBm8B2QeAGvsg1BS"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOtJO-0001Yc-VJ
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:24:00 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HOtJO-0006OT-W6
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 02:24:01 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.

--Multipart=_Wed__7_Mar_2007_11_23_47_+0100_jBm8B2QeAGvsg1BS
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Hi,

I get a good 10 second delay anytime I am accessing my NFS mounts from
a client for the first time (or after a long time not accessing them --
I suppose whenever the cache is cleared or something similar).

I usually did not bother, even though it is very annoying, but this
time I collected a network protocol capture, which is attached. Notice
the big delay between packet #6 and #8, while #7 should show that it is
not a network issue.

I would be very glad if somebody could explain these delays.

Thanks,
Simon

--Multipart=_Wed__7_Mar_2007_11_23_47_+0100_jBm8B2QeAGvsg1BS
Content-Type: text/plain;
 name="capture.txt"
Content-Disposition: attachment;
 filename="capture.txt"
Content-Transfer-Encoding: 7bit

No.     Time        Source                Destination           Protocol Info
      3 2.814252    192.168.110.10        192.168.110.1         TCP      675 > nfs [SYN] Seq=0 Len=0 MSS=1460 TSV=1145045 TSER=0 WS=7

Frame 3 (74 bytes on wire, 74 bytes captured)
Ethernet II, Src: AsustekC_0a:06:28 (00:0c:6e:0a:06:28), Dst: ZonetTec_8c:11:73 (00:50:22:8c:11:73)
Internet Protocol, Src: 192.168.110.10 (192.168.110.10), Dst: 192.168.110.1 (192.168.110.1)
Transmission Control Protocol, Src Port: 675 (675), Dst Port: nfs (2049), Seq: 0, Len: 0

No.     Time        Source                Destination           Protocol Info
      4 2.814382    192.168.110.1         192.168.110.10        TCP      nfs > 675 [SYN, ACK] Seq=0 Ack=1 Win=92672 Len=0 MSS=1460 TSV=474034265 TSER=1145045 WS=4

Frame 4 (74 bytes on wire, 74 bytes captured)
Ethernet II, Src: ZonetTec_8c:11:73 (00:50:22:8c:11:73), Dst: AsustekC_0a:06:28 (00:0c:6e:0a:06:28)
Internet Protocol, Src: 192.168.110.1 (192.168.110.1), Dst: 192.168.110.10 (192.168.110.10)
Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 675 (675), Seq: 0, Ack: 1, Len: 0

No.     Time        Source                Destination           Protocol Info
      5 2.814410    192.168.110.10        192.168.110.1         TCP      675 > nfs [ACK] Seq=1 Ack=1 Win=5888 Len=0 TSV=1145045 TSER=474034265

Frame 5 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: AsustekC_0a:06:28 (00:0c:6e:0a:06:28), Dst: ZonetTec_8c:11:73 (00:50:22:8c:11:73)
Internet Protocol, Src: 192.168.110.10 (192.168.110.10), Dst: 192.168.110.1 (192.168.110.1)
Transmission Control Protocol, Src Port: 675 (675), Dst Port: nfs (2049), Seq: 1, Ack: 1, Len: 0

No.     Time        Source                Destination           Protocol Info
      6 2.822284    192.168.110.10        192.168.110.1         NFS      V3 GETATTR Call (Reply In 8), FH:0x43fe0000

Frame 6 (210 bytes on wire, 210 bytes captured)
Ethernet II, Src: AsustekC_0a:06:28 (00:0c:6e:0a:06:28), Dst: ZonetTec_8c:11:73 (00:50:22:8c:11:73)
Internet Protocol, Src: 192.168.110.10 (192.168.110.10), Dst: 192.168.110.1 (192.168.110.1)
Transmission Control Protocol, Src Port: 675 (675), Dst Port: nfs (2049), Seq: 1, Ack: 1, Len: 144
Remote Procedure Call, Type:Call XID:0x8e4655b0
Network File System, GETATTR Call FH:0x43fe0000
    [Program Version: 3]
    [V3 Procedure: GETATTR (1)]
    object

No.     Time        Source                Destination           Protocol Info
      7 2.822400    192.168.110.1         192.168.110.10        TCP      nfs > 675 [ACK] Seq=1 Ack=145 Win=6864 Len=0 TSV=474034267 TSER=1145047

Frame 7 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: ZonetTec_8c:11:73 (00:50:22:8c:11:73), Dst: AsustekC_0a:06:28 (00:0c:6e:0a:06:28)
Internet Protocol, Src: 192.168.110.1 (192.168.110.1), Dst: 192.168.110.10 (192.168.110.10)
Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 675 (675), Seq: 1, Ack: 145, Len: 0

No.     Time        Source                Destination           Protocol Info
      8 13.749967   192.168.110.1         192.168.110.10        NFS      V3 GETATTR Reply (Call In 6)  Directory mode:2775 uid:102 gid:1000

Frame 8 (182 bytes on wire, 182 bytes captured)
Ethernet II, Src: ZonetTec_8c:11:73 (00:50:22:8c:11:73), Dst: AsustekC_0a:06:28 (00:0c:6e:0a:06:28)
Internet Protocol, Src: 192.168.110.1 (192.168.110.1), Dst: 192.168.110.10 (192.168.110.10)
Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 675 (675), Seq: 1, Ack: 145, Len: 116
Remote Procedure Call, Type:Reply XID:0x8e4655b0
Network File System, GETATTR Reply  Directory mode:2775 uid:102 gid:1000
    [Program Version: 3]
    [V3 Procedure: GETATTR (1)]
    Status: NFS3_OK (0)
    obj_attributes  Directory mode:2775 uid:102 gid:1000
        Type: Directory (2)
        mode: 042775
        nlink: 2
        uid: 102
        gid: 1000
        size: 4096
        used: 4096
        rdev: 0,0
        fsid: 0x000000000000fe00
        fileid: 15650
        atime: Mar  7, 2007 10:31:07.000000000
        mtime: Mar  7, 2007 10:31:07.000000000
        ctime: Mar  7, 2007 10:31:07.000000000

No.     Time        Source                Destination           Protocol Info
      9 13.750012   192.168.110.10        192.168.110.1         TCP      675 > nfs [ACK] Seq=145 Ack=117 Win=5888 Len=0 TSV=1147787 TSER=474037003

Frame 9 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: AsustekC_0a:06:28 (00:0c:6e:0a:06:28), Dst: ZonetTec_8c:11:73 (00:50:22:8c:11:73)
Internet Protocol, Src: 192.168.110.10 (192.168.110.10), Dst: 192.168.110.1 (192.168.110.1)
Transmission Control Protocol, Src Port: 675 (675), Dst Port: nfs (2049), Seq: 145, Ack: 117, Len: 0

No.     Time        Source                Destination           Protocol Info
     12 14.695027   192.168.110.10        192.168.110.1         NFS      V3 ACCESS Call (Reply In 14), FH:0x43fe0000

Frame 12 (214 bytes on wire, 214 bytes captured)
Ethernet II, Src: AsustekC_0a:06:28 (00:0c:6e:0a:06:28), Dst: ZonetTec_8c:11:73 (00:50:22:8c:11:73)
Internet Protocol, Src: 192.168.110.10 (192.168.110.10), Dst: 192.168.110.1 (192.168.110.1)
Transmission Control Protocol, Src Port: 675 (675), Dst Port: nfs (2049), Seq: 145, Ack: 117, Len: 148
Remote Procedure Call, Type:Call XID:0x8f4655b0
Network File System, ACCESS Call FH:0x43fe0000
    [Program Version: 3]
    [V3 Procedure: ACCESS (4)]
    object
    access: 0x1f

No.     Time        Source                Destination           Protocol Info
     13 14.695157   192.168.110.1         192.168.110.10        TCP      nfs > 675 [ACK] Seq=117 Ack=293 Win=7936 Len=0 TSV=474037239 TSER=1148027

Frame 13 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: ZonetTec_8c:11:73 (00:50:22:8c:11:73), Dst: AsustekC_0a:06:28 (00:0c:6e:0a:06:28)
Internet Protocol, Src: 192.168.110.1 (192.168.110.1), Dst: 192.168.110.10 (192.168.110.10)
Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 675 (675), Seq: 117, Ack: 293, Len: 0

No.     Time        Source                Destination           Protocol Info
     14 14.695260   192.168.110.1         192.168.110.10        NFS      V3 ACCESS Reply (Call In 12)

Frame 14 (190 bytes on wire, 190 bytes captured)
Ethernet II, Src: ZonetTec_8c:11:73 (00:50:22:8c:11:73), Dst: AsustekC_0a:06:28 (00:0c:6e:0a:06:28)
Internet Protocol, Src: 192.168.110.1 (192.168.110.1), Dst: 192.168.110.10 (192.168.110.10)
Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 675 (675), Seq: 117, Ack: 293, Len: 124
Remote Procedure Call, Type:Reply XID:0x8f4655b0
Network File System, ACCESS Reply
    [Program Version: 3]
    [V3 Procedure: ACCESS (4)]
    Status: NFS3_OK (0)
    obj_attributes  Directory mode:2775 uid:102 gid:1000
    access: 0x1f

No.     Time        Source                Destination           Protocol Info
     15 14.695269   192.168.110.10        192.168.110.1         TCP      675 > nfs [ACK] Seq=293 Ack=241 Win=5888 Len=0 TSV=1148027 TSER=474037239

Frame 15 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: AsustekC_0a:06:28 (00:0c:6e:0a:06:28), Dst: ZonetTec_8c:11:73 (00:50:22:8c:11:73)
Internet Protocol, Src: 192.168.110.10 (192.168.110.10), Dst: 192.168.110.1 (192.168.110.1)
Transmission Control Protocol, Src Port: 675 (675), Dst Port: nfs (2049), Seq: 293, Ack: 241, Len: 0

No.     Time        Source                Destination           Protocol Info
     16 14.695344   192.168.110.10        192.168.110.1         NFS      V3 READDIRPLUS Call (Reply In 17), FH:0x43fe0000

Frame 16 (234 bytes on wire, 234 bytes captured)
Ethernet II, Src: AsustekC_0a:06:28 (00:0c:6e:0a:06:28), Dst: ZonetTec_8c:11:73 (00:50:22:8c:11:73)
Internet Protocol, Src: 192.168.110.10 (192.168.110.10), Dst: 192.168.110.1 (192.168.110.1)
Transmission Control Protocol, Src Port: 675 (675), Dst Port: nfs (2049), Seq: 293, Ack: 241, Len: 168
Remote Procedure Call, Type:Call XID:0x904655b0
Network File System, READDIRPLUS Call FH:0x43fe0000
    [Program Version: 3]
    [V3 Procedure: READDIRPLUS (17)]
    dir
    cookie: 0
    Verifier: Opaque Data
    dircount: 512
    maxcount: 4096

No.     Time        Source                Destination           Protocol Info
     17 14.695604   192.168.110.1         192.168.110.10        NFS      V3 READDIRPLUS Reply (Call In 16) . ..

Frame 17 (482 bytes on wire, 482 bytes captured)
Ethernet II, Src: ZonetTec_8c:11:73 (00:50:22:8c:11:73), Dst: AsustekC_0a:06:28 (00:0c:6e:0a:06:28)
Internet Protocol, Src: 192.168.110.1 (192.168.110.1), Dst: 192.168.110.10 (192.168.110.10)
Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 675 (675), Seq: 241, Ack: 461, Len: 416
Remote Procedure Call, Type:Reply XID:0x904655b0
Network File System, READDIRPLUS Reply
    [Program Version: 3]
    [V3 Procedure: READDIRPLUS (17)]
    Status: NFS3_OK (0)
    dir_attributes  Directory mode:2775 uid:102 gid:1000
    Verifier: Opaque Data
    Value Follows: Yes
    Entry: name .
    Value Follows: Yes
    Entry: name ..
    Value Follows: No
    EOF: 1

No.     Time        Source                Destination           Protocol Info
     18 14.733282   192.168.110.10        192.168.110.1         TCP      675 > nfs [ACK] Seq=461 Ack=657 Win=6912 Len=0 TSV=1148037 TSER=474037239

Frame 18 (66 bytes on wire, 66 bytes captured)
Ethernet II, Src: AsustekC_0a:06:28 (00:0c:6e:0a:06:28), Dst: ZonetTec_8c:11:73 (00:50:22:8c:11:73)
Internet Protocol, Src: 192.168.110.10 (192.168.110.10), Dst: 192.168.110.1 (192.168.110.1)
Transmission Control Protocol, Src Port: 675 (675), Dst Port: nfs (2049), Seq: 461, Ack: 657, Len: 0

--Multipart=_Wed__7_Mar_2007_11_23_47_+0100_jBm8B2QeAGvsg1BS
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--Multipart=_Wed__7_Mar_2007_11_23_47_+0100_jBm8B2QeAGvsg1BS
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--Multipart=_Wed__7_Mar_2007_11_23_47_+0100_jBm8B2QeAGvsg1BS--
