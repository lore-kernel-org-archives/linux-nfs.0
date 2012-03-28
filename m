Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39785 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933232Ab2C1XzF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 19:55:05 -0400
Received: by iagz16 with SMTP id z16so2172223iag.19
        for <linux-nfs@vger.kernel.org>; Wed, 28 Mar 2012 16:55:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <74BCDDD5-955E-4C06-9640-47D477A9FF8F@netapp.com>
References: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
	<38AF6CFC-8017-4D08-8DB0-A80BA724E54A@netapp.com>
	<1332947296.11400.7.camel@lade.trondhjem.org>
	<74BCDDD5-955E-4C06-9640-47D477A9FF8F@netapp.com>
Date: Thu, 29 Mar 2012 08:55:04 +0900
Message-ID: <CAKYAXd-eWRrja8bGqS7tTWehPNgAM4gtPALfAexRvTwkbbBOGw@mail.gmail.com>
Subject: Re: [PATCH 1/3] NFSv4: Fix two infinite loops in the mount code
From: Namjae Jeon <linkinjeon@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi. Trond.

Normally goto statement is not recommended(pipeline and branch
prediction) it is only recommended as a last resort if there is no
method to escape this loop.
It is just my opinion. And when I think more,, looks not bad about
forward goto statement.

Thanks~

2012/3/29 Adamson, Dros <Weston.Adamson@netapp.com>:
> OK, I need more coffee :)
>
> -dros
>
> On Mar 28, 2012, at 11:08 AM, Myklebust, Trond wrote:
>
>> On Wed, 2012-03-28 at 15:07 +0000, Adamson, Dros wrote:
>>> This should probably be sent to stable.
>>
>> See below. :-)
>>
>>> -dros
>>>
>>> On Mar 27, 2012, at 6:35 PM, Trond Myklebust wrote:
>>>
>>>> We can currently loop forever in nfs4_lookup_root() and in
>>>> nfs41_proc_secinfo_no_name(), if the first iteration returns a
>>>> NFS4ERR_DELAY or something else that causes exception.retry to get
>>>> set.
>>>>
>>>> Reported-by: Dros Adamson <Weston.Adamson@netapp.com>
>>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>>> Cc: stable@vger.kernel.org
>>>> ---
>>>> fs/nfs/nfs4proc.c |    6 ++++--
>>>> 1 files changed, 4 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>> index 45df7d4..ee9ca19 100644
>>>> --- a/fs/nfs/nfs4proc.c
>>>> +++ b/fs/nfs/nfs4proc.c
>>>> @@ -2290,11 +2290,12 @@ static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
>>>>             switch (err) {
>>>>             case 0:
>>>>             case -NFS4ERR_WRONGSEC:
>>>> -                   break;
>>>> +                   goto out;
>>>>             default:
>>>>                     err = nfs4_handle_exception(server, err, &exception);
>>>>             }
>>>>     } while (exception.retry);
>>>> +out:
>>>>     return err;
>>>> }
>>>>
>>>> @@ -6229,11 +6230,12 @@ nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
>>>>             case 0:
>>>>             case -NFS4ERR_WRONGSEC:
>>>>             case -NFS4ERR_NOTSUPP:
>>>> -                   break;
>>>> +                   goto out;
>>>>             default:
>>>>                     err = nfs4_handle_exception(server, err, &exception);
>>>>             }
>>>>     } while (exception.retry);
>>>> +out:
>>>>     return err;
>>>> }
>>>>
>>>> --
>>>> 1.7.7.6
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>> --
>> Trond Myklebust
>> Linux NFS client maintainer
>>
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
>>
>
