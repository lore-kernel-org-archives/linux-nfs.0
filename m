From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Fri, 18 Apr 2008 13:20:48 -0500
Message-ID: <4808E680.2010507@gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com> <20080418173646.GC19038@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Janne Karhunen <janne.karhunen@gmail.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23288 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759667AbYDRSU5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2008 14:20:57 -0400
In-Reply-To: <20080418173646.GC19038@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Apr 17, 2008 at 12:38:43PM -0400, Janne Karhunen wrote:
>   
>> Apparently lockd does not expect statd to be used with -n
>> switch: statd is expected to bind loopback, always. Attached
>> patches show one (IPv4 specific) way of fixing it. Comments?
>>     
>
> Maybe statd really should always bind to the loopback interface?  Is
> there any reason not to?
>   

This patch is very similar to what we had about one year ago for cluster 
lock failover... Maybe it is about time to revisit the issues ?

-- Wendy


