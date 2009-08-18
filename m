From: maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
Subject: Re: nfs MNT include cleanup
Date: Tue, 18 Aug 2009 14:44:07 +0200
Message-ID: <20090818124406.GD13440@baikonur.stro.at>
References: <20090811104418.GA6175@stro.at> <C7D2AC7D-48B2-4206-A6B1-3780FE7D51CE@oracle.com> <20090818103653.GB3954@stro.at> <86201444-2DDC-47B0-A92E-81CB19224CCB@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>, klibc@zytor.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:36897 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbZHRNQN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2009 09:16:13 -0400
In-Reply-To: <86201444-2DDC-47B0-A92E-81CB19224CCB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 18, 2009 at 08:45:49AM -0400, Chuck Lever wrote:
> 
> However, the kernel has its own NFS mount client (the piece that  
> handles rpcbind query and obtaining the root file handle), and you can  
> pass a C string of mount options to the kernel with mount(2).  Perhaps  
> in the long term, you might consider replacing the specialized code in  
> klibc with simply passing the server, export path, and mount options  
> right to the kernel and let it do the work.  This should work with any  
> kernel later than 2.6.23.
> 
> I'm happy to help with any questions.

sounds good indeed.
a quick one: can it do nfs v4 mounts?

