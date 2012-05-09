Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:57944 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756492Ab2EINMF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 May 2012 09:12:05 -0400
Received: by yenm10 with SMTP id m10so227348yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 May 2012 06:12:04 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 9 May 2012 09:12:04 -0400
Message-ID: <CAKnQG+ejcCWbBfPy8hjWsrR2eX6-2zvCCf-v9OUTvUnDV7F8Gg@mail.gmail.com>
Subject: libgssglue-0.4 now available
From: Kevin Coffman <kwc@citi.umich.edu>
To: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A new version of library libgssglue is now available from:

http://www.citi.umich.edu/projects/nfsv4/linux/libgssglue/libgssglue-0.4.tar.gz

Changes since libgssglue-0.3:

    - Fix for CVE-2011-2709
      Patch from Marcus Meissner
      Note: Although https://bugzilla.novell.com/show_bug.cgi?id=694598
      mentions mount.nfs, libgssglue is not used by mount.nfs.
