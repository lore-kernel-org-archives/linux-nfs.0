Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:35381 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755013Ab2FXMrU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jun 2012 08:47:20 -0400
Date: Sun, 24 Jun 2012 08:46:25 -0400
From: Jim Rees <rees@umich.edu>
To: Namjae Jeon <linkinjeon@gmail.com>
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
Subject: Re: [RFC PATCH] nfs: Support posix_fadvise(POSIX_FADV_RANDOM) on nfs
 server.
Message-ID: <20120624124625.GA15586@umich.edu>
References: <1340448446-10198-1-git-send-email-linkinjeon@gmail.com>
 <20120623115106.GA2742@umich.edu>
 <5AC2C9F0-EEFE-423E-BBB9-27102D1CA163@oracle.com>
 <CAKYAXd_QKsiTV86H4eykjOzfJc8Who1T8in5TmnJyxigw=+7AQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKYAXd_QKsiTV86H4eykjOzfJc8Who1T8in5TmnJyxigw=+7AQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Namjae Jeon wrote:

  > Yes, posix_fadvise support is part of NFSv4.2.
  Where can I check it ?
  Thanks.

NFS is standardized throught the IETF.  4.2 is not out yet, so you'll find
it in the drafts rather than the RFCs.  You can search them here:
http://www.rfc-editor.org/idsearch.html

Here is the current draft:
ftp://ftp.rfc-editor.org/in-notes/internet-drafts/draft-ietf-nfsv4-minorversion2-12.txt
