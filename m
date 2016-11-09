Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17992 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933045AbcKIQFX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 11:05:23 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=utf-8
Date: Wed, 9 Nov 2016 11:05:19 -0500
Subject: wireshark's RPC-over-RDMA dissector
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        List Linux RDMA Mailing <linux-rdma@vger.kernel.org>
Message-Id: <2975B49B-2696-4E2A-B9D0-2D6CB607EC59@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Thanks to Yan Berman, for a couple of years now we've had a basic
RPC-over-RDMA dissector in wireshark that can be used with ibdump
captures. There have been some bugs noted, but no-one has had the
cycles to dig in and address.

Recently Tom Haynes helped me set up my own wireshark build so I
could help address some of the known issues.

http://git.linux-nfs.org/?p=cel/wireshark.git;a=shortlog;h=refs/heads/rpc-rdma-fixes

Posting here for review before I take the next steps to push these
to the wireshark community. Constructive critique and other
suggestions are welcome.

The fixes so far focus on dissecting transport headers correctly.
There continue to be significant open issues with the dissector:
	• There does not appear to be any support for dissecting
	  RPC-over-RDMA on iWARP or RoCE
	• The NFS dissector does not handle portions of the XDR
	  stream that were transmitted via RDMA Read/Write
	• RPC messages conveyed via RDMA_NOMSG are not recognized
	  or dissected
	• There is no association between RDMA Reads and Writes
	  and the RPC-over-RDMA message they go with
	• A CREQ / CREP pair are needed to identify which QP
	  numbers are used for RPC-over-RDMA traffic
	• With TCP, the dissector fully outdents the RPC and NFS
	  dissection results; but with RDMA, the dissector places
	  the results in the tree under the Infiniband header
	• Not enough error detection in the dissector

--
Chuck Lever



