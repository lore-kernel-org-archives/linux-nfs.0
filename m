Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:36077 "EHLO
	mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbcHREJU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Aug 2016 00:09:20 -0400
Received: by mail-ua0-f181.google.com with SMTP id 97so11110771uav.3
        for <linux-nfs@vger.kernel.org>; Wed, 17 Aug 2016 21:09:19 -0700 (PDT)
MIME-Version: 1.0
From: james harvey <jamespharvey20@gmail.com>
Date: Thu, 18 Aug 2016 00:09:18 -0400
Message-ID: <CA+X5Wn4f8b+DXGT-OpPWmF=uZ=8m+mh27SfCJNMrven_DZtRVg@mail.gmail.com>
Subject: Is NFSv4.2 now compatible & stable with rdma?
To: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A year ago, on 7/30/2015, Chuck Lever said NFS/RDMA wasn't yet working
with NFSv4.1 and NFSv4.2, as a known issue.

I was able to use "vers=4.0" to get around the issue.

I see v4.2 seems to mount properly, but before switching over to it, I
wanted to see if it's considered stable, or still to be avoided.
