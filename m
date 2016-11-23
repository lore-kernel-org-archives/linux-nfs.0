Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57612 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933483AbcKWUlw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Nov 2016 15:41:52 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>
Subject: NFSv4.2 mode_umask support
Date: Wed, 23 Nov 2016 15:41:38 -0500
Message-Id: <1479933700-5743-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Resending--can we get any opinions on these?

The following patches allow the umask to be ignored in the presence of
inheritable NFSv4 ACLs.  Otherwise inheritable ACLs can be rendered
mostly useless whenever the umask masks out group bits.

This solves a problem we've seen complaints about for some time, both
upstream and from RHEL users.

The new protocol has been discussed in the IETF working group and is
documented at:

        https://tools.ietf.org/html/draft-ietf-nfsv4-umask-02

It's unlikely that we'll discover problems requiring an incompatible
change, so I think we should consider this for 4.10.

--b.

