Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:36394 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477AbbDUN3b convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2015 09:29:31 -0400
Received: by iebrs15 with SMTP id rs15so13386918ieb.3
        for <linux-nfs@vger.kernel.org>; Tue, 21 Apr 2015 06:29:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyGSEURn62cawEbudhQ5gsEdRD+HB7qKjYRS-3L-OLsPrQ@mail.gmail.com>
References: <CAN-5tyE60A+2h6My0Ebb=5j4DbVifDBuG6CjymCRsRefNTMd=w@mail.gmail.com>
	<CAHQdGtSTc-34R_C0TwYmwk8KdQFadxQbhgmoTxzhWKhsYjiFww@mail.gmail.com>
	<CAN-5tyEx_Pp0q58EiYSLLAZZ1cR4Tn9=gkD7b_pubsZdXymsFg@mail.gmail.com>
	<CAN-5tyGSEURn62cawEbudhQ5gsEdRD+HB7qKjYRS-3L-OLsPrQ@mail.gmail.com>
Date: Tue, 21 Apr 2015 09:29:30 -0400
Message-ID: <CAN-5tyHMNh7X0YZSpXD4YZJ=iv9i=jXnx8cG5pw020dXAUtg3A@mail.gmail.com>
Subject: Re: is receiving BAD_STATEID during IO on delegated stateid unrecoverable?
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, which of those two fixes would you be willing to accept?

This is an easily reproducible problem and leads to client EIO and
needs to be addressed.

On Thu, Apr 16, 2015 at 2:07 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Which of the two solutions would you prefer as fix?
>
> Problem statement: SETATTR is sent with a delegation stateid after the
> original open was closed so we have no open state. When the server
> fails the SETATTR with stateid-type of error BAD_STATEID or
> ADMIN_REVOKED, client fails to recover because it has no open state to
> initiate recovery and instead fails with EIO.
>
> Solution #1: When we need to send a SETATTR and we have no state, use
> zero stateid instead. Disadvantage of this approach is that if the
> delegation state is actually valid, then it'll force a delegation to
> be recalled by the server.
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index ad7cf7e..4dda0f1 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2485,7 +2485,8 @@ static int _nfs4_do_setattr(struct inode *inode, struct rp
>         truncate = (sattr->ia_valid & ATTR_SIZE) ? true : false;
>         fmode = truncate ? FMODE_WRITE : FMODE_READ;
>
> -       if (nfs4_copy_delegation_stateid(&arg.stateid, inode, fmode)) {
> +       if (state != NULL &&
> +               nfs4_copy_delegation_stateid(&arg.stateid, inode, fmode)) {
>                 /* Use that stateid */
>         } else if (truncate && state != NULL) {
>
> Solution #2: If we get a stateid-like error on a SETATTR and we have
> no state, return/remove bad delegation and retry the call again which
> will have the code pick the zero stateid.
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index ad7cf7e..be16143 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2535,6 +2535,14 @@ static int nfs4_do_setattr(struct inode *inode, struct rp
>                                         err = -EACCES;
>                                 goto out;
>                         }
> +               case -NFS4ERR_DELEG_REVOKED:
> +               case -NFS4ERR_ADMIN_REVOKED:
> +               case -NFS4ERR_BAD_STATEID:
> +                       if (state == NULL) {
> +                               nfs4_inode_return_delegation(inode);
> +                               exception.retry = 1;
> +                               continue;
> +                       }
>                 }
>                 err = nfs4_handle_exception(server, err, &exception);
>         } while (exception.retry);
>
> On Wed, Apr 15, 2015 at 2:27 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> Hi Trond,
>>
>> I'm resurrecting an old client received "BAD_STATEID" using delegation
>> stateid on some operation thread.... If client used a delegation
>> stateid on a SETATTR (i.e. for open truncate) and received this error,
>> does this also lead to unrecoverable state or do you think client
>> should try recover? I can see the same argument that if state was
>> revoked another client could have change the file already.
>>
>> If you think it's recoverable, there is a bug in the client because it
>> doesn't recover. I can explain why but there is no need if this is an
>> acceptable behavior.
>>
>> Thanks.
>>
>> On Thu, Nov 20, 2014 at 4:14 PM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>> On Thu, Nov 20, 2014 at 12:57 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>> Hi folks,
>>>>
>>>> As far as I can tell, receiving a BAD_STATEID on an IO operation on a
>>>> delegated stateid when there was a local lock acquired for this IO is
>>>> unrecoverable — leads to EIO. Codewise, stateid recovery sees that it
>>>> has a local lock and marks it lost and retry of the IO operation
>>>> returns the EIO.
>>>>
>>>> Is the reason for seizing the IO is that if the server for some reason
>>>> revoked this stateid then there is no guarantee about the locks and
>>>> thus doing any IO.
>>>>
>>>> This also applies to both 4.0 and 4.1 code as far as I can tell.
>>>>
>>>> Can somebody confirm or tell me if this is wrong?
>>>>
>>>
>>> Yes. If the server has lost the lock, then the application has lost
>>> atomicity for the set of operations that were supposed to be protected
>>> by that lock, and this is why we return the EIO. In older kernels we
>>> did try to recover the lock, but that can lead to application-visible
>>> corruption of data, and so we no longer do that unless you explicitly
>>> set the nfs 'recover_lost_locks' module parameter - see
>>> Documentation/kernel-parameters.txt.
>>>
>>> --
>>> Trond Myklebust
>>>
>>> Linux NFS client maintainer, PrimaryData
>>>
>>> trond.myklebust@primarydata.com
