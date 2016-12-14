Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37544 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755002AbcLNTfW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Dec 2016 14:35:22 -0500
Date: Wed, 14 Dec 2016 14:28:16 -0500
To: Daniel Pocock <daniel@pocock.pro>
Cc: linux-nfs@vger.kernel.org
Subject: Re: improving NFS stability in next Debian release
Message-ID: <20161214192816.GB2212@fieldses.org>
References: <4415ff5c-98c3-629d-aefd-a5e677688bbb@pocock.pro>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4415ff5c-98c3-629d-aefd-a5e677688bbb@pocock.pro>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 11, 2016 at 08:01:12PM +0100, Daniel Pocock wrote:
> NFS was quite stable with previous Debian versions but in Jessie, the
> current stable release, it has been prone to crashes under load (kernel
> 3.16, bug report[1]).  A user also asked[2] about this on the
> linux-fsdevel list a few months ago.
> 
> With the next Debian release freeze approaching, what will it take to
> ensure a stable experience for NFS users?
> 
> Are there any known problems for NFS in the current Debian kernel[3]?
> 
> Which version of nfs-utils should be distributed?  The current package
> is quite old[4].
> 
> Debian jessie-backports contains a 4.7.9 kernel, should that be
> compatible with the nfs-utils package v1.2.8 and other related things in
> jessie?

We're pretty conservative about changes to the nfs-utils<->kernel
interfaces.  I wouldn't expect incompatibilites between versions only a
few years out of sync.

As for questions about known problems and stability of particular kernel
versions, sorry, I really don't have a simple answer.  I think it's
mainly a matter of investigating individual bug reports and keeping an
eye on upstream patches, especially anything marked for stable.

--b.

> 
> Regards,
> 
> Daniel
> 
> 
> 1. http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=847549
> 2. http://www.spinics.net/lists/linux-fsdevel/msg98540.html
> 3. https://packages.qa.debian.org/l/linux.html
> 4. https://packages.qa.debian.org/n/nfs-utils.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
