Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:35359 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965089AbcJGQnN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Oct 2016 12:43:13 -0400
Received: by mail-it0-f41.google.com with SMTP id o21so20643050itb.0
        for <linux-nfs@vger.kernel.org>; Fri, 07 Oct 2016 09:43:12 -0700 (PDT)
MIME-Version: 1.0
From: Matt Garman <matthew.garman@gmail.com>
Date: Fri, 7 Oct 2016 11:43:11 -0500
Message-ID: <CAJvUf-CSsxw0v5fncoM3fKxwdSp6Gv_WO3dszcz+Rjpopc77_g@mail.gmail.com>
Subject: Kerberized NFS client and slow user write performance
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We seem to be increasingly hit by this bug:

https://access.redhat.com/solutions/2040223
"On RHEL 6 NFS client usring kerberos (krb5), one user experiences
slow write performance, another does not"

You need a RH subscription to see that in its entirety.  But the
subject basically says it all: randomly, one or more users will be
subjected to *terrible* NFS write performance that persists until
reboot.

There is a root cause shown, but that is cryptic to non-kernel devs;
it doesn't explain from a user perspective what triggers this state.
(That's why it appears to be random to me.)

There is no solution or workaround given.  This appears to be on a
per-user + per-server basis, so a crude workaround is to migrate the
user to a different server.  And we do regular reboots, which somewhat
hides the problem.

Does this bug also exist in upstream (i.e. non distro specific Linux
NFS code)?  If so, is there any more detail on it, and/or a fix?

Thanks,
Matt
