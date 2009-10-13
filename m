From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
Date: Tue, 13 Oct 2009 11:51:31 -0400
Message-ID: <4d569c330910130851o155050djdfed6a52e1f3177a@mail.gmail.com>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
	 <20091009121602.5ec86dfb@tlielax.poochiereds.net>
	 <1c358fde92c49215d84129a1bfe2c6ec.squirrel@webmail.rainiday.com>
	 <20091010090039.4dfd1dfb@tlielax.poochiereds.net>
	 <ee56329e7d86a3e4b15001a39bb7e14a.squirrel@webmail.rainiday.com>
	 <20091013114441.2882c8b9@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:56108 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759766AbZJMPwJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 11:52:09 -0400
Received: by fxm27 with SMTP id 27so10360751fxm.17
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 08:51:32 -0700 (PDT)
In-Reply-To: <20091013114441.2882c8b9-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 13, 2009 at 11:44 AM, Jeff Layton <jlayton@redhat.com> wrot=
e:
> On Tue, 13 Oct 2009 08:28:52 -0700
> raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org wrote:
>
>> Jeff Layton <jlayton@redhat.com> said:
>> >> Just to be clear - you mean doable to a coder who might like to i=
mprove
>> >> on
>> >> gssd/kernel credential separation, rather than a non-coding sysad=
min who
>> >> needs with work within the current NFS/gssd framework?
>> >>
>> >
>> > Correct, that's what I mean. It'll mean modifying kernel and rpc.g=
ssd
>> > code.
>>
>> Thanks for confirming. =A0Skipping back a little:
>>
>> >> > No, gssd (the client side daemon) will search /tmp for anything=
 that
>> >> > looks like a credcache for the right user, verify that it is a
>> >> > credcache and then pick the one with the latest TGT expiration.
>>
>> Kevin Coffman on the NFS4 list actually implied this used simple mti=
me
>> rather than actually scanning /tmp/krb5cc_uid* for ccache files with=
 the
>> latest TGT expiration, which is how I originally read your statement=
=2E
>> This seemingly would make a difference in an environment with a batc=
h job
>> with a long lifetime ticket and subsequent interactive login generat=
ing a
>> separate ccache file with a shorter lifetime but newer mtime.
>>
>> I'm not a coder but I scanned krb5_util.c in the gssd code, and it *=
seems*
>> to me it only looks at mtime, although what you suggest would be mor=
e
>> optimal. =A0Could you confirm whether it's scanning ccache files for=
 longest
>> TGT, or just using mtime?
>>
>
> You and Kevin are correct. rpc.gssd only looks at the mtime. When I d=
id
> the work to allow the CIFS SPNGEO upcall to find alternate credcaches=
,
> I implemented the behavior I described (prefer the latest TGT
> expiration) -- sorry for the confusion...
>
> It probably wouldn't be too hard to change rpc.gssd to prefer
> credcaches with the latest TGT expiration if it was considered a
> desirable change.
>
> Kevin, any thoughts?

I agree it shouldn't be too hard to change if that behavior is desirabl=
e/useful.
