From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH V2] make "noac" and "actimeo=0" work correctly
Date: Fri, 11 Jul 2008 16:24:26 -0400
Message-ID: <4877C17A.7000009@redhat.com>
References: <484EE994.5030907@redhat.com> <487390EC.7080403@redhat.com>	 <76bd70e30807100858g58fbf454uc9331035a2bbf264@mail.gmail.com>	 <487649AE.1090909@redhat.com> <1215718184.7126.44.camel@localhost>	 <4877BF39.20102@redhat.com> <1215807540.17983.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: chucklever@gmail.com, NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756399AbYGKUYo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2008 16:24:44 -0400
In-Reply-To: <1215807540.17983.2.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Fri, 2008-07-11 at 16:14 -0400, Peter Staubach wrote:
>   
>> Given that we seem to "own" time_in_range(), how about the
>> attached patch which just modifies time_in_range() to calculate
>> [b,c) instead of [b,c], removes the special case for attrtimeo==0
>> in nfs_attribute_timeout() and adds a comment that Chuck requested
>> concerning the need to ensure that zero timeout values continue
>> to work?
>>     
>
> I'm fine with that, but still suggest that you change the name in order
> to avoid confusing possible out-of-tree users.

Okie doke.  I will introduce time_in_range_open(), retest, and then
repost the patch.  Unfortunately, modifying jiffies.h means pretty
much a full kernel build instead of a small incremental build...  :-(

    Thanx!

       ps
