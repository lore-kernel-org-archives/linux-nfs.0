Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bn1bon0083.outbound.protection.outlook.com ([157.56.111.83]:49760
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755763AbbIYQeu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2015 12:34:50 -0400
Subject: Re: [PATCH v2 16/26] IB/srp: Convert to new registration API
To: Sagi Grimberg <sagig@mellanox.com>, <linux-rdma@vger.kernel.org>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
 <1443116118-10730-17-git-send-email-sagig@mellanox.com>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <560577A4.4080806@sandisk.com>
Date: Fri, 25 Sep 2015 09:34:44 -0700
MIME-Version: 1.0
In-Reply-To: <1443116118-10730-17-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/24/2015 10:35 AM, Sagi Grimberg wrote:
> Remove srp_finish_mapping since no one is calling it.

Please move the srp_finish_mapping() removal into a separate patch.

Thanks,

Bart.
