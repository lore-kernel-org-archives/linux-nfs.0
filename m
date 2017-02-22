Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34158 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753558AbdBVIB2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Feb 2017 03:01:28 -0500
Received: by mail-it0-f66.google.com with SMTP id r141so607118ita.1
        for <linux-nfs@vger.kernel.org>; Wed, 22 Feb 2017 00:01:22 -0800 (PST)
Subject: Re: some problems about permission of subdirectory
To: houlinfei <hou.linfei@h3c.com>
References: <24b92a5f.6561.15a64adfe18.Coremail.hou.linfei@h3c.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        bfields@fieldses.org, neilb@suse.com, SteveD@redhat.com,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <39acaddb-d4c0-dbda-3e22-11b865d4b9ec@gmail.com>
Date: Wed, 22 Feb 2017 16:00:36 +0800
MIME-Version: 1.0
In-Reply-To: <24b92a5f.6561.15a64adfe18.Coremail.hou.linfei@h3c.com>
Content-Type: text/plain; charset=gbk
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/22/2017 15:16, houlinfei wrote:
> hi Kinglong:
> Thank you for your answer about this phenomenon, i just try the method you provide, but problem also exist. If i want to change the code about nfsd and rpc.mountd, where should i change? I'm not familiar with this part of the code. 

Sorry, I test it with the following sets (with "no_root_squash"),
/root/hh/hh1    *(rw,no_subtree_check,no_root_squash,insecure)

It's okay for your problem, but all client's process will be treated as root.
But, it's just a hacker method with many limits,
I think you'd better change your exports as,

/root/hh/hh1  *(ro,sync,insecure,no_subtree_check)
/root/hh/hh2  *(rw,sync,insecure,no_subtree_check)

thanks,
Kinglong Mee
