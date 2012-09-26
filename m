Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:55191 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903Ab2IZWUI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Sep 2012 18:20:08 -0400
Received: by padhz1 with SMTP id hz1so794495pad.19
        for <linux-nfs@vger.kernel.org>; Wed, 26 Sep 2012 15:20:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1348687553-8461-1-git-send-email-bjschuma@netapp.com>
References: <1348687553-8461-1-git-send-email-bjschuma@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 27 Sep 2012 00:19:47 +0200
Message-ID: <CAJ75kXZHD9nkL_bEzqd-L=5OVmxQjEwgPT_2Oj2pfCjfMdK_5w@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] NFS: Remove bad delegations during open recovery
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 26, 2012 at 9:25 PM,  <bjschuma@netapp.com> wrote:
> This causes a loop because the client never updates the nfs4_state after
> discovering that the delegation is invalid.  This means it will keep
> trying to read using the bad delegation rather than attempting to re-open
> the file.

Oh, I already encountered this bug but never found the time to debug
it / report it.

Thanks a lot! I'll try to test it soon.

-- 
William
