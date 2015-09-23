Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:36632 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753922AbbIWMwa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2015 08:52:30 -0400
Received: by obbmp4 with SMTP id mp4so32009668obb.3
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2015 05:52:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <56029EF5.1000507@gmail.com>
References: <1442892922-10834-1-git-send-email-tao.peng@primarydata.com>
	<56025A7D.2060207@gmail.com>
	<56025AE6.6020808@gmail.com>
	<56026273.8040707@gmail.com>
	<CAHQdGtRHNs0MOP2mx6jiA5dFXfzM2UZHwuGkTyoNpit-vpGzsQ@mail.gmail.com>
	<56029EF5.1000507@gmail.com>
Date: Wed, 23 Sep 2015 08:52:29 -0400
Message-ID: <CAHQdGtReUEbzgTq_LsEUfJKDYxJfDmNmfqLURrzg_1moTt9oJw@mail.gmail.com>
Subject: Re: [PATCH v2] NFS41: make close wait for layoutreturn
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Peng Tao <tao.peng@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 23, 2015 at 8:45 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> On 9/23/2015 20:05, Trond Myklebust wrote:
>> On Wed, Sep 23, 2015 at 4:27 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
>>> I find the inode returned from nfs_igrab_and_active is NULL
>>> in _nfs4_proc_delegreturn(),
>>>
>>>         data->inode = nfs_igrab_and_active(inode);
>>>
>>> So that, NFS_I(inode) causes the panic.
>>
>> I've added a check for ino == NULL to nfs4_wait_on_layoutreturn()...
>
> Yes, that's right.
>
> But you add the checking at the wrong place in pnfs_wait_on_layoutreturn() at your tree.
>

Sigh...errno = ENOCOFFEE;

Thanks for reviewing! I'll revert and fix up again... :-/

Trond
