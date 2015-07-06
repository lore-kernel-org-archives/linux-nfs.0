Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752341AbbGFRg2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jul 2015 13:36:28 -0400
Message-ID: <559ABC9A.2080107@RedHat.com>
Date: Mon, 06 Jul 2015 13:36:26 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount.nfs: Teach mount.nfs about the mountversion option
References: <1436193748-4301-1-git-send-email-steved@redhat.com>	<CAHQdGtR8ag7UvqWAATAYJ2XhOZLq3i1pQ1yPEkNdxTTMb_G9aA@mail.gmail.com>	<559AB1F1.1070704@RedHat.com> <CAHQdGtSAMvSKDHAEuVY4Sj1stDtn7sxSw0PS_3jQHwEP9mecng@mail.gmail.com>
In-Reply-To: <CAHQdGtSAMvSKDHAEuVY4Sj1stDtn7sxSw0PS_3jQHwEP9mecng@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/06/2015 12:53 PM, Trond Myklebust wrote:
> On Mon, Jul 6, 2015 at 12:50 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>>
>> On 07/06/2015 11:19 AM, Trond Myklebust wrote:
>>> On Mon, Jul 6, 2015 at 10:42 AM, Steve Dickson <steved@redhat.com> wrote:
>>>> When the mountversion option is used, there should
>>>> not be any mount negotiations with the server.
>>>>
>>>> Also, when the option is used, its know that the mount
>>>> is a v4 mount and a V_SPECFIC type.
>>>>
>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>> ---
>>>>  utils/mount/network.c | 7 ++++++-
>>>>  1 file changed, 6 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>>> index b5ed850..ebc39d3 100644
>>>> --- a/utils/mount/network.c
>>>> +++ b/utils/mount/network.c
>>>> @@ -92,6 +92,7 @@ static const char *nfs_version_opttbl[] = {
>>>>         "v4",
>>>>         "vers",
>>>>         "nfsvers",
>>>> +       "minorversion",
>>>>         NULL,
>>>>  };
>>>>
>>>> @@ -1272,7 +1273,11 @@ nfs_nfs_version(struct mount_options *options, struct nfs_version *version)
>>>>         if (!(version->major = strtol(version_val, &cptr, 10)))
>>>>                 goto ret_error;
>>>>
>>>> -       if (version->major < 4)
>>>> +       if (strcmp(nfs_version_opttbl[i], "minorversion") == 0) {
>>>> +               version->v_mode = V_SPECIFIC;
>>>> +               version->minor = version->major;
>>>> +               version->major = 4;
>>>> +       } else if (version->major < 4)
>>>>                 version->v_mode = V_SPECIFIC;
>>>>
>>>>         if (*cptr == '.') {
>>>>
>>>
>>> Doesn't this cause a dependency on the ordering of 'nfsvers'/'vers'
>>> and 'minorversion' in your mount options string?
>> I don't think so... The only combination that does not work
>> is -o nfsvers=3,minorversion=1 which should fail...
>>
>> What am I missing?
>>
> 
> Does "-o minorversion=1,nfsvers=3" show the same behaviour?
It does 
# mount.nfs -o minorversion=1,nfsvers=3 freddy:/home /mnt/home
mount.nfs: an incorrect mount option was specified

Plus a nice little error message comes out on the console
NFS: mount option vers=3 does not support minorversion=1

And -o minorversion=0,nfsvers=3 works as expected...

steved.



> 
> Cheers
>  Trond
> 
