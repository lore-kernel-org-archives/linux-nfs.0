Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f42.google.com ([74.125.82.42]:34870 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776Ab2FXEVB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jun 2012 00:21:01 -0400
MIME-Version: 1.0
In-Reply-To: <20120623115106.GA2742@umich.edu>
References: <1340448446-10198-1-git-send-email-linkinjeon@gmail.com>
	<20120623115106.GA2742@umich.edu>
Date: Sun, 24 Jun 2012 13:20:59 +0900
Message-ID: <CAKYAXd9JodvjUbnJ5zrmCkXgvwssK0p1jy=E8NxkJVzMHWfgsg@mail.gmail.com>
Subject: Re: [RFC PATCH] nfs: Support posix_fadvise(POSIX_FADV_RANDOM) on nfs server.
From: Namjae Jeon <linkinjeon@gmail.com>
To: Jim Rees <rees@umich.edu>
Cc: bfields@fieldses.org, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, bharrosh@panasas.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Namjae Jeon <namjae.jeon@samsung.com>,
        Vivek Trivedi <t.vivek@samsung.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/6/23, Jim Rees <rees@umich.edu>:
> Namjae Jeon wrote:
>
>   From: Namjae Jeon <namjae.jeon@samsung.com>
>
>   This patch disable readahead for a file on NFS Server when
>   posix_fadvise(fd..., POSIX_FADV_RANDOM) is called on NFS
>   Client.
>
> It looks like you're adding an argument to the read op.  Wouldn't that be
> an
> incompatible change?  In which case wouldn't it be better to propose this
> for inclusion in NFS 4.2?  In fact didn't Dean propose this?  What ever
> happened with that?
Dean ? I don't know specific history. Would you give me the
information about Dean's proposal ?
>
