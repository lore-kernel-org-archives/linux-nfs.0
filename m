Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:58124 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726149AbeJBCe0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 22:34:26 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: refresh of git://git.linux-nfs.org/projects/trondmy/linux-nfs.git
 testing
Message-Id: <2EF3FAED-A930-4813-9C70-D7190189BA87@oracle.com>
Date: Mon, 1 Oct 2018 15:54:54 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

I pulled your testing branch this afternoon, and did some basic
testing:

- 9 different iozone read and write tests
- fio 8KB 70% read / 30% write
- fio 4KB 100% read
- multi-threaded git regression
- xfstests

with both NFSv3 and NFSv4.1. I found no regressions.


--
Chuck Lever
