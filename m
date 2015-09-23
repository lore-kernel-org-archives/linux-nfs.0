Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35307 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbbIWMpz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2015 08:45:55 -0400
Received: by pacfv12 with SMTP id fv12so40554932pac.2
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2015 05:45:54 -0700 (PDT)
Subject: Re: [PATCH v2] NFS41: make close wait for layoutreturn
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <1442892922-10834-1-git-send-email-tao.peng@primarydata.com>
 <56025A7D.2060207@gmail.com> <56025AE6.6020808@gmail.com>
 <56026273.8040707@gmail.com>
 <CAHQdGtRHNs0MOP2mx6jiA5dFXfzM2UZHwuGkTyoNpit-vpGzsQ@mail.gmail.com>
Cc: Peng Tao <tao.peng@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <56029EF5.1000507@gmail.com>
Date: Wed, 23 Sep 2015 20:45:41 +0800
MIME-Version: 1.0
In-Reply-To: <CAHQdGtRHNs0MOP2mx6jiA5dFXfzM2UZHwuGkTyoNpit-vpGzsQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/23/2015 20:05, Trond Myklebust wrote:
> On Wed, Sep 23, 2015 at 4:27 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
>> I find the inode returned from nfs_igrab_and_active is NULL
>> in _nfs4_proc_delegreturn(),
>>
>>         data->inode = nfs_igrab_and_active(inode);
>>
>> So that, NFS_I(inode) causes the panic.
> 
> I've added a check for ino == NULL to nfs4_wait_on_layoutreturn()...

Yes, that's right.

But you add the checking at the wrong place in pnfs_wait_on_layoutreturn() at your tree.


+bool pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task)
+{
+        struct pnfs_layout_hdr *lo;
+        bool sleep = false;
+
+	if (ino == NULL)
+		goto out;
+	/* we might not have grabbed lo reference. so need to check under

thanks, 
Kinglong Mee
