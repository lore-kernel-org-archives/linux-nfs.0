Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37102 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab1EAJdd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 May 2011 05:33:33 -0400
Received: by iyb14 with SMTP id 14so4006732iyb.19
        for <linux-nfs@vger.kernel.org>; Sun, 01 May 2011 02:33:32 -0700 (PDT)
Date: Sun, 1 May 2011 11:33:32 +0200
Message-ID: <BANLkTi=X0VtcSecmEwzPBTqk3L154aj+2Q@mail.gmail.com>
Subject: How does NFS handle notify?
From: Stef Bon <stefbon@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I'm working on a FUSE filesystem, which is part of a construction like
GoboLinux. It offers the user, when her/his session begins an
environment like:

/Computer
/Home
/Internet Services
/Mounts
/Network
/Shared
/System

The normal directories like /bin, /etc, /usr etcetera are present but
hidden ( by the FUSE fs).

See:

http://linux.bononline.nl/wiki/index.php/Mount.md5key

(especially the changes and the screenshots..)

To make this environment more consistent and usefull, it has to
support (i)notify.
Earlier I've posted a message about that on the linux fsdevel mailist:

http://marc.info/?l=linux-fsdevel&m=130052497829681&w=2

Mentioned there - and I agree - that when developing support for
notify on mounted filesystems you need to have one base (in VFS), and
a part which is handled by the (mounted) fs self.

So here my question, how does NFS handle notify?? I'm not that
familiar with NFS, so maybe I'm asking something really stupid here...

Thanks in advance,

Stef
