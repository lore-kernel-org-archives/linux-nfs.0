Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from python-06.easyrencontre.com ([91.199.255.56]:52324 "EHLO
	mail.easyflirt.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131Ab0IBHcV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Sep 2010 03:32:21 -0400
Received: from [127.0.0.1] (office.easyrencontre.com [78.155.152.6])
	by mail.easyflirt.com (Postfix) with ESMTPSA id 2192B6374D2
	for <linux-nfs@vger.kernel.org>; Thu,  2 Sep 2010 09:32:19 +0200 (CEST)
Message-ID: <4C7F5302.30300@duchatelet.net>
Date: Thu, 02 Sep 2010 09:32:18 +0200
From: Greg <greg-sys@duchatelet.net>
To: linux-nfs@vger.kernel.org
Subject: Re: Relocate NFS root FS for maintenance
References: <4C7E4469.70807@duchatelet.net> <4C7ECB23.60300@excfb.com>
In-Reply-To: <4C7ECB23.60300@excfb.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  Tom,

>
> What you are missing here is that the client uses two things to access 
> content on
> the servers - path and file handles. When you do the reshare, you 
> would be pointing any
> new requests to the empty directories. But, any application which 
> already had a
> file handle would have a reference to the old mount (via the fsid part 
> of the file handle).

OK thanks for the precisions. It's why I'm getting those errors :
Sep  1 15:12:53 varan-14 kernel: [3424547.256518] NFS: server 
filer-large-vip.local error: fileid changed
Sep  1 15:12:53 varan-14 kernel: [3424547.256518] fsid 0:13: expected 
fileid 0x2, got 0x41

> The options I see are to:
>
> 1) Shutdown NFS/remove write access to the export/etc - this is along 
> the lines of what
> you have done. And the result is that the server will inform the 
> client of an error.
>
> 2) Disconnect the servers from the network. (Or partition the 
> network). In this scenario,
> the client will be getting timeouts and will probably use a retry schema.
>
> 3) Shutdown the NFS clients - harsh, but they will not be accessing 
> the servers and you
> can easily do the upgrades.
>
> These all result in downtime for both your servers and your clients.

So in short there is no way to do a maintenance on attached storage, 
could it be hard drives, RAID, iSCSI or anything.
Is such a "feature" in the roadmap ?

-- 
Greg

