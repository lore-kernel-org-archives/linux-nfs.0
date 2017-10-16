Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46272 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756752AbdJPSyE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Oct 2017 14:54:04 -0400
Date: Mon, 16 Oct 2017 14:54:03 -0400
To: Sverd Johnsen <sverd.johnsen@googlemail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: rpc.gssd vs 32bit userland on aarch64
Message-ID: <20171016185403.GE12608@fieldses.org>
References: <CAGmahrTrXKdc2tDN4eByn+-WBrp1cz4aU6QWE5k2rNZSi3PKmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAGmahrTrXKdc2tDN4eByn+-WBrp1cz4aU6QWE5k2rNZSi3PKmw@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 15, 2017 at 09:06:51PM +0200, Sverd Johnsen wrote:
> I noticed that it calls syscall directly in gssd_proc.c. This fails
> here as setgroups, setresuid and setresgid don't seem to work.

Huh.  I wonder what we're doing that's wrong for the aarch64/32-bit
userland case.

Any more details?  How exactly does the call fail?

--b.
