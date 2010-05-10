From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/8] nfsd4: keep the client from expiring while in use
 by nfs41 compounds
Date: Mon, 10 May 2010 17:15:43 +0300
Message-ID: <4BE8150F.2050706@panasas.com>
References: <4BE0A1AE.4040905@panasas.com> <20100507223836.GO19142@fieldses.org> <4BE65687.8050806@panasas.com> <20100509165551.GA15429@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:54523 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715Ab0EJOQI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 May 2010 10:16:08 -0400
Received: by bwz19 with SMTP id 19so1787954bwz.21
        for <linux-nfs@vger.kernel.org>; Mon, 10 May 2010 07:16:06 -0700 (PDT)
In-Reply-To: <20100509165551.GA15429@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 09, 2010, 19:55 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> On Sun, May 09, 2010 at 09:30:31AM +0300, Benny Halevy wrote:
>> Correct.  The intentions are:
>> 1. Make the laundromat process ignore clients that are in
>> use by a 4.1 session.
>> 2. Renew the client when the compound ends, rather than when it begins.
>> 3. Unhash the client when it's expired explicitly but don't destroy it
>> until there's no reference to it.
> 
> OK.  My one slight worry there is to make sure that code getting a
> pointer to a client through a sessionid won't inadvertently assume it's
> still hashed.

That's a good point.
In fact, the client should not be renewed when the compound is done
if it was already explicitly expired.

Another way to deal with this which may be safer but is less optimal
is to keep only the sessionid and look it up on each use. Then, using
it while holding the state lock will make sure it's valid when used.

Benny

> 
> By the way, the current stateid may present a similar problem to the
> session, since it also lasts across compound ops and references a
> client (and other state).
> 
> Looking through the code....  We don't implement the current stateid at
> all yet.  Ouch.
> 
> I'll add that to the wiki.
> 
>>>> [PATCH 8/8] nfsd41: cstate->session can NULL in nfsd4_destroy_session
>>>> I think this was introduced in: 26c0c75 nfsd4: fix unlikely race in session replay case
>>>> though I'm not sure how it ever worked correctly...
>>> Me neither.  I've got a similar patch in my tree.
>> Heh, I see.
>> 5d4cec2 nfsd4: fix bare destroy_session null dereference
> 
> Apologies, I'd applied it privately but not pushed it out yet....  I
> should have gotten that out faster.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

