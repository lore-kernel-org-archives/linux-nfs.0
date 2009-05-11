From: Holger Kiehl <Holger.Kiehl-ra7Ruw+Xvfw@public.gmane.org>
Subject: Re: NFS write OOPS with 2.6.29.2
Date: Mon, 11 May 2009 09:24:15 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0905110919490.27423@praktifix.dwd.de>
References: <Pine.LNX.4.64.0905031552340.1774@praktifix.dwd.de>
 <20090504231426.2e5a51b0.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0905091913010.3181@praktifix.dwd.de>
 <1241929074.5149.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dwdmx5.dwd.de ([141.38.3.242]:55051 "EHLO dwdmx5.dwd.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754853AbZEKJYY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 May 2009 05:24:24 -0400
Received: from localhost (localhost [127.0.0.1])
	by node7.dwd.de (Postfix) with ESMTP id AD0E9790587
	for <linux-nfs@vger.kernel.org>; Mon, 11 May 2009 09:24:24 +0000 (UTC)
Received: from node7.dwd.de ([127.0.0.1])
	by localhost (node7.csg-cluster.lan [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id HdMr23TVJD9i for <linux-nfs@vger.kernel.org>;
	Mon, 11 May 2009 09:24:18 +0000 (UTC)
In-Reply-To: <1241929074.5149.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 10 May 2009, Trond Myklebust wrote:

> On Sat, 2009-05-09 at 19:16 +0000, Holger Kiehl wrote:
>> On Mon, 4 May 2009, Andrew Morton wrote:
>>
>>>
>>> (cc linux-nfs)
>>>
>>> On Sun, 3 May 2009 16:03:38 +0000 (GMT) Holger Kiehl <Holger.Kiehl-ra7Ruw+Xvfw@public.gmane.org> wrote:
>>>
>>>> Hello
>>>>
>>>> With plain kernel 2.6.29.2 I get the following OOPS (several of them) when
>>>> writing lots of small files on the client system:
>>>>
>>>>     May  3 18:48:34 obelix kernel: ------------[ cut here ]------------
>>>>     May  3 18:48:34 obelix kernel: kernel BUG at fs/nfs/write.c:252!
>>>
>>> I think this is a well-know bug, and fixes should be available in 2.6.29.3?
>>>
>> Thanks for this information. I just tried 2.6.29.3 and it still oopses.
>> Are there any patches I can try?
>
> The attached backports against 2.6.29 are untested, but they are known
> to compile at least. Could you give them a try?
>
Thanks. They do compile but when there is a mmap on the NFS drive the
program gets a SIGBUS:

    unlink("/home/afdbench/afd2/fifodir/AFD_ACTIVE") = 0
    close(3)                                = 0
    open("/home/afdbench/afd2/fifodir/AFD_ACTIVE", O_RDWR|O_CREAT|O_TRUNC|O_CLOEXEC, 0600) = 3
    lseek(3, 78, SEEK_SET)                  = 78
    write(3, "\377"..., 1)                  = 1
    mmap(NULL, 78, PROT_READ|PROT_WRITE, MAP_SHARED, 3, 0) = 0x7f8045cdb000
    --- SIGBUS (Bus error) @ 0 (0) ---

This was with 2.6.29.3 plus the patches you send me.

Holger
