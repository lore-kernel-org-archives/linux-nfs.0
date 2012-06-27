Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:63630 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754685Ab2F0Ajf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jun 2012 20:39:35 -0400
MIME-Version: 1.0
In-Reply-To: <4FEA4DE7.3030606@gmail.com>
References: <1340448446-10198-1-git-send-email-linkinjeon@gmail.com>
	<20120623115106.GA2742@umich.edu>
	<5AC2C9F0-EEFE-423E-BBB9-27102D1CA163@oracle.com>
	<CAKYAXd_QKsiTV86H4eykjOzfJc8Who1T8in5TmnJyxigw=+7AQ@mail.gmail.com>
	<20120624124625.GA15586@umich.edu>
	<CAKYAXd-OT9nV--vYOseGYHp35g3qo86rzYJPDiP454ipoGJ2Xw@mail.gmail.com>
	<4FEA4DE7.3030606@gmail.com>
Date: Wed, 27 Jun 2012 09:39:33 +0900
Message-ID: <CAKYAXd9V7GyLNcsn5pkR34ckzsJGSxykXoPFo=91NO5tPeCU+g@mail.gmail.com>
Subject: Re: [RFC PATCH] nfs: Support posix_fadvise(POSIX_FADV_RANDOM) on nfs server.
From: Namjae Jeon <linkinjeon@gmail.com>
To: Dean <seattleplus@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>,
        VivekTrivedi <t.vivek@samsung.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi. Dean.

I have currenlty been having the deep interest about NFS. If I have a
chance to help you for NFSv2, It is a great honor for me.
Acutally I don't know how to contribute something for NFSv2 spec. If
you give me some guide or advice, I will join postively.

Thanks.

2012/6/27, Dean <seattleplus@gmail.com>:
> Hi Namjae,
>
> I'm glad you also see the usefulness of sending such hints to the NFS
> server.
>
> Beyond reviewing the  NFSv4.2 spec, it would also be very useful to
> implement a version of IO_ADVISE and show performance results with your
> traverse test (among others).  If you have time for this, that would
> really be helpful in ensuring the usefulness of IO_ADVISE.
>
> Dean Hildebrand
>
> On 6/24/12 6:54 PM, Namjae Jeon wrote:
>> 2012/6/24, Jim Rees <rees@umich.edu>:
>>> Namjae Jeon wrote:
>>>
>>>    > Yes, posix_fadvise support is part of NFSv4.2.
>>>    Where can I check it ?
>>>    Thanks.
>>>
>>> NFS is standardized throught the IETF.  4.2 is not out yet, so you'll
>>> find
>>> it in the drafts rather than the RFCs.  You can search them here:
>>> http://www.rfc-editor.org/idsearch.html
>>>
>>> Here is the current draft:
>>> ftp://ftp.rfc-editor.org/in-notes/internet-drafts/draft-ietf-nfsv4-minorversion2-12.txt
>>>
>> Okay, I will check, Thanks a lot Jim~. We hope to contribute NFSv4.2.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>
