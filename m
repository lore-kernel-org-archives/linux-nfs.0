From: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Subject: Unusual FSINFO
Date: Tue, 26 Aug 2008 17:12:16 -0400
Message-ID: <64AE2A02-CC2D-4017-9A1F-3C1C6008D3A1@myri.com>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1842 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751068AbYHZVMU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Aug 2008 17:12:20 -0400
Received: from scott-wlan.sw.myri.com (scott-wlan.sw.myri.com [172.31.162.6])
	by myri.com (8.13.7+Sun/8.13.7) with ESMTP id m7QLCHuA008035
	for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2008 14:12:17 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I am working on a new RPC XPRT for Myrinet Express (MX). I am unable  
to complete a mount request. It fails for one of two causes.

1. Client's request fails with ESTALE

This happens when the server tries to authenticate the client's UNIX  
credentials. The first svc_athenticate(1) succeeds, and the second  
reports:

svc: svc_authenticate (1)
RPC:       Want update, refage=120, age=0
svc: calling dispatcher
nfsd_dispatch: vers 3 proc 19
nfsd: FSINFO(3)   12: 00000001 0000fd00 00380001 00000000 00000000  
00000000
nfsd: fh_verify(12: 00000001 0000fd00 00380001 00000000 00000000  
00000000)
RPC:       Want update, refage=120, age=0
found domain -test-client-
found fsidtype 0
found fsid length 8
Path seems to be <>
revisit queued

The only place I can find -test-client- in in exportfs.c. I am at a  
loss as to how it ends up here.

2. Client's request fails with EACCESS

I believe this is actually a RPC_AUTH_BADCRED issue on the server that  
is returned to the client, which converts it to EACCESS in client.c.

I am still trying to diagnose both cases and I would entertain any  
suggestions. ;-)

Thanks,

Scott


--
Scott Atchley
Myricom Inc.
http://www.myri.com


