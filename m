Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:50447 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaKKOan (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Nov 2014 09:30:43 -0500
Received: by mail-wi0-f172.google.com with SMTP id bs8so1821934wib.5
        for <linux-nfs@vger.kernel.org>; Tue, 11 Nov 2014 06:30:42 -0800 (PST)
Message-ID: <54621D8D.7050508@dev.mellanox.co.il>
Date: Tue, 11 Nov 2014 16:30:37 +0200
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 07/10] xprtrdma: Display async errors
References: <20141109010328.8806.5861.stgit@manet.1015granger.net> <20141109011501.8806.23478.stgit@manet.1015granger.net>
In-Reply-To: <20141109011501.8806.23478.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/9/2014 3:15 AM, Chuck Lever wrote:
> An async error upcall is a hard error, and should be reported in
> the system log.
>

Could be useful to others... Any chance you put this in ib_core for all
of us?

Sagi.
