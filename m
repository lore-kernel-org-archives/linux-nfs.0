Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53797 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758880Ab0J1ODN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 10:03:13 -0400
Message-ID: <4CC9829E.90709@RedHat.com>
Date: Thu, 28 Oct 2010 10:03:10 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
CC: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: fix default value for --enable-tirpc
References: <1286846991-4876-1-git-send-email-jlayton@redhat.com>	<4CC97970.6010706@RedHat.com> <20101028093833.6541ce21@tlielax.poochiereds.net>
In-Reply-To: <20101028093833.6541ce21@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 10/28/2010 09:38 AM, Jeff Layton wrote:
> On Thu, 28 Oct 2010 09:24:00 -0400
> Steve Dickson <SteveD@redhat.com> wrote:
> 
>> Jeff,
>>
>> On 10/11/2010 09:29 PM, Jeff Layton wrote:
>>> The patch I originally proposed to make --enable-tirpc the default had
>>> the default for $enable_tirpc as a blank string. When it was merged
>>> however, that value was changed to a 'yes'. 
>> Which commit or proposal are you talking about? I'm looking at commit 148503a
>> which changed it for no to yes, but I can not seem to find the 
>> proposal you are talking about?
>>
>> I'm just trying to figure how the merge broke it so it does
>> not happen again... 
>>
>> steved.
>>
> 
> Here was the original patch posting:
> 
> http://www.spinics.net/lists/linux-nfs/msg07718.html
> 
> I checked my mail archives and didn't see emails where we discussed
> this patch specifically around that time. Maybe we did on IRC before
> you merged it and I misunderstood what you intended to change? Hard to
> remember since it was over a year ago...
I generally just cut and paste the patches and if 
I make any changes I post them... So I'm wondering 
how that got changed... anyway... its fixed now...

steved.
 
