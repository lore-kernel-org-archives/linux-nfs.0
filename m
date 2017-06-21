Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3.molgen.mpg.de ([141.14.17.11]:48675 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750859AbdFULqc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Jun 2017 07:46:32 -0400
From: Paul Menzel <pmenzel@molgen.mpg.de>
Subject: How to debug permission denied issues?
To: linux-nfs@vger.kernel.org
Cc: it+linux-nfs@molgen.mpg.de
Message-ID: <03f0da7e-99c1-a015-c701-b8c8f4a6ec85@molgen.mpg.de>
Date: Wed, 21 Jun 2017 13:46:30 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear NFS folks,


We experience the following behavior with the Linux series 4.4 and 4.9.

When the exported directory on the server gets full to 100 % some NFS 
clients are unable to access the server anymore, but others can.

The error is, that the server says the client ID has expired. The 
server, on which the client runs on, needs to be restarted. Then it 
works again.

Can you think of an error path causing such a failure? What would be the 
right way to deal with this error?


Kind regards,

Paul
