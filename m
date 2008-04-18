From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] fix statd -n
Date: Fri, 18 Apr 2008 16:32:25 -0400
Message-ID: <20080418203225.GD28277@fieldses.org>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com> <20080418173646.GC19038@fieldses.org> <480902CA.1070805@redhat.com> <48090356.9020703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Janne Karhunen <janne.karhunen@gmail.com>,
	linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41240 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751417AbYDRUc3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2008 16:32:29 -0400
In-Reply-To: <48090356.9020703@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2008 at 04:23:50PM -0400, Peter Staubach wrote:
> Peter Staubach wrote:
>> J. Bruce Fields wrote:
>>> On Thu, Apr 17, 2008 at 12:38:43PM -0400, Janne Karhunen wrote:
>>>  
>>>> Apparently lockd does not expect statd to be used with -n
>>>> switch: statd is expected to bind loopback, always. Attached
>>>> patches show one (IPv4 specific) way of fixing it. Comments?
>>>>     
>>>
>>> Maybe statd really should always bind to the loopback interface?  Is
>>> there any reason not to?
>>>
>>>   
>>
>> I think that statd needs to be reachable from clients
>> and/or servers when the state changes on the other end.
>>
>> This "-n" option really assumes that the system is single-homed
>> though, doesn't it?  Binding to one particular interface will
>> make it so that statd will not be reachable via any of the other
>> interfaces on the system.
>>
>> Perhaps statd should always bind to the loopback interface
>> if it doesn't bind to INADDR_ANY?
>>
>
> Sorry, not very clear.  Perhaps statd should bind to the loopback
> interface in addition to any other interfaces if it doesn't bind
> to INADDR_ANY.

Right, that's what would make the most sense to me.  Janne, is there any
reason that wouldn't solve your problem?

--b.
