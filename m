Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59734 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755773Ab2AQVRK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jan 2012 16:17:10 -0500
Received: by vbbfp1 with SMTP id fp1so1387041vbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2012 13:17:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120117204510.GD16118@fieldses.org>
References: <1326644410-7482-1-git-send-email-tigran.mkrtchyan@desy.de>
	<1326644410-7482-3-git-send-email-tigran.mkrtchyan@desy.de>
	<20120117194054.GA16118@fieldses.org>
	<CAGue13oDaGn3DbyVDmAZhxqZ1+bwd53X0o-a+Hix-nHgwZ4wBw@mail.gmail.com>
	<20120117204510.GD16118@fieldses.org>
Date: Tue, 17 Jan 2012 22:17:09 +0100
Message-ID: <CAFpJMDqNuuGq0m_3RH+soRyCe2AtXpc=mNyTJBj2TQ7SXnxzGw@mail.gmail.com>
Subject: Re: [PATH v6 2/9] nfsd41: handle current stateid in open and close
From: Tiramisu Mokka <kofemann@googlemail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-- kofemann
/** caffeinated mutations of the core personality */



On Tue, Jan 17, 2012 at 21:45, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Jan 17, 2012 at 09:14:47PM +0100, Tigran Mkrtchyan wrote:
>> On Tue, Jan 17, 2012 at 8:40 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > On Sun, Jan 15, 2012 at 05:20:03PM +0100, Tigran Mkrtchyan wrote:
>> >> +static void
>> >> +put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
>> >> +{
>> >> +     if (cstate->minorversion)
>> >> +             cstate->current_stateid = stateid;
>> >> +}
>> > ...
>> >> @@ -54,6 +54,7 @@ struct nfsd4_compound_state {
>> >>       size_t                  iovlen;
>> >>       u32                     minorversion;
>> >>       u32                     status;
>> >> +     const stateid_t *current_stateid;
>> >>  };
>> >
>> > I'd be more comfortable with passing stateid's by value rather than by
>> > reference.
>> >
>> > Presumably you're only ever pointing into one of the argument or result
>> > structures which are currently guaranteed to be around for as long as
>> > the compound is processed.
>> >
>> > But it'd seem safer not to have to worry about the lifetime of the
>> > pointed-to data at all, and just copy the stateid--it's only 16 bytes.
>>
>> Sure, it's only 16 bytes. Nevertheless, there are no allocation or
>> de-allocation of it. It just pointing to an existing stateid.
>
> Well, it's conceivable some day that we could for example take more of a
> one-op-at-a-time approach to compound processing and free the arguments
> and results from the previous op once we're done processing and xdr
> encoding it, in which case continuing to refer to a stateid from the
> previous op would be unsafe.
>
> Or maybe some day there will be an operation that sets the current
> stateid without also returning it in an argument, in which case we could
> be tempted to take a pointer to a field in an object without being
> assured how long that object will be around.
>
> Likely?  Maybe not.  I'd still feel safer not having to think about it.
>
>> Should be safe to use pointer. And yes, it's just 16 bytes, but if we can
>> avoid to
>> copy them why not?
>>
>> Of course I can change it if you want to.
>
> I'd prefer that.
>

Ok. No Problem!

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
