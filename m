Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50563 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757749Ab1BKUch (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Feb 2011 15:32:37 -0500
Received: by bwz15 with SMTP id 15so3596334bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 Feb 2011 12:32:36 -0800 (PST)
In-Reply-To: <76B48A68-FCC3-4E52-9FF3-43C6C68CD0AA@netapp.com>
References: <1297443279-19813-1-git-send-email-iisaman@netapp.com>
	<76B48A68-FCC3-4E52-9FF3-43C6C68CD0AA@netapp.com>
Date: Fri, 11 Feb 2011 15:32:35 -0500
Message-ID: <AANLkTinMyMmFz5BH+sWxuX+T8aCr2n7tdTHjw-w4VwtZ@mail.gmail.com>
Subject: Re: [PATCH 0/7] pnfs wave 4 proposal
From: Fred Isaman <iisaman@netapp.com>
To: Andy Adamson <andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Feb 11, 2011 at 3:19 PM, Andy Adamson <andros@netapp.com> wrote:
> I don't see pnfs_initiate_write
>
> -->Andy
>

It is inlined at the end of nfs_rpc_setup, added in patch 5/7.

Fred
