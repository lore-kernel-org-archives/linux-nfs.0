Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50273 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415Ab1LSXmo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Dec 2011 18:42:44 -0500
Received: by yenm11 with SMTP id m11so3705948yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 19 Dec 2011 15:42:44 -0800 (PST)
Message-ID: <4EEFCBF0.1070407@opensuse.org>
Date: Mon, 19 Dec 2011 20:42:40 -0300
From: Cristian Rodriguez <crrodriguez@opensuse.org>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org, systemd-devel@lists.freedesktop.org
Subject: Re: [PATCH v2] rpcbind: add support for systemd socket activation
References: <1323271100-3565-1-git-send-email-teg@jklm.no>
In-Reply-To: <1323271100-3565-1-git-send-email-teg@jklm.no>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/12/11 12:18, Tom Gundersen wrote:
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


Thanks for your effort, however, this patch doesnt appear to work..

- There is a missing AC_DEFINE..



   if test "x$with_systemdsystemunitdir" != xno; then

.. (various tests)
 
 
 
 
 

AC_DEFINE([SYSTEMD], [1], [has systemd]) 
 
 

fi

Otherwise SYSTEMD is never defined in CPPFLAGS and the code is skipped.

Also, after fixing this particular nit, I am stuck in an assetion 
failure starting rpcbind

Dec 19 20:00:05 linux-lu80 rpcbind[2013]: rpcbind: svc.c:298: 
svc_register: Assertion `xprt != ((void *)0)' failed.
Dec 19 20:00:05 linux-lu80 systemd[1]: rpcbind.service: main process 
exited, code=killed, status=6
Dec 19 20:00:05 linux-lu80 systemd[1]: Unit rpcbind.service entered 
failed state.
Dec 19 20:00:05 linux-lu80 rpcbind[2015]: rpcbind: svc.c:298: 
svc_register: Assertion `xprt != ((void *)0)' failed.
Dec 19 20:00:05 linux-lu80 systemd[1]: rpcbind.service: main process 
exited, code=killed, status=6
Dec 19 20:00:05 linux-lu80 systemd[1]: Unit rpcbind.service entered 
failed state.
Dec 19 20:00:05 linux-lu80 rpcbind[2017]: rpcbind: svc.c:298: 
svc_register: Assertion `xprt != ((void *)0)' failed.
Dec 19 20:00:05 linux-lu80 systemd[1]: rpcbind.service: main process 
exited, code=killed, status=6
Dec 19 20:00:05 linux-lu80 systemd[1]: Unit rpcbind.service entered 
failed state.
Dec 19 20:00:05 linux-lu80 rpcbind[2019]: rpcbind: svc.c:298: 
svc_register: Assertion `xprt != ((void *)0)' failed.
Dec 19 20:00:05 linux-lu80 systemd[1]: rpcbind.service: main process 
exited, code=killed, status=6
Dec 19 20:00:05 linux-lu80 systemd[1]: Unit rpcbind.service entered 
failed state.
Dec 19 20:00:05 linux-lu80 rpcbind[2021]: rpcbind: svc.c:298: 
svc_register: Assertion `xprt != ((void *)0)' failed.
Dec 19 20:00:05 linux-lu80 systemd[1]: rpcbind.service: main process 
exited, code=killed, status=6
Dec 19 20:00:05 linux-lu80 systemd[1]: Unit rpcbind.service entered 
failed state.
Dec 19 20:00:05 linux-lu80 rpcbind[2023]: rpcbind: svc.c:298: 
svc_register: Assertion `xprt != ((void *)0)' failed.
Dec 19 20:00:05 linux-lu80 systemd[1]: rpcbind.service: main process 
exited, code=killed, status=6
Dec 19 20:00:05 linux-lu80 systemd[1]: Unit rpcbind.service entered 
failed state.
Dec 19 20:00:05 linux-lu80 systemd[1]: rpcbind.service start request 
repeated too quickly, refusing to start.

