Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:39083 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754005Ab1LWBfF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Dec 2011 20:35:05 -0500
Received: by ggdk6 with SMTP id k6so6615688ggd.19
        for <linux-nfs@vger.kernel.org>; Thu, 22 Dec 2011 17:35:03 -0800 (PST)
Message-ID: <4EF3DAC2.5040806@opensuse.org>
Date: Thu, 22 Dec 2011 22:34:58 -0300
From: =?UTF-8?B?Q3Jpc3RpYW4gUm9kcsOtZ3Vleg==?= <crrodriguez@opensuse.org>
MIME-Version: 1.0
To: Tom Gundersen <teg@jklm.no>
CC: linux-nfs@vger.kernel.org, Steve Dickson <steved@redhat.com>,
        systemd-devel@lists.freedesktop.org
Subject: Re: [PATCH] rpcbind: add support for systemd socket activation
References: <4EEFCBF0.1070407@opensuse.org> <1324602327-1789-1-git-send-email-teg@jklm.no>
In-Reply-To: <1324602327-1789-1-git-send-email-teg@jklm.no>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 22/12/11 22:05, Tom Gundersen wrote:
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
>   * It uses the shared library.
>   * It comes with unit files.
>   * It is rebased on top of master.
>
> Please review the patch with "git show -b" or otherwise ignoring the
> whitespace changes, or it will be extremely difficult to read.
>
> Comments welcome.
>
> v2: correctly enable systemd code at compile time
>      handle the case where not all the required sockets were supplied
>      listen on udp/tcp port 111 in addition to /var/run/rpcbind.sock
>      do not daemonize
>
> Original-patch-by: Lennart Poettering<lennart@poettering.net>
> Cc: Steve Dickson<steved@redhat.com>
> Cc: systemd-devel@lists.freedesktop.org
> Cc: Cristian Rodríguez<crrodriguez@opensuse.org>
> Signed-off-by: Tom Gundersen<teg@jklm.no>
> ---
>
> Thanks to Cristian for testing. The testcase I had been using was entirely flawed,
> the code did in fact not work at all. Sorry about that!

ACKed: Cristian Rodríguez<crrodriguez@opensuse.org>

This version works as expected here.


