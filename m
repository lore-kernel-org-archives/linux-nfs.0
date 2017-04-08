Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20464 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751735AbdDHSr4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Apr 2017 14:47:56 -0400
Date: Sat, 8 Apr 2017 21:47:06 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [bug report] NFS filelayout:call GETDEVICEINFO after
 pnfs_layout_process completes
Message-ID: <20170408184443.GB4420@mwanda>
References: <20170408182846.GA8017@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170408182846.GA8017@mwanda>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Oops.  Also the _write() function has a warning as well.

    fs/nfs/filelayout/filelayout.c:978 filelayout_pg_init_write()
    warn: 'pgio->pg_lseg' is an error pointer or valid


regards,
dan carpenter

