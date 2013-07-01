Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:40572 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755339Ab3GAUyo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jul 2013 16:54:44 -0400
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r61KshUb015718
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 1 Jul 2013 20:54:43 GMT
Received: from userz7022.oracle.com (userz7022.oracle.com [156.151.31.86])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r61KsgPj007089
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 1 Jul 2013 20:54:43 GMT
Received: from abhmt111.oracle.com (abhmt111.oracle.com [141.146.116.63])
	by userz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r61Ksgdx017549
	for <linux-nfs@vger.kernel.org>; Mon, 1 Jul 2013 20:54:42 GMT
Message-ID: <51D1EC91.9050308@oracle.com>
Date: Mon, 01 Jul 2013 14:54:41 -0600
From: Jeff Wright <jeff.wright@oracle.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Question on tuning sunrpc.tcp_slot_table_entries
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Team,

I am supporting Oracle MOS note 1354980.1, which covers tuning clients 
for RMAN backup to the ZFS Storage Appliance.  One of the tuning 
recommendations is to change sunrpc.tcp_slot_table_entries from the 
default (16) to 128 to open up the number of concurrent I/O we can get 
per client mount point.  This is presumed good for general-purpose 
kernel NFS application traffic to the ZFS Storage Appliance.  I recently 
received the following comment regarding the efficacy of the 
sunrpc.tcp_slot_table_entries tune:

"In most cases, the parameter "sunrpc.tcp_slot_table_entries" can not be 
set even if applying int onto /etc/sysctl.conf although this document 
says users should do so.
Because, the parameter is appeared after sunrpc.ko module is loaded(=NFS 
service is started), and sysctl was executed before starting NFS service."

I'd like to find out how to tell if the tune is actually in play for the 
running kernel and if there is a difference in what is reported /proc 
compared to what is running in core.  Could anyone on the alias suggest 
how to validate if the aforementioned comment is relevant for the Linux 
kernel I am running with?  I am familiar with using mdb on Solaris to 
check what values the Solaris kernel is running with, so if there is a 
Linux equivalent, or another way to do this sort of thing with Linux, 
please let me know.

Thanks,

Jeff

