From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 21 Apr 2008 11:01:43 -0400
Message-ID: <30C5E99C-CADB-469E-9862-857884A3B40B@oracle.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com> <20080418173646.GC19038@fieldses.org> <480902CA.1070805@redhat.com> <48090356.9020703@redhat.com> <20080418203225.GD28277@fieldses.org> <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com> <20080421000214.GA5453@fieldses.org> <24c1515f0804201749x47bee916y9970fe1102bfb5@mail.gmail.com> <20080421021153.GC5453@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Janne Karhunen <janne.karhunen@gmail.com>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:50187 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbYDUPC2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 11:02:28 -0400
In-Reply-To: <20080421021153.GC5453@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 20, 2008, at 10:11 PM, J. Bruce Fields wrote:
> On Sun, Apr 20, 2008 at 08:49:52PM -0400, Janne Karhunen wrote:
>> On Sun, Apr 20, 2008 at 8:02 PM, J. Bruce Fields <bfields@fieldses.org 
>> > wrote:
>>
>>>> I didn't get the idea. So the idea is to use multiple sockets,
>>>> one bound to LOOPBACK and one to external interface?
>>>
>>> I suppose so.  One socket would be for communication for the local
>>> kernel nfsd, one for communication with statd peers.
>>
>> Ok, but that's really quite intrusive - my goal with that
>> patch was to minimize the amount of changes. Sure,
>> we can rework larger part of it if you think is better
>> that way.
>
> Yes.  Hopefully it's not too bad....

My two pfennigs worth:

I think creating a separate loopback listener in the "-n" case is a  
reasonable thing to do, and probably won't be terribly complex.  This  
isn't a performance path, so you can probably get away with a select  
on multiple sockets.

Alternately, you could create separate rpc.statd daemons -- one would  
listen only for loopback.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
