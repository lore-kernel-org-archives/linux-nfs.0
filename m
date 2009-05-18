From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: [PATCH 3/7] gssd: add support for callback authentication
Date: Mon, 18 May 2009 11:40:28 -0400
Message-ID: <4d569c330905180840h6c0a45b4gf088210b1f812f5e@mail.gmail.com>
References: <20090429214300.25811.81332.stgit@jazz.citi.umich.edu>
	 <20090429215626.25811.13927.stgit@jazz.citi.umich.edu>
	 <20090430212457.GA5700@fieldses.org>
	 <4d569c330905061422t53d4a96as712678f2805c81ac@mail.gmail.com>
	 <4A117C61.9000504@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f180.google.com ([209.85.221.180]:38637 "EHLO
	mail-qy0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754347AbZERPk1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 May 2009 11:40:27 -0400
Received: by qyk10 with SMTP id 10so1346426qyk.33
        for <linux-nfs@vger.kernel.org>; Mon, 18 May 2009 08:40:28 -0700 (PDT)
In-Reply-To: <4A117C61.9000504-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK.  I'll squash this in and re-submit the series on Wednesday.

On Mon, May 18, 2009 at 11:18 AM, Steve Dickson <SteveD@redhat.com> wro=
te:
> Since I'm just getting around to this now... just
> replace this patch please....
>
> tia,
>
> steved
>
> Kevin Coffman wrote:
>> On Thu, Apr 30, 2009 at 5:24 PM, J. Bruce Fields <bfields@fieldses.o=
rg> wrote:
>>> On Wed, Apr 29, 2009 at 05:56:26PM -0400, Kevin Coffman wrote:
>>>> From: Olga Kornievskaia <aglo@citi.umich.edu>
>>>>
>>>> Add support for handling upcalls on the new "nfsd4_cb" directory p=
ipes.
>>>> Only new kernels (2.6.29) have support for this new pipe directory=
=2E
>>>> (The need for this new pipe directory will go away with NFSv4.1 wh=
ere
>>>> the callback can be done on the same connection as the fore-channe=
l.)
>>> My only complaint is that the code would be robust (and more
>>> future-proof) if instead of specifically looking for "nfs" and
>>> "nfsd4_cb", we just look at all top-level rpc_pipefs directories an=
d
>>> handed directories under any of them in the same way.
>>>
>>> --b.
>>
>> In our offline discussion, Bruce convinced me that we should just
>> treat all the directories under the rpc_pipefs directory as equal, a=
nd
>> process any clnt directories that show up within them. =A0(This
>> currently includes, "lockd =A0mount =A0nfs =A0nfsd4_cb =A0portmap =A0=
statd".)
>> Any new directories appearing in the future will automatically get t=
he
>> same treatment.
>>
>> Steve, I don't know what you might have already done with these
>> patches. =A0Would you prefer a replacement for this patch, or patch =
on
>> top of this?
>>
>> K.C.
>
>
