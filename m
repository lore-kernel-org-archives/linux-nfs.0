Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:51225 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753712AbcJLRoK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Oct 2016 13:44:10 -0400
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
        by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u9CHhU7G012606
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Wed, 12 Oct 2016 17:43:30 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u9CHgTDR011637
        (version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Wed, 12 Oct 2016 17:42:29 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.13.8/8.13.8) with ESMTP id u9CHgTSx001690
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Wed, 12 Oct 2016 17:42:29 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by aserv0121.oracle.com (8.13.8/8.13.8) with ESMTP id u9CHgRit031347
        for <linux-nfs@vger.kernel.org>; Wed, 12 Oct 2016 17:42:28 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: nfsd: managing pages under network I/O
Message-Id: <BD4A3DBB-71B5-4C30-8976-43F4DD58CBBE@oracle.com>
Date: Wed, 12 Oct 2016 13:42:26 -0400
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm studying the way that the ->recvfrom and ->sendto calls work
for RPC-over-RDMA.

The ->sendto path moves pages out of the svc_rqst before posting
I/O (RDMA Write and Send). Once the work is posted, ->sendto
returns, and looks like svc_rqst is released at that point. The
subsequent completion of the Send then releases those moved pages.

I'm wondering if the transport can be simplified: instead of
moving pages around, ->sendto could just wait until the Write and
Send activity is complete, then return. The upper layer then
releases everything.

Another option would be for ->sendto to return a value that means
the transport will release the svc_rqst and pages.

Or, the svc_rqst could be reference counted.

Anyone have thoughts about this?

--
Chuck Lever



