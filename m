From: Paolo Galtieri <pgaltieri-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Subject: NFS over TCP behavior in older 2.6 kernel
Date: Thu, 28 Aug 2008 10:36:06 -0700
Message-ID: <48B6E206.1020401@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Scott A. Ikenaga" <sikenaga-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>,
	Yuksel Tokuz <ytokuz-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:63204 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbYH1RgI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Aug 2008 13:36:08 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Folks,
  I have a question regarding the behavior of nfsd v3 running over TCP.  
Specifically how should the NFS server behave if the clock is moved 
backwards on the server.  I've tried to find references to what the 
correct behavior should be and have been unable to, so I'm posting to 
this list with the hope someone can point me to where I can find it.

I'm running a 2.6.10 kernel on 2 systems, one acting as an NFS server 
the other as the client (obviously).  I advertise to the client a 
directory that contains several files which I mount on the client as /app

On the server I run the following test:

while ;
do
   date 022910002008;
   sleep 10;
   date 022910102008;
   sleep 10;
done

on the client I run the following in /app

while :
do
  ls
  sleep 10
done

What I observe is that often I see long pauses when doing the ls before 
it actually displays the data.

I ran tcpdump and what I observed is that the NFS server closed the 
connection when the timestamp of ACK for a packet sent by the client is 
earlier than the timestamp for the original packet, i.e. between the 
receipt of the original packet and the sending of the ACK the clock went 
backwards.  For example:

Frame 1019 contains this packet

TCP      nfs > legent-1 [FIN, ACK] Seq=961 Ack=937 Win=1448 Len=0 
TSV=979162569 TSER=979004710

0000  00 14 f8 ec 30 2f 00 14  f8 ec 47 11 08 00 45 00   ....0/.. ..G...E.
0010  00 34 2a 2c 40 00 40 06  ba 95 a9 fe 01 01 a9 fe   .4*,@.@. ........
0020  01 05 08 01 01 75 03 a6  6d a7 a9 d3 d4 ff 80 11   .....u.. m.......
0030  05 a8 69 d4 00 00 01 01  08 0a 3a 5c d5 c9 3a 5a   ..i..... ..:\..:Z
0040  6d 26 

and is time stamped (using wireshark) 2008-02-29 02:00:00.911651.  The 
original packet for which this is the ACK is frame 924 and contains:

TCP      legent-1 > nfs [ACK] Seq=937 Ack=961 Win=1460 Len=0 
TSV=979004710 TSER=979159895

0000  00 14 f8 ec 47 11 00 14  f8 ec 30 2f 08 00 45 00   ....G... ..0/..E.
0010  00 34 2b e9 40 00 40 06  b8 d8 a9 fe 01 05 a9 fe   .4+.@.@. ........
0020  01 01 01 75 08 01 a9 d3  d4 ff 03 a6 6d a7 80 10   ...u.... ....m...
0030  05 b4 74 3b 00 00 01 01  08 0a 3a 5a 6d 26 3a 5c   ..t;.... ..:Zm&:\
0040  cb 57                                              .W             

Wireshark reports the RTT as:

[The RTT to ACK the segment was: -7.377099000 seconds]

After the server disconnects the client has to reconnect and it is looks 
like the delay is occurring during this disconnect/reconnect process.

Can someone point me to any documentation, either for NFS or TCP that 
explains the behavior?  Note that this problem does not occur with UDP 
so I suspect it's a consequence of the connection oriented aspects of 
the TCP protocol vs UDP, but it would nice to see it in writing.

I appreciate any assistance, flames, or other comments :-)

Thank you,
Paolo
