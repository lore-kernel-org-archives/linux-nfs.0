Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([209.166.131.148]:38490 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753556AbaDXLzX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 07:55:23 -0400
Message-ID: <5358FB9C.5000509@panasas.com>
Date: Thu, 24 Apr 2014 14:55:08 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Anna Schumaker <schumaker.anna@gmail.com>,
        Weston Andros Adamson <dros@primarydata.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 13/17] nfs: remove list of [rw]data from pgio header
References: <1398202165-78897-1-git-send-email-dros@primarydata.com> <1398202165-78897-14-git-send-email-dros@primarydata.com> <5357CB59.9060704@gmail.com> <777A277A-CC34-4BD4-993F-9756A6AF7943@primarydata.com> <5357CFD9.7010705@gmail.com> <4C64EB26-388C-4C90-A570-25BEE0A81E71@primarydata.com> <5357FDB2.5010001@gmail.com>
In-Reply-To: <5357FDB2.5010001@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/23/2014 08:51 PM, Anna Schumaker wrote:
> On 04/23/2014 01:44 PM, Weston Andros Adamson wrote:
>> Great news - the merge was pretty easy!
>>
>> I ended up merging by hand - doing “git am --3way” on each patch so I could ensure
>> that they each build cleanly. When there were conflicts, I was able to compare the
>> old patch to the newly rebased patch to make sure I didn’t miss anything.
>>
>> This exercise also helped me find a few problems with my patchset ;)
>>
>> Now it’s time to test! I’ll share my branch on a public repo and repost my patchset
>> soon.
> 
> Great!  I'm glad it went smoothly!
> 
> 
>>
>> -dros

Cool so I'll wait with the testing for your combined branch
Thanks
Boaz

