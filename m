Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:36923 "EHLO
	mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbcGFFwq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 01:52:46 -0400
Received: by mail-it0-f47.google.com with SMTP id f6so98991637ith.0
        for <linux-nfs@vger.kernel.org>; Tue, 05 Jul 2016 22:52:46 -0700 (PDT)
MIME-Version: 1.0
From: Pankaj Singh <psingh.ait@gmail.com>
Date: Wed, 6 Jul 2016 11:22:45 +0530
Message-ID: <CAPrqf91tFmR3BVk8RbBbXvMsFa-SOC2WKqGvsb-LvTiLUT61hA@mail.gmail.com>
Subject: When can nfsv3 returns nfs3err_jukebox to client?
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,

I have read in the RFC 1813 that "nfs3err_jukebox" will be return only
when server is not able to finish the RPC request within time. To
indicate client to wait and retry again.

Could anyone tell me is there any senario where NFSv3 or SUN RPC can
send this error to client, if not returned from base filesystem?

Here base filesystem means exporting file system via NFS.

-- 
Regards,
Pankaj SIngh
Phone No: 8826266889
