Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f174.google.com ([209.85.212.174]:51895 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753396Ab2AQUOt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jan 2012 15:14:49 -0500
Received: by wibhm6 with SMTP id hm6so1696941wib.19
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2012 12:14:48 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <20120117194054.GA16118@fieldses.org>
References: <1326644410-7482-1-git-send-email-tigran.mkrtchyan@desy.de>
	<1326644410-7482-3-git-send-email-tigran.mkrtchyan@desy.de>
	<20120117194054.GA16118@fieldses.org>
Date: Tue, 17 Jan 2012 21:14:47 +0100
Message-ID: <CAGue13oDaGn3DbyVDmAZhxqZ1+bwd53X0o-a+Hix-nHgwZ4wBw@mail.gmail.com>
Subject: Re: [PATH v6 2/9] nfsd41: handle current stateid in open and close
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 17, 2012 at 8:40 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Sun, Jan 15, 2012 at 05:20:03PM +0100, Tigran Mkrtchyan wrote:
>> +static void
>> +put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
>> +{
>> +     if (cstate->minorversion)
>> +             cstate->current_stateid = stateid;
>> +}
> ...
>> @@ -54,6 +54,7 @@ struct nfsd4_compound_state {
>>       size_t                  iovlen;
>>       u32                     minorversion;
>>       u32                     status;
>> +     const stateid_t *current_stateid;
>>  };
>
> I'd be more comfortable with passing stateid's by value rather than by
> reference.
>
> Presumably you're only ever pointing into one of the argument or result
> structures which are currently guaranteed to be around for as long as
> the compound is processed.
>
> But it'd seem safer not to have to worry about the lifetime of the
> pointed-to data at all, and just copy the stateid--it's only 16 bytes.

Sure, it's only 16 bytes. Nevertheless, there are no allocation or
de-allocation of it. It just pointing to an existing stateid. Should be
safe to use pointer. And yes, it's just 16 bytes, but if we can avoid to
copy them why not?

Of course I can change it if you want to.

Tigran.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
