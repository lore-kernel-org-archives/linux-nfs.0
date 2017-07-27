Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx.cs.uchicago.edu ([128.135.164.214]:57316 "EHLO
        mx.cs.uchicago.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751633AbdG0VkH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jul 2017 17:40:07 -0400
Received: from localhost (localhost [127.0.0.1])
        by mx.cs.uchicago.edu (Postfix) with ESMTP id 619845FFB0
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jul 2017 16:40:07 -0500 (CDT)
Received: from mx.cs.uchicago.edu ([127.0.0.1])
        by localhost (mx.cs.uchicago.edu [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id 4k9eMe_Q93fE for <linux-nfs@vger.kernel.org>;
        Thu, 27 Jul 2017 16:40:06 -0500 (CDT)
Received: from [128.135.11.234] (hester2.cs.uchicago.edu [128.135.11.234])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mx.cs.uchicago.edu (Postfix) with ESMTPSA id 9004C5FD8E
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jul 2017 16:40:06 -0500 (CDT)
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
To: linux-nfs@vger.kernel.org
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu>
 <8737a9x9ky.fsf@notabene.neil.brown.name> <595F1A3A.7070405@cs.uchicago.edu>
 <87efto69rs.fsf@notabene.neil.brown.name>
 <4ec2a8fc-3ca5-d26b-7742-be4e2f749c21@cs.uchicago.edu>
 <87y3rv4zrb.fsf@notabene.neil.brown.name>
 <1740081e-6180-1c88-0a0c-8747a92c65a1@cs.uchicago.edu>
 <87bmoq4h41.fsf@notabene.neil.brown.name>
 <9e16d6c3-a675-b53e-c6f3-dfa9cdf1d5c9@cs.uchicago.edu>
 <871spj1pfr.fsf@notabene.neil.brown.name>
 <03636068-4cc7-896e-5f8b-8c3ebfd2aa94@cs.uchicago.edu>
 <87h8xywl4t.fsf@notabene.neil.brown.name>
From: Phil Kauffman <kauffman@cs.uchicago.edu>
Message-ID: <3fd8c348-13ee-ce90-a1d5-d0c652f66c89@cs.uchicago.edu>
Date: Thu, 27 Jul 2017 16:40:06 -0500
MIME-Version: 1.0
In-Reply-To: <87h8xywl4t.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/26/2017 11:37 PM, NeilBrown wrote:
> Weird.
I thought so as well.

> So it seems like the context is different in some way.
It is in the sense that I am now using 1.3.4 and 2.1.1 vanilla on Ubuntu Xenial(provides 1.2.8) without any of debian's patches or niceties. 

 
> Your nfs_test_notes.txt doesn't show /etc/export.d getting filled in
> ... maybe that it done automatically somehow...
I copied the files from the original NFS server into /etc/exports.d  as part of the VM snapshot I revert back to. My notes say 'mkdir -p /etc/exports.d', but this step is not necessary.

root@nfsserver:~# ls /etc/exports.d/ | wc -l
972

I only added 3 extra files so that 'nfsclient' would be able to mount from the testing server (nfsserver).

The ZFS datasets were also precreated:

root@nfsserver:~# zfs list | wc -l
6062


> Can you try with unpatches 2.1.1?
I assume you mean without any patches. vanilla 2.1.1

> Also maybe provide an strace starting before any attempt to mount
> anything, and with an extra option "-s 1000"..

This is all that happens *before* trying to mount from the client.
root@nfsserver:~# systemctl restart nfs-server; exportfs -f; m=$(pgrep rpc.mountd); strace -s 1000 -ttt -T -p $m 2>&1 | tee strace_rpc.mountd2.txt
strace: Process 2517 attached
1501190436.659800 select(1024, [3 4 5 7 8 9 10 11 12 13 14 15 16 17 18], NULL, NULL, NULL

Stracing rpc.nfsd:
root@nfsserver:~# exportfs -f; strace -s1000 -ttt -T /usr/sbin/rpc.nfsd 0 2>&1| tee strace_nfsd.txt; /usr/sbin/sm-notify
http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/take3/strace_rpc.nfsd.txt

When mounting from the client I get a strace that is 1.3G (it seems '-s' was not respected for some reason): http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/take3/strace_rpc.mountd.txt 




-- 
Phil Kauffman
Systems Admin
Dept. of Computer Science
University of Chicago
kauffman@cs.uchicago.edu
