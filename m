Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35325 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbbJJATD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2015 20:19:03 -0400
MIME-Version: 1.0
In-Reply-To: <1444412674-3077-1-git-send-email-trond.myklebust@primarydata.com>
References: <9459055931ab4f269b96bad953738778@HQMAIL102.nvidia.com>
	<1444412674-3077-1-git-send-email-trond.myklebust@primarydata.com>
Date: Fri, 9 Oct 2015 17:19:02 -0700
Message-ID: <CA+55aFzMMEB_zLoS+SznZCiW8k3ZgMO4BBFFJz7=Cj99FXiXmQ@mail.gmail.com>
Subject: Re: [PATCH] namei: results of d_is_negative() should be checked after
 dentry revalidation
From: Linus Torvalds <torvalds@linux-foundation.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Leandro Awa <lawa@nvidia.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 9, 2015 at 10:44 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
>
> The issue is that revalidation may cause the dentry to be dropped in NFS
> if, say, the client notes that the directory timestamps have changed.

Ack.

We've had this bug before, where we returned something else than
-ENOCHLD while we were doing RCU lookups. See for example commit
97242f99a013 ("link_path_walk(): be careful when failing with
ENOTDIR").

So in general, we should always (a) either verify all sequence points
or (b) return -ENOCHLD to go into slow mode. The patch seems

However, this thing was explicitly made to be this way by commit
766c4cbfacd8 ("namei: d_is_negative() should be checked before ->d_seq
validation"), so while my gut feel is to consider this fix
ObviouslyCorrect(tm), I will delay it a bit in the hope to get an ACK
and comment from Al about the patch.

Al?

                  Linus
