Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:35656 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757693Ab2EORon (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 13:44:43 -0400
Date: Tue, 15 May 2012 10:44:43 -0700 (PDT)
From: Alexandre Depoutovitch <adepoutovitch@vmware.com>
To: Dean <seattleplus@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Message-ID: <745238188.5696519.1337103883067.JavaMail.root@zimbra-prod-mbox-3.vmware.com>
In-Reply-To: <4FAD5C44.50407@gmail.com>
Subject: Re: [PATCH RFC v2] Performing direct I/O on sector-aligned requests
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Dean" <seattleplus@gmail.com>
> To: "Alexandre Depoutovitch" <adepoutovitch@vmware.com>
> Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
> Sent: Friday, May 11, 2012 2:36:52 PM
> Subject: Re: [PATCH RFC v2] Performing direct I/O on sector-aligned requests
> 
> 
> 
> On 4/29/12 2:03 PM, Alexandre Depoutovitch wrote:
> > A new flag is exposed to users through /proc/fs/nfsd/direct_io
> > node. The
> > default value of 1 results in the above behavior. Writing 0 to the
> > node
> > turns off the direct I/O completely, and forces NFS daemon to
> > always use
> > buffered IO (as it has done before). Writing 2 to the node tells
> > NFS
> > daemon to use direct I/O whenever possible, even if  requests are
> > aligned
> > at file system block boundary.
> 
> Not sure if this was previously discussed, but I assume the default
> would remain the same (value 0)?
> 
> Dean
> 
> 


Yes. The default should be 0 (the behavior will not change, unless the user explicitly enables it).
