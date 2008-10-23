From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: [RFC] [PATCH 1/1] tcp-autotuning-on-recv-window-fix
Date: Thu, 23 Oct 2008 14:46:21 -0400
Message-ID: <4900C67D.6040208@citi.umich.edu>
References: <48FE200A.6070805@citi.umich.edu> <20081022194605.GA4409@fieldses.org> <49009591.2000306@citi.umich.edu> <20081023175309.GE23838@fieldses.org> <4900C3CE.3030403@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:41386 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757498AbYJWSqW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2008 14:46:22 -0400
In-Reply-To: <4900C3CE.3030403@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Olga Kornievskaia wrote:
>
>
> J. Bruce Fields wrote:
>> On Thu, Oct 23, 2008 at 11:17:37AM -0400, Olga Kornievskaia wrote:
>>  
>>> J. Bruce Fields wrote:
>>>    
>>>> Could we get a really brief summary of the performance improvement 
>>>> for a
>>>> high-speed network, to include in the commit message?
>>>>         
>>> Here's a pick from some LAN performance #s: w/o 237479Mb/s => w/ 
>>> 343669Mb/s.
Sorry, wrong units: 237479KB/s and 343669KB/s.

