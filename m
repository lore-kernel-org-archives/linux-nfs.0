Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx.cs.uchicago.edu ([128.135.164.214]:35825 "EHLO
        mx.cs.uchicago.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750983AbdGGFVB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jul 2017 01:21:01 -0400
Received: from localhost (localhost [127.0.0.1])
        by mx.cs.uchicago.edu (Postfix) with ESMTP id F0017605C9
        for <linux-nfs@vger.kernel.org>; Fri,  7 Jul 2017 00:21:00 -0500 (CDT)
Received: from mx.cs.uchicago.edu ([127.0.0.1])
        by localhost (mx.cs.uchicago.edu [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id 6IQib9TGgRgZ for <linux-nfs@vger.kernel.org>;
        Fri,  7 Jul 2017 00:21:00 -0500 (CDT)
Received: from pippin.local (c-98-212-54-164.hsd1.il.comcast.net [98.212.54.164])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mx.cs.uchicago.edu (Postfix) with ESMTPSA id 210D4605B5
        for <linux-nfs@vger.kernel.org>; Fri,  7 Jul 2017 00:21:00 -0500 (CDT)
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
To: linux-nfs@vger.kernel.org
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu>
 <8737a9x9ky.fsf@notabene.neil.brown.name>
From: Phil Kauffman <kauffman@cs.uchicago.edu>
Message-ID: <595F1A3A.7070405@cs.uchicago.edu>
Date: Fri, 7 Jul 2017 00:20:58 -0500
MIME-Version: 1.0
In-Reply-To: <8737a9x9ky.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I can imagine /etc/mtab being read once for every line in /etc/exports,
> but unless your /etc/exports is very big, I can't easily see why it
> would be read 900 times.
> Maybe lots of different mount points are being accessed by something and
> each one triggers a few reads...
>
> Can you show your /etc/exports file?

These get generated via puppet and dropped into /etc/exports.d/

Any given host will have 3 files associated with it:

root@charlie-storage1:~# cat 
/etc/exports.d/client1.cs.uchicago.edu.charliestorage1_fsidroot.charliestorage1_fsidroot.exports
/tank 
client1.cs.uchicago.edu(fsid=0,rw,async,no_subtree_check,insecure,crossmnt)
root@charlie-storage1:~# cat 
/etc/exports.d/client1.cs.uchicago.edu.charliestorage1_homes.charliestorage1_homes.exports 

/tank/homes 
client1.cs.uchicago.edu(rw,async,no_subtree_check,insecure,crossmnt)
root@charlie-storage1:~# cat 
/etc/exports.d/client1.cs.uchicago.edu.charliestorage1_stage.charliestorage1_stage.exports
/tank/stage 
client1.cs.uchicago.edu(rw,async,no_subtree_check,insecure,crossmnt)

Here we can see that there are 960 files in /etc/exports.d
root@storage1:~# find /etc/exports.d/ -type f | wc
960 960 88701

You probably don't want or need this but here is a link to all of my 
/etc/exports.d/ combined into one file which I redacted the hostnames: 
http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/all_etc_exports.d_in_one_file.txt

> I don't recommend this approach.  If you have data, just provide it.  If
> it is really really big, provide a link.
> You have my attention now.  You might not get it again when you send the
> strace.  You might have wasted your opportunity.
> Yes - please provide the strace showing lots of reads through
> /etc/mtab.  Don't provide it privately to me.  Either post it to the
> list, or post a link to it.

Thanks for the advice.

Here is a link to a best effort redacted strace: 
http://people.cs.uchicago.edu/~kauffman/nfs-kernel-server/redacted_strace.txt

I would prefer to keep user name leakage to a minimum.


Cheers,

Phil


-- 
Phil Kauffman
Systems Admin
Dept. of Computer Science
University of Chicago
kauffman@cs.uchicago.edu
773-702-3913
