Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from www.llwyncelyn.cymru ([82.70.14.225]:58116 "EHLO fuzix.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750857AbdKKCrV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Nov 2017 21:47:21 -0500
Date: Sat, 11 Nov 2017 02:47:10 +0000
From: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
To: Patrick McLean <chutzpah@gentoo.org>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        stable@vger.kernel.org, regressions@leemhuis.info,
        torvalds@linux-foundation.org
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
Message-ID: <20171111024710.172301eb@alans-desktop>
In-Reply-To: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 8 Nov 2017 16:43:17 -0800
Patrick McLean <chutzpah@gentoo.org> wrote:

> As of 4.13.11 (and also with 4.14-rc) we have an issue where when
> serving nfs4 sometimes we get the following BUG. When this bug happens,
> it usually also causes the motherboard to no longer POST until we
> externally re-flash the BIOS (using the BMC web interface). If a
> motherboard does not have an external way to flash the BIOS, this would
> brick the hardware.

If that is a production x86 system then you need to raise a large red
flag with the vendor because it should not even be possible to splat the
BIOS firmware on a modern PC by running even malicious OS code.

Not only that but if it has a flaw, and you bisect down to create a
reproducer then it's not going to take the bad guys very long to turn it
into an interesting toy to run if they ever exploit a box with that board.

Alan
