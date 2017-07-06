Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx.cs.uchicago.edu ([128.135.164.214]:50053 "EHLO
        mx.cs.uchicago.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751943AbdGFWwp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Jul 2017 18:52:45 -0400
Received: from localhost (localhost [127.0.0.1])
        by mx.cs.uchicago.edu (Postfix) with ESMTP id 601CD605B5
        for <linux-nfs@vger.kernel.org>; Thu,  6 Jul 2017 17:43:11 -0500 (CDT)
Received: from mx.cs.uchicago.edu ([127.0.0.1])
        by localhost (mx.cs.uchicago.edu [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id HhNy9W9gC0bJ for <linux-nfs@vger.kernel.org>;
        Thu,  6 Jul 2017 17:43:10 -0500 (CDT)
Received: from [128.135.11.234] (hester2.cs.uchicago.edu [128.135.11.234])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mx.cs.uchicago.edu (Postfix) with ESMTPSA id 134F45FDC4
        for <linux-nfs@vger.kernel.org>; Thu,  6 Jul 2017 17:43:10 -0500 (CDT)
From: Phil Kauffman <kauffman@cs.uchicago.edu>
To: linux-nfs@vger.kernel.org
Subject: /etc/mtab read ~900 times by rpc.mountd
Message-ID: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu>
Date: Thu, 6 Jul 2017 17:43:09 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In response to this thread that died out a while back: http://marc.info/?t=142727765600001&r=1&w=2

I have the same issue and am looking for a solution.

My current setup involves nested ZFS datasets. It looks like this:
  tank/homes/user{1..6000}
  tank/stage/somedirname{1..100}

tank/homes and tank/stage are datasets and the immediate children are also datasets.

There are huge benefits to using datasets that I don't want to get into here, so lets leave it at I would prefer to keep this setup.


Now to the issue. Because of the nested mounts I need to use the 'crossmnt' export option which seems to invoke a loop over '/etc/mtab'. During various straces I have seen /etc/mtab get read over 900 times (on ssh login) while a users home directory is being mounted.

Since /etc/mtab has around 6000 lines (and growing) it takes a long time to complete. Around 8 seconds actually from the time you start an ssh connection to when the password prompt appears (tested with 'time ssh -o BatchMode=yes root@client1'). It seems that most of this time is spent by rpc.mountd reading /etc/mtab about 900 times while the client waits for the server to finish.

# ls -l /etc/mtab
lrwxrwxrwx 1 root root 19 Jun 22 14:31 /etc/mtab -> ../proc/self/mounts

# cat /proc/self/mounts > mtab

# ls -lh mtab
-rw-rw---- 1 root root 442K Jul  6 16:51 mtab

# wc -l mtab
6051 mtab


Right now I am dealing with 'nfs-kernel-server' version '1:1.2.8-9ubuntu12.1' (on Xenial), which I already had to patch with http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commitdiff;h=35640883cf34a32f893e9fecefbb193782e9bc75 suggested here http://marc.info/?t=138684383100001&r=1&w=2 
(This works brilliantly BTW, it shaved a good 20 seconds off the mount time because all those devices were being skipped.)


I was hoping you folks might take a look, and maybe provide a patch. /crosses fingers/

steved suggested that this took place around: utils/mountd/cache.c:nfsd_fh():path = next_mnt(&mnt, exp->m_export.e_path);


Cheers,

Phil


P.S.: I can provide straces on demand if required, I didn't want to clutter up the message.

-- 
Phil Kauffman
Systems Admin
Dept. of Computer Science
University of Chicago
kauffman@cs.uchicago.edu

