Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:18078 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab2FWNbO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Jun 2012 09:31:14 -0400
References: <1340448446-10198-1-git-send-email-linkinjeon@gmail.com> <20120623115106.GA2742@umich.edu>
In-Reply-To: <20120623115106.GA2742@umich.edu>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <5AC2C9F0-EEFE-423E-BBB9-27102D1CA163@oracle.com>
Cc: Namjae Jeon <linkinjeon@gmail.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "bharrosh@panasas.com" <bharrosh@panasas.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>,
        VivekTrivedi <t.vivek@samsung.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH] nfs: Support posix_fadvise(POSIX_FADV_RANDOM) on nfs server.
Date: Sat, 23 Jun 2012 09:30:36 -0400
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Sent from my iPad

On Jun 23, 2012, at 7:51 AM, Jim Rees <rees@umich.edu> wrote:

> Namjae Jeon wrote:
> 
>  From: Namjae Jeon <namjae.jeon@samsung.com>
> 
>  This patch disable readahead for a file on NFS Server when
>  posix_fadvise(fd..., POSIX_FADV_RANDOM) is called on NFS
>  Client.
> 
> It looks like you're adding an argument to the read op.  Wouldn't that be an
> incompatible change?  In which case wouldn't it be better to propose this
> for inclusion in NFS 4.2?  In fact didn't Dean propose this?  What ever
> happened with that?

Yes, posix_fadvise support is part of NFSv4.2.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
