Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:46798 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbbCIWgS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2015 18:36:18 -0400
Received: by iecrd18 with SMTP id rd18so16892145iec.13
        for <linux-nfs@vger.kernel.org>; Mon, 09 Mar 2015 15:36:17 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 9 Mar 2015 17:36:17 -0500
Message-ID: <CABrM6wnked-ZShCTC2cT-UNA+wrLPA5hmCJNhbXi-hirbE5RMw@mail.gmail.com>
Subject: NFS hang after concurrent writes
From: Peng Yu <pengyu.ut@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have a home directory from an ubuntu server shared to multiple other
ubuntu servers as the home directory (the default login shell is bash
on these servers) via NFS (see the following configuration in
/etc/exports from the NFS server).

/mnt/home 172.17.0.0/16(fsid=2,rw,insecure,no_subtree_check,sync,no_root_squash)

autofs is used to mount the NFS on the client servers (see the
following configuration).

~$ cat /etc/auto.master
+auto.master
/home   /etc/auto.home --timeout=90
~$ cat /etc/auto.home
*  -fstype=nfs4,rw,intr,fsc    nsfserver:/mnt/home/&

But I frequently end up with a situation when ~/.bash_history is not
readable which blocks the logins to these client servers. I feel that
this may be related with concurrent write to ~/.bash_history from
these servers, which somehow screw up NFS.

Has anybody seen this before? If so, is there a solution to this
problem? Thanks.

-- 
Regards,
Peng
