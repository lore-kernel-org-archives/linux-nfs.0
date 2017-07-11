Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx.cs.uchicago.edu ([128.135.164.214]:56119 "EHLO
        mx.cs.uchicago.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933351AbdGKPjM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Jul 2017 11:39:12 -0400
Received: from localhost (localhost [127.0.0.1])
        by mx.cs.uchicago.edu (Postfix) with ESMTP id 55D7C6076D
        for <linux-nfs@vger.kernel.org>; Tue, 11 Jul 2017 10:39:06 -0500 (CDT)
Received: from mx.cs.uchicago.edu ([127.0.0.1])
        by localhost (mx.cs.uchicago.edu [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id iFtxCljuNJJV for <linux-nfs@vger.kernel.org>;
        Tue, 11 Jul 2017 10:39:05 -0500 (CDT)
Received: from [128.135.11.234] (hester2.cs.uchicago.edu [128.135.11.234])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mx.cs.uchicago.edu (Postfix) with ESMTPSA id 81CD76070E
        for <linux-nfs@vger.kernel.org>; Tue, 11 Jul 2017 10:39:05 -0500 (CDT)
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
To: linux-nfs@vger.kernel.org
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu>
 <8737a9x9ky.fsf@notabene.neil.brown.name> <595F1A3A.7070405@cs.uchicago.edu>
 <87efto69rs.fsf@notabene.neil.brown.name>
 <4ec2a8fc-3ca5-d26b-7742-be4e2f749c21@cs.uchicago.edu>
 <87y3rv4zrb.fsf@notabene.neil.brown.name>
From: Phil Kauffman <kauffman@cs.uchicago.edu>
Message-ID: <1740081e-6180-1c88-0a0c-8747a92c65a1@cs.uchicago.edu>
Date: Tue, 11 Jul 2017 10:39:05 -0500
MIME-Version: 1.0
In-Reply-To: <87y3rv4zrb.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/10/2017 06:51 PM, NeilBrown wrote:
> This does look encouraging ... but I'm not sure we are comparing apples
> with apples.
I had a feeling this was the case.


> Could you repeat your experiments after first running "exportfs -f" on
> the nfs server?  That should cause worst-case load on mountd.
The new strace with '-tt': http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/test_with_patch_take2/2017-07-11_100929_strace.txt
SSH test: http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/test_with_patch_take2/ssh_output.txt

nfsserver# exportfs -f; m=$(pgrep rpc.mountd); strace -tt -p ${m} 2>&1 | tee `date +%F_%T`_strace.txt


# cut -d' ' -f2 2017-07-11_100929_strace.txt| cut -d'(' -f1 | sort | uniq -c | sort -n
      1 Process
     73 select
    143 write
    216 close
    216 fstat
    216 open
  48240 read
 435599 stat
 871162 statfs
 871163 lstat


> (and thanks for providing all the tracing details - I love getting
> unambiguous data!!)
No problem, I'm available to run any necessary tests. I also appreciate your help on this.



-- 
Phil Kauffman
Systems Admin
Dept. of Computer Science
University of Chicago
kauffman@cs.uchicago.edu
773-702-3913
