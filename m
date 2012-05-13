Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36590 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304Ab2EMNyQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 May 2012 09:54:16 -0400
Received: by bkcji2 with SMTP id ji2so3183337bkc.19
        for <linux-nfs@vger.kernel.org>; Sun, 13 May 2012 06:54:15 -0700 (PDT)
Message-ID: <4FAFBD04.8020301@tonian.com>
Date: Sun, 13 May 2012 16:54:12 +0300
From: Lior <lior@tonian.com>
MIME-Version: 1.0
To: tigran.mkrtchyan@desy.de
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: nfs v4.1 client without pNFS
References: <4FAF9E19.4060802@tonian.com> <CAGue13rFG30EzmQX7sfYA_ouPBxaUu1Xs8sb1ee4fBMtaufKpA@mail.gmail.com>
In-Reply-To: <CAGue13rFG30EzmQX7sfYA_ouPBxaUu1Xs8sb1ee4fBMtaufKpA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tigran,

I guess that's one way ( a dark white box way, which still needs to be 
looked into)... but I was more thinking of a more high level built in 
user method  (e.g module option ,or mount option)

Thanks for the fast response,
Lior K.

בתאריך 13/05/2012 16:37, ציטוט Tigran Mkrtchyan:
> Hi Lior,
>
> you can blacklist the layout driver in /etc/modprobe.d/nfsv41.conf
>
> blacklist nfs_layout_nfsv41_files
>
>
> Tigran.
> On Sun, May 13, 2012 at 1:42 PM, Lior<lior@tonian.com>  wrote:
>> Hi Trond,
>>
>> The rfc 5661 states that pNFS is an optional feature.
>> Is there currently an intent to implement some sort of an option (module
>> option ,or mount option) to run the NFSv4.1 client without pNFS
>> functionality?
>>
>> Thanks,
>>   Lior K.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

