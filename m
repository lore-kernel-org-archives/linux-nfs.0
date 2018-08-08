Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mails1n0-route0.email.arizona.edu ([128.196.130.69]:1793 "EHLO
        mails1n0-route0.email.arizona.edu" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1728471AbeHHVP6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2018 17:15:58 -0400
Subject: Re: RDMA connection closed and not re-opened
References: <f1e596cf-0e70-39af-99e9-a0a7e912bad3@genome.arizona.edu>
 <4A72535B-E6D2-4E8A-B6DB-BF09856A41EB@gmail.com>
 <19cd3809-669b-2d63-d453-ed553c9e01a9@genome.arizona.edu>
 <E7AAFE10-FBFE-41E9-9731-D9C50DD2F654@oracle.com>
 <57cf42c5-d12d-fff3-fd77-0d191d32111e@genome.arizona.edu>
 <9b0802b9-ad7c-0969-6087-9f2aef703143@genome.arizona.edu>
 <0423D037-63F9-4BA6-882A-CBD9EBC630F2@oracle.com>
 <5b08ea1b-4cde-c432-92cc-04eff469ed54@genome.arizona.edu>
 <7F74B5E4-DCAD-46E1-988F-68E79FBD72FA@oracle.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: admin@genome.arizona.edu
Message-ID: <51f7869c-de9a-65c3-9fd7-0133ca7232e1@genome.arizona.edu>
Date: Wed, 8 Aug 2018 11:54:58 -0700
MIME-Version: 1.0
In-Reply-To: <7F74B5E4-DCAD-46E1-988F-68E79FBD72FA@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote on 07/14/2018 07:37 AM:
>> On Jul 13, 2018, at 6:32 PM, admin@genome.arizona.edu wrote:
>> Chuck Lever wrote on 07/13/2018 07:36 AM:
>>> You should be able to mount using "proto=tcp" with your mlx4 cards.
>>> That avoids the use of NFS/RDMA but would enable the use of the
>>> higher bandwidth network fabric.
>> Thanks I could definitely try that.  IPoIB has it's own set of issues though but can cross that bridge when I get to it....
> Stick with connected mode and keep rsize and wsize smaller
> than the IPoIB MTU, which can be set as high as 65KB.
We are running in this setup, so far so good... however the rsize/wsize 
were much greater than the IPoIB MTU, and it is probably causing these 
"page allocation failures" which fortunately have not been fatal; our 
computation is still running.  In the ifcfg file for the IPoIB 
interface, the MTU is set to 65520, which was the recommended maximum 
from the Red Hat manual.  So should rsize/wsize be set to 65519? or is 
it better to pick another value that is a multiple 1024 or something?
Thanks
