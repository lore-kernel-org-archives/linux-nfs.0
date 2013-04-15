Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw1.transmode.se ([195.58.98.146]:57621 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934427Ab3DOI3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Apr 2013 04:29:47 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id F08DF258020
	for <linux-nfs@vger.kernel.org>; Mon, 15 Apr 2013 10:19:40 +0200 (CEST)
To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Subject: NFS loop on 3.4.39
From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Message-ID: <OF6F031A84.8897519B-ONC1257B4E.002D1BA3-C1257B4E.002DBEFD@transmode.se>
Date: Mon, 15 Apr 2013 10:19:40 +0200
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I get som NFS loop which generates lots of (from tcpdump):
9:48:43.156252 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], ack 
8406616, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], length 
0
09:48:43.156258 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], ack 
8426888, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], length 
0
09:48:43.156669 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], ack 
8445712, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], length 
0
09:48:43.156675 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], ack 
8459880, win 32883, options [nop,nop,TS val 43795665 ecr 57419706], length 
0
09:48:43.156679 IP 192.168.201.44.nfs > 172.20.4.10.2889942938: reply ok 
52 getattr ERROR: unk 10024
09:48:43.156704 IP 172.20.4.10.2923497370 > 192.168.201.44.nfs: 2892 
getattr fh 0,0/22
09:48:43.156712 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8462776:8467120, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156719 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8467120:8471464, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156725 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8471464:8475808, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156731 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8475808:8480152, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156745 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8480152:8484496, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156748 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8484496:8487392, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 2896
09:48:43.156751 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8487392:8491736, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156755 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8491736:8496080, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156758 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8496080:8500424, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156764 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8500424:8504768, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156767 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8504768:8509112, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156770 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8509112:8512008, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 2896
09:48:43.156773 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8512008:8516352, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156778 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8516352:8520696, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156956 IP 192.168.201.44.nfs > 172.20.4.10.2906720154: reply ok 
52 getattr ERROR: unk 10024
09:48:43.156969 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8520696:8525040, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156975 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8525040:8529384, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156980 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8529384:8533728, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156984 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8533728:8536624, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 2896
09:48:43.156988 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8536624:8540968, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156994 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8540968:8545312, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.156999 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8545312:8549656, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.157209 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], ack 
8464224, win 32872, options [nop,nop,TS val 43795665 ecr 57419706], length 
0
09:48:43.157219 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8549656:8554000, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.157225 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8554000:8558344, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.157230 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [P.], seq 
8558344:8558424, ack 9577, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 80
09:48:43.157235 IP 172.20.4.10.2940274586 > 192.168.201.44.nfs: 532 
getattr fh 0,0/22
09:48:43.157460 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], ack 
8485944, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], length 
0
09:48:43.157709 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], ack 
8504768, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], length 
0
09:48:43.157715 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], ack 
8526488, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], length 
0
09:48:43.158126 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], ack 
8543864, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], length 
0
09:48:43.158133 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], ack 
8558960, win 32883, options [nop,nop,TS val 43795665 ecr 57419706], length 
0
09:48:43.158138 IP 192.168.201.44.nfs > 172.20.4.10.2923497370: reply ok 
52 getattr ERROR: unk 10024
09:48:43.158143 IP 192.168.201.44.nfs > 172.20.4.10.2940274586: reply ok 
52 getattr ERROR: unk 10024
09:48:43.158149 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], ack 
9745, win 23907, options [nop,nop,TS val 57419706 ecr 43795665], length 0
09:48:43.158174 IP 172.20.4.10.2957051802 > 192.168.201.44.nfs: 2892 
getattr fh 0,0/22
09:48:43.158192 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8561856:8566200, ack 9745, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.158197 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8566200:8570544, ack 9745, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.158204 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8570544:8574888, ack 9745, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.158210 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8574888:8579232, ack 9745, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.158216 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8579232:8583576, ack 9745, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.158222 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8583576:8586472, ack 9745, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 2896
09:48:43.158226 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8586472:8590816, ack 9745, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.158233 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8590816:8595160, ack 9745, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344
09:48:43.158239 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], seq 
8595160:8599504, ack 9745, win 23907, options [nop,nop,TS val 57419706 ecr 
43795665], length 4344

I wonder if this is a variant on:
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/fs/nfs/nfs4proc.c?h=linux-3.6.y&id=9fa2b82e5592a7aa7a63b7f6a32c5aa9e580643a

which does seem to be in the 3.4 stable branch?

 Jocke
