Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36558 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbcDZUuL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:50:11 -0400
Subject: Re: [PATCH v2 17/18] xprtrdma: Remove ro_unmap() from all
 registration modes
To: Chuck Lever <chuck.lever@oracle.com>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
 <20160425192307.3566.96703.stgit@manet.1015granger.net>
 <571FCF8E.1060304@grimberg.me>
 <2AB2B747-1D14-4885-9CEA-23104AC2A379@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <571FD480.80100@grimberg.me>
Date: Tue, 26 Apr 2016 23:50:08 +0300
MIME-Version: 1.0
In-Reply-To: <2AB2B747-1D14-4885-9CEA-23104AC2A379@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> Now we have ro_unmap_safe() which sorta implies that there
>> is a non-safe unmap? Why not just keep it ro_umap?
>
> Er, I would find that confusing too.
>
> How about name it ro_unmap_slow(), but it's for asynchronous
> cases too.

Heh, if a future nfs-rdma developer sees ro_unmap_slow() I assume his
first action is to grep ro_unmap_fast...

Anyway, it's not critical, your call..
