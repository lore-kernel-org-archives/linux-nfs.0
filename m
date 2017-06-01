Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3.molgen.mpg.de ([141.14.17.11]:53866 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750952AbdFAMwj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Jun 2017 08:52:39 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, it+linux-nfs@molgen.mpg.de
From: Paul Menzel <pmenzel@molgen.mpg.de>
Subject: Add two commits two 4.4 stable kernel series
Message-ID: <708fe54a-01bd-485e-f8c2-39533714e09b@molgen.mpg.de>
Date: Thu, 1 Jun 2017 14:52:38 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Trond, dear Anna,


Should commit 5c5fc09 (NFS: Ensure we revalidate attributes before using 
execute_ok()) and commit 762674f8 (NFSv4: Don't perform cached access 
checks before we've OPENed the file) be added to the Linux 4.4 series? 
Was it just overlooked as there is no stable tag?


Kind regards,

Paul
