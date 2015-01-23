Return-Path: linux-nfs-owner@vger.kernel.org
Received: from evbyminsa0101.epam.com ([217.21.63.36]:57923 "EHLO
	EVBYMINSA0101.epam.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754278AbbAWNcM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2015 08:32:12 -0500
From: Pavel Karneliuk <Pavel_Karneliuk@epam.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: nfstrace - sniffer of NFS statistics for 1+Gbps traffic
Date: Fri, 23 Jan 2015 13:17:03 +0000
Message-ID: <d210b8c7bfcf429b852e186fe10a6918@EPBYMINSA0001.epam.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I would like to present the nfstrace utility - it is a tool for collecting NFS statistics in LAN.
Nfstrace captures a raw network traffic, performs payload filtration and performs full analysis and tracing of NFSv3/v4 procedures(operations).
The key feature of nfstrace is that it is designed and implemented for online analysis of 1-10Gbps traffic in LAN.

At this moment, the utility supports next protocols:
- Ethernet;
- IPv4, v6;
- UDP, TCP;
- NFSv3, NFSv4 (4.1 and CIFS are coming).

The nfstrace is user-space utility and performs interactions with NIC via libpcap (similar to wireshark/tcpdump). 
Therefore, it could be ported to many POSIX platforms.

Now it is available in:
Debian:     https://packages.debian.org/unstable/main/nfstrace
Ubuntu:    http://packages.ubuntu.com/vivid/net/nfstrace
ALT Linux: http://www.sisyphus.ru/en/srpm/Sisyphus/nfstrace

The key feature is reliable statistics on high traffic speed.
Nfstrace cuts-off payload on earlier stages of filtration and stays focused on headers of NFSv3/v4 procedures and operations.
The analysis is performed on the fly, without storing huge amount of network packets to memory/disk.
So, it is faster that Wireshark/Tshark.
Nfstrace provides API for custom plug-ins. It is easy to sharp its functionality for special purposes and metrics.
There are set of standard plugins in sources tree. For example, the watch plug-in - it is clone of old and famous nfswatch tool (but with Ipv6, NFSv4 and TCP stream reassembling).

Take a look, please:
 https://github.com/epam/nfstrace

It would be nice to get feedback and some opinions from community.
Feature requests are welcome!

Thanks!
Pavel K

