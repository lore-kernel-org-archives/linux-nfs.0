Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:47998 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453AbaHYVRb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2014 17:17:31 -0400
Received: by mail-vc0-f179.google.com with SMTP id hq11so15822853vcb.38
        for <linux-nfs@vger.kernel.org>; Mon, 25 Aug 2014 14:17:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1409000826.3033.32.camel@deadeye.wl.decadent.org.uk>
References: <1927160445.21851828.1408504000719.JavaMail.zimbra@redhat.com>
	<1408576235.2618.47.camel@deadeye.wl.decadent.org.uk>
	<1859750321.23735105.1408945864304.JavaMail.zimbra@redhat.com>
	<1409000826.3033.32.camel@deadeye.wl.decadent.org.uk>
Date: Mon, 25 Aug 2014 17:17:30 -0400
Message-ID: <CAHQdGtT0WhB38XYToS8ceiepW2v_stKZcVYsktBG26iBS4KHAg@mail.gmail.com>
Subject: Re: [PATCH v2] nfs: remove redundant slash from nfs_path
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Xiong Zhou <xzhou@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 25, 2014 at 5:07 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Mon, 2014-08-25 at 01:51 -0400, Xiong Zhou wrote:
>> When export root dir(/) via nfs, and mount a particular dir under root, eg
>> /nfsexport, there will be defect double slash output in /proc/mounts, like
>> localhost://nfsexport. While this patch change it to localhost:/nfsexport.
>>
>> Signed-off-by: Xiong Zhou <xzhou@redhat.com>
>> ---
>>  fs/nfs/namespace.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
>> index b5a0afc..24f954e 100644
>> --- a/fs/nfs/namespace.c
>> +++ b/fs/nfs/namespace.c
>> @@ -98,7 +98,7 @@ rename_retry:
>>               return end;
>>       }
>>       namelen = strlen(base);
>> -     if (flags & NFS_PATH_CANONICAL) {
>> +     if ((flags & NFS_PATH_CANONICAL) || *end == '/') {
>>               /* Strip off excess slashes in base string */
>>               while (namelen > 0 && base[namelen - 1] == '/')
>>                       namelen--;
>
> I think this makes sense, though I'm not sure I completely understand
> this function. :-/
>

It breaks the function's guarantee concerning NFS_PATH_CANONICAL; that
"if unset, the original name is returned verbatim".

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
