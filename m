Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:50530 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757242Ab1JDPwu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 11:52:50 -0400
Received: by ggnv2 with SMTP id v2so274215ggn.19
        for <linux-nfs@vger.kernel.org>; Tue, 04 Oct 2011 08:52:50 -0700 (PDT)
Message-ID: <4E8B2BC6.6020209@tonian.com>
Date: Tue, 04 Oct 2011 17:52:38 +0200
From: Benny Halevy <bhalevy@tonian.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] nfsd4: construct stateid from clientid and counter
References: <20110919131415.GB32498@fieldses.org> <1316438143-1057-4-git-send-email-bfields@redhat.com> <4E89CA1C.4050107@tonian.com> <20111003145749.GB5524@pad.fieldses.org> <4E89D114.1020109@tonian.com> <20111003153821.GC5524@pad.fieldses.org>
In-Reply-To: <20111003153821.GC5524@pad.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-10-03 17:38, J. Bruce Fields wrote:
> On Mon, Oct 03, 2011 at 05:13:24PM +0200, Benny Halevy wrote:
>> On 2011-10-03 16:57, J. Bruce Fields wrote:
>>> On Mon, Oct 03, 2011 at 04:43:40PM +0200, Benny Halevy wrote:
>>>> Bruce, it seems with this patch, doing si_opaque.so_id = current_stateid
>>>> makes all stateid's unique, regardless of their type.
>>>> Is find_stateid_by_type still needed?
>>>>
>>>> And if the opaque part of the stateid isn't unique,
>>>> shouldn't find_stateid_by_type go over the hash bucket by itself
>>>> to look for other stateid's sharing the same opaque but having
>>>> the type it is looking for?
>>>
>>> Stateid's have actually always been unique--they'd have to be, since
>>> e.g. READ doesn't come with any indication of which type of stateid
>>> you're being given.  All find_stateid_by_type() does is fail when it
>>> doesn't find something of the right type.
>>>
>>
>> So I'm still confused.  That's what I thought.
>> So in what cases find_stateid that find_stateid_by_type calls
>> will find a stateid structure with a non-matching sc_type?
> 
> Suppose, for example, the server gets a DELEGRETURN, looks up the
> provided stateid, and finds an open stateid.
> 
> At this point either the client is buggy, or else something very
> unlikely has happened.  (E.g. a stateid was retired and then reused).
> 
> So find_stateid_by_type() returns NULL which the caller will likely
> translate to something like BAD_STATEID.
> 
> Other cases: open_confirm and close require an open stateid, ulock or
> lock with the !new_lock_owner case requires a lock stateid, etc.

OK, I'm going to use the common hash table also for the layout state
which will have to use the same encoding linage.

It's a non-trivial rewrite of the layout state mechanisms but I
it seems to simplify the code overall and will be more efficient
in terms of lookup complexity (hash table vs. linear list)

I'm pretty hosed right now but I'd like to finish this
before the Bakeathon so we can test the result there.

Benny

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
