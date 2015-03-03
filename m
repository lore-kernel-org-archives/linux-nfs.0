Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.piware.de ([37.120.164.117]:44970 "EHLO mail.piware.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441AbbCCUMS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 15:12:18 -0500
Date: Tue, 3 Mar 2015 21:12:14 +0100
From: Martin Pitt <martin.pitt@ubuntu.com>
To: linux-nfs@vger.kernel.org
Cc: systemd-devel@lists.freedesktop.org
Subject: Re: [systemd-devel] [PATCH 2/2] systemd: Relax dependencies of
 services
Message-ID: <20150303201214.GA3473@piware.de>
References: <1425403690-23847-1-git-send-email-martin.pitt@ubuntu.com>
 <1425403690-23847-3-git-send-email-martin.pitt@ubuntu.com>
 <20150303180809.GJ3058@in.waw.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20150303180809.GJ3058@in.waw.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,

Zbigniew Jędrzejewski-Szmek [2015-03-03 19:08 +0100]:
> Are you sure that all of those nfs daemons do not require
> sockets.target and other stuff provided by basic.target to be ready?

The corresponding upstart jobs trigger on virtual file systems (/sys,
etc.) and rpcbind, and we've used them for years. Also, NFS does not
yet use socket activation, or talks to other services on sockets
(except for rpcbind), so we don't need sockets.target either.  The
other dependencies (some network.target, some nss-lookup.target, etc.)
are already specified explicitly. So I'm quite sure.

That said, there's of course always a nonzero chance that this breaks
in a case which I haven't tested. In particular, I didn't test
kerberos/gssd, I'd appreciate if someone who has a real-world setup
with that could give this a spin.

Thanks,

Martin
-- 
Martin Pitt                        | http://www.piware.de
Ubuntu Developer (www.ubuntu.com)  | Debian Developer  (www.debian.org)
