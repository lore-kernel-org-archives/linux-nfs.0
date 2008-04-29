From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] fix statd -n
Date: Tue, 29 Apr 2008 12:16:07 -0400
Message-ID: <20080429161607.GA20420@fieldses.org>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com> <20080418173646.GC19038@fieldses.org> <480902CA.1070805@redhat.com> <48090356.9020703@redhat.com> <20080418203225.GD28277@fieldses.org> <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com> <20080421000214.GA5453@fieldses.org> <24c1515f0804281352u2d04ac89i820dc6807dde39f1@mail.gmail.com> <4817346F.5000101@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Janne Karhunen <janne.karhunen@gmail.com>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Wendy Cheng <wcheng@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52160 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932650AbYD2QQY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Apr 2008 12:16:24 -0400
In-Reply-To: <4817346F.5000101@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 29, 2008 at 10:45:03AM -0400, Wendy Cheng wrote:
> Janne Karhunen wrote:
>> On Sun, Apr 20, 2008 at 8:02 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>
>>   
>>>  > >  Right, that's what would make the most sense to me.  Janne, is there any
>>>  > >  reason that wouldn't solve your problem?
>>>  >
>>>  > I didn't get the idea. So the idea is to use multiple sockets,
>>>  > one bound to LOOPBACK and one to external interface?
>>>
>>>  I suppose so.  One socket would be for communication for the local
>>>  kernel nfsd, one for communication with statd peers.
>>>     
>>
>> Finally got around to it again. Attached patch takes a
>> shot at the two socket approach. Patch is a draft to
>> see what you guys would really think about this
>> approach.
>>
>>   
> Do we really have to add so many lines of the code just to fix "statd  
> -n" ? Maybe we should go back to the basics by understanding the  
> requirement of this command ? So why do we need it (i.e. what kind of  
> bad things we'll see if we don't fix this) ? Some short description  
> would help. 

I recall two reasons for -n given in this thread; I think one was just
security (maybe you don't want statd listening on some ports, for
whatever reason.  The other was a code comment quoted here:

	http://marc.info/?l=linux-nfs&m=120854237320424&w=2

	"This is required to support clients that ignore the mon_name in
	the statd protocol but use the source address from the request
	packet."

Which I don't completely understand.  I guess it was meant as a way to
ensure that *outgoing* packets are sent from the correct (floating) ip
address?

--b.
