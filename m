Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:39862 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751402AbeBWRFK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Feb 2018 12:05:10 -0500
Received: by mail-ua0-f195.google.com with SMTP id c20so5340011uak.6
        for <linux-nfs@vger.kernel.org>; Fri, 23 Feb 2018 09:05:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <034fb5f1-eba5-030b-aad2-6ac5e87f2066@RedHat.com>
References: <20180222192806.67911-1-kolga@netapp.com> <034fb5f1-eba5-030b-aad2-6ac5e87f2066@RedHat.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 23 Feb 2018 12:05:08 -0500
Message-ID: <CAN-5tyE2wqrgkQuHSFy7=EDricmx6jPKA9=PnqSdf8rr_0rxwQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFS guard against incorrect vers inputs from nfs-utils
To: Steve Dickson <SteveD@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 23, 2018 at 11:24 AM, Steve Dickson <SteveD@redhat.com> wrote:
> Hey Olga,
>
> On 02/22/2018 02:28 PM, Olga Kornievskaia wrote:
>> It is possible that userland can pass to the kernel mismatching
>> inputs for the minorversion. like vers=4.1,minorversion=0. Instead
>> of making the kernel responposible for 'choosing' the minorversion,
>> make the userland always responsible for not sending a mismatch.
> I'm thinking this is probably more of mount problem...

Yes the problem is a broken user land sending incorrect arguments but
I still think the kernel needs to do sanity checking on arguments to
prevent this from happening again.

> mount -t nfs4 -o minorversion=0 server:/export /mnt
>
> shouldn't this be a  v4.0 mount instead of a 4.2 mount?

Yes I would think this should create a v4.0 mount.

>
> steved.
>
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  fs/nfs/super.c | 10 +++++++++-
>>  1 file changed, 9 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 29bacdc..90c0584 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -1207,7 +1207,7 @@ static int nfs_parse_mount_options(char *raw,
>>                                  struct nfs_parsed_mount_data *mnt)
>>  {
>>       char *p, *string, *secdata;
>> -     int rc, sloppy = 0, invalid_option = 0;
>> +     int rc, sloppy = 0, invalid_option = 0, minorversion = -1;
>>       unsigned short protofamily = AF_UNSPEC;
>>       unsigned short mountfamily = AF_UNSPEC;
>>
>> @@ -1419,6 +1419,7 @@ static int nfs_parse_mount_options(char *raw,
>>                       if (option > NFS4_MAX_MINOR_VERSION)
>>                               goto out_invalid_value;
>>                       mnt->minorversion = option;
>> +                     minorversion = option;
>>                       break;
>>
>>               /*
>> @@ -1655,6 +1656,9 @@ static int nfs_parse_mount_options(char *raw,
>>               }
>>       }
>>
>> +     if (minorversion >= 0 && minorversion != mnt->minorversion)
>> +             goto out_mountvers_mismatch;
>> +
>>       return 1;
>>
>>  out_mountproto_mismatch:
>> @@ -1685,6 +1689,10 @@ static int nfs_parse_mount_options(char *raw,
>>       free_secdata(secdata);
>>       printk(KERN_INFO "NFS: security options invalid: %d\n", rc);
>>       return 0;
>> +out_mountvers_mismatch:
>> +     printk(KERN_INFO "NFS: mismatch versions supplied vers=4.%d and "
>> +                      "minorversion=%d\n", mnt->minorversion, minorversion);
>> +     return 0;
>>  }
>>
>>  /*
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
