Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:54716 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965239AbaDJH5Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 03:57:24 -0400
Message-ID: <53464E88.4000309@mellanox.com>
Date: Thu, 10 Apr 2014 10:55:52 +0300
From: Or Gerlitz <ogerlitz@mellanox.com>
MIME-Version: 1.0
To: Allen Andrews <allen.andrews@cox.net>
CC: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs-rdma: Fix for FMR leaks
References: <nyc61n00p3VzoHe01yc7ug> <002e01cf5444$a58c2c10$f0a48430$@cox.net>
In-Reply-To: <002e01cf5444$a58c2c10$f0a48430$@cox.net>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/04/2014 01:40, Allen Andrews wrote:
> Two memory region leaks iwere found during testing:
s/iwere/were/

