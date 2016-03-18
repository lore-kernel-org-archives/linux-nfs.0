Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33318 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbcCRDqs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2016 23:46:48 -0400
Received: by mail-oi0-f45.google.com with SMTP id d205so78801737oia.0
        for <linux-nfs@vger.kernel.org>; Thu, 17 Mar 2016 20:46:48 -0700 (PDT)
MIME-Version: 1.0
From: Nelson Elhage <nelhage@nelhage.com>
Date: Thu, 17 Mar 2016 20:46:28 -0700
Message-ID: <CAPSG9dbOPRv_gM_w_Ys9fJ-fSPRnw+Rgb3yaaHVEqZ9YyDntzg@mail.gmail.com>
Subject: NFSv3 may inappropriately return EPERM for fsetxattr
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@lst.de>, Bruce Fields <bfields@fieldses.org>,
        James Brown <jbrown@easypost.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[resending without a text/html subpart]

This is https://bugzilla.kernel.org/show_bug.cgi?id=114751

Since some time around kernel 3.16, NFSv3 mounts can return EPERM for
POSIX extended ACL calls if the current user does not match the owner,
instead of EOPNOTSUPP.

James Brown, CC'd, has confirmed the bug is still present in mainline 4.4.

Using ftrace, I've observed[0] that the call fails inside the VFS
layer before even hitting the NFS code, which makes me suspect
013cdf1088d7235da9477a2375654921d9b9ba9f (“nfs: use generic posix ACL
infrastructure for v3 Posix ACLs”). Unfortunately I haven't had a
chance to confirm that theory by building the before/after revisions.

CC'ing Christoph, who authored that series.

- Nelson

[0] http://nelhagedebugsshit.tumblr.com/post/116688651723/broken-posix-acls-on-nfs-on-kernel-316
