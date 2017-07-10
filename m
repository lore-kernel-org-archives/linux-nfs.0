Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx.cs.uchicago.edu ([128.135.164.214]:40593 "EHLO
        mx.cs.uchicago.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754312AbdGJU75 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jul 2017 16:59:57 -0400
Received: from localhost (localhost [127.0.0.1])
        by mx.cs.uchicago.edu (Postfix) with ESMTP id E7EEC606E0
        for <linux-nfs@vger.kernel.org>; Mon, 10 Jul 2017 15:59:46 -0500 (CDT)
Received: from mx.cs.uchicago.edu ([127.0.0.1])
        by localhost (mx.cs.uchicago.edu [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id qoleAGv4tNUJ for <linux-nfs@vger.kernel.org>;
        Mon, 10 Jul 2017 15:59:45 -0500 (CDT)
Received: from [128.135.11.234] (hester2.cs.uchicago.edu [128.135.11.234])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mx.cs.uchicago.edu (Postfix) with ESMTPSA id DC7AC606DC
        for <linux-nfs@vger.kernel.org>; Mon, 10 Jul 2017 15:59:45 -0500 (CDT)
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
To: linux-nfs@vger.kernel.org
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu>
 <8737a9x9ky.fsf@notabene.neil.brown.name> <595F1A3A.7070405@cs.uchicago.edu>
 <87efto69rs.fsf@notabene.neil.brown.name>
From: Phil Kauffman <kauffman@cs.uchicago.edu>
Message-ID: <4ec2a8fc-3ca5-d26b-7742-be4e2f749c21@cs.uchicago.edu>
Date: Mon, 10 Jul 2017 15:59:45 -0500
MIME-Version: 1.0
In-Reply-To: <87efto69rs.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/10/2017 02:17 AM, NeilBrown wrote:
> Another is to move the code around.  In your case there are really just
> 3 exports to each of 300+ clients (I assume "client.cs.uchicago.edu" in
> the combined exports file is really different in different files).
> So any one client only needs to consider 3 exports, not 300.
This assumption is correct. We have ~300 clients and growing (slowly).

> Could you test with this patch applied and see what
> difference it makes?
After being confused by conflicting test results and determining that the service nfs-server takes a bit longer to start than 'systemctl' will let you believe, I believe Niel's patch works.


The new cache.c file I am using to test with: http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/test_with_patch/cache.c
  It also contains the official patch from this thread: http://marc.info/?l=linux-nfs&m=138900709311582&w=2

Building the new deb packages: http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/test_with_patch/build_deb.txt

Install nfs-kernel-server and nfs-common debs on server and nfs-common on client.


I reboot everything: client and server

Run ssh for loop (no stracing) with the result that every user was able to ssh in under a second (I consider this to be a success).
  http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/test_with_patch/ssh_result_no-strace.txt

I then used a larger sample size of users (~/f) and got a similar result.


Now lets strace rpc.mountd while sshing with one user:

$ time ssh -o BatchMode=yes $CLIENTHOSTNAME -l user_not_in_list_f
Permission denied (publickey,password).

real	0m0.352s
user	0m0.020s
sys	0m0.012s

The resulting strace seems entirely reasonable: http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/test_with_patch/ssh_one_user_strace.txt


$ for user in $(cat ~/users | grep -E "^g*"); do time ssh -o BatchMode=yes $CLIENTHOSTNAME -l $user; done
  The first few dozen users whos usernames happen to start with 'g': 
    http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/test_with_patch/ssh_multiple_user_strace.txt



-- 
Phil Kauffman
Systems Admin
Dept. of Computer Science
University of Chicago
kauffman@cs.uchicago.edu

