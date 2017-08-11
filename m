Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35220 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752631AbdHKOJi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Aug 2017 10:09:38 -0400
MIME-Version: 1.0
In-Reply-To: <87378yr2sx.fsf@notabene.neil.brown.name>
References: <20170807212355.29127-1-kolga@netapp.com> <20170807212355.29127-3-kolga@netapp.com>
 <1502281848.12841.2.camel@redhat.com> <87378yr2sx.fsf@notabene.neil.brown.name>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 11 Aug 2017 10:09:36 -0400
Message-ID: <CAN-5tyEYcdGDLmQZvfdnrvCS+ndLVnjrg4GhFt2JYBhHNk2-ZQ@mail.gmail.com>
Subject: Re: [RFC 1/1] destroy_creds.2: new page documenting destroy_creds()
To: NeilBrown <neilb@suse.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

apologies for duplicates (first attempt bounced from the mailing lists)

On Fri, Aug 11, 2017 at 3:17 AM, NeilBrown <neilb@suse.com> wrote:
> On Wed, Aug 09 2017, Jeff Layton wrote:
> ....
>>
>> Thanks, that helps a bit. I'm less clear on what the higher-level
>> vision is here though:
>>
>> Are we all going to be running scripts on logout that scrape
>> /proc/mounts and run fslogout on each? Will this be added to kdestroy?
>>
>> Or are you aiming to have KCM do this on some trigger? (see:
>> https://fedoraproject.org/wiki/Changes/KerberosKCMCache)
>>
>> Also, doing this per-mount seems wrong to me. Shouldn't this be done on
>> a per-net-namespace basis or maybe even globally?
>
> Having looked at the code, I think this is invalidating cached
> credentials globally -- or at least, globally for all filesystems that
> use sunrpc.

Yes all filesystems that use sunrpc could benefit from by calling the
same routine that NFS calls. It only does it per =E2=80=9Cauth=E2=80=9D fla=
vor. If you
have multiple flavor mounts, only specified one is effected.

>
> I actually question the premise for wanting to do this.  Tickets have a
> timeout and will expire.  Any code that is allowed to get a ticket, can
> hold on to it as long as it likes - but it will cease to work after the
> expiry time.

However, when kdestroy is called, then any code that tries to use it
will yet. User land is unaware that the kernel has cached his
credentials.

> Hunting out all the places that a key might be cached, and
> invalidating them, seems to deviate from the model.

No caching should be valid after credentials were explicitly removed.

> If you are concerned
> about leaving credentials around where they can theoretically be
> misused, then set a smaller expiry time.

That=E2=80=99s correct. The only means that people who have complained
about is left with is using short credentials. But security context
establishment is not for-free and impacts performance.

>
> What is the threat-model that this change is supposed to guard against?

It=E2=80=99s a limitation of a system that I feel has solution of providing=
 the
extension to kdestroy that destroys FS creds.

What=E2=80=99s the disadvantage of providing this feature? There are folks =
who
have been asking for it. It tightens up the security.

>
> Looking that the syscall itself:
>  1/ why restrict the call to directories only?

No real reason. It seems unlikely that the practical unlog application woul=
d
open a filesystem specific file and then call the unlog on that file. It=E2=
=80=99ll be
problematic as without creds no close can be done and would leave state
on the server?

>  2/ Every new syscall should have a 'flags' argument, because you never
>     know when you'll need one.
>
> NeilBrown
>
>
>>
>> It seems like we can afford to be rather cavalier about destroying
>> creds here. Even if we purge creds for a user that should have remained
>> valid, we just end up having to re-upcall for them, right?

Ok.

>> --
>> Jeff Layton <jlayton@redhat.com>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
