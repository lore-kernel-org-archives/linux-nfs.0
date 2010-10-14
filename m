Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from snt0-omc3-s7.snt0.hotmail.com ([65.55.90.146]:4707 "EHLO
	snt0-omc3-s7.snt0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753539Ab0JNWjL convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Oct 2010 18:39:11 -0400
Message-ID: <SNT118-W30AF741CD2856C503B4CBECD560@phx.gbl>
From: David Stalder <davestar99@hotmail.com>
To: <linux-nfs@vger.kernel.org>
Subject: Client machine freezes under various circumstances
Date: Thu, 14 Oct 2010 22:39:10 +0000
In-Reply-To: <SNT118-W26DE5FF8A1DD773D3EDD64CD560@phx.gbl>
References: <SNT118-W26DE5FF8A1DD773D3EDD64CD560@phx.gbl>
Content-Type: text/plain; charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hello


I'm not sure if this is the right place to post this issue but I'm trying here because different support forums for my Linux distribution and hours of searching the web couldn't solve my question. I'm quite a linux novice, though.


I'm running a NFS server (Kubuntu 10.4 / 2.6.32-25) on which I accessed without problems for months with a Kubuntu 8.04 client machine. The machines are connected via Gigabit Ethernet. Recently I upgraded the client machine to Kubuntu 10.10 / 2.6.35-22 and now I'm facing the following problems:


Under various circumstances the client machine completely locks up when performing actions on the NFS shares
- Unzipping a big file from the NFS server to the NFS server via the client -> always freezes (mostly after a few seconds, sometimes it takes a bit longer)

- Transfering big files from one NFS folder to another -> mostly freezes after a short while
- Letting the Strigi-Indexer index files on the NFS shares -> mostly freeze after a short while
- Watching a movie which is on the NFS server -> sometimes freezes after variably amounts of time



So it seems that 'heavy' data transfer load causes the client to lock up.


/proc/mounts tells me that the shares are mounted as follows:


192.168.1.101:/media/data4 /media/data4 nfs rw,sync,nosuid,nodev,noexec,noatime,nodiratime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.1.101,mountvers=3,mountport=51311,mountproto=udp ,addr=192.168.1.101 0 0

Before at the 8.04 setup which worked perfectly it was:

192.168.1.101:/media/data4 /media/data4 nfs rw,nosuid,nodev,noexec,vers=3,rsize=262144,wsize=2 62144,hard,nointr,proto=tcp,timeo=600,retrans=2,se c=sys,addr=192.168.1.101 0 0



I tried to change some of the mount / export options (for example switching from async to sync) but nothing caused any positive effect on the problem.


I'd gladly provide you with any additional informations and/or logs if you could tell me how to enable respectively where to gather.


Thanks!


 		 	   		  