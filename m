Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:50218 "EHLO
        elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752913AbdHOAf7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Aug 2017 20:35:59 -0400
Received: from [67.170.185.135] (helo=FranksLaptop)
        by elasmtp-dupuy.atl.sa.earthlink.net with esmtpa (Exim 4)
        (envelope-from <ffilzlnx@mindspring.com>)
        id 1dhPD7-000C7r-R9
        for linux-nfs@vger.kernel.org; Mon, 14 Aug 2017 19:55:53 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: <linux-nfs@vger.kernel.org>
Subject: Pull request for pynfs
Date: Mon, 14 Aug 2017 16:55:48 -0700
Message-ID: <047901d31558$dadb5930$90920b90$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

Please pull from https://github.com/ffilz/pynfs/commits/master

This patch fixes CSESS29 to issue the invalid CREATE_SESSION inside a valid
session so that the SEQUENCE op will renew the lease on the clientid. This
test may take sufficient time on some servers to have the unconfirmed
clientid expire, requiring setting a long lease period for testing that
impacts the overall run time.

Thanks

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

