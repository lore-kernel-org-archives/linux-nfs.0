Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34963 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776Ab2FXEWf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jun 2012 00:22:35 -0400
MIME-Version: 1.0
In-Reply-To: <5AC2C9F0-EEFE-423E-BBB9-27102D1CA163@oracle.com>
References: <1340448446-10198-1-git-send-email-linkinjeon@gmail.com>
	<20120623115106.GA2742@umich.edu>
	<5AC2C9F0-EEFE-423E-BBB9-27102D1CA163@oracle.com>
Date: Sun, 24 Jun 2012 13:22:33 +0900
Message-ID: <CAKYAXd_QKsiTV86H4eykjOzfJc8Who1T8in5TmnJyxigw=+7AQ@mail.gmail.com>
Subject: Re: [RFC PATCH] nfs: Support posix_fadvise(POSIX_FADV_RANDOM) on nfs server.
From: Namjae Jeon <linkinjeon@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jim Rees <rees@umich.edu>, "bfields@fieldses.org" <bfields@fieldses.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "bharrosh@panasas.com" <bharrosh@panasas.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>,
        VivekTrivedi <t.vivek@samsung.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/6/23, Chuck Lever <chuck.lever@oracle.com>:
>
>
> Sent from my iPad
>
> On Jun 23, 2012, at 7:51 AM, Jim Rees <rees@umich.edu> wrote:
>
>> Namjae Jeon wrote:
>>
>>  From: Namjae Jeon <namjae.jeon@samsung.com>
>>
>>  This patch disable readahead for a file on NFS Server when
>>  posix_fadvise(fd..., POSIX_FADV_RANDOM) is called on NFS
>>  Client.
>>
>> It looks like you're adding an argument to the read op.  Wouldn't that be
>> an
>> incompatible change?  In which case wouldn't it be better to propose this
>> for inclusion in NFS 4.2?  In fact didn't Dean propose this?  What ever
>> happened with that?
>
> Yes, posix_fadvise support is part of NFSv4.2.
Where can I check it ?
Thanks.
>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
