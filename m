Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59558 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755208Ab0GAOTd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Jul 2010 10:19:33 -0400
Cc: "linux-nfs@vger.kernel.org Mailing list" <linux-nfs@vger.kernel.org>
Message-Id: <109F45DA-79E0-44FA-9205-5D70E4336288@netapp.com>
From: Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
In-Reply-To: <4C2CA1FC.8060803@panasas.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: get_lock_alloc_layout
Date: Thu, 1 Jul 2010 10:19:31 -0400
References: <7B1AD6D8-4D7D-48B6-9439-7A1469784754@netapp.com> <4C2CA1FC.8060803@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jul 1, 2010, at 10:11 AM, Benny Halevy wrote:

> On Jul. 01, 2010, 16:50 +0300, Andy Adamson <andros@netapp.com> wrote:
>> Hi Benny
>>
>> Why do we have the complexity of waiting on a bit lock for allocating
>> a layout? Why can't we use the normal form:
>
> It's possible but the expectation was that the race here would
> not be infrequent enough it's worth (statistically) losing it.

Well, I feel that for code maintainability that we use the normal  
form. I'll submit a patch.

-->Andy
>
> Benny
>
>>
>> take the i_lock
>> lookup layout
>> if (layout == NULL) {
>>         give up i_lock
>>         allocate and init new layout
>>                return NULL if allocation fails
>>         take the i_lock
>>         lookup layout
>>         if (layout == NULL)
>>                 set new layout for return
>>         else
>>                 set found layout for return
>> }
>> give up i_lock
>> if new was allocated and not used
>>           free the new layout
>> return layout
>>
>>
>> -->Andy
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

