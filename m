From: "Sachin S. Prabhu" <sprabhu@redhat.com>
Subject: Virtual IPs and blocking locks
Date: Fri, 15 May 2009 15:48:22 +0100
Message-ID: <4A0D80B6.4070101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47370 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845AbZEOOsX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 May 2009 10:48:23 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n4FEmO1n006326
	for <linux-nfs@vger.kernel.org>; Fri, 15 May 2009 10:48:24 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n4FEmNwX025863
	for <linux-nfs@vger.kernel.org>; Fri, 15 May 2009 10:48:24 -0400
Received: from splp.fab.redhat.com (splp.fab.redhat.com [10.33.0.53])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n4FEmMAD018522
	for <linux-nfs@vger.kernel.org>; Fri, 15 May 2009 10:48:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have had a few reported cases of problems using blocking locks on nfs shares 
mounted using virtual ips. In these cases, the NFS server was using a floating 
ip for clustering purposes.

Please consider the transaction below

NFS client: 10.33.8.75
NFS Server:
Primary IP : 10.33.8.71
Floating IP:  10.33.8.77

$ tshark -r block-virtual.pcap -R 'nlm'
19   2.487622   10.33.8.75 -> 10.33.8.77   NLM V4 LOCK Call FH:0x6176411a svid:4 
pos:0-0
22   2.487760   10.33.8.77 -> 10.33.8.75   NLM V4 LOCK Reply (Call In 19) 
NLM_BLOCKED
33   2.489518   10.33.8.71 -> 10.33.8.75   NLM V4 GRANTED_MSG Call FH:0x6176411a 
svid:4 pos:0-0
36   2.489635   10.33.8.75 -> 10.33.8.71   NLM V4 GRANTED_MSG Reply (Call In 33)
46   2.489977   10.33.8.75 -> 10.33.8.71   NLM V4 GRANTED_RES Call NLM_DENIED
49   2.490096   10.33.8.71 -> 10.33.8.75   NLM V4 GRANTED_RES Reply (Call In 46)

19 - A lock request is sent from the client to the floating ip.
22 - A NLM_BLOCKED request is sent back by the Floating ip to the client.
33 - Server Primary IP address returns a NLM_GRANTED using the async callback 
mechanism.
36 - Ack for GRANTED_MSG in 33.
47 - Client returns a NLM_DENIED to the SERVER. This is done since it doesn't 
match the locks requested.
49 - Ack for GRANTED_RES in 46.

In this case, the GRANTED_MSG is sent by the primary ip as determined by the 
routing table. This lock grant is rejected by the server since the ip address of 
the server doesn't match the ip address of the server against which the request 
was made. The locks are eventually granted after a 30 second poll timeout on the 
client.

Similar problems are also seen when nfs shares are exported from GFS filesystems 
since GFS uses deferred locks.

The problem was introduced by commit 5ac5f9d1ce8492163dbde5d357dc5d03becf7e36 
which adds a check for the server ip address. This causes a regression for 
clients which mount off a virtual ip address from the server.

A possible fix for this issue is to use the server ip address in the nlm_lock.oh 
field used to make the request and compare it to the nlm_lock.oh returned in the 
GRANTED_MSG call instead of checking the ip address of the server calling making 
the GRANTED_MSG call.

Sachin Prabhu
