Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:32965 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbbHMRUq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Aug 2015 13:20:46 -0400
Received: by obbhe7 with SMTP id he7so42215826obb.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2015 10:20:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1439480749-54600-1-git-send-email-trond.myklebust@primarydata.com>
References: <1439480749-54600-1-git-send-email-trond.myklebust@primarydata.com>
Date: Thu, 13 Aug 2015 13:20:45 -0400
Message-ID: <CAHQdGtRi4ULA2uuKYLAX1wNZFOtAqR_Bb5B-zUrMzi7fqoRkmQ@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.1/pNFS: Fix borken function _same_data_server_addrs_locked()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 13, 2015 at 11:45 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
>
> - Switch back to using list_for_each_entry(). To fix an incorrect test
>   for list NULL termination.
> - Do not assume that lists are sorted.
> - Finally, consider an existing entry to match if it consists of a subset
>   of the addresses in the new entry.
>
> Cc: stable@vger.kernel.org # 4.0+

Note that the bug predates Linux-4.0; it goes all the way back to
February 2012. This patch will not apply to older versions though,
since it used to live in fs/nfs/filelayout/filelayoutdev.c.

Cheers
  Trond
