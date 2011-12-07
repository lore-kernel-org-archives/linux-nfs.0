Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mg.narl.org.tw ([140.110.32.154]:42907 "HELO mg.narl.org.tw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755050Ab1LGMuP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Dec 2011 07:50:15 -0500
Message-ID: <4EDF5F94.80208@nchc.org.tw>
Date: Wed, 07 Dec 2011 20:44:04 +0800
From: Steven Shiau <steven@nchc.org.tw>
MIME-Version: 1.0
To: Anibal Monsalve Salazar <anibal@debian.org>
CC: Steve Dickson <SteveD@redhat.com>, Kevin Coffman <kwc@umich.edu>,
        linux-nfs@vger.kernel.org, Michael Rasmussen <mir@datanom.net>,
        651032@bugs.debian.org, Rares Aioanei <schaiba@gmail.com>,
        649491@bugs.debian.org, Bjoern Buerger <bbu@pengutronix.de>,
        650904@bugs.debian.org, 650948@bugs.debian.org
Subject: Re: Bug#651032: /usr/sbin/rpc.idmapd: rpc.idmapd referring to none
 existing library
References: <20111205071808.5626.67399.reportbug@sleipner.datanom.net> <20111205082520.GA5890@debian.org> <4EDCE8B2.1050702@RedHat.com> <20111205184206.GA5207@debian.org> <4EDD27AB.9010803@RedHat.com>
In-Reply-To: <4EDD27AB.9010803@RedHat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anibal,
I confirm this issue is gone in 0.24-4. Cool! Thanks!
========================================
$ sudo apt-get install nfs-common
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following extra packages will be installed:
  libnfsidmap2
The following NEW packages will be installed:
  libnfsidmap2 nfs-common
0 upgraded, 2 newly installed, 0 to remove and 1 not upgraded.
Need to get 304 kB of archives.
After this operation, 752 kB of additional disk space will be used.
Do you want to continue [Y/n]?
Get:1 http://free.nchc.org.tw/debian/ sid/main libnfsidmap2 i386 0.24-4
[28.5 kB]
Get:2 http://free.nchc.org.tw/debian/ sid/main nfs-common i386
1:1.2.5-2+b1 [276 kB]
Fetched 304 kB in 0s (1,284 kB/s)
Selecting previously unselected package libnfsidmap2.
(Reading database ... 139229 files and directories currently installed.)
Unpacking libnfsidmap2 (from .../libnfsidmap2_0.24-4_i386.deb) ...
Selecting previously unselected package nfs-common.
Unpacking nfs-common (from .../nfs-common_1%3a1.2.5-2+b1_i386.deb) ...
Processing triggers for man-db ...
Setting up libnfsidmap2 (0.24-4) ...
Setting up nfs-common (1:1.2.5-2+b1) ...

Creating config file /etc/idmapd.conf with new version

Creating config file /etc/default/nfs-common with new version
Starting NFS common utilities: statd idmapd.
========================================

Steven.

-- 
Steven Shiau <steven _at_ nchc org tw> <steven _at_ stevenshiau org>
National Center for High-performance Computing, Taiwan.
http://www.nchc.org.tw
Public Key Server PGP Key ID: 1024D/9762755A
Fingerprint: A2A1 08B7 C22C 3D06 34DB  F4BC 08B3 E3D7 9762 755A
