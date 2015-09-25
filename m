Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32589 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933215AbbIYVVm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2015 17:21:42 -0400
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t8PLLg7F003549
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2015 21:21:42 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t8PLLfoU015889
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2015 21:21:42 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0122.oracle.com (8.13.8/8.13.8) with ESMTP id t8PLLfht021501
	for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2015 21:21:41 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=utf-8
Subject: "Lock reclaim failed!" after cluster fail over
Message-Id: <0E2C4BF6-14AE-44B0-A0C2-CF4203D7DD8C@oracle.com>
Date: Fri, 25 Sep 2015 14:21:40 -0700
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Part of our internal testing involves performing server
fail-over while under load. On regular occasion, we see
Linux clients (post 4.0 kernels) report “Lock reclaim
failed!” but the wire capture looks unremarkable.

I’ve instrumented a Linux client, and both the recovery
open and reclaim_locks calls return 0, the workload
does not report any problem, yet the client is still
reporting a failure.

Delegation on the server is disabled during the test.

Any opinions about why the client is reporting a
failure, or where to explore next?


—
Chuck Lever



