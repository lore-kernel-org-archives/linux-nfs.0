Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cn.fujitsu.com ([183.91.158.132]:12859 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752214AbeBIB1I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Feb 2018 20:27:08 -0500
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
From: Lu Xinyu <luxy.fnst@cn.fujitsu.com>
Subject: Questions about pynfs:testLargeData-WRT5
Message-ID: <918ad604-2365-b612-56a2-8d88a29f77ff@cn.fujitsu.com>
Date: Fri, 9 Feb 2018 09:27:00 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,Bruce

I ran pynfs on the RHEL7.4GA with different kernels(3.10.0-830.el7,4.15). The testLargeData:WRT5 failed with broken pipe. I investigated pynfs code and got the following questions.

1.The intent of WRT5
To check whether the server could handle a too-large value over NFSSVC_MAXBLKSIZE.

2.The expected procedure when test gets passed
The server could write down the oversize data successfully sent by client and return NFS4_OK.
Then, client could read back the data from server.
(Actually, the test failed with broken pipe and did not return packet information.)

3.The nfs server's standrd procedure of handling oversize data
It seems that the related error is not defined in the RFC3530. Whether the server should return any NFSERR before ceasing receving ?

Thanks for check the above questions.

Best regards!

--
Lu Xinyu 
--


