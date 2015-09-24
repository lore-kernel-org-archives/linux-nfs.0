Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-am1on0068.outbound.protection.outlook.com ([157.56.112.68]:10840
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751073AbbIXJHF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 05:07:05 -0400
Subject: Re: [PATCH v1 15/24] IB/srp: Convert to new memory registration API
To: Bart Van Assche <bart.vanassche@sandisk.com>, <linux-rdma@vger.kernel.org>
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <1442482947-27785-16-git-send-email-sagig@mellanox.com>
 <5601CF20.3040102@sandisk.com>
CC: <linux-nfs@vger.kernel.org>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@mellanox.com>
Message-ID: <5603BD30.7060908@mellanox.com>
Date: Thu, 24 Sep 2015 12:06:56 +0300
MIME-Version: 1.0
In-Reply-To: <5601CF20.3040102@sandisk.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/23/2015 12:58 AM, Bart Van Assche wrote:
> On 09/17/2015 02:42 AM, Sagi Grimberg wrote:
>> Since SRP supports both FMRs and FRWR, the new API conversion
>> includes splitting the sg list mapping routines in srp_map_data to
>> srp_map_sg_fr that works with the new memory registration API,
>> srp_map_sg_fmr which constructs a page vector and calls
>> ib_fmr_pool_map_phys, and srp_map_sg_dma which is used only
>> if no FRWR nor FMR are supported (which I'm not sure is a valid
>> use-case anymore).
>>
>> The srp protocol is able to pass to the target multiple descriptors
>> for remote access, so it basically calls registers muleitple sg list
>> partials the entire sg list is mapped and registered (each time maps
>> a prefix of an sg list).
>
> This sentence is hard to comprehend, and the spelling of "multiple"
> should be addressed.
>
> Another comment about this patch is that there are multiple changes in
> this patch. It should be split into multiple patches, e.g. one patch
> that converts srp_map_sg() into srp_map_sg_fmr() and srp_map_sg_fr() and
> another patch that introduces the ib_map_mr_sg() call.

OK Bart, I'll split the patches.

Thanks,

Sagi.
