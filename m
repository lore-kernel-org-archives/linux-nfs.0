Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw1.transmode.se ([195.58.98.146]:52526 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754154Ab3DPKl5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Apr 2013 06:41:57 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id 90C60258020
	for <linux-nfs@vger.kernel.org>; Tue, 16 Apr 2013 12:41:54 +0200 (CEST)
In-Reply-To: <OF64305930.0F7881A0-ONC1257B4E.0030250F-C1257B4E.00306CEC@LocalDomain>
References: <OF6F031A84.8897519B-ONC1257B4E.002D1BA3-C1257B4E.002DBED0@LocalDomain> <OF83CD52DB.8DBE497B-ONC1257B4E.002F8695-C1257B4E.002FBBD0@LocalDomain> <OF64305930.0F7881A0-ONC1257B4E.0030250F-C1257B4E.00306CEC@LocalDomain>
Cc: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Subject: Re: NFS loop on 3.4.39
From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Message-ID: <OFA06D4153.317BAF9A-ONC1257B4F.002F597B-C1257B4F.003AC46C@transmode.se>
Date: Tue, 16 Apr 2013 12:41:54 +0200
Content-Type: text/plain; charset="US-ASCII"
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here we go again, this time i happened while browsing the Boston news on 
www.dn.se
Now gvfsd-metadata is turned off(not running at all) and I get:
10:28:44.616146 IP 192.168.201.44.nfs > 172.20.4.10.3671768838: reply ok 
52 getattr ERROR: unk 10024
10:28:44.616170 IP 172.20.4.10.3688546054 > 192.168.201.44.nfs: 2892 
getattr fh 0,0/22
10:28:44.616181 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.616188 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.616195 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.616202 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.616220 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.616226 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.616231 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.616235 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.616238 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113785365:113789709, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616242 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113789709:113794053, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616248 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113794053:113798397, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616251 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113798397:113801293, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 2896
10:28:44.616256 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113801293:113805637, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616264 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113805637:113809981, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616269 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113809981:113814325, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616272 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113814325:113818669, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616276 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.616314 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113823013:113825909, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 2896
10:28:44.616317 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113825909:113830253, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616372 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113830253:113834597, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616425 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113834597:113838941, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616432 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113838941:113843285, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616469 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113843285:113846181, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 2896
10:28:44.616523 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113846181:113850525, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616583 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
113752061, win 32878, options [nop,nop,TS val 52675811 ecr 19887700], 
length 0
10:28:44.616597 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113850525:113854869, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616600 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.616617 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113859213:113863557, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616667 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113863557:113867901, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616721 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113867901:113870797, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 2896
10:28:44.616766 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
113767989, win 32885, options [nop,nop,TS val 52675811 ecr 19887700], 
length 0
10:28:44.616776 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113870797:113875141, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616783 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113875141:113879485, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616818 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
113772333, win 32885, options [nop,nop,TS val 52675811 ecr 19887700], 
length 0
10:28:44.616824 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113879485:113883829, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616871 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113883829:113888173, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.616926 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.616933 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113892517:113895413, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 2896
10:28:44.617018 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113895413:113899757, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.617024 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113899757:113904101, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.617069 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
113785365, win 32885, options [nop,nop,TS val 52675811 ecr 19887700], 
length 0
10:28:44.617078 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113904101:113908445, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.617085 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113908445:113912789, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.617114 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113912789:113917133, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.617169 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113917133:113920029, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 2896
10:28:44.617221 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
113808533, win 32885, options [nop,nop,TS val 52675811 ecr 19887700], 
length 0
10:28:44.617229 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.617269 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113924373:113928717, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.617275 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113928717:113933061, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.617314 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113933061:113937405, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.617372 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113937405:113941749, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 4344
10:28:44.617415 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
113831701, win 32885, options [nop,nop,TS val 52675811 ecr 19887700], 
length 0
10:28:44.617424 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113941749:113944645, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 2896
10:28:44.617431 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113944645:113946093, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 1448
10:28:44.617472 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [P.], seq 
113946093:113946157, ack 33936, win 24576, options [nop,nop,TS val 
19887700 ecr 52675811], length 64
10:28:44.617567 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
113851973, win 32885, options [nop,nop,TS val 52675811 ecr 19887700], 
length 0
10:28:44.617770 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
113865005, win 32885, options [nop,nop,TS val 52675811 ecr 19887700], 
length 0
10:28:44.617965 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
113882381, win 32885, options [nop,nop,TS val 52675811 ecr 19887700], 
length 0
10:28:44.618184 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
113904101, win 32885, options [nop,nop,TS val 52675811 ecr 19887700], 
length 0
10:28:44.618432 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
113927269, win 32885, options [nop,nop,TS val 52675811 ecr 19887700], 
length 0
10:28:44.618547 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
113946157, win 32885, options [nop,nop,TS val 52675811 ecr 19887700], 
length 0
10:28:44.618553 IP 192.168.201.44.nfs > 172.20.4.10.3688546054: reply ok 
52 getattr ERROR: unk 10024
10:28:44.618574 IP 172.20.4.10.3705323270 > 192.168.201.44.nfs: 2892 
getattr fh 0,0/22
10:28:44.618590 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.618594 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.618602 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.618607 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.618612 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.618617 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.618622 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.618625 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.618629 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113982357:113986701, ack 33992, win 24576, options [nop,nop,TS val 
19887701 ecr 52675811], length 4344
10:28:44.618634 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113986701:113991045, ack 33992, win 24576, options [nop,nop,TS val 
19887701 ecr 52675811], length 4344
10:28:44.618638 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113991045:113995389, ack 33992, win 24576, options [nop,nop,TS val 
19887701 ecr 52675811], length 4344
10:28:44.618642 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113995389:113998285, ack 33992, win 24576, options [nop,nop,TS val 
19887701 ecr 52675811], length 2896
10:28:44.618646 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
113998285:114002629, ack 33992, win 24576, options [nop,nop,TS val 
19887701 ecr 52675811], length 4344
10:28:44.618656 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
114002629:114006973, ack 33992, win 24576, options [nop,nop,TS val 
19887701 ecr 52675811], length 4344
10:28:44.618662 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
114006973:114011317, ack 33992, win 24576, options [nop,nop,TS val 
19887701 ecr 52675811], length 4344
10:28:44.618665 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
114011317:114015661, ack 33992, win 24576, options [nop,nop,TS val 
19887701 ecr 52675811], length 4344
10:28:44.636565 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
115255533, win 32885, options [nop,nop,TS val 52675813 ecr 19887705], 
length 0
10:28:44.644779 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
115865333, win 32885, options [nop,nop,TS val 52675813 ecr 19887707], 
length 0
10:28:44.652558 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
116404181, win 32885, options [nop,nop,TS val 52675814 ecr 19887709], 
length 0
10:28:44.652774 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
116427349, win 32885, options [nop,nop,TS val 52675814 ecr 19887709], 
length 0
10:28:44.653089 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
116449069, win 32885, options [nop,nop,TS val 52675814 ecr 19887709], 
length 0
10:28:44.653225 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
116470789, win 32885, options [nop,nop,TS val 52675814 ecr 19887709], 
length 0
10:28:44.653378 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
116483821, win 32885, options [nop,nop,TS val 52675814 ecr 19887709], 
length 0
10:28:44.653525 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
116499749, win 32885, options [nop,nop,TS val 52675814 ecr 19887709], 
length 0
10:28:44.653793 IP 192.168.201.44.nfs > 172.20.4.10.725: Flags [.], ack 
116507053, win 32885, options [nop,nop,TS val 52675814 ecr 19887709], 
length 0
10:28:44.653799 IP 192.168.201.44.nfs > 172.20.4.10.3906649862: reply ok 
52
10:28:44.653825 IP 172.20.4.10.3923427078 > 192.168.201.44.nfs: 2892 
getattr fh 0,0/22
10:28:44.653836 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.653844 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.653851 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.653865 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.653870 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.653875 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.653881 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.653884 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.653888 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116543253:116547597, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 4344
10:28:44.653891 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116547597:116551941, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 4344
10:28:44.653894 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116551941:116556285, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 4344
10:28:44.653898 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116556285:116559181, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 2896
10:28:44.653902 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116559181:116563525, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 4344
10:28:44.653908 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116563525:116567869, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 4344
10:28:44.653912 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116567869:116572213, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 4344
10:28:44.653921 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116572213:116576557, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 4344
10:28:44.653926 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
10:28:44.653971 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116580901:116583797, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 2896
10:28:44.653974 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116583797:116588141, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 4344
10:28:44.654020 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116588141:116592485, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 4344
10:28:44.654072 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116592485:116596829, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 4344
10:28:44.654078 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116596829:116601173, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 4344
10:28:44.654125 IP 172.20.4.10.725 > 192.168.201.44.nfs: Flags [.], seq 
116601173:116604069, ack 34720, win 24576, options [nop,nop,TS val 
19887710 ecr 52675814], length 2896

This pattern pretty much repeats. Firefox has hung up too:
ps uaxww| grep firefox
jocke     6330  0.2  0.0      0     0 tty1     Zl   Apr15   3:04 [firefox] 
<defunct>
jocke    10655  0.0  6.8 733648 279432 tty1    D    10:25   0:00 firefox
jocke    10691  0.0  6.8 733648 279432 tty1    D    10:26   0:00 firefox

restarting client nfs(on gentoo) /etc/init.d/nfs restart
does nothing.
Anyone?

 Jocke

Joakim Tjernlund/Transmode wrote on 2013/04/15 10:48:56:

> From: Joakim Tjernlund/Transmode
> To: 
> Cc: linux-nfs@vger.kernel.org
> Date: 2013/04/15 10:48
> Subject: Re: NFS loop on 3.4.39
> 
> Just as I had sent this it happened again, this time the log is 
different:
> 
> 10:44:04.620830 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], seq 
> 1201909:1207701, ack 4573720, win 32885, options [nop,nop,TS val 
44127811 ecr 
> 585513], length 5792
> 10:44:04.620836 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [.], ack 
> 1207701, win 5928, options [nop,nop,TS val 585514 ecr 44127811], length 
0
> 10:44:04.620868 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [P.], seq 

> 1207701:1209133, ack 4573720, win 32885, options [nop,nop,TS val 
44127811 ecr 
> 585513], length 1432
> 10:44:04.620899 IP 172.20.4.10.1635289962 > 192.168.201.44.nfs: 2892 
getattr fh 0,0/22
> 10:44:04.620908 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [P.], seq 

> 4576616:4578056, ack 1209133, win 5928, options [nop,nop,TS val 585514 
ecr 
> 44127811], length 1440
> 10:44:04.621365 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], ack 
> 4578056, win 32872, options [nop,nop,TS val 44127811 ecr 585514], length 
0
> 10:44:04.621370 IP 192.168.201.44.nfs > 172.20.4.10.1635289962: reply ok 
132 
> getattr NON 3 ids 0/38 sz 0
> 10:44:04.621389 IP 172.20.4.10.1652067178 > 192.168.201.44.nfs: 224 
getattr fh 0,0/22
> 10:44:04.621747 IP 192.168.201.44.nfs > 172.20.4.10.1652067178: reply ok 
132 
> getattr NON 3 ids 0/4 sz 0
> 10:44:04.621807 IP 172.20.4.10.1668844394 > 192.168.201.44.nfs: 236 
getattr fh 0,0/22
> 10:44:04.621830 IP 172.20.4.10.1685621610 > 192.168.201.44.nfs: 232 
getattr fh 0,0/22
> 10:44:04.622263 IP 192.168.201.44.nfs > 172.20.4.10.1668844394: reply ok 
136 
> getattr NON 3 ids 0/28 sz 0
> 10:44:04.622320 IP 192.168.201.44.nfs > 172.20.4.10.1685621610: reply ok 
236 
> getattr NON 4 ids 0/15 sz 0
> 10:44:04.622327 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [.], ack 
> 1209785, win 5928, options [nop,nop,TS val 585514 ecr 44127811], length 
0
> 10:44:04.622366 IP 172.20.4.10.1702398826 > 192.168.201.44.nfs: 228 
getattr fh 0,0/22
> 10:44:04.622770 IP 192.168.201.44.nfs > 172.20.4.10.1702398826: reply ok 
216 
> getattr NON 3 ids 0/28 sz 0
> 10:44:04.623288 IP 172.20.4.10.1719176042 > 192.168.201.44.nfs: 316 
getattr fh 0,0/22
> 10:44:04.623786 IP 192.168.201.44.nfs > 172.20.4.10.1719176042: reply ok 
372 
> getattr NON 7 ids 0/32 sz 0
> 10:44:04.623841 IP 172.20.4.10.1735953258 > 192.168.201.44.nfs: 248 
getattr fh 0,0/22
> 10:44:04.624323 IP 192.168.201.44.nfs > 172.20.4.10.1735953258: reply ok 
208 
> getattr NON 3 ids 0/34 sz 0
> 10:44:04.624386 IP 172.20.4.10.1752730474 > 192.168.201.44.nfs: 2892 
getattr fh 0,0/22
> 10:44:04.624397 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [.], seq 
> 4582460:4586804, ack 1210593, win 5928, options [nop,nop,TS val 585514 
ecr 
> 44127811], length 4344
> 10:44:04.624404 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [.], seq 
> 4586804:4588252, ack 1210593, win 5928, options [nop,nop,TS val 585514 
ecr 
> 44127811], length 1448
> 10:44:04.624410 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [P.], seq 

> 4588252:4588412, ack 1210593, win 5928, options [nop,nop,TS val 585514 
ecr 
> 44127811], length 160
> 10:44:04.624976 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], ack 
> 4586804, win 32861, options [nop,nop,TS val 44127811 ecr 585514], length 
0
> 10:44:04.624987 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], ack 
> 4588412, win 32875, options [nop,nop,TS val 44127811 ecr 585514], length 
0
> 10:44:04.625038 IP 192.168.201.44.nfs > 172.20.4.10.1752730474: reply ok 
132 
> getattr NON 3 ids 0/38 sz 0
> 10:44:04.625070 IP 172.20.4.10.1769507690 > 192.168.201.44.nfs: 224 
getattr fh 0,0/22
> 10:44:04.625432 IP 192.168.201.44.nfs > 172.20.4.10.1769507690: reply ok 
132 
> getattr NON 3 ids 0/4 sz 0
> 10:44:04.625536 IP 172.20.4.10.1786284906 > 192.168.201.44.nfs: 328 
getattr fh 0,0/22
> 10:44:04.626082 IP 192.168.201.44.nfs > 172.20.4.10.1786284906: reply ok 
372 
> getattr NON 7 ids 0/32 sz 0
> 10:44:04.626171 IP 172.20.4.10.1803062122 > 192.168.201.44.nfs: 248 
getattr fh 0,0/22
> 10:44:04.626672 IP 192.168.201.44.nfs > 172.20.4.10.1803062122: reply ok 
208 
> getattr NON 3 ids 0/34 sz 0
> 10:44:04.626790 IP 172.20.4.10.1819839338 > 192.168.201.44.nfs: 200 
getattr fh 0,0/22
> 10:44:04.627315 IP 192.168.201.44.nfs > 172.20.4.10.1819839338: reply ok 
116 
> getattr NON 2 ids 0/9 sz 0
> 10:44:04.627407 IP 172.20.4.10.1836616554 > 192.168.201.44.nfs: 232 
getattr fh 0,0/22
> 10:44:04.627910 IP 192.168.201.44.nfs > 172.20.4.10.1836616554: reply ok 
52 
> getattr ERROR: No such file or directory
> 10:44:04.627999 IP 172.20.4.10.1853393770 > 192.168.201.44.nfs: 2892 
getattr fh 0,0/22
> 10:44:04.628009 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.628015 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.628021 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.628024 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.628030 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.628102 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.628112 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.628147 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.628604 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], ack 
> 4604144, win 32825, options [nop,nop,TS val 44127812 ecr 585515], length 
0
> 10:44:04.628994 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], ack 
> 4614280, win 32855, options [nop,nop,TS val 44127812 ecr 585515], length 
0
> 10:44:04.629143 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], ack 
> 4622672, win 32856, options [nop,nop,TS val 44127812 ecr 585515], length 
0
> 10:44:04.629153 IP 192.168.201.44.nfs > 172.20.4.10.1853393770: reply ok 
132 
> getattr NON 3 ids 0/38 sz 0
> 10:44:04.629207 IP 172.20.4.10.1870170986 > 192.168.201.44.nfs: 224 
getattr fh 0,0/22
> 10:44:04.629767 IP 192.168.201.44.nfs > 172.20.4.10.1870170986: reply ok 
132 
> getattr NON 3 ids 0/4 sz 0
> 10:44:04.629898 IP 172.20.4.10.1886948202 > 192.168.201.44.nfs: 316 
getattr fh 0,0/22
> 10:44:04.630472 IP 192.168.201.54.1533 > 172.20.4.10.40942: Flags [P.], 
seq 
> 39752:40773, ack 1, win 353, options [nop,nop,TS val 647820778 ecr 
585507], length 1021
> 10:44:04.630482 IP 192.168.201.44.nfs > 172.20.4.10.1886948202: reply ok 
404 
> getattr NON 7 ids 0/32 sz 0
> 10:44:04.630574 IP 172.20.4.10.40942 > 192.168.201.54.1533: Flags [.], 
ack 
> 40773, win 369, options [nop,nop,TS val 585516 ecr 647820778], length 0
> 10:44:04.630582 IP 172.20.4.10.1903725418 > 192.168.201.44.nfs: 208 
getattr fh 0,0/22
> 10:44:04.631037 IP 192.168.201.44.nfs > 172.20.4.10.1903725418: reply ok 
124 
> getattr NON 3 ids 0/3 sz 0
> 10:44:04.631130 IP 172.20.4.10.1920502634 > 192.168.201.44.nfs: 296 
getattr fh 0,0/22
> 10:44:04.631671 IP 192.168.201.44.nfs > 172.20.4.10.1920502634: reply ok 
372 
> getattr NON 7 ids 0/32 sz 0
> 10:44:04.631757 IP 172.20.4.10.1937279850 > 192.168.201.44.nfs: 224 
getattr fh 0,0/22
> 10:44:04.632133 IP 192.168.201.44.nfs > 172.20.4.10.1937279850: reply ok 
236 
> getattr NON 4 ids 0/15 sz 0
> 10:44:04.632225 IP 172.20.4.10.1954057066 > 192.168.201.44.nfs: 240 
getattr fh 0,0/22
> 10:44:04.632661 IP 192.168.201.44.nfs > 172.20.4.10.1954057066: reply ok 
52 
> getattr ERROR: No such file or directory
> 10:44:04.632746 IP 172.20.4.10.1970834282 > 192.168.201.44.nfs: 304 
getattr fh 0,0/22
> 10:44:04.633220 IP 192.168.201.44.nfs > 172.20.4.10.1970834282: reply ok 
404 
> getattr NON 7 ids 0/32 sz 0
> 10:44:04.633313 IP 172.20.4.10.1987611498 > 192.168.201.44.nfs: 288 
getattr fh 0,0/22
> 10:44:04.633836 IP 192.168.201.44.nfs > 172.20.4.10.1987611498: reply ok 
404 
> getattr NON 7 ids 0/32 sz 0
> 10:44:04.633930 IP 172.20.4.10.2004388714 > 192.168.201.44.nfs: 200 
getattr fh 0,0/22
> 10:44:04.634466 IP 192.168.201.44.nfs > 172.20.4.10.2004388714: reply ok 
188 
> getattr NON 2 ids 0/9 sz 0
> 10:44:04.634595 IP 172.20.4.10.2021165930 > 192.168.201.44.nfs: 216 
getattr fh 0,0/22
> 10:44:04.635213 IP 192.168.201.44.nfs > 172.20.4.10.2021165930: reply ok 
4340 
> getattr NON 2 ids 0/25 sz 0
> 10:44:04.635225 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [.], ack 
> 1218461, win 5928, options [nop,nop,TS val 585517 ecr 44127812], length 
0
> 10:44:04.635260 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [P.], seq 

> 1218461:1222789, ack 4625228, win 32885, options [nop,nop,TS val 
44127812 ecr 
> 585517], length 4328
> 10:44:04.635274 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [.], ack 
> 1222789, win 5928, options [nop,nop,TS val 585517 ecr 44127812], length 
0
> 10:44:04.635319 IP 172.20.4.10.2037943146 > 192.168.201.44.nfs: 2892 
getattr fh 0,0/22
> 10:44:04.635327 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [P.], seq 

> 4628124:4629564, ack 1222789, win 5928, options [nop,nop,TS val 585517 
ecr 
> 44127812], length 1440
> 10:44:04.636099 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], ack 
> 4629564, win 32872, options [nop,nop,TS val 44127812 ecr 585517], length 
0
> 10:44:04.636105 IP 192.168.201.44.nfs > 172.20.4.10.2037943146: reply ok 
132 
> getattr NON 3 ids 0/38 sz 0
> 10:44:04.636135 IP 172.20.4.10.2054720362 > 192.168.201.44.nfs: 224 
getattr fh 0,0/22
> 10:44:04.636645 IP 192.168.201.44.nfs > 172.20.4.10.2054720362: reply ok 
132 
> getattr NON 3 ids 0/4 sz 0
> 10:44:04.636698 IP 172.20.4.10.2071497578 > 192.168.201.44.nfs: 236 
getattr fh 0,0/22
> 10:44:04.636720 IP 172.20.4.10.2088274794 > 192.168.201.44.nfs: 232 
getattr fh 0,0/22
> 10:44:04.637307 IP 192.168.201.44.nfs > 172.20.4.10.2071497578: reply ok 
136 
> getattr NON 3 ids 0/28 sz 0
> 10:44:04.637319 IP 192.168.201.44.nfs > 172.20.4.10.2088274794: reply ok 
236 
> getattr NON 4 ids 0/15 sz 0
> 10:44:04.637328 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [.], ack 
> 1223441, win 5928, options [nop,nop,TS val 585518 ecr 44127812], length 
0
> 10:44:04.637394 IP 172.20.4.10.2105052010 > 192.168.201.44.nfs: 228 
getattr fh 0,0/22
> 10:44:04.638006 IP 192.168.201.44.nfs > 172.20.4.10.2105052010: reply ok 
216 
> getattr NON 3 ids 0/28 sz 0
> 10:44:04.638594 IP 172.20.4.10.2121829226 > 192.168.201.44.nfs: 316 
getattr fh 0,0/22
> 10:44:04.639181 IP 192.168.201.44.nfs > 172.20.4.10.2121829226: reply ok 
372 
> getattr NON 7 ids 0/32 sz 0
> 10:44:04.639293 IP 172.20.4.10.2138606442 > 192.168.201.44.nfs: 248 
getattr fh 0,0/22
> 10:44:04.639737 IP 192.168.201.44.nfs > 172.20.4.10.2138606442: reply ok 
208 
> getattr NON 3 ids 0/34 sz 0
> 10:44:04.639833 IP 172.20.4.10.2155383658 > 192.168.201.44.nfs: 2892 
getattr fh 0,0/22
> 10:44:04.639842 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [.], seq 
> 4633968:4638312, ack 1224249, win 5928, options [nop,nop,TS val 585518 
ecr 
> 44127813], length 4344
> 10:44:04.639849 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [.], seq 
> 4638312:4639760, ack 1224249, win 5928, options [nop,nop,TS val 585518 
ecr 
> 44127813], length 1448
> 10:44:04.639855 IP 172.20.4.10.763 > 192.168.201.44.nfs: Flags [P.], seq 

> 4639760:4639920, ack 1224249, win 5928, options [nop,nop,TS val 585518 
ecr 
> 44127813], length 160
> 10:44:04.640300 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], ack 
> 4633968, win 32878, options [nop,nop,TS val 44127813 ecr 585518], length 
0
> 10:44:04.640387 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], ack 
> 4639920, win 32885, options [nop,nop,TS val 44127813 ecr 585518], length 
0
> 10:44:04.640393 IP 192.168.201.44.nfs > 172.20.4.10.2155383658: reply ok 
132 
> getattr NON 3 ids 0/38 sz 0
> 10:44:04.640430 IP 172.20.4.10.2172160874 > 192.168.201.44.nfs: 224 
getattr fh 0,0/22
> 10:44:04.640807 IP 192.168.201.44.nfs > 172.20.4.10.2172160874: reply ok 
132 
> getattr NON 3 ids 0/4 sz 0
> 10:44:04.640902 IP 172.20.4.10.2188938090 > 192.168.201.44.nfs: 208 
getattr fh 0,0/22
> 10:44:04.641345 IP 192.168.201.44.nfs > 172.20.4.10.2188938090: reply ok 
124 
> getattr NON 3 ids 0/3 sz 0
> 10:44:04.641436 IP 172.20.4.10.2205715306 > 192.168.201.44.nfs: 328 
getattr fh 0,0/22
> 10:44:04.642009 IP 192.168.201.44.nfs > 172.20.4.10.2205715306: reply ok 
372 
> getattr NON 7 ids 0/32 sz 0
> 10:44:04.642087 IP 172.20.4.10.2222492522 > 192.168.201.44.nfs: 248 
getattr fh 0,0/22
> 10:44:04.642601 IP 192.168.201.44.nfs > 172.20.4.10.2222492522: reply ok 
208 
> getattr NON 3 ids 0/34 sz 0
> 10:44:04.642686 IP 172.20.4.10.2239269738 > 192.168.201.44.nfs: 200 
getattr fh 0,0/22
> 10:44:04.643176 IP 192.168.201.44.nfs > 172.20.4.10.2239269738: reply ok 
116 
> getattr NON 2 ids 0/9 sz 0
> 10:44:04.643209 IP 172.20.4.10.2256046954 > 192.168.201.44.nfs: 232 
getattr fh 0,0/22
> 10:44:04.643671 IP 192.168.201.44.nfs > 172.20.4.10.2256046954: reply ok 
52 
> getattr ERROR: No such file or directory
> 10:44:04.643711 IP 172.20.4.10.2272824170 > 192.168.201.44.nfs: 2892 
getattr fh 0,0/22
> 10:44:04.643722 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.643737 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.643740 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.643745 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.643750 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.643812 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.643818 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.643861 IP 172.20.4.10.0 > 192.168.201.44.nfs: 0 null
> 10:44:04.644229 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], ack 
> 4650072, win 32848, options [nop,nop,TS val 44127813 ecr 585519], length 
0
> 10:44:04.644285 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], ack 
> 4657312, win 32861, options [nop,nop,TS val 44127813 ecr 585519], length 
0
> 10:44:04.644526 IP 192.168.201.44.nfs > 172.20.4.10.763: Flags [.], ack 
> 4674392, win 32885, options [nop,nop,TS val 44127813 ecr 585519], length 
0
> 10:44:04.644583 IP 192.168.201.44.nfs > 172.20.4.10.2272824170: reply ok 
132 
> getattr NON 3 ids 0/38 sz 0
> 10:44:04.644641 IP 172.20.4.10.2289601386 > 192.168.201.44.nfs: 224 
getattr fh 0,0/22
> 10:44:04.645057 IP 192.168.201.44.nfs > 172.20.4.10.2289601386: reply ok 
132 
> getattr NON 3 ids 0/4 sz 0
> 10:44:04.645149 IP 172.20.4.10.2306378602 > 192.168.201.44.nfs: 316 
getattr fh 0,0/22
> 10:44:04.645601 IP 192.168.201.44.nfs > 172.20.4.10.2306378602: reply ok 
404 
> getattr NON 7 ids 0/32 sz 0
> 10:44:04.645661 IP 172.20.4.10.2323155818 > 192.168.201.44.nfs: 296 
getattr fh 0,0/22
> 10:44:04.646057 IP 192.168.201.44.nfs > 172.20.4.10.2323155818: reply ok 
372 
> getattr NON 7 ids 0/32 sz 0
> 10:44:04.646144 IP 172.20.4.10.2339933034 > 192.168.201.44.nfs: 240 
getattr fh 0,0/22
> 10:44:04.646572 IP 192.168.201.44.nfs > 172.20.4.10.2339933034: reply ok 
52 
> getattr ERROR: No such file or directory
> 10:44:04.646601 IP 172.20.4.10.2356710250 > 192.168.201.44.nfs: 304 
getattr fh 0,0/22
> 10:44:04.647090 IP 192.168.201.44.nfs > 172.20.4.10.2356710250: reply ok 
404 
> getattr NON 7 ids 0/32 sz 0
> 10:44:04.648915 IP 192.168.201.44.nfs > 172.20.4.10.2407041898: reply ok 
2892
> 
> This time it seems like 
>   3014 jocke     20   0  8488 1988 1636 D   14  0.0   2:28.67 
gvfsd-metadata
> is the victim.
> 
>  Jocke
> 
> Joakim Tjernlund/Transmode wrote on 2013/04/15 10:41:22:
> 
> > From: Joakim Tjernlund/Transmode
> > To: 
> > Cc: linux-nfs@vger.kernel.org
> > Date: 2013/04/15 10:41
> > Subject: Re: NFS loop on 3.4.39
> > 
> > hmm, I got another log which i a little different:
> > 
> > 16:01:48.478917 IP 172.20.4.10.3676268197 > 192.168.201.44.nfs: 272 
getattr fh 0,0/22
> > 16:01:48.479352 IP 192.168.201.44.nfs > 172.20.4.10.3676268197: reply 
ok 52 
> > getattr ERROR: unk 10025
> > 16:01:48.479394 IP 172.20.4.10.3693045413 > 192.168.201.44.nfs: 272 
getattr fh 0,0/22
> > 16:01:48.479761 IP 192.168.201.44.nfs > 172.20.4.10.3693045413: reply 
ok 52 
> > getattr ERROR: unk 10025
> > 16:01:48.479887 IP 172.20.4.10.3709822629 > 192.168.201.44.nfs: 272 
getattr fh 0,0/22
> > 16:01:48.480316 IP 192.168.201.44.nfs > 172.20.4.10.3709822629: reply 
ok 52 
> > getattr ERROR: unk 10025
> > 16:01:48.480415 IP 172.20.4.10.3726599845 > 192.168.201.44.nfs: 272 
getattr fh 0,0/22
> > 16:01:48.480760 IP 192.168.201.44.nfs > 172.20.4.10.3726599845: reply 
ok 52 
> > getattr ERROR: unk 10025
> > 16:01:48.480882 IP 172.20.4.10.3743377061 > 192.168.201.44.nfs: 272 
getattr fh 0,0/22
> > 16:01:48.481554 IP 192.168.201.44.nfs > 172.20.4.10.3743377061: reply 
ok 52 
> > getattr ERROR: unk 10025
> > 16:01:48.481652 IP 172.20.4.10.3760154277 > 192.168.201.44.nfs: 272 
getattr fh 0,0/22
> > 16:01:48.482002 IP 192.168.201.44.nfs > 172.20.4.10.3760154277: reply 
ok 52 
> > getattr ERROR: unk 10025
> > 16:01:48.482085 IP 172.20.4.10.3776931493 > 192.168.201.44.nfs: 272 
getattr fh 0,0/22
> > 16:01:48.482452 IP 192.168.201.44.nfs > 172.20.4.10.3776931493: reply 
ok 52 
> > getattr ERROR: unk 10025
> > 16:01:48.482537 IP 172.20.4.10.3793708709 > 192.168.201.44.nfs: 272 
getattr fh 0,0/22
> > 16:01:48.482937 IP 192.168.201.44.nfs > 172.20.4.10.3793708709: reply 
ok 52 
> > getattr ERROR: unk 10025
> > 16:01:48.483050 IP 172.20.4.10.3810485925 > 192.168.201.44.nfs: 272 
getattr fh 0,0/22
> > 16:01:48.483399 IP 192.168.201.44.nfs > 172.20.4.10.3810485925: reply 
ok 52 
> > getattr ERROR: unk 10025
> > 16:01:48.483439 IP 172.20.4.10.3827263141 > 192.168.201.44.nfs: 272 
getattr fh 0,0/22
> > 16:01:48.483803 IP 192.168.201.44.nfs > 172.20.4.10.3827263141: reply 
ok 52 
> > getattr ERROR: unk 10025
> > 
> > This is with a somewhat older kernel though: 3.4.35
> > 
> > The NFS sever is running 3.4.39 in both cases.
> > 
> > Joakim Tjernlund/Transmode wrote on 2013/04/15 10:19:39:
> > 
> > > From: Joakim Tjernlund/Transmode
> > > To: linux-nfs@vger.kernel.org, 
> > > Date: 2013/04/15 10:19
> > > Subject: NFS loop on 3.4.39
> > > 
> > > I get som NFS loop which generates lots of (from tcpdump):
> > > 9:48:43.156252 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], 
ack 
> > > 8406616, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], 
length 0
> > > 09:48:43.156258 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], 
ack 
> > > 8426888, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], 
length 0
> > > 09:48:43.156669 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], 
ack 
> > > 8445712, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], 
length 0
> > > 09:48:43.156675 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], 
ack 
> > > 8459880, win 32883, options [nop,nop,TS val 43795665 ecr 57419706], 
length 0
> > > 09:48:43.156679 IP 192.168.201.44.nfs > 172.20.4.10.2889942938: 
reply ok 52 
> > > getattr ERROR: unk 10024
> > > 09:48:43.156704 IP 172.20.4.10.2923497370 > 192.168.201.44.nfs: 2892 

> getattrfh 0,0/22
> > > 09:48:43.156712 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8462776:8467120, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156719 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8467120:8471464, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156725 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8471464:8475808, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156731 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8475808:8480152, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156745 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8480152:8484496, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156748 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8484496:8487392, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 2896
> > > 09:48:43.156751 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8487392:8491736, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156755 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8491736:8496080, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156758 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8496080:8500424, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156764 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8500424:8504768, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156767 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8504768:8509112, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156770 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8509112:8512008, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 2896
> > > 09:48:43.156773 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8512008:8516352, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156778 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8516352:8520696, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156956 IP 192.168.201.44.nfs > 172.20.4.10.2906720154: 
reply ok 52 
> > > getattr ERROR: unk 10024
> > > 09:48:43.156969 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8520696:8525040, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156975 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8525040:8529384, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156980 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8529384:8533728, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156984 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8533728:8536624, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 2896
> > > 09:48:43.156988 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8536624:8540968, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156994 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8540968:8545312, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.156999 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8545312:8549656, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.157209 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], 
ack 
> > > 8464224, win 32872, options [nop,nop,TS val 43795665 ecr 57419706], 
length 0
> > > 09:48:43.157219 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8549656:8554000, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.157225 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8554000:8558344, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.157230 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [P.], 
seq 
> > > 8558344:8558424, ack 9577, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 80
> > > 09:48:43.157235 IP 172.20.4.10.2940274586 > 192.168.201.44.nfs: 532 
> getattr fh 0,0/22
> > > 09:48:43.157460 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], 
ack 
> > > 8485944, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], 
length 0
> > > 09:48:43.157709 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], 
ack 
> > > 8504768, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], 
length 0
> > > 09:48:43.157715 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], 
ack 
> > > 8526488, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], 
length 0
> > > 09:48:43.158126 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], 
ack 
> > > 8543864, win 32885, options [nop,nop,TS val 43795665 ecr 57419706], 
length 0
> > > 09:48:43.158133 IP 192.168.201.44.nfs > 172.20.4.10.con: Flags [.], 
ack 
> > > 8558960, win 32883, options [nop,nop,TS val 43795665 ecr 57419706], 
length 0
> > > 09:48:43.158138 IP 192.168.201.44.nfs > 172.20.4.10.2923497370: 
reply ok 52 
> > > getattr ERROR: unk 10024
> > > 09:48:43.158143 IP 192.168.201.44.nfs > 172.20.4.10.2940274586: 
reply ok 52 
> > > getattr ERROR: unk 10024
> > > 09:48:43.158149 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
ack 9745, 
> > > win 23907, options [nop,nop,TS val 57419706 ecr 43795665], length 0
> > > 09:48:43.158174 IP 172.20.4.10.2957051802 > 192.168.201.44.nfs: 2892 

> getattrfh 0,0/22
> > > 09:48:43.158192 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8561856:8566200, ack 9745, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.158197 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8566200:8570544, ack 9745, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.158204 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8570544:8574888, ack 9745, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.158210 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8574888:8579232, ack 9745, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.158216 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8579232:8583576, ack 9745, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.158222 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8583576:8586472, ack 9745, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 2896
> > > 09:48:43.158226 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8586472:8590816, ack 9745, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.158233 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8590816:8595160, ack 9745, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 09:48:43.158239 IP 172.20.4.10.con > 192.168.201.44.nfs: Flags [.], 
seq 
> > > 8595160:8599504, ack 9745, win 23907, options [nop,nop,TS val 
57419706 ecr 
> > > 43795665], length 4344
> > > 
> > > I wonder if this is a variant on:
> > > 
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/

> > > 
fs/nfs/nfs4proc.c?h=linux-3.6.y&id=9fa2b82e5592a7aa7a63b7f6a32c5aa9e580643a
> > > 
> > > which does seem to be in the 3.4 stable branch?
> > > 
> > >  Jocke
