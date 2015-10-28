Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32433 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755601AbbJ1S4w convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Oct 2015 14:56:52 -0400
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t9SIuoCw006168
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2015 18:56:51 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t9SIuo2Z025413
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2015 18:56:50 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0121.oracle.com (8.13.8/8.13.8) with ESMTP id t9SIuoe9005979
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2015 18:56:50 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=utf-8
Subject: GSSD warning with proto=rdma
Message-Id: <216A83C3-D724-49C7-A64B-3471CF981AA3@oracle.com>
Date: Wed, 28 Oct 2015 14:56:48 -0400
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I’m beginning to try Kerberos with NFS/RDMA. I get this complaint
from GSSD:

Oct 28 13:10:02 manet rpc.gssd[2549]: WARNING: unrecognized
protocol, 'rdma', requested for connection to server
klimt-ib.1015granger.net for user with uid 0

Should I change the kernel NFS client to tell GSSD it’s using
TCP, or should I change GSSD to recognize RDMA as another form
of TCP?


-—
Chuck Lever



