Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx.cs.uchicago.edu ([128.135.164.214]:57597 "EHLO
        mx.cs.uchicago.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752617AbdGLRzk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 13:55:40 -0400
Received: from localhost (localhost [127.0.0.1])
        by mx.cs.uchicago.edu (Postfix) with ESMTP id 259A660883
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 12:55:39 -0500 (CDT)
Received: from mx.cs.uchicago.edu ([127.0.0.1])
        by localhost (mx.cs.uchicago.edu [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id lPoJvBTTAWCM for <linux-nfs@vger.kernel.org>;
        Wed, 12 Jul 2017 12:55:38 -0500 (CDT)
Received: from [128.135.11.234] (hester2.cs.uchicago.edu [128.135.11.234])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mx.cs.uchicago.edu (Postfix) with ESMTPSA id 7E9516083C
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 12:55:38 -0500 (CDT)
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
To: linux-nfs@vger.kernel.org
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu>
 <8737a9x9ky.fsf@notabene.neil.brown.name> <595F1A3A.7070405@cs.uchicago.edu>
 <87efto69rs.fsf@notabene.neil.brown.name>
 <4ec2a8fc-3ca5-d26b-7742-be4e2f749c21@cs.uchicago.edu>
 <87y3rv4zrb.fsf@notabene.neil.brown.name>
 <1740081e-6180-1c88-0a0c-8747a92c65a1@cs.uchicago.edu>
 <87bmoq4h41.fsf@notabene.neil.brown.name>
From: Phil Kauffman <kauffman@cs.uchicago.edu>
Message-ID: <9e16d6c3-a675-b53e-c6f3-dfa9cdf1d5c9@cs.uchicago.edu>
Date: Wed, 12 Jul 2017 12:55:38 -0500
MIME-Version: 1.0
In-Reply-To: <87bmoq4h41.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/11/2017 07:46 PM, NeilBrown wrote:
> So the new data shows about 7 seconds for a login, which is probably
> a little longer than you would like, but might be acceptable?
Unfortunately, the delay is not acceptable.

The ideal would be to achieve performance parity with when one is not 
forced to use the 'crossmnt' option.

My current setup (home directory server) does not require 'crossmnt' and 
does not incur a delay. It is a standard nfs server using mdadm, lvm, 
and xfs.

While my current setup is probably "normal" and using nested datasets 
with the 'crossmnt' option might be "weird" now; nested mounts will 
probably only become more common as BTRFS, ZFS, and other filesystems 
with similar features gain traction on linux.


> That is more than a 2-line patch.  I might have a go later this week.
That would be super! Thanks for taking a look.



-- 
Phil Kauffman
Systems Admin
Dept. of Computer Science
University of Chicago
kauffman@cs.uchicago.edu

