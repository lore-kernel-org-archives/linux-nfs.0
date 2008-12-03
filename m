From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: [PATCH/RFC] svcgssd always sets an infinite expiry on authentication tokens etc.
Date: Wed, 3 Dec 2008 17:26:36 -0500
Message-ID: <4d569c330812031426hb9a2717wf430bab74781070a@mail.gmail.com>
References: <18740.50457.981544.21225@notabene.brown>
	 <4d569c330812012145y2353bc9asd7a0c62fef42ed3a@mail.gmail.com>
	 <49355C78.6080607@RedHat.com>
	 <4d569c330812020940n3b8561fexfb97d89a7d5779a4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Neil Brown" <neilb@suse.de>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>
To: "Steve Dickson" <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:17066 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbYLCW0i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Dec 2008 17:26:38 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1577449yxm.1
        for <linux-nfs@vger.kernel.org>; Wed, 03 Dec 2008 14:26:37 -0800 (PST)
In-Reply-To: <4d569c330812020940n3b8561fexfb97d89a7d5779a4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Dec 2, 2008 at 12:40 PM, Kevin Coffman <kwc@citi.umich.edu> wrote:
> On Tue, Dec 2, 2008 at 11:04 AM, Steve Dickson <SteveD@redhat.com> wrote:
>> Kevin Coffman wrote:
>>> Hi Neil,
>>> This seems reasonable.
>>>
>>> I have a patch somewhere that gets the actual Kerberos expiration that
>>> could be used for the rsc timeout.  But I think this should be fine
>>> for now.  (Perhaps at the cost of requiring clients to negotiate a new
>>> context every hour?)
>> This question is a bit worrisome, imho... I understand the need to release
>> memory consumed by dead contexts but on the other hand, renegotiating
>> contexts every hour on the hours seems a bit costly as well...
>>
>> Does it make sense to make this time out configurable? Yes, it would be
>> a very obscure knob, but in the unlikely event there is a bug in the
>> renegotiating code or renegotiating simply becomes too costly, I think
>> it would good to have a way to dial the time out back up as a work-around.
>>
>> steved.
>
> Hi Steve,
>
> Rather than adding another config knob, how 'bout I dust off my patch
> to get the "right" timeout value?  I should be able to make that
> available tomorrow.  (I have limited resources to work on this at the
> moment.)
>
> K.C.

It took me a bit longer than I anticipated to retrofit my changes for
this.  I have patches that I will send out for review later tonight or
tomorrow.

K.C.
