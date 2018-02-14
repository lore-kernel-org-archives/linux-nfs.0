Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:38940 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1031611AbeBNPmK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Feb 2018 10:42:10 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: jlayton@redhat.com, aglo@umich.edu, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] NFSv4: Fix CLOSE races with OPEN
Date: Wed, 14 Feb 2018 10:42:08 -0500
Message-ID: <D0761437-4614-41C7-AC85-76EF45D67C70@redhat.com>
In-Reply-To: <1518622194.4737.1.camel@primarydata.com>
References: <1479140396-17779-1-git-send-email-trond.myklebust@primarydata.com>
 <1479140396-17779-2-git-send-email-trond.myklebust@primarydata.com>
 <CAN-5tyGEn3vGJicR+00ATSp7PzUEm_6FzjBwYwiS-++OcqqfaA@mail.gmail.com>
 <698A2B0C-1E38-4B65-ABA3-60C396393E30@redhat.com>
 <1518621683.13566.5.camel@redhat.com>
 <1518622194.4737.1.camel@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14 Feb 2018, at 10:29, Trond Myklebust wrote:
> On Wed, 2018-02-14 at 10:21 -0500, Jeff Layton wrote:
>> On Wed, 2018-02-14 at 10:05 -0500, Benjamin Coddington wrote:
>>> Hi Olga,
>>>
>>> On 13 Feb 2018, at 15:08, Olga Kornievskaia wrote:
>>>
>>>> On Mon, Nov 14, 2016 at 11:19 AM, Trond Myklebust
>>>> <trond.myklebust@primarydata.com> wrote:
>>>> ...
>>> Ah, good question there..  Even though the stateid is not useful
>>> for
>>> operations that follow, I think the sequenceid should be
>>> incremented because
>>> the CLOSE is an operation that modifies the set of locks or state:
>>>
>>
>> It doesn't matter.

Yes, good condensed point.  It doesn't matter.

>>> ...
> Is there a proposal to change the current client behaviour here? As far
> as I can tell, the answer is "no". Am I missing something?

Not that I can see.  I think we're just comparing linux and netapp server
behaviors..

Ben
