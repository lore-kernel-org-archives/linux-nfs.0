Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33686 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbbJJRTe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Oct 2015 13:19:34 -0400
MIME-Version: 1.0
In-Reply-To: <20151010171317.GF22011@ZenIV.linux.org.uk>
References: <9459055931ab4f269b96bad953738778@HQMAIL102.nvidia.com>
	<1444412674-3077-1-git-send-email-trond.myklebust@primarydata.com>
	<CA+55aFzMMEB_zLoS+SznZCiW8k3ZgMO4BBFFJz7=Cj99FXiXmQ@mail.gmail.com>
	<20151010013657.GD22011@ZenIV.linux.org.uk>
	<20151010171317.GF22011@ZenIV.linux.org.uk>
Date: Sat, 10 Oct 2015 10:19:33 -0700
Message-ID: <CA+55aFz4SKKWPRWSj3UnELcdYnqLJBKxPwLsQG1oiGKh2kp-_Q@mail.gmail.com>
Subject: Re: [PATCH] namei: results of d_is_negative() should be checked after
 dentry revalidation
From: Linus Torvalds <torvalds@linux-foundation.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Leandro Awa <lawa@nvidia.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 10, 2015 at 10:13 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> OK, I've attemtped to add an explanation of what's going on; please, pull from
..

Heh. I just committed it myself with your emailed explanation, so ..

                  Linus
