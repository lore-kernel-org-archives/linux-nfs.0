Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f44.google.com ([209.85.216.44]:39314 "EHLO
	mail-vn0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbbFLVmT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 17:42:19 -0400
Received: by vnbg190 with SMTP id g190so8063076vnb.6
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2015 14:42:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <433911A8-6C05-4F6A-888F-4C3CD3FC7ED0@netapp.com>
References: <1434142410-86401-1-git-send-email-kolga@netapp.com>
	<CAHQdGtQVgDcT53C+_GsFjQ-qdWy1XOhRgx5HAk-WCC-8ik7i+g@mail.gmail.com>
	<433911A8-6C05-4F6A-888F-4C3CD3FC7ED0@netapp.com>
Date: Fri, 12 Jun 2015 17:42:18 -0400
Message-ID: <CAHQdGtQ8R600Dai=n4gzctE39dBaek6o1DNeGGuTu0MXo1vfPw@mail.gmail.com>
Subject: Re: [PATCH 1/1] Recover from stateid-type error on SETATTR
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
Cc: "Schumaker, Anna" <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 12, 2015 at 5:37 PM, Kornievskaia, Olga
<Olga.Kornievskaia@netapp.com> wrote:
>
>> On Jun 12, 2015, at 5:21 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>
>> On Fri, Jun 12, 2015 at 4:53 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
>>> Client can receives stateid-type error (eg., BAD_STATEID) on SETATTR when
>>> delegation stateid was used. When no open state exists, in case of application
>>> calling truncate() on the file, client has no state to recover and fails with
>>> EIO.
>>>
>>> Instead, upon such error, return the bad delegation and then resend the
>>> SETATTR with a zero stateid.
>>>
>>> Signed-off: Olga Kornievskaia <kolga@netapp.com>
>>> ---
>>> fs/nfs/nfs4proc.c | 8 +++++++-
>>> 1 file changed, 7 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index ad7cf7e..2a85af3 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -360,8 +360,14 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
>>>                case -NFS4ERR_DELEG_REVOKED:
>>>                case -NFS4ERR_ADMIN_REVOKED:
>>>                case -NFS4ERR_BAD_STATEID:
>>> -                       if (state == NULL)
>>> +                       if (state == NULL) {
>>> +                               if (inode && nfs4_have_delegation(inode,
>>> +                                               FMODE_READ)) {
>>> +                                       nfs4_inode_return_delegation(inode);
>>> +                                       exception->retry = 1;
>>> +                               }
>>>                                break;
>>> +                       }
>>>                        ret = nfs4_schedule_stateid_recovery(server, state);
>>>                        if (ret < 0)
>>>                                break;
>>
>> My remaining question here is: We don't seem to be communicating the
>> _REVOKED state of the delegation to nfs4_schedule_stateid_recovery(),
>> so won't we continue to loop if state != NULL?
>
> I’m not following. This patch is to handle the case when state is NULL and therefore we can’t initiate recovery. Before this patch, the problem was that when state was NULL we didn’t (a) clean up by doing delegreturn and (b) we weren’t retrying when we can — i.e. with a special stateid for SETATTR.
>
> If state is not null, I’m assuming the code is handling correctly by calling nfs4_schedule_stateid_recovery. The correctness of that code is beyond the scope of the problem i’m proposing to solve here.

That's my point. I'm not seeing that the code is handling that case,
and so I'm not seeing why we should treat state == NULL as being
special.

>
>
>> IOW: is there any reason not to do the same thing here that we already
>> do for NFS4ERR_OPENMODE?
>
> The OPENMODE error mode code seems to have slightly different logic. It wants to return  the delegation regardless of whether or not state is NULL.

See above.
