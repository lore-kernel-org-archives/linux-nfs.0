Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:55415 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947077Ab2LFTod (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Dec 2012 14:44:33 -0500
Date: Thu, 6 Dec 2012 19:49:49 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, wine-devel@winehq.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
Message-ID: <20121206194949.7ab20d56@pyramind.ukuu.org.uk>
In-Reply-To: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu,  6 Dec 2012 22:26:28 +0400
Pavel Shilovsky <piastry@etersoft.ru> wrote:

> Network filesystems CIFS, SMB2.0, SMB3.0 and NFSv4 have such flags - this change can benefit cifs and nfs modules. While this change is ok for network filesystems, itsn't not targeted for local filesystems due security problems (e.g. when a user process can deny root to delete a file).

If I have my root fs on NFS then the same applies does it not.

Your patches fail to describe the security semantics and what file rights
I must have to apply each option. How do I track down a lock user, what
tools are provided ? How do the new options interact with the security
layer?

I don't have a problem with the idea, but it needs a lot more clear
description of how it works so the model can be checked and if need be
things tweaked (eg needing write to denywrite etc)

Alan
