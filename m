Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40477 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823Ab1B0WJE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Feb 2011 17:09:04 -0500
Received: by bwz15 with SMTP id 15so3252820bwz.19
        for <linux-nfs@vger.kernel.org>; Sun, 27 Feb 2011 14:09:03 -0800 (PST)
In-Reply-To: <4D6A67F3.3060308@panasas.com>
References: <4D686893.7010106@panasas.com>
	<4D6A67F3.3060308@panasas.com>
Date: Sun, 27 Feb 2011 14:09:02 -0800
Message-ID: <AANLkTimZS=54ZkwXwK9tMUUBn_JDXD5=+ohBpnKemtbQ@mail.gmail.com>
Subject: Re: [PATCH] SQUASHME: pnfs: FIX stupid recall_layout BUG
From: Fred Isaman <iisaman@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Feb 27, 2011 at 7:04 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>
> OK, who wrote this code? He did not stop to think for even a
> second. And surely it was never tested, since it is 100%
> repeatable. Smack yourself on the head!
>

I wrote the code.  But note that the tree you are using is taking the
tested, reasonably mature code that is currently in the downstream
kernel and reverting it back to ancient buggy prototype code.  My
understanding was that Benny was rightly ripping out the reversions at
bakeathon.

Fred
