Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33872 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753144AbdHKOFm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Aug 2017 10:05:42 -0400
MIME-Version: 1.0
In-Reply-To: <1502450305.4950.4.camel@redhat.com>
References: <20170807212355.29127-1-kolga@netapp.com> <20170807212355.29127-3-kolga@netapp.com>
 <1502281848.12841.2.camel@redhat.com> <87378yr2sx.fsf@notabene.neil.brown.name>
 <1502450305.4950.4.camel@redhat.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 11 Aug 2017 10:05:40 -0400
Message-ID: <CAN-5tyH=V_tLQw7mu+AaxudVyVPeJ6bDo8pi3CkSgVibJt6QhA@mail.gmail.com>
Subject: Re: [RFC 1/1] destroy_creds.2: new page documenting destroy_creds()
To: Jeff Layton <jlayton@redhat.com>
Cc: NeilBrown <neilb@suse.com>, Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 11, 2017 at 7:18 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Fri, 2017-08-11 at 17:17 +1000, NeilBrown wrote:
>> On Wed, Aug 09 2017, Jeff Layton wrote:
>> ....
>> >
>> > Thanks, that helps a bit. I'm less clear on what the higher-level
>> > vision is here though:
>> >
>> > Are we all going to be running scripts on logout that scrape
>> > /proc/mounts and run fslogout on each? Will this be added to kdestroy?
>> >
>> > Or are you aiming to have KCM do this on some trigger? (see:
>> > https://fedoraproject.org/wiki/Changes/KerberosKCMCache)
>> >
>> > Also, doing this per-mount seems wrong to me. Shouldn't this be done o=
n
>> > a per-net-namespace basis or maybe even globally?
>>
>> Having looked at the code, I think this is invalidating cached
>> credentials globally -- or at least, globally for all filesystems that
>> use sunrpc.
>>
>> I actually question the premise for wanting to do this.  Tickets have a
>> timeout and will expire.  Any code that is allowed to get a ticket, can
>> hold on to it as long as it likes - but it will cease to work after the
>> expiry time.  Hunting out all the places that a key might be cached, and
>> invalidating them, seems to deviate from the model.  If you are concerne=
d
>> about leaving credentials around where they can theoretically be
>> misused, then set a smaller expiry time.
>>
>> What is the threat-model that this change is supposed to guard against?
>>
>> Looking that the syscall itself:
>>  1/ why restrict the call to directories only?
>>  2/ Every new syscall should have a 'flags' argument, because you never
>>     know when you'll need one.
>>
>
> I have some of the same concerns. For instance, we don't kill off ssh
> sessions that were established with krb5 just because the credcache was
> destroyed. RPC is a bit different since we authenticate every call, but
> is this fundamentally different from keeping an ssh session around that
> was established before the credcache was destroyed?

Probably because fundamentally, it=E2=80=99s the same user that keeps using=
 it.
If the same ssh connection was shared by multiple users that were inserting
and deleting their credentials then it would be as problematic.

>
> Are we just getting tickets with too long a lifetime here? Maybe we just
> need to be more cavalier about destroying cached creds on some event or
> on a more timely basis?
>
> Also, the whole gssapi credcache in the kernel is showing its age a bit.
> struct auth_cred has had this over it for about as long as I've been
> doing kernel work:
>
>     /* Work around the lack of a VFS credential */
>
> We've had struct cred for ages now.
>
> David and I were chatting about this the other day and were wondering if
> we could change the RPC gssapi code to cache credentials in one of the
> keyrings in struct cred. Then, once the struct cred goes away, the key
> would go away as well. It wouldn't be destroyed on kdestroy, but once
> the last process with those creds exits, they would go away.

One argument against it: Kerberos has changed their storage location
over the years (FILES =E2=80=A6 to keyring). What if they change again? The=
n NFS
would have to change their implementation as well.

Having said that: outside of the fs-mailing list, I have asked Trond that
if VFS decides to reject the syscall idea, what would be an alternative
and one of the choices is the keyring. Of course there are variations of
how the keyring would be used. One option would be to totally switch to
storing credentials in the keyring. To what what Andy had originally
proposed of introducing a gss key type and storing the gss context in
the keyring.

>
> --
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
