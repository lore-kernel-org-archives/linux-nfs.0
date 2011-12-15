Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tango.0pointer.de ([85.214.72.216]:43632 "EHLO
	tango.0pointer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651Ab1LOPB5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2011 10:01:57 -0500
Date: Thu, 15 Dec 2011 15:54:32 +0100
From: Lennart Poettering <lennart@poettering.net>
To: Tom Gundersen <teg@jklm.no>
Cc: linux-nfs@vger.kernel.org, systemd-devel@lists.freedesktop.org
Subject: Re: [systemd-devel] [PATCH v2] rpcbind: add support for systemd
 socket activation
Message-ID: <20111215145432.GB16014@tango.0pointer.de>
References: <1323271100-3565-1-git-send-email-teg@jklm.no>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323271100-3565-1-git-send-email-teg@jklm.no>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 07.12.11 16:18, Tom Gundersen (teg@jklm.no) wrote:

> Making rpcbind sockect activated will greatly simplify
> its integration in systemd systems. In essence, other services
> may now assume that rpcbind is always available, even during very
> early boot. This means that we no longer need to worry about any
> ordering dependencies.
> 
> This is based on a patch originally posted by Lennart Poettering:
> <http://permalink.gmane.org/gmane.linux.nfs/33774>.
> 
> That patch was not merged due to the lack of a shared library and
> as systemd was seen to be too Fedora specific.
> 
> Systemd now provides a shared library, and it is shipped by defalt in
> OpenSUSE in addition to Fedora, and it is available in Debain, Gentoo,
> Arch, and others.
> 
> This version of the patch has three changes from the original:
> 
>  * It uses the shared library.
>  * It comes with unit files.
>  * It is rebased on top of master.
> 
> Please review the patch with "git show -b" or otherwise ignoring the
> whitespace changes, or it will be extremely difficult to read.

Looks good to me! Thanks for looking into this again!

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
