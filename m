Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pc175e.fzu.cz ([147.231.127.175]:33811 "EHLO postak-1.fzu.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755867Ab0JFNCW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Oct 2010 09:02:22 -0400
Received: from pc175e.fzu.cz (postak0.fzu.cz [10.128.1.10])
	by postak-1.fzu.cz (8.13.1/8.13.1) with ESMTP id o96CgcJL030090
	for <linux-nfs@vger.kernel.org>; Wed, 6 Oct 2010 14:42:39 +0200
Received: from [172.31.1.101] (85.6.broadband12.iol.cz [90.179.6.85])
	(authenticated bits=0)
	by pc175e.fzu.cz (8.13.6/8.13.6) with ESMTP id o96CgiVJ026059
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 6 Oct 2010 14:42:45 +0200
Message-ID: <4CAC6EBE.9010809@gmail.com>
Date: Wed, 06 Oct 2010 14:42:38 +0200
From: Jiri Horky <jiri.horky@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: MDS network utilization
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I am trying to do some testing of SPNFS NFS4.1 implementation and I came 
across the following problem. When copying a new file to NFS4.1 cluster 
from a client, the network utilization of the MDS client is unexpectedly 
high. The test case and test-be is following:

1 MDS, three DSes + 1 client, using FC13, 
2.6.34.7-58.pnfs35.2010.09.14.fc13.i686.PAE kernel and 
nfs-utils-1.2.2-4.pnfs.fc13.i686.

I copy a new 4GB file (dd if=/dev/zero of=/nfs41/zero.file5 bs=4M 
count=1000) to the cluster and measuring number of bytes transfered on 
each server. While DSes show about 1.4GB of incoming traffic, and the 
client shows 4.2GB of outcoming traffic (which is reasonable), MDS 
numbers (that I expected to be negligible) show 5.1G In and 4.5G Out --> 
it seems like the data flow through the MDS.

Furthermore, when rewriting the same 4GB file with another 4GB bunch of 
data, the numbers are even worse:
MDS: 8.0G In / 4.7G out
DSes: 1.5G In / 1.3G out
Client: ~0.1 In / 4.2 out

I might be doing  something wrong, but I don't see it. My goal is to do 
some preliminary performance tests of NFS4.1, but maybe it is not yet a 
time to do that?

Cheers
Jiri Horky


$cat /etc/spnfsd.conf
[General]

Verbosity = 1
Stripe-size = 8192
Dense-striping = 0
Pipefs-Directory = /var/lib/nfs/rpc_pipefs
DS-Mount-Directory = /pnfs

[DataServers]
NumDS = 3
....
.....
