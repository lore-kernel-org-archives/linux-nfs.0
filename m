Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og116.obsmtp.com ([64.18.1.37]:46229 "HELO
	exprod6og116.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750772Ab0IGGTd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 02:19:33 -0400
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01CB4E54.A2029C95"
Subject: RE: Query regarding NFS packet capture at application layer - umount operation.
Date: Tue, 7 Sep 2010 02:19:28 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D19843F@nsmail.netscout.com>
From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
To: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

------_=_NextPart_001_01CB4E54.A2029C95
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

> -----Original Message-----
> From: Tayade, Nilesh
> Sent: Monday, September 06, 2010 6:03 PM
> To: linux-nfs@vger.kernel.org
> Subject: Query regarding NFS packet capture at application layer -
> umount operation.
>=20
> Hi,
>=20
> I have a query related to NFS packet captured at application layer.
> I have setup the NFS node on local system itself (just for test
> purpose).
> And capturing the packets for various events (mount, umount, file
> access etc) on loop-back interface itself. However, in case of the
> umount scenario, I do not see any NFS packet captured (I can only
> see three TCP packets exchanged).
>=20
> Could someone please explain why there is no NFS packet observed
> during an unmount? Also there seems not much information, related to
> NFS mount point being unmounted, in TCP packet. So is there any way
> to detect the unmount operation by hacking such packets?
>=20
> The last TCP packet looks like:
>=20
> Transmission Control Protocol, Src Port: 866 (866), Dst Port: 2049
> (2049), Seq: 1, Ack: 1, Len: 0
> Source port: 866 (866)
> Destination port: 2049 (2049)
> Sequence number: 1    (relative sequence number)
> Acknowledgement number: 1    (relative ack number)
> Header length: 32 bytes
> Flags: 0x10 (ACK)
> Checksum: 0xef2f [correct]
> Options: (12 bytes)
> This is an ACK to the segment in frame: 2
> The RTT to ACK the segment was: 0.000017000 seconds
>=20
> Please let me know in case the capture file is required.

Attached is the capture file obtained using tshark, in case required.
Also the NFS protocol version here is NFSv3.

> --
> Thanks,
> Nilesh
> [nilesh(dot)tayade(at)netscout(dot)com]


------_=_NextPart_001_01CB4E54.A2029C95
Content-Type: application/octet-stream;
	name="nfs_unmount"
Content-Transfer-Encoding: base64
Content-Description: nfs_unmount
Content-Disposition: attachment;
	filename="nfs_unmount"

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAKduETO9JDQBCAAAAQgAAAAAAAAAAAAAAAAAAAAgARQAA
NHwMQABABsLewKg9RMCoPUQDYggBySUP3sjj2+eAEQEB/PQAAAEBCAoBRX95AUVxtynbhEz2SQ0A
QgAAAEIAAAAAAAAAAAAAAAAAAAAIAEUAADSrr0AAQAaTO8CoPUTAqD1ECAEDYsjj2+fJJQ/fgBEB
AO8xAAABAQgKAUV/egFFf3kp24RMB0oNAEIAAABCAAAAAAAAAAAAAAAAAAAACABFAAA0fA1AAEAG
wt3AqD1EwKg9RANiCAHJJQ/fyOPb6IAQAQHvLwAAAQEICgFFf3oBRX96

------_=_NextPart_001_01CB4E54.A2029C95--
