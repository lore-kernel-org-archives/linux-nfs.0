Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og111.obsmtp.com ([64.18.1.27]:37532 "HELO
	exprod6og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750784Ab0IFMdH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Sep 2010 08:33:07 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: Query regarding NFS packet capture at application layer - umount operation.
Date: Mon, 6 Sep 2010 08:33:03 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D19835A@nsmail.netscout.com>
From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
To: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I have a query related to NFS packet captured at application layer. I
have setup the NFS node on local system itself (just for test purpose). 
And capturing the packets for various events (mount, umount, file access
etc) on loop-back interface itself. However, in case of the umount
scenario, I do not see any NFS packet captured (I can only see three TCP
packets exchanged). 

Could someone please explain why there is no NFS packet observed during
an unmount? Also there seems not much information, related to NFS mount
point being unmounted, in TCP packet. So is there any way to detect the
unmount operation by hacking such packets?

The last TCP packet looks like:

Transmission Control Protocol, Src Port: 866 (866), Dst Port: 2049
(2049), Seq: 1, Ack: 1, Len: 0
Source port: 866 (866)
Destination port: 2049 (2049)
Sequence number: 1    (relative sequence number)
Acknowledgement number: 1    (relative ack number)
Header length: 32 bytes
Flags: 0x10 (ACK)
Checksum: 0xef2f [correct]
Options: (12 bytes)
This is an ACK to the segment in frame: 2
The RTT to ACK the segment was: 0.000017000 seconds

Please let me know in case the capture file is required.

--
Thanks,
Nilesh
[nilesh(dot)tayade(at)netscout(dot)com]

