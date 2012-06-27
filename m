Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:51226 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368Ab2F0AEJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jun 2012 20:04:09 -0400
Message-ID: <4FEA4DE7.3030606@gmail.com>
Date: Tue, 26 Jun 2012 17:03:51 -0700
From: Dean <seattleplus@gmail.com>
MIME-Version: 1.0
To: Namjae Jeon <linkinjeon@gmail.com>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>,
        VivekTrivedi <t.vivek@samsung.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>
Subject: Re: [RFC PATCH] nfs: Support posix_fadvise(POSIX_FADV_RANDOM) on
 nfs server.
References: <1340448446-10198-1-git-send-email-linkinjeon@gmail.com> <20120623115106.GA2742@umich.edu> <5AC2C9F0-EEFE-423E-BBB9-27102D1CA163@oracle.com> <CAKYAXd_QKsiTV86H4eykjOzfJc8Who1T8in5TmnJyxigw=+7AQ@mail.gmail.com> <20120624124625.GA15586@umich.edu> <CAKYAXd-OT9nV--vYOseGYHp35g3qo86rzYJPDiP454ipoGJ2Xw@mail.gmail.com>
In-Reply-To: <CAKYAXd-OT9nV--vYOseGYHp35g3qo86rzYJPDiP454ipoGJ2Xw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Namjae,

I'm glad you also see the usefulness of sending such hints to the NFS 
server.

Beyond reviewing the  NFSv4.2 spec, it would also be very useful to 
implement a version of IO_ADVISE and show performance results with your 
traverse test (among others).  If you have time for this, that would 
really be helpful in ensuring the usefulness of IO_ADVISE.

Dean Hildebrand

On 6/24/12 6:54 PM, Namjae Jeon wrote:
> 2012/6/24, Jim Rees <rees@umich.edu>:
>> Namjae Jeon wrote:
>>
>>    > Yes, posix_fadvise support is part of NFSv4.2.
>>    Where can I check it ?
>>    Thanks.
>>
>> NFS is standardized throught the IETF.  4.2 is not out yet, so you'll find
>> it in the drafts rather than the RFCs.  You can search them here:
>> http://www.rfc-editor.org/idsearch.html
>>
>> Here is the current draft:
>> ftp://ftp.rfc-editor.org/in-notes/internet-drafts/draft-ietf-nfsv4-minorversion2-12.txt
>>
> Okay, I will check, Thanks a lot Jim~. We hope to contribute NFSv4.2.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


