Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:36089 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbbEFKMO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 06:12:14 -0400
Received: by obbkp3 with SMTP id kp3so3307404obb.3
        for <linux-nfs@vger.kernel.org>; Wed, 06 May 2015 03:12:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150506065651.GA22454@lst.de>
References: <1430895024-1403-1-git-send-email-andreas.gruenbacher@gmail.com>
	<20150506065651.GA22454@lst.de>
Date: Wed, 6 May 2015 12:12:13 +0200
Message-ID: <CAHpGcMJe1YyCev2mza=pOCvs1pcV6M2AnX-0hVa4gdppnXassA@mail.gmail.com>
Subject: Re: [PATCH] nfsd: Disable NFSv2 timestamp workaround for NFSv3+
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-06 8:56 GMT+02:00 Christoph Hellwig <hch@lst.de>:
> How about moving the workaround into the NFSv2 specific code?

Not trivially, we would have to fh_verify() the file handle in
nfsd_proc_setattr() first. Is that preferable?

> Looks like the call from nfsd_create() should never be used for this
> workaround,

Right, the workaround won't trigger there because setting the times
arbitrarily will already succeed because we are the owner
(nfsd_sanitize_attrs tries that first with inode_change_ok).

Thanks,
Andreas
