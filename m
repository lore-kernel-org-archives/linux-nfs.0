Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:38457 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232AbaCEK6Q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 05:58:16 -0500
Received: by mail-vc0-f180.google.com with SMTP id ks9so821019vcb.39
        for <linux-nfs@vger.kernel.org>; Wed, 05 Mar 2014 02:58:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <FE2FF2AA-62E5-4D8C-9025-D6C648385FFA@primarydata.com>
References: <1393954269-3974-1-git-send-email-andros@netapp.com>
	<FE2FF2AA-62E5-4D8C-9025-D6C648385FFA@primarydata.com>
Date: Wed, 5 Mar 2014 05:58:15 -0500
Message-ID: <CAHVgHyUn9RkcNm=8-Y+JmE9QoQA2nLCWvQgrP81h62r0CFObpA@mail.gmail.com>
Subject: Re: [PATCH 0/4] NFSv4 fix nfs4_stateid_is_current processing
From: Andy Adamson <androsadamson@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 4, 2014 at 1:09 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
>
> On Mar 4, 2014, at 12:31, andros@netapp.com wrote:
>
>> From: Andy Adamson <andros@netapp.com>
>>
>> This is an expanded version of the "NFSv4 always compare stateids in nfs4_stateid_is_current" patch I sent on Feb 27.
>>
>> Found at Connectathon 2014 and NetApp internal testing.
>>
>> nfs4_stateid_is_current is used on the NFSv4 I/O path to determine if a
>> stateid has changed. The idea is that if there is a stateid expire error
>> such as NFS4ERR_BAD_STATEID and the stateid used that induced the error has
>> changed, then we can just resend the RPC from the call prepare state with
>> the changed stateid instead of kicking off recovery as the changed stateid
>> indicates it already had been recovered.
>>
>> This patch set fixes a false positive that resulted in an NFS4ERR_BAD_STATEID
>> infinite loop. Trond pointed out that the nfs4_select_rw_stateid -EIO error
>> is special in that it indicates a lost lock.
>>
>> As I examined the use of nfs4_select_rw_stateid, I addressed some other errors
>> in the use of nfs4_set_rw_stateid and friends in setattr and filelayout
>> prepare functions.
>>
>> Just tested with connectathon tests. Will test more once I'm back in town...
>
> One question:
>
> Do we need the EWOULDBLOCK case at all in nfs4_copy_lock_stateid/nfs4_copy_open_stateid? Looking at the code, it seems particularly redundant for the case of NFSv4.1, where we set the seqid to '0'. Given that we do the nfs4_stateid_is_current() test, it seems unnecessary in the case of NFSv4.0 too...

Yes - Even though you mentioned it's importance at Connectathon, I
could not find a use of the EWOULDBLOCK return.

>
> So, how about just throwing out the EWOULDBLOCK returns, then keeping nfs4_stateid_is_current() as it is,

So, you mean keeping nfs4_stateid_is_current as a boolean, and then
assume that a false  return == -EIO?

I don't like that because that is how this bug was created - mixing
bool and int functions.

> fixing up _nfs4_do_setattr to only deal with the -EIO case,

Yes.

 and then fixing  up the file layout uses of nfs4_select_rw_stateid()
to check the return values?

As I did in the last patch...

>
> _________________________________
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
