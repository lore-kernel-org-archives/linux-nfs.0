From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs-utils: Handle authentication flavour order properly
Date: Fri, 7 Mar 2008 11:16:57 -0500
Message-ID: <629ABBF6-C368-44AC-B4B9-471296229325@oracle.com>
References: <f88853200803061908y497164bdpdff7b9109567d8c0@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: "bc Wong" <bcwalrus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:42530 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157AbYCGQR0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Mar 2008 11:17:26 -0500
In-Reply-To: <f88853200803061908y497164bdpdff7b9109567d8c0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi BC-

On Mar 6, 2008, at 10:08 PM, bc Wong wrote:
> There were 2 things wrong with auth flavour ordering:
> - Mountd used to advertise AUTH_NULL as the first flavour on
>   the list, which means that it prefers AUTH_NULL to anything
>   else (as per RFC 2623 section 2.7).
> - Mount.nfs used to scan the returned list in reverse order,
>   and stopping at the first AUTH_NULL or AUTH_SYS encountered.
>   If a server advertises (AUTH_SYS, AUTH_NULL), it will by
>   default choose AUTH_NULL and have degraded access.

This patch addresses problems only in the legacy part of the user  
space mount.nfs command.  Since 2.6.24 NFS mount option parsing is  
handled in the kernel instead.

I don't think the new in-kernel mount client even supports receiving  
a list of auth flavors from the server.  Do you have an equivalent  
patch for that?  If you'd like help we can discuss it off-line.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
