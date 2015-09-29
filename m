Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-by2on0067.outbound.protection.outlook.com ([207.46.100.67]:37024
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964820AbbI2TEA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Sep 2015 15:04:00 -0400
Subject: Re: [PATCH v1 00/24] New fast registration API
To: Sagi Grimberg <sagig@mellanox.com>, <linux-rdma@vger.kernel.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <560AE099.2080004@sandisk.com>
Date: Tue, 29 Sep 2015 12:03:53 -0700
MIME-Version: 1.0
In-Reply-To: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/17/2015 02:42 AM, Sagi Grimberg wrote:
> - Converted SRP initiator and RDS iwarp ULPs to the new API

Hello Sagi,

How has the converted SRP initiator driver been tested ? With the kernel 
tree that is available on branch reg_api.4 
(427def03e9fa9801efbb27f6c3c6bf7fc0d012e1) I see on the initiator system 
that login fails and that the following message is logged:

Sep 29 12:01:05 ion-dev-ib-ini kernel: scsi host72: ib_srp: failed 
receive status WR flushed (5) for iu ffff88045bb80930

Thanks,

Bart.
