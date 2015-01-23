Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:49124 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbbAWVAQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2015 16:00:16 -0500
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t0NL0F6K031551
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2015 21:00:15 GMT
Received: from aserz7022.oracle.com (aserz7022.oracle.com [141.146.126.231])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id t0NL0E6e004605
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2015 21:00:15 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id t0NL0EZg008394
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2015 21:00:14 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=windows-1252
Subject: NFSv4.1 backchannel for RDMA
Message-Id: <E4A8B62E-BCFC-497F-B134-ECD90F232804@oracle.com>
Date: Fri, 23 Jan 2015 16:00:13 -0500
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I’d like to restart the discussion in this thread:

  http://marc.info/?l=linux-nfs&m=141348840527766&w=2

It seems to me there are two main points:

1.  Is bi-directional RPC on RPC/RDMA transports desirable?

2.  Is a secondary backchannel-only transport adequate and reliable?

I’ll try to summarize the current thinking.


Question 1:

The main reason to plumb bi-RPC into RPC/RDMA is that no changes to
the NFSv4.1 client upper layers would be needed. I think we also
agree that:

 - There is no performance benefit. CB operations typically lack
   significant payload, are infrequent, and can be long-running.

 - There is no need to penetrate firewalls. Firewall compatibility
   was the original motivation for single-transport NFSv4.1
   operation. Firewalls are not typically found in RDMA-native
   environments.

 - There is no requirement in RFC 5661 for the forward channel
   transport to support bi-directional RPC. Backchannel capability
   is detected via the CREATE_SESSION operation.

 - TCP connectivity will always be available wherever NFS/RDMA is
   deployed. For NFS/RDMA operation, IP address to GUID mapping must
   be provided by the transport layer, below RPC/RDMA.

 - To handle large payloads (possibly required by certain pNFS
   CB operations), an NFSv4.1 client would need to handle
   RDMA_NOMSG type calls over the backchannel. This would require
   the client to perform RDMA READ and WRITE operations against the
   server (the opposite of what happens in the forward channel).

There is some interest in prototyping an RPC/RDMA transport that is
capable of bi-directional RPC. A prototype would help us determine
whether there are subtle problems that make bi-RPC impossible for
RPC/RDMA, and identify any spec gaps that need to be addressed.
Because of the development cost and lack of perceptible benefits, a
prototype has not been attempted so far.

Would it be productive for a bi-capable RPC/RDMA transport prototype
to be pursued in Linux?


Question 2:

The Solaris client and server already implement a sidecar TCP
backchannel for NFSv4.1. This is something that can be tested.
Further, I think we agree that:

 - Servers are required to support a separate backchannel and
   forward channel transport, and both sides can detect what is
   supported with CREATE_SESSION. However, there are no existing
   implementations that have deployed this kind of logic widely.
 
 - The addition of a separate backchannel-only connection is
   considered session trunking, which is regarded as potentially
   hazardous. We haven’t identified exactly what the  hazards might
   be when the second connection handles only backchannel activity.

 - Although there are few or no server changes required to support
   a secondary backchannel, clients would have to be modified to
   establish this connection when one or both sides do not support
   a backchannel on the main transport and the server asserts the
   SEQ4_STATUS_CB_PATH_DOWN flag.

 - We have some confidence that creation of the second backchannel-
   only connection followed by BIND_CONN_TO_SESSION appears to be
   adequate and robust. However, the salient recovery edge conditions
   when a secondary backchannel transport is being used still need to
   be identified.

What further investigation is needed to be confident that the sidecar
solution is adequate and appropriate?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



