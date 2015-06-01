Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31397 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbbFAL3P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jun 2015 07:29:15 -0400
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t51BTEpk023390
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 1 Jun 2015 11:29:14 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t51BTDhA022782
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 1 Jun 2015 11:29:14 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0122.oracle.com (8.13.8/8.13.8) with ESMTP id t51BTD1M003658
	for <linux-nfs@vger.kernel.org>; Mon, 1 Jun 2015 11:29:13 GMT
Message-ID: <556C41FC.3060902@oracle.com>
Date: Mon, 01 Jun 2015 19:29:00 +0800
From: Shuang Qiu <shuang.qiu@oracle.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: Stanislav Kholmanskikh <stanislav.kholmanskikh@oracle.com>,
        yueyi Li <yueyi.li@oracle.com>
Subject: truncate() syscall against EFBIG errno issue over nfs filesystem
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi guys,

In LTP truncate03 testcase 
(https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/truncate/truncate03.c),the 
sub-test which test the EFBUG errno will fail.
The test want to truncate the testfile to twice of the RLIMIT_FSIZE size.

According to the man page:
RLIMIT_FSIZE
               The  maximum  size of files that the process may create.  
Attempts to extend a file beyond this limit result in delivery of a
               SIGXFSZ signal.  By default, this signal terminates a 
process, but a process can catch this signal instead, in which case the
               relevant system call (e.g., write(2), truncate(2)) fails 
with the error EFBIG.

We can get EFBIG on some other filesystem such like ext4,xfs.
But truncate will succeed unexpectedly if the testfile on nfs filesystem 
after catch the SIGXFSZ signal.
I'm not sure if it is a bug for truncate(2) on nfs,or expected behavior?
Could someone help to have a look?

Thanks
Shuang
