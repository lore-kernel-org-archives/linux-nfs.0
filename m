Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32970 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754433AbdBVN15 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Feb 2017 08:27:57 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Miklos Szeredi" <miklos@szeredi.hu>,
        "Jeff Layton" <jlayton@redhat.com>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        "Linux NFS list" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vget.kernel.org" <linux-fsdevel@vget.kernel.org>
Subject: Re: [PATCH 3/4] locks: Set FL_CLOSE when removing flock locks on
 close()
Date: Wed, 22 Feb 2017 08:27:54 -0500
Message-ID: <41D6F495-507F-4EA0-B629-BB400E4B1573@redhat.com>
In-Reply-To: <CAJfpegtArWuOKVS_Qq8E0Fw4pcsYC4sj==BN5=3WQSLDXA5AQg@mail.gmail.com>
References: <cover.1487691345.git.bcodding@redhat.com>
 <c43ab767372bd73a60a4e1c97b39bb6fc0722590.1487691345.git.bcodding@redhat.com>
 <1487765584.2886.8.camel@redhat.com> <1487766356.2886.11.camel@redhat.com>
 <CAJfpegtArWuOKVS_Qq8E0Fw4pcsYC4sj==BN5=3WQSLDXA5AQg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 22 Feb 2017, at 8:25, Miklos Szeredi wrote:

> On Wed, Feb 22, 2017 at 1:25 PM, Jeff Layton <jlayton@redhat.com> 
> wrote:
>> On Wed, 2017-02-22 at 07:13 -0500, Jeff Layton wrote:
>>> On Tue, 2017-02-21 at 10:39 -0500, Benjamin Coddington wrote:
>>>> Set FL_CLOSE in fl_flags as in locks_remove_posix() when clearing 
>>>> locks.
>>>> NFS will check for this flag to ensure an unlock is sent in a 
>>>> following
>>>> patch.
>>>>
>>>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>>>> ---
>>>>  fs/locks.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/fs/locks.c b/fs/locks.c
>>>> index 26811321d39b..af2031a1fcff 100644
>>>> --- a/fs/locks.c
>>>> +++ b/fs/locks.c
>>>> @@ -2504,7 +2504,7 @@ locks_remove_flock(struct file *filp, struct 
>>>> file_lock_context *flctx)
>>>>             .fl_owner = filp,
>>>>             .fl_pid = current->tgid,
>>>>             .fl_file = filp,
>>>> -           .fl_flags = FL_FLOCK,
>>>> +           .fl_flags = FL_FLOCK | FL_CLOSE,
>>>>             .fl_type = F_UNLCK,
>>>>             .fl_end = OFFSET_MAX,
>>>>     };
>>>
>>> Looks good. I'm fine with merging this one via the NFS tree, btw...
>>>
>>> Reviewed-by: Jeff Layton <jlayton@redhat.com>
>>>
>>
>> (cc'ing linux-fsdevel and Miklos)
>>
>> Hmm, that said, this potentially may affect other filesystems. If you 
>> do
>> any more postings of this set, please cc linux-fsdevel.
>>
>> In particular, I'll note that fuse has this:
>>
>>         /* Unlock on close is handled by the flush method */
>>         if (fl->fl_flags & FL_CLOSE)
>>                 return 0;
>>
>> I don't see any lock handling in fuse_flush (though it does pass down 
>> a
>> lockowner). I guess the expectation is that the userland driver 
>> should
>> close down POSIX locks when the flush method is called.
>
> Right.
>
>>
>> Miklos, does this also apply to flock locks? Would Ben's patch cause 
>> any
>> grief here?
>
> Yes, it would make the final close of file not unlock flocks on that 
> open file.
>
> Simple fix is to change that condition to
>
> #define FL_CLOSE_POSIX (FL_POSIX | FL_CLOSE)
>
>         if (fl->fl_flags & FL_CLOSE_POSIX == FL_CLOSE_POSIX)
>                 return 0;

OK, I can that in the next version.  Thanks for that catch Jeff.

Ben
