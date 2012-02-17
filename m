Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:51540 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539Ab2BQSq5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Feb 2012 13:46:57 -0500
Subject: Re: [PATCH Version 2 1/1] NFSv4.1 set the cl_hostname for data servers
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHVgHyVGoJNfh-cQ7KsNCyUJhegYpKaJAdsAa5D-QACf-krA_g@mail.gmail.com>
Date: Fri, 17 Feb 2012 13:46:52 -0500
Cc: Dros Adamson <Weston.Adamson@netapp.com>,
        Andy Adamson <William.Adamson@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <91D161E5-801B-44C3-A110-9CFD21C7D0B1@oracle.com>
References: <1329426646-2074-1-git-send-email-andros@netapp.com> <1329427752.19793.30.camel@lade.trondhjem.org> <18B83A3A-12E1-42D8-AE93-9BC2C5FDB136@netapp.com> <B2C8E6B1-523D-4890-B433-64B2BCB5B9AD@netapp.com> <CAHVgHyVGoJNfh-cQ7KsNCyUJhegYpKaJAdsAa5D-QACf-krA_g@mail.gmail.com>
To: Andy Adamson <androsadamson@gmail.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've got a patch that already does this, which Trond wrote a year ago.  I can submit this for 3.4.

On Feb 17, 2012, at 1:40 PM, Andy Adamson wrote:

> Isn't the clp->cl_rpcclient->cl_server always the same as
> clp->cl_hostname? Can we just get rid of the cl_hostname and use the
> cl_server?
> 
> -->Andy
> 
> On Thu, Feb 16, 2012 at 5:08 PM, Adamson, Dros
> <Weston.Adamson@netapp.com> wrote:
>> 
>> On Feb 16, 2012, at 5:00 PM, Adamson, Dros wrote:
>> 
>>> 
>>> On Feb 16, 2012, at 4:29 PM, Myklebust, Trond wrote:
>>> 
>>>> On Thu, 2012-02-16 at 16:10 -0500, andros@netapp.com wrote:
>>>>> From: Andy Adamson <andros@netapp.com>
>>>>> 
>>>>> Used by /proc/fs/nfsfs/servers
>>>>> 
>>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>>> ---
>>>>> fs/nfs/client.c            |    3 ++-
>>>>> fs/nfs/internal.h          |    3 ++-
>>>>> fs/nfs/nfs4filelayoutdev.c |   11 ++++++++++-
>>>>> 3 files changed, 14 insertions(+), 3 deletions(-)
>>>>> 
>>>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>>>>> index d0f850f..c625284 100644
>>>>> --- a/fs/nfs/client.c
>>>>> +++ b/fs/nfs/client.c
>>>>> @@ -1443,7 +1443,7 @@ error:
>>>>> */
>>>>> struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
>>>>>             const struct sockaddr *ds_addr,
>>>>> -           int ds_addrlen, int ds_proto)
>>>>> +           int ds_addrlen, int ds_proto, char *ds_hostname)
>>>> 
>>>> Can you make this (and the other instances below) 'const char *', so
>>>> that we avoid any confusion? Otherwise it looks more or less OK...
>>>> 
>>>> Note that we should consider splitting da->da_remotestr into a
>>>> hostname/port part at some point so that we avoid the copy below.
>>> 
>>> da_remotestr (and ds_remotestr) were meant to be for display only (and iirc they can actually be NULL).
>> 
>> ^^ dprintk() display, that is.
>> 
>>> 
>>> The right way to do this is from the actual sin_addr (da_addr).
>>> 
>>> -dros
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




