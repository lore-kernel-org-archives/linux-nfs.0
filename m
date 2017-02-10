Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37382 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdBJJte (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2017 04:49:34 -0500
Received: by mail-wm0-f54.google.com with SMTP id v77so43260531wmv.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Feb 2017 01:49:33 -0800 (PST)
MIME-Version: 1.0
From: Pankaj Singh <psingh.ait@gmail.com>
Date: Fri, 10 Feb 2017 14:51:14 +0530
Message-ID: <CAPrqf9378wbKmv9EaiuFzYLwvCxziXtkk-ZY-jsJxSOgSNm+QA@mail.gmail.com>
Subject: How NLM support posix threads?
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am getting a strange problem where locks are denied by NFSv3 server
even though no locks on same file where taken.

While looking at the code it seems like NLM compares a lock by using
"pid" and other options like form - to file offset, type of lock etc.
But we are interested in "pid" because other comparison can be same
for different file_locks.

 As we know posix threads use tgid as pid for all its thread hence
NFSv3 server will can get lock request from different posix thread but
with same pid. Hence NLM  will treat the locking request as they are
coming from same process. This may result in following problems

1. Different threads of same process can get lock on same file.
2. During "fl_grant" callback wrong "block" will be compared hence
this will result in lock failure even if lock is actually granted.

Is this a limitation of NLM?

-- 
Regards,
Pankaj SIngh
Phone No: 8826266889
