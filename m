Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:61100 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757752Ab2HHVZ3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 17:25:29 -0400
Received: by obbuo13 with SMTP id uo13so1681397obb.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 14:25:28 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 9 Aug 2012 02:55:28 +0530
Message-ID: <CAOn_VZbzhGMtYmOZJe-kGqhFLRsWpw6B3+uv+d4UAx9t1-Ew=A@mail.gmail.com>
Subject: reconnect_path fails with EACCES
From: Rajesh Ghanekar <rajeshsg@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
I am facing problem with reconnect_path failing with EACCES when doing
lookup_one_len. I have 2 users goind to same directory, one with uid=0
and another with uid=xxx. Sometime for uid=0 request, nfsd is still is using
uid=xxx (as it was used previously), as uid=xxx doesn't have any permissions
on the directory.

Should this probably do nfsd_setuser_and_check_port before
the below code in nfsd_set_fh_dentry()? As it carries older
fsuid and fsgid, can it create issues. This always happens
with disconnected dentries.

        if (exp->ex_flags & NFSEXP_NOSUBTREECHECK) {
                /* Elevate privileges so that the lack of 'r' or 'x'
                 * permission on some parent directory will
                 * not stop exportfs_decode_fh from being able
                 * to reconnect a directory into the dentry cache.
                 * The same problem can affect "SUBTREECHECK" exports,
                 * but as nfsd_acceptable depends on correct
                 * access control settings being in effect, we cannot
                 * fix that case easily.

Thanks,
Rajesh
