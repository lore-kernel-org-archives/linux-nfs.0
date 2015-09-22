Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bl2on0099.outbound.protection.outlook.com ([65.55.169.99]:8544
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759304AbbIVWOG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Sep 2015 18:14:06 -0400
Subject: Re: [PATCH v1 15/24] IB/srp: Convert to new memory registration API
To: Sagi Grimberg <sagig@mellanox.com>, <linux-rdma@vger.kernel.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <1442482947-27785-16-git-send-email-sagig@mellanox.com>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <5601CF20.3040102@sandisk.com>
Date: Tue, 22 Sep 2015 14:58:56 -0700
MIME-Version: 1.0
In-Reply-To: <1442482947-27785-16-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/17/2015 02:42 AM, Sagi Grimberg wrote:
> Since SRP supports both FMRs and FRWR, the new API conversion
> includes splitting the sg list mapping routines in srp_map_data to
> srp_map_sg_fr that works with the new memory registration API,
> srp_map_sg_fmr which constructs a page vector and calls
> ib_fmr_pool_map_phys, and srp_map_sg_dma which is used only
> if no FRWR nor FMR are supported (which I'm not sure is a valid
> use-case anymore).
>
> The srp protocol is able to pass to the target multiple descriptors
> for remote access, so it basically calls registers muleitple sg list
> partials the entire sg list is mapped and registered (each time maps
> a prefix of an sg list).

This sentence is hard to comprehend, and the spelling of "multiple" 
should be addressed.

Another comment about this patch is that there are multiple changes in 
this patch. It should be split into multiple patches, e.g. one patch 
that converts srp_map_sg() into srp_map_sg_fmr() and srp_map_sg_fr() and 
another patch that introduces the ib_map_mr_sg() call.

Bart.
