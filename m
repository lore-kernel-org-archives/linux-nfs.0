Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35662 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755708Ab2ENLaJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2012 07:30:09 -0400
Received: by bkcji2 with SMTP id ji2so3693212bkc.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 May 2012 04:30:08 -0700 (PDT)
Message-ID: <4FB0ECBE.2060503@tonian.com>
Date: Mon, 14 May 2012 14:30:06 +0300
From: Lior <lior@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: tigran.mkrtchyan@desy.de, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: nfs v4.1 client without pNFS
References: <4FAF9E19.4060802@tonian.com> <CAGue13rFG30EzmQX7sfYA_ouPBxaUu1Xs8sb1ee4fBMtaufKpA@mail.gmail.com> <4FAFBD04.8020301@tonian.com> <4FB0CF8C.8090405@panasas.com>
In-Reply-To: <4FB0CF8C.8090405@panasas.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

בתאריך 14/05/2012 12:25, ציטוט Boaz Harrosh:
> On 05/13/2012 04:54 PM, Lior wrote:
>
>> Hi Tigran,
>>
>> I guess that's one way ( a dark white box way, which still needs to be
>> looked into)... but I was more thinking of a more high level built in
>> user method  (e.g module option ,or mount option)
>>
>
> We used to have it but it was removed, being pointless. 4.1 means pNFS.
>
> The optional clause in the STD means client need no implement it but since
> we slaved so hard to do implement it we see no point ever disabling it.
>
> As an administrator policy it is best controlled in a single place at the
> Server. Instead of having a crap option set at every client. What does that
> give you?
>
> If the admin wants to let you have a choice, for what ever reason that I
> can't currently imagine, He can setup two exports of the same FS one
> with the pnfs option, one without.
I don't think you can export the same FS ( same path ) twice in 2 
different ways...
In any case, I understand the explanation above concerning the design. 
just tried to check if this line of thinking (4.1 without pNFS) is 
needed and/or /wanted.

Thanks,

Lior K.
> The point of the all pNFS support is that everything is automatic, Server
> upgraded/extended/scaled boom transparently works.
>
> NACK on any user visible disables. It's a maintenance disaster. If you
> do find any real bugs with the pNFS option left on, please report ASAP
> and we'll fix it
>
> Cheers
> Boaz
>
>> Thanks for the fast response,
>> Lior K.
>>
>> בתאריך 13/05/2012 16:37, ציטוט Tigran Mkrtchyan:
>>> Hi Lior,
>>>
>>> you can blacklist the layout driver in /etc/modprobe.d/nfsv41.conf
>>>
>>> blacklist nfs_layout_nfsv41_files
>>>
>>>
>>> Tigran.
>>> On Sun, May 13, 2012 at 1:42 PM, Lior<lior@tonian.com>   wrote:
>>>> Hi Trond,
>>>>
>>>> The rfc 5661 states that pNFS is an optional feature.
>>>> Is there currently an intent to implement some sort of an option (module
>>>> option ,or mount option) to run the NFSv4.1 client without pNFS
>>>> functionality?
>>>>
>>>> Thanks,
>>>>    Lior K.
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

