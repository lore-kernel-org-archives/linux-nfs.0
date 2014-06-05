Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:52226 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbaFEMvU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 08:51:20 -0400
Received: by mail-ie0-f170.google.com with SMTP id to1so837339ieb.1
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 05:51:19 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH pynfs 05/17] move .x files to subdir 'xdrdef'
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20140605023150.GC12044@fieldses.org>
Date: Thu, 5 Jun 2014 08:51:18 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <74D88701-81C4-471F-A66D-15EB25BE8CFC@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com> <1401915726-29092-6-git-send-email-dros@primarydata.com> <20140605023150.GC12044@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Huh, I didn’t know there was such an option. I’ll repost.

-dros



On Jun 4, 2014, at 10:31 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Wed, Jun 04, 2014 at 05:01:53PM -0400, Weston Andros Adamson wrote:
>> nfs4.1/nfs4.x                               | 3290 ---------------------------
> ...
>> nfs4.1/xdrdef/nfs4.x                        | 3290 +++++++++++++++++++++++++++
> 
> git should be able to show that as a rename instead of a huge add/delete
> pair.  Maybe git-format-patch needs the -M option or something?
> 
> --b.

