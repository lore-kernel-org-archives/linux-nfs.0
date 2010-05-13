Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:60991 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780Ab0EMPfi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 11:35:38 -0400
Received: by wwi18 with SMTP id 18so962520wwi.19
        for <linux-nfs@vger.kernel.org>; Thu, 13 May 2010 08:35:36 -0700 (PDT)
Message-ID: <4BEC1C45.6020907@panasas.com>
Date: Thu, 13 May 2010 18:35:33 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Jiri Kortus <sumix@atlas.cz>
CC: linux-nfs@vger.kernel.org
Subject: Re: pNFS-related questions
References: <4BEB283C.1020102@atlas.cz> <4BEBBF92.4020705@panasas.com> <4BEC0373.9040606@atlas.cz> <4BEC1BCE.1010907@panasas.com>
In-Reply-To: <4BEC1BCE.1010907@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/13/2010 06:33 PM, Boaz Harrosh wrote:
> On 05/13/2010 04:49 PM, Jiri Kortus wrote:
>> Hi Boaz,
>>
>> thank you for describing how it works :) It looks good and quite simple 
>> to grasp.
>> I'd like to ask you whether you would be also so kind as to write me 
>> some information about the IPv6 support?
>>
>> Thank you very much.
>>
>> Best regards,
>>
>> Jiri
>>
> 
> No idea! :-(
> 
> I don't have any ipv6 setup anywhere
> 
> Boaz

BTW tgtd does not support it yet as well. iscsi-initiator does.
osd does not care it is all hidden under the iscsi stack.

Boaz
