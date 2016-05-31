Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtpi.meduniwien.ac.at ([149.148.51.14]:38658 "EHLO
	smtpi.meduniwien.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbcEaMKy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2016 08:10:54 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtpi.meduniwien.ac.at (Postfix) with ESMTP id 30A0160641
	for <linux-nfs@vger.kernel.org>; Tue, 31 May 2016 14:10:52 +0200 (CEST)
Received: from smtpi.meduniwien.ac.at ([127.0.0.1])
	by localhost (mailsip.meduniwien.ac.at [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id HiIXtbyhnhKe for <linux-nfs@vger.kernel.org>;
	Tue, 31 May 2016 14:10:51 +0200 (CEST)
Received: from [149.148.52.63] (itsc063.cc.meduniwien.ac.at [149.148.52.63])
	by smtpi.meduniwien.ac.at (Postfix) with ESMTPS id 3AEDB6062E
	for <linux-nfs@vger.kernel.org>; Tue, 31 May 2016 14:10:50 +0200 (CEST)
To: linux-nfs@vger.kernel.org
From: Matthias Leopold <matthias.leopold@meduniwien.ac.at>
Subject: getattr ERROR: Request couldn't be completed in time
Message-ID: <574D7F26.1090202@meduniwien.ac.at>
Date: Tue, 31 May 2016 14:10:14 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi,

i'm trying to mount a NFS 4 share with "sec=sys" from a NetApp FAS3250 
on a CentOS KVM guest. this doesn't work, the mount doesn't complete and 
hangs.

mount command is:
/bin/mount -v -t nfs -s -o vers=4.1,sec=sys 10.110.96.90:/home /home/cir

what i'm seeing in tcpdump is:

08:36:48.875019 IP 10.110.96.112.2456702824 > 10.110.96.90.2049: 212 
getattr fh 0,1/53
08:36:48.875355 IP 10.110.96.90.2049 > 10.110.96.112.2456702824: reply 
ok 96 getattr ERROR: Request couldn't be completed in time

server: 10.110.96.90
client: 10.110.96.112

status of nfs services:

nfslock: running
rpcbind: running
rpcidmapd: stopped

this happens with a centos 6 _and_ a centos 7 client (both KVM).
NFS 3 mount from the same host don't work either.

other kvm guests (centos 6) on the same physical host can mount the 
share with no problem.

the netapp admin tells me there's "no problem" on his side.
iptables is disabled of course.

###

what could be the problem on my (client) side?
could this be a kvm problem?

kvm host is centos 6.
network mode is "bridge".
network driver is "virtio".

thx for any advice
matthias
