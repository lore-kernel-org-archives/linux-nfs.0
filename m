Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34356 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750842AbdCNI2r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Mar 2017 04:28:47 -0400
Received: by mail-it0-f68.google.com with SMTP id r141so8505013ita.1
        for <linux-nfs@vger.kernel.org>; Tue, 14 Mar 2017 01:28:46 -0700 (PDT)
Subject: Re: some problems about nfs mount
To: Houlinfei <hou.linfei@h3c.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <3858597F7658604DB90E3F60F716249C4696B42E@H3CMLB12-EX.srv.huawei-3com.com>
 <d8a1fbe6-0373-ea97-16d3-c9c4b5e49880@gmail.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "neilb@suse.com" <neilb@suse.com>,
        "SteveD@redhat.com" <SteveD@redhat.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <d15aa1b9-b0f6-d9d3-4853-d83f57dcfabb@gmail.com>
Date: Tue, 14 Mar 2017 16:28:24 +0800
MIME-Version: 1.0
In-Reply-To: <d8a1fbe6-0373-ea97-16d3-c9c4b5e49880@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3/14/2017 13:41, Kinglong Mee wrote:
> On 3/14/2017 11:52, Houlinfei wrote:
>> hi Kinglong:
>> There has no firewall. While my client system is Ubuntu 14.04, it's ok.
>> There has problem on ubuntu12.04 system. But if I add a parameter sec=sys, it is also ok. Such as, #mount -t nfs -o sec=sys 193.168.70.26:/root/hh /mnt/uu
>> But when my mount command line t is #mount -t nfs 193.168.70.26:/root/hh /mnt/uu   it fail.
>> There is some client fail log:
> 
> The ubuntu12.04 system contains an old kernel, the problem should be a bug in that kernel.
> I don't have an old kernel as ubuntu12.04 system, so I don't check the code.
> 
> Can you have a try with the following patch ?
> Your can get more information from the comments in the patch.
> 
> Commit 4580a92d4 ("NFS: Use server-recommended security flavor by default"),
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4580a92d4
> 

Sorry, please ignore the above comments.
I don't think it's useful, I will find an ubuntu12.04 and have a check.	

thanks,
Kinglong Mee
