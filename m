Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35379 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbbHFPho (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2015 11:37:44 -0400
Received: by wibxm9 with SMTP id xm9so27763626wib.0
        for <linux-nfs@vger.kernel.org>; Thu, 06 Aug 2015 08:37:43 -0700 (PDT)
Subject: Re: [PATCH V6 6/9] isert: Rename IO functions to more descriptive
 names
To: Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161848.25617.26092.stgit@build2.ogc.int>
 <55B4B190.7070305@dev.mellanox.co.il>
 <55B5404F.5040404@opengridcomputing.com>
 <000001d0ce23$27048810$750d9830$@opengridcomputing.com>
 <55C0F5B7.4040100@dev.mellanox.co.il>
 <00b001d0cfc4$f83a14c0$e8ae3e40$@opengridcomputing.com>
Cc: infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55C37F43.6080106@dev.mellanox.co.il>
Date: Thu, 6 Aug 2015 18:37:39 +0300
MIME-Version: 1.0
In-Reply-To: <00b001d0cfc4$f83a14c0$e8ae3e40$@opengridcomputing.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/6/2015 12:23 AM, Steve Wise wrote:
>
>>>
>>>> Hey Sagi, how is this coming along?  How can I help?
>>>>
>>>
>>> Hi Steve,
>>>
>>> This is taking longer than I expected, the changes needed seem
>>> pretty extensive throughout the IO path. I don't think it will be ready
>>> for 4.3
>>>
>>
>> Perhaps then we should go with my version that adds iwarp-only FRMR IO handlers for 4.3.  Then they can be phased out as the rework
>> matures.  Thoughts?
>>
>
> Shall I send out the series again for merging into 4.3?

Hi Steve,

Not sure about that.. I'm a bit reluctant in adding a code that
branches the isert code even more than it already is.

Nic, WDYT?
