Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:38431 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751682AbdGZM5L (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jul 2017 08:57:11 -0400
Subject: Re: [REGRESSION 4.13-rc] NFS returns -EACCESS at the first read
To: Takashi Iwai <tiwai@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
References: <s5h4ltzl5oq.wl-tiwai@suse.de>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <acfb6b19-b183-16ef-a6c5-2fc97cf8eb6b@gmail.com>
Date: Wed, 26 Jul 2017 08:57:07 -0400
MIME-Version: 1.0
In-Reply-To: <s5h4ltzl5oq.wl-tiwai@suse.de>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Takashi,

On 07/26/2017 08:54 AM, Takashi Iwai wrote:
> Hi,
> 
> I seem hitting a regression of NFS client on the today's Linus git
> tree.  The symptom is that the file read over NFS returns occasionally
> -EACCESS at the first read.  When I try to read the same file again
> (or do some other thing), I can read it successfully.
> 
> The git bisection leaded to the commit
> bd8b2441742b49c76bec707757bd9c028ea9838e
>     NFS: Store the raw NFS access mask in the inode's access cache
> 
> 
> Any further hint for debugging?

Does the patch in this email thread help? http://www.spinics.net/lists/linux-nfs/msg64930.html

Thanks,
Anna
> 
> 
> thanks,
> 
> Takashi
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
