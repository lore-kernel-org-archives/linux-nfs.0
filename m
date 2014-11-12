Return-Path: trond.myklebust@primarydata.com
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.11.1411120755430.20279@sh-el6.eng.rdu2.redhat.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>
	<alpine.LRH.2.11.1411120755430.20279@sh-el6.eng.rdu2.redhat.com>
Date: Wed, 12 Nov 2014 09:36:00 -0500
Message-ID: <CAHQdGtS7LxQWpu4MrkYf2AhboeDC1TRQ5R8wVEJBcppLtDy7Ag@mail.gmail.com>
Subject: Re: mount default minor version behavior
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2014 at 8:09 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> Here's a quick summary of where the threads ended up:
>
>  - Everyone agrees that if a specific minor version is specified, only
>    that version should be attempted.
>
>  - On the issue of minor version omission, the positions are:
>    1) vers=4 means try 4.1, 4.0.
>     Steve D
>     Boaz
>     Ben C

So where does the number 4.1 come from here? Is that a compile option?
That means we would need to recompile every time someone wants to bump
the version number to a new default.

>    2) vers=4 means try 4.0 only.
>     Andros
>     Anna
>     Frank
>
>    3) vers=4 means
>    - if conf file defaultvers=4.1, try 4.1, 4.0.
>    - else if defaultvers not set try 4.0 only.
>     Trond
>
> Anyone else want to weigh in? Trond's position can also count towards
> the second position because we should consider the case where the config
> file is not used or turned off in the build.  I think I could just add a
> bit to the config file that switches between 1 and 2, something like
> "usebestversion", which defaults to position 2.  That would allow a
> distro to use the first behavior if they chose.
>
> Ben
>
>
> On Tue, 11 Nov 2014, Benjamin Coddington wrote:
>
>> I will update mount.nfs so the default version is 4.1.  I have two quick
>> questions on desired behavior:
>>
>>  o  Should mounts that do not specify a minor version be upgraded to the
>> default minor version?
>>
>> For example, should 'mount -overs=4' turn into 'mount -overs4.1', if the
>> current default is 4.1?
>>
>>
>>  o If 'yes' to the above, should mount auto-retry decrementing minor
>> versions if EPROTONOSUPPORT?
>>
>> For example, 'mount -overs=4' with a default of 4.2 would attempt: 4.2,
>> then 4.1, then 4.0.
>>
>> Ben
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
