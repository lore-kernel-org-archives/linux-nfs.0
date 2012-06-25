Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:57459 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167Ab2FYByL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jun 2012 21:54:11 -0400
MIME-Version: 1.0
In-Reply-To: <20120624124625.GA15586@umich.edu>
References: <1340448446-10198-1-git-send-email-linkinjeon@gmail.com>
	<20120623115106.GA2742@umich.edu>
	<5AC2C9F0-EEFE-423E-BBB9-27102D1CA163@oracle.com>
	<CAKYAXd_QKsiTV86H4eykjOzfJc8Who1T8in5TmnJyxigw=+7AQ@mail.gmail.com>
	<20120624124625.GA15586@umich.edu>
Date: Mon, 25 Jun 2012 10:54:10 +0900
Message-ID: <CAKYAXd-OT9nV--vYOseGYHp35g3qo86rzYJPDiP454ipoGJ2Xw@mail.gmail.com>
Subject: Re: [RFC PATCH] nfs: Support posix_fadvise(POSIX_FADV_RANDOM) on nfs server.
From: Namjae Jeon <linkinjeon@gmail.com>
To: Jim Rees <rees@umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
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

2012/6/24, Jim Rees <rees@umich.edu>:
> Namjae Jeon wrote:
>
>   > Yes, posix_fadvise support is part of NFSv4.2.
>   Where can I check it ?
>   Thanks.
>
> NFS is standardized throught the IETF.  4.2 is not out yet, so you'll find
> it in the drafts rather than the RFCs.  You can search them here:
> http://www.rfc-editor.org/idsearch.html
>
> Here is the current draft:
> ftp://ftp.rfc-editor.org/in-notes/internet-drafts/draft-ietf-nfsv4-minorversion2-12.txt
>
Okay, I will check, Thanks a lot Jim~. We hope to contribute NFSv4.2.
