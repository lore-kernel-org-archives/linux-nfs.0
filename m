Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:36860 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754258AbbGFW3N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2015 18:29:13 -0400
Received: by oiaf66 with SMTP id f66so96937573oia.3
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jul 2015 15:29:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <559AFF61.9010606@gmail.com>
References: <1436193748-4301-1-git-send-email-steved@redhat.com>
	<CAHQdGtR8ag7UvqWAATAYJ2XhOZLq3i1pQ1yPEkNdxTTMb_G9aA@mail.gmail.com>
	<559AFF61.9010606@gmail.com>
Date: Mon, 6 Jul 2015 18:29:13 -0400
Message-ID: <CAHQdGtTLA9rOtngX7Z1+4jv3jGQ+WkRekvMR1USk59bt9XYk1w@mail.gmail.com>
Subject: Re: [PATCH] mount.nfs: Teach mount.nfs about the mountversion option
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 6, 2015 at 6:21 PM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> On 7/6/2015 23:19, Trond Myklebust wrote:
>> On Mon, Jul 6, 2015 at 10:42 AM, Steve Dickson <steved@redhat.com> wrote:
>>> When the mountversion option is used, there should
>>> not be any mount negotiations with the server.
>>>
>>> Also, when the option is used, its know that the mount
>>> is a v4 mount and a V_SPECFIC type.
>>>
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>>  utils/mount/network.c | 7 ++++++-
>>>  1 file changed, 6 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>> index b5ed850..ebc39d3 100644
>>> --- a/utils/mount/network.c
>>> +++ b/utils/mount/network.c
>>> @@ -92,6 +92,7 @@ static const char *nfs_version_opttbl[] = {
>>>         "v4",
>>>         "vers",
>>>         "nfsvers",
>>> +       "minorversion",
>>>         NULL,
>>>  };
>>>
>>> @@ -1272,7 +1273,11 @@ nfs_nfs_version(struct mount_options *options, struct nfs_version *version)
>>>         if (!(version->major = strtol(version_val, &cptr, 10)))
>>>                 goto ret_error;
>>>
>>> -       if (version->major < 4)
>>> +       if (strcmp(nfs_version_opttbl[i], "minorversion") == 0) {
>>> +               version->v_mode = V_SPECIFIC;
>>> +               version->minor = version->major;
>>> +               version->major = 4;
>>> +       } else if (version->major < 4)
>>>                 version->v_mode = V_SPECIFIC;
>>>
>>>         if (*cptr == '.') {
>>>
>>
>> Doesn't this cause a dependency on the ordering of 'nfsvers'/'vers'
>> and 'minorversion' in your mount options string?
>
> Without this patch, there is a dependency on the ordering now.
> mount with "-o minorversion=1", nfs gets strings as "minorversion=1,vers=4.2"
>
> If nfs-utils doesn't parse minorversion, the order dependency also exist.
>
> I agree with parsing minorversion in nfs-utils.
>

I was rather hoping we could get rid of 'minorversion' soon. It is a
wart, and we've already agreed to deprecate it.

Trond
