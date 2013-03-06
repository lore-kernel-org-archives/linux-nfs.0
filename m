Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:50409 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755230Ab3CFKHu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2013 05:07:50 -0500
Received: from sim by peace.netnation.com with local (Exim 4.80)
	(envelope-from <sim@netnation.com>)
	id 1UDB0c-0006Q1-GZ
	for linux-nfs@vger.kernel.org; Wed, 06 Mar 2013 01:51:38 -0800
Date: Wed, 6 Mar 2013 01:51:38 -0800
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: NFSv3 TCP socket stuck when all slots used and server goes away
Message-ID: <20130306095138.GC4736@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We had an issue with an Pacemaker/CRM HA-NFSv3 setup where one particular
export hit an XFS locking issue on one node and got completely stuck.
Upon failing over, service recovered for all clients that hadn't hit the
mount since the issue occurred, but almost all of the usual clients
(which also statfs commonly as a monitoring check) sat forever (>20
minutes) without reconnecting.

It seems that the clients filled the RPC slots with requests over the TCP
socket to the NFS VIP and the server ack'd everything at the TCP layer,
but was not able to reply to anything due to the FS locking issue. When
we failed over the VIP to the other node, service was restored, but the
clients stuck this way continued to sit with nothing to tickle the TCP
layer. netstat shows a socket with no send-queue, in ESTABLISHED state,
and with no timer enabled:

tcp        0      0 c:724         s:2049       ESTABLISHED -                off (0.00/0/0)

The mountpoint options used are: rw,hard,intr,tcp,vers=3

The export options are: rw,async,hide,no_root_squash,no_subtree_check,mp

Is this expected behaviour? I suspect if TCP keepalived were enabled, the
socket would eventually get torn down as soon as the client tries to send
something to the (effectively rebooted / swapped) NFS server and gets an
RST. However, as-is, there seems to be nothing here that would eventually
cause anything to happen. Am I missing something?

Simon-
