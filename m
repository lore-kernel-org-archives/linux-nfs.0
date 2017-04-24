Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43418 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1169692AbdDXMQX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Apr 2017 08:16:23 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Anna Schumaker" <anna.schumaker@netapp.com>,
        "Trond Myklebust" <trondmy@primarydata.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Callback threads not getting cleaned up
Date: Mon, 24 Apr 2017 08:16:16 -0400
Message-ID: <50B1D6E0-A38B-4B16-AAF1-3C6B9ED2A905@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna and Trond,

We've had some complaints on v4.9/v4.10 about NFSv4 callback threads not 
getting cleaned up:

https://bugzilla.redhat.com/show_bug.cgi?id=1427493

I think the problem started with bb6aeba736ba NFSv4.x: Switch to using 
svc_set_num_threads() to manage the callback threads.

I just ran a quick test on the testing branch, and this problem 
persists.  I also tested with Kinglong Mee's two patches:

[PATCH v2 1/2] NFSv4.x/callback: Create the callback service through 
svc_create_pooled
Message-ID: <322d5c7d-d3b4-1e02-de3f-8e1a900cb150@gmail.com>

and

[PATCH v2 2/2] NFSv4.x/callback: make sure callback threads are 
interruptible
Message-ID: <d8e459af-1efa-dae9-61b6-253e8945831f@gmail.com>

.. with those, the callback threads are cleaned up properly.  Any chance 
we can take those two patches this time?  I haven't reviewed those 
patches (yet), I've just hand tested them to see if they fix this 
problem.

Ben
