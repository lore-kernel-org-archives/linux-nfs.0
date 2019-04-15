Return-Path: <SRS0=/Mrm=SR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7509EC10F0E
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 15:05:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 40A6C20880
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 15:05:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="nkU9U29E"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727252AbfDOPFH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 Apr 2019 11:05:07 -0400
Received: from userp2130.oracle.com ([156.151.31.86]:44850 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726298AbfDOPFH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Apr 2019 11:05:07 -0400
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3FExJ0N184336;
        Mon, 15 Apr 2019 15:05:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : content-type :
 content-transfer-encoding : mime-version : subject : message-id : date :
 cc : to; s=corp-2018-07-02;
 bh=M1fULTiOZpv7SoV3LqiVEGqsIGOTkQZMFgBzM5XoZX8=;
 b=nkU9U29E/8wRHGCmq/i5hd7NEBzM0IFL2fL+aV4PZZ9GJ8CKq8SIuYRMjTtTNmSL1PCp
 8idlnPn0qjbXOZwx8W6JLqhMJzySLsOVcIGn+vYh4oqoy2BwvUQnRN29ZxclZF60+VO4
 8HZ3ZPvvPOfmKYNE+ngAum5sgMF8ruU2agiLyujXNFQU9x5W5lqX6tuZdYUeEM3fkHio
 bFq7YlDUhz3UPuG/+/kjrHQDNCCIW/4qJ9UgzUmh0bEzooSopNuXvnDhwvtUXv1/wpvn
 rs9PA3/s2ZhrdotTAk02yT3NdVF67Cu94VG8mpXiJojD8X6OCSbZ0J85zcrzjVuJ45kg 1A== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
        by userp2130.oracle.com with ESMTP id 2ru76t781d-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 15 Apr 2019 15:05:03 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
        by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3FF4KY5065524;
        Mon, 15 Apr 2019 15:05:03 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userp3020.oracle.com with ESMTP id 2rubq5t0dx-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 15 Apr 2019 15:05:03 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3FF4wsk004791;
        Mon, 15 Apr 2019 15:05:02 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 15 Apr 2019 08:04:58 -0700
From:   Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: error=Invalid slot
Message-Id: <2996CEEE-0A1A-4C15-AA8B-A97E917D7924@oracle.com>
Date:   Mon, 15 Apr 2019 11:04:57 -0400
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9227 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=829
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904150104
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9227 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=855 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904150104
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Just happened again. Any thoughts about where I should start looking?

Mon Apr 15 11:01:40 EDT 2019
4k100test: (g=3D0): rw=3Drandread, bs=3D(R) 4096B-4096B, (W) =
4096B-4096B, (T) 4096B-4096B, ioengine=3Dlibaio, iodepth=3D1024
...
fio-3.1
Starting 12 processes
4k100test: Laying out IO file (1 file / 1024MiB)
fio: native_fallocate call failed: Operation not supported
4k100test: Laying out IO file (1 file / 1024MiB)
fio: native_fallocate call failed: Operation not supported
4k100test: Laying out IO file (1 file / 1024MiB)
fio: native_fallocate call failed: Operation not supported
4k100test: Laying out IO file (1 file / 1024MiB)
fio: native_fallocate call failed: Operation not supported
4k100test: Laying out IO file (1 file / 1024MiB)
fio: native_fallocate call failed: Operation not supported
4k100test: Laying out IO file (1 file / 1024MiB)
fio: native_fallocate call failed: Operation not supported
4k100test: Laying out IO file (1 file / 1024MiB)
fio: native_fallocate call failed: Operation not supported
4k100test: Laying out IO file (1 file / 1024MiB)
fio: native_fallocate call failed: Operation not supported
4k100test: Laying out IO file (1 file / 1024MiB)
fio: native_fallocate call failed: Operation not supported
4k100test: Laying out IO file (1 file / 1024MiB)
fio: native_fallocate call failed: Operation not supported
4k100test: Laying out IO file (1 file / 1024MiB)
fio: native_fallocate call failed: Operation not supported
4k100test: Laying out IO file (1 file / 1024MiB)
fio: native_fallocate call failed: Operation not supported
fio: io_u error on file 4k100test.7.0: Invalid slot: read =
offset=3D938229760, buflen=3D4096
fio: pid=3D2653, err=3D57/file:io_u.c:1756, func=3Dio_u error, =
error=3DInvalid slot
fio: io_u error on file 4k100test.10.0: Invalid slot: read =
offset=3D331800576, buflen=3D40963s]
fio: pid=3D2650, err=3D57/file:io_u.c:1756, func=3Dio_u error, =
error=3DInvalid slot
Jobs: 10 (f=3D10): =
[r(2),X(1),r(2),X(1),r(6)][100.0%][r=3D617MiB/s,w=3D0KiB/s][r=3D158k,w=3D0=
 IOPS][eta 00m:00s]
4k100test: (groupid=3D0, jobs=3D12): err=3D57 (file:io_u.c:1756, =
func=3Dio_u error, error=3DInvalid slot): pid=3D2648: Mon Apr 15 =
11:02:25 2019
   read: IOPS=3D157k, BW=3D613MiB/s (643MB/s)(11.4GiB/19024msec)
    slat (usec): min=3D2, max=3D9808, avg=3D 7.36, stdev=3D30.80
    clat (usec): min=3D43, max=3D1236.1k, avg=3D74443.93, stdev=3D85310.03=

     lat (usec): min=3D134, max=3D1236.1k, avg=3D74451.53, =
stdev=3D85309.77
    clat percentiles (usec):
     |  1.00th=3D[   807],  5.00th=3D[  1287], 10.00th=3D[  1647], =
20.00th=3D[  2376],
     | 30.00th=3D[  3490], 40.00th=3D[  8160], 50.00th=3D[ 69731], =
60.00th=3D[ 76022],
     | 70.00th=3D[ 80217], 80.00th=3D[139461], 90.00th=3D[181404], =
95.00th=3D[233833],
     | 99.00th=3D[375391], 99.50th=3D[438305], 99.90th=3D[549454], =
99.95th=3D[616563],
     | 99.99th=3D[750781]
   bw (  KiB/s): min=3D46941, max=3D70036, per=3D8.73%, avg=3D54819.99, =
stdev=3D4131.49, samples=3D430
   iops        : min=3D11735, max=3D17509, avg=3D13704.80, =
stdev=3D1032.88, samples=3D430
  lat (usec)   : 50=3D0.01%, 100=3D0.01%, 250=3D0.01%, 500=3D0.14%, =
750=3D0.63%
  lat (usec)   : 1000=3D1.48%
  lat (msec)   : 2=3D12.84%, 4=3D17.70%, 10=3D7.87%, 20=3D0.77%, =
50=3D0.21%
  lat (msec)   : 100=3D34.04%, 250=3D20.30%, 500=3D3.82%, 750=3D0.20%, =
1000=3D0.01%
  lat (msec)   : 2000=3D0.01%
  cpu          : usr=3D2.04%, sys=3D7.06%, ctx=3D698855, majf=3D0, =
minf=3D6299
  IO depths    : 1=3D0.1%, 2=3D0.1%, 4=3D0.1%, 8=3D0.1%, 16=3D0.1%, =
32=3D0.1%, >=3D64=3D100.0%
     submit    : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, =
64=3D0.0%, >=3D64=3D0.0%
     complete  : 0=3D0.1%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, =
64=3D0.0%, >=3D64=3D0.1%
     issued rwt: total=3D2986716,0,0, short=3D0,0,0, dropped=3D0,0,0
     latency   : target=3D0, window=3D0, percentile=3D100.00%, =
depth=3D1024

Run status group 0 (all jobs):
   READ: bw=3D613MiB/s (643MB/s), 613MiB/s-613MiB/s (643MB/s-643MB/s), =
io=3D11.4GiB (12.2GB), run=3D19024-19024msec

--
Chuck Lever



