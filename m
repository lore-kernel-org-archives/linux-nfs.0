Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:37404 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754593AbdCHVxC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Mar 2017 16:53:02 -0500
Received: by mail-it0-f47.google.com with SMTP id g138so53339826itb.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Mar 2017 13:53:01 -0800 (PST)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 8 Mar 2017 16:52:54 -0500
Message-ID: <CAN-5tyEe9txY5CmcZLOE4du=modRSaxKm8uLLT44YtKmSgAOgg@mail.gmail.com>
Subject: question about error case in pnfs
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

Currently there is an infinite loop in the pnfs code when it gets an
error on doing COMMIT after doing the IO. Looking at the code
filelayout_commit_done_cb() it will translate that into
ERR_RESET_TO_MDS and retry. In my test case, MDS and DS are the same.
It resends, sends COMMIT and gets EACCES and in the infinite loop it
goes.  At the connectathon, going against Tigran's server, the retries
didn't go to MDS and went to the same DS (let's set the issue of going
to the wrong server aside).

In a non-pnfs case, when COMMIT gets EACCES it fails and doesn't retry
any writing and application gets "Permission denied".

Question: why is pnfs retrying to MDS?

Is the solution to the looping problem:
1. not retry as in non-pnfs case.
2. detect that DS=MDS and then not retry?

Thanks.
