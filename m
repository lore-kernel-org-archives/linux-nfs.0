Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f42.google.com ([74.125.82.42]:40669 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282Ab2F1Xde convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jun 2012 19:33:34 -0400
Received: by wgbds11 with SMTP id ds11so577484wgb.1
        for <linux-nfs@vger.kernel.org>; Thu, 28 Jun 2012 16:33:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120628140351.527c5060@tlielax.poochiereds.net>
References: <1340827535-3062-1-git-send-email-andros@netapp.com>
	<20120628114353.4f75aabc@tlielax.poochiereds.net>
	<19150370-D1BD-4CC1-90BD-383805DE9557@netapp.com>
	<20120628140351.527c5060@tlielax.poochiereds.net>
Date: Thu, 28 Jun 2012 19:33:32 -0400
Message-ID: <CAHVgHyWs+_Ep_wP6QASSJ18tM8OhYkQ+o=h5NKnOqdC6HWchKQ@mail.gmail.com>
Subject: Re: [PATCH 0/1] SUNRPC handle EKEYEXPIRED in call_refreshresult
From: Andy Adamson <androsadamson@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 28, 2012 at 2:03 PM, Jeff Layton <jlayton@redhat.com> wrote:
> On Thu, 28 Jun 2012 16:31:41 +0000
> "Adamson, Andy" <William.Adamson@netapp.com> wrote:
>
>>
>> On Jun 28, 2012, at 11:43 AM, Jeff Layton wrote:
>>
>> > On Wed, 27 Jun 2012 16:05:34 -0400
>> > andros@netapp.com wrote:
>> >
>> >> From: Andy Adamson <andros@netapp.com>
>> >>
>> >> Without this patch attempting to access a Kerberos mount with expired or no
>> >> credentials resulted in the NFS client hanging while retrying to refresh creds
>> >> for ever.
>> >>
>> >> I tested NFSv3/v4/v4.1 sec=krb5 mounts. With expired or non-existent user
>> >> Kerberos credentials, trying to ls the mountpoint, or cd into the mountpoint
>> >> resulted in three failed upcalls to gssd (due to tk_cred_retry being set to 2)
>> >> then the 'Operation not permitted' message is returned to the user.
>> >>
>> >> I think this patch should go into the stable kernel.
>> >>
>> >> Andy Adamson (1):
>> >>  SUNRPC handle EKEYEXPIRED in call_refreshresult
>> >>
>> >> fs/nfs/nfs4proc.c |    2 --
>> >> net/sunrpc/clnt.c |    4 ++++
>> >> 2 files changed, 4 insertions(+), 2 deletions(-)
>> >>
>> >
>> > Wait...is this really the behavior you want here?
>>
>> Yes. Just having the client hang with no indication to the user is wrong.
>>
>
> I presume you mean to say that that behavior isn't ideal. I tend to
> agree, but there's no good way to report that to the user who can do
> anything about it. I'll also point out that this scheme doesn't really
> help that either. The user will end up with a failing job, at which
> point it's too late to do anything about it...
>
>> >
>> > We had many complaints from users of krb5 mounts where long-running
>> > jobs would routinely fail when the ticket expired.
>>
>> That is a Kerberos ticket management issue, not an NFS kernel client issue.
>> You have long-running jobs, then kinit -l,  run krenew, or use a keytab with a cron job,
>> or use some other credential management software package.
>>
>
> Easy to say, far more difficult to do.

Here is how simple it is.

$ kinit
$ krenew  -K 30&

This simple krenew command says to renew the current users TGT every
30 minutes for
as long as the TGT is renewable. For my setup, the TGT lasts 10 days -
long enough for most long-running jobs. The kinit is to get a fresh
TGT prior to running renew so that you start with as much time as
possible.

I just tested it. My TGS expires in 30 minutes, my TGT in 1 hour. 3
hours later, I'm still able to access the kerberos mount.

I'm sure most users with long running jobs could handle this. If you
need longer running jobs, then you simply talk to the Kerberos admin
and either get an extended TGT lifetime, or get a keytab and run a
cron job (or use krenew to run a script).


>Most of the people who
> complained about the non-robustness of this were people who were
> running jobs that took days or weeks. They were understandably upset
> when that job failed just because the ticket expired.

Well, they get what they setup. If they didn't ensure a long enough
ticket lifetime, then
they shouldn't be surprised when the access to the file system fails.

>>
>> > The compromise behavior that we worked out at that time was to treat an
>> > expired credcache differently from a "no credcache" situation. gssd would
>> > return EKEYEXPIRED if the credcache existed but was expired, and
>> > EACCES otherwise. The kernel would then treat those errors
>> > differently:
>>
>> In both cases, EPERM is the correct response from the Linux NFS client, as
>> the user has no permissions to do anything in the file system.
>>
>
> But, in the case of an expired ticket, it's quite likely that he had
> permissions at some point in time. The rationale at the time was that
> if that user could reacquire creds he could keep his job going.

Exactly! It's just not the NFS clients job to arrange this! It's a
Kerberos Ticket Lifetime Issue. Use the Kerberos Ticket Lifetime Issue
Tools!

>
>> >
>> >    http://permalink.gmane.org/gmane.linux.nfsv4/11019
>> >
>> > With EKEYEXPIRED, we'd want RPCs to hang indefinitely until the tickets
>> > were renewed.
>>
>> Sounds like a good DOS attack.  Consider V4.1 and a multi-user machine. If a
>> users credentials expire during a heavy I/O run - that user could be using all of the
>> session slots, and no other user could make progress while the RPCs call rpc_delay
>> and retry  indefinitely...
>>
>
> Well, no. That was the main reason we handled this in the NFS layer and
> not in sunrpc. The rpc_task would exit with EKEYEXPIRED and the NFS
> code would treat that like an NFS4ERR_DELAY. Back off and try again
> later.
> Once the task has exited, any resources held in the rpc layer
> including the slot should be available.

Ah - nfs4_async_handle_error on EKEYEXPIRED calls rpc_delay then
returs with an EAGAIN error code - so it  doesn't call rpc_exit, but
the EKEYEXPIRED is handled  the rpc_call_done routine which frees the
slot allowing it to be reused.

Fair enough.

After the delay timer expires, the task goes into the rpc_prepare_task
state to get a new slot, e.g. put on the session slot_tbl_waitq in
heavy I/O situations where all slots are being used.

So in my example above with an expired user GSS context on a
multi-user client, I/O gets stacked up in the session slot_tbl_waitq -
which I've seen to grow to hundreds of RPC requests depending on the
number of session slots and the amount of I/O.  Each I/O will keep on
returning to the session slot_tbl_waitq after an up call to GSSD which
fails with -EKEYEXPIRED.  Gssd gets pounded. The session
slot_tbl_waitq is not drained of this users I/O.

Other users will feel pain. Especially if there is more than one user
on the client irresponsible enough to start a long-running job without
handling their Kerberos credentials.

>
>>
>> > With EACCES, the call would return an error. The idea
>> > there is that the user would kdestroy if he needed to unwedge his krb5
>> > mount.
>>
>> Exactly how is the user supposed to know to kdestroy? All they see is a hung mount.
>>
>
> We do throw a warning when the state manager's ticket expires. Perhaps
> we could do something similar from gssd for user tickets. The point is
> though that the user has the ability to unwedge the mount without
> reacquiring the ticket if he so chooses.

And my point is - this is wrong!  It is a key management issue!  What
if the user doesn't choose to 'unwed'  the mount? Does it hang
forever?

If the user is going to have to make a choice, let them make it on the
front end, and setup their Kerberos tickets according to their need.

>
>> >
>> > This patch makes it sound like you're wanting to revert that behavior.
>> > Is that the case?
>>
>> Yes.
>>
>> > If so, what about people trying to run long-running
>> > tasks on a kerberized mount? Are they just SOL if their ticket isn't
>> > renewed in time?
>>
>> Yes - as with _any_ resource, you need to plan ahead.  As I said above, the administrator in such a situation
>> needs to setup krenew or the equivalent.
>>
>
> That's not helpful. Everyone makes mistakes and you don't necessarily
> want your job to fail simply due to that fact.

Yes, WRT security, you actually do.  There is a reason Kerberos
tickets have a lifetime.
The user needs to be aware of it, and extend or cut-off credentials
according to what their use case is.

> But regardless, Trond
> NAK'ed a similar idea not that long ago:
>
>    http://marc.info/?l=linux-nfs&m=132161606503398&w=2
>
> ...you may want to read over that thread as I'm fairly certain what
> you're proposing will have the same issues...

Your'e referring to data corruption due to buffered writes or commits
with expired GSS credentials?
I'm preparing patches for this issue as well. I'll resend this patch
with the others that
handle the expired GSS creds.

-->Andy

>
> --
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
