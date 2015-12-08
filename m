Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:32804 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbbLHViY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2015 16:38:24 -0500
Received: by iouu10 with SMTP id u10so39510406iou.0
        for <linux-nfs@vger.kernel.org>; Tue, 08 Dec 2015 13:38:23 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.1 \(3096.5\))
Subject: Re: [PATCH RFC 0/4] Deal with lost delegations and EKEYEXPIRED
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <1449067193-53310-1-git-send-email-aweits@rit.edu>
Date: Tue, 8 Dec 2015 16:38:22 -0500
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <38076235-99FC-4CC7-8F16-3518A58CABA2@primarydata.com>
References: <1449067193-53310-1-git-send-email-aweits@rit.edu>
To: Andrew Elble <aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches look reasonable to me. I agree with Trond that you should
separate the client and server patches.

One part I’m not sure about is in nfsd4_spo_must_allow dealing with putfh like
ops vs not putfh-like ops. I’ll have to check the spec and take a deeper look at
that when I get some time, but maybe a brief explanation in a comment would
help?

To be honest, I've always been hazy on where in the spec the ramifications of
SP4_MACH_CRED only covering part of a compound is discussed… I’ll take a
look soon.

-dros



> On Dec 2, 2015, at 9:39 AM, Andrew Elble <aweits@rit.edu> wrote:
> 
> I've finally discovered that the majority of our lost delegation problems
> come from EKEYEXPIRED. This seems to work fine in our environment, but
> I am unsure of the ramifications of this in a broader context, so it's
> time to get other folks to look at it.
> 
> Andrew Elble (4):
>  nfs/nfsd: Move useful bitfield ops to a commonly accessible place
>  nfs: machine credential support for additional operations
>  nfsd: allow mach_creds_match to be used more broadly
>  nfsd: implement machine credential support for some operations
> 
> fs/nfs/nfs4proc.c         | 20 +++++++++++++++++
> fs/nfsd/export.c          |  4 ++++
> fs/nfsd/nfs4proc.c        | 55 +++++++++++++++++++++++++++++++++++++++++++++++
> fs/nfsd/nfs4state.c       | 35 ++++++++++++++++++++++++------
> fs/nfsd/nfs4xdr.c         | 51 ++++++++++++++++++++-----------------------
> fs/nfsd/nfsd.h            |  1 +
> fs/nfsd/state.h           |  1 +
> fs/nfsd/xdr4.h            |  5 +++++
> include/linux/nfs4.h      | 11 ++++++++++
> include/linux/nfs_fs_sb.h |  1 +
> include/linux/nfs_xdr.h   | 11 ----------
> 11 files changed, 149 insertions(+), 46 deletions(-)
> 
> -- 
> 2.6.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

