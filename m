Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35168 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727075AbeJPLoO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Oct 2018 07:44:14 -0400
From: Ronnie Sahlberg <lsahlber@redhat.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Cc: Steve French <smfrench@gmail.com>
Subject: [PATCH 0/1] Support ioctl for directories
Date: Tue, 16 Oct 2018 13:55:43 +1000
Message-Id: <20181016035544.31101-1-lsahlber@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve, all
This patch adds support for using the passthrough ioctl on directories.
To do so, we always create a compound for open/query/close.
Technically, in the case for files when we have a pSMBFile we could just
do the query on the existing handle but that would complicate the code.
If we need to avoid the extra open/close for the file case we could add 
those conditionals if we need to/they cause issues.
