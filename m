Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail132.messagelabs.com ([216.82.242.115]:35497 "EHLO
	mail132.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995Ab2BOP1K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 10:27:10 -0500
Message-ID: <4F3BCEC8.6050509@nexenta.com>
Date: Wed, 15 Feb 2012 19:27:04 +0400
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
MIME-Version: 1.0
To: Andy Adamson <androsadamson@gmail.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at nfs4_init_slot_table()
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com> <1329259606.11759.15.camel@lade.trondhjem.org> <4F3AFD84.3020709@nexenta.com> <1329266587.28837.4.camel@lade.trondhjem.org> <20120215005315.GA9018@fieldses.org> <1329270628.28837.15.camel@lade.trondhjem.org> <0C12B635-0094-4099-B96C-3637B914A814@netapp.com> <4F3BC9F6.90409@nexenta.com> <CAHVgHyXaAQvngPMrv+NaOKvKauHaqWJJbjqciJCOtJwYuSKVow@mail.gmail.com>
In-Reply-To: <CAHVgHyXaAQvngPMrv+NaOKvKauHaqWJJbjqciJCOtJwYuSKVow@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/15/2012 07:16 PM, Andy Adamson wrote:
>>> No, commit aacd5537270a752fe12a9914a207284fc2341c6d initializes and resets
>>> the slot tables with the ivalue
>>> which is 1 for the forechannel and 0 for the back channel, just as in 3.2.
>>
>>
>>
>> nfs4_init_slot_table() doesn't use ivalue at all.
>
> Yep - that is the bug - which is in v2.6.39, and v3.2 ....

This bug was introduced by commit aacd5537270

