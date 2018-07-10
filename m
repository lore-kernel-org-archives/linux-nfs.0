Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.jpl.nasa.gov ([128.149.139.106]:36806 "EHLO
        mail.jpl.nasa.gov" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932620AbeGJCfH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jul 2018 22:35:07 -0400
Received: from [128.149.87.53] (ps-128-149-87-53.jpl.nasa.gov [128.149.87.53])
        (authenticated (0 bits))
        by smtp.jpl.nasa.gov (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id w6A2SrQA027722
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128 bits) verified NO)
        for <linux-nfs@vger.kernel.org>; Mon, 9 Jul 2018 19:28:54 -0700
To: linux-nfs@vger.kernel.org
From: Peter Scott <pjscott@jpl.nasa.gov>
Subject: NFSv4 file lock reporting interface request
Message-ID: <8dd8a352-aaca-71af-aca7-9be6c7039ff4@jpl.nasa.gov>
Date: Mon, 9 Jul 2018 19:28:53 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.  I am with the institutional hosting service at NASA's Jet 
Propulsion Laboratory and we have been trying to find the answer to an 
apparently simple question.

We are running an NFSv4 server on Centos 7 and we need to get the server 
to tell us which files it thinks are locked by which clients.  This is 
because we have observed failure modes where something apparently has a 
lock (because attempting to lock the file again blocks) but we can't 
find a client that has the lock. Finding out what the server believes 
would be critical to troubleshooting this.

We tracked down Trond Myklebust and Neil Brown and conversation suggests 
that this is a function that is (a) not currently available and (b) 
reasonable to ask for.  So this is me suggesting that an interface be 
provided to have knfsd output its list of locked files and clients.

Regards,
Peter Scott
Office of the CIO
