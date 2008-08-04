From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs-utils and unfsd
Date: Mon, 4 Aug 2008 16:18:11 -0400
Message-ID: <6C6DC223-D883-4822-81E1-9292DC47A567@oracle.com>
References: <959E2970-49E6-425C-A10D-2D486913CD3F@oracle.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>, Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:54078 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762344AbYHDUTZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Aug 2008 16:19:25 -0400
In-Reply-To: <959E2970-49E6-425C-A10D-2D486913CD3F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 4, 2008, at 3:55 PM, Chuck Lever wrote:
> There is a generic RPC server helper in nfs-utils called  
> rpc_init().  This API will need to be modified to support IPv6 in  
> statd and mountd, at least.
>
> However, there is a comment inside support/nfs/rpcmisc.c, where  
> rpc_init() resides, that suggests that this interface is also used  
> by unfsd.
>
> Is it OK for me to modify nfs-utils' copy of this function, or is  
> there any kind of ABI restriction between unfsd and nfs-utils?

I'd also like to point out that the block comment at the top of  
support/nfs/rpcmisc.c says:

   5  * This code is partially snarfed from rpcgen -s tcp -s udp,
   6  * partly written by Mark Shand, Donald Becker, and Rick
   7  * Sladkey. It was tweaked slightly by Olaf Kirch to be
   8  * usable by both unfsd and mountd.
   9  *
  10  * This software may be used for any purpose provided
  11  * the above copyright notice is retained.  It is supplied
  12  * as is, with no warranty expressed or implied.

The second paragraph refers to "the above copyright notice," but there  
is no copyright notice.

--
Chuck Lever
chucklever[at]mac[dot]com


--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



