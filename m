Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f53.google.com ([209.85.220.53]:38734 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbaAYEX2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 23:23:28 -0500
Received: by mail-pa0-f53.google.com with SMTP id lj1so3977292pab.40
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 20:23:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140124192830.GA16164@fieldses.org>
References: <20140124063202.GA23937@ulegcprs1.emea.nsn-net.net>
	<20140124192830.GA16164@fieldses.org>
Date: Sat, 25 Jan 2014 05:23:28 +0100
Message-ID: <CAObFj3z9o7QzSk0AOfUZWk1+xv4k6mB9OHtuMC5JjUqvudXL2w@mail.gmail.com>
Subject: Re: [PATCH] use NFS4_MAXMINOR instead of hard coded number
From: Robert Schiele <rschiele@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 24, 2014 at 8:28 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> While we're at it, is there any harm to letting NFS4_MAXMINOR be much
> higher?  That would save the need to rebuild nfs-utils just because you
> want to test a kernel with new minor version support.

That does not work. This constant is used to generate the string to be
thrown into the kernel and the kernel complains about items in the
string it does not know about, even if they are disabled, like "-4.7".
It would work if at the same time you got a patch into the kernel that
it no longer complains about unknown items that are disabled.

Robert
