Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22863 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755271AbbEEXgf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 19:36:35 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=windows-1252
Subject: problem with commit 5bb89b4702e2
Date: Tue, 5 May 2015 19:36:52 -0400
Message-Id: <3CB8BDBA-ABB9-4C8B-8440-9B83C21CFB03@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

I’ve found that after 4.1-rc1, cthon basic test 5 fails when run over
NFSv4.0 against Solaris servers (affects both TCP and RDMA).

> [cel@manet cthon04]$ ./server -b
> 
> sh ./runtests  -b -t /mnt/lebasque/manet.test
> 
> Starting BASIC tests: test directory /mnt/lebasque/manet.test (arg: -t)
> 
> ./test5a: write
> 	./test5a: (/mnt/lebasque/manet.test) 'bigfile' has size 0, should be 1048576
> basic tests failed
> Tests failed, leaving /mnt/lebasque mounted
> [cel@manet cthon04]$


I bisected to commit 5bb89b4702e2 ("NFSv4.1/pnfs: Separate out metadata
and data consistency for pNFS”). I’ve been comparing network captures
and I don’t see anything that stands out.

Reverting just the change to nfs_wb_all() makes the regression go away.

As a rough guess, I think the problem could be that Solaris is handing
out a write delegation, and after commit 5bb89b4702e2, the client is not
flushing as often as it needs to ?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



