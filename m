From: Neil Brown <neilb@suse.de>
Subject: Re: Doc for adding new NFS export option
Date: Mon, 7 Jul 2008 16:29:21 +1000
Message-ID: <18545.47041.516146.605353@notabene.brown>
References: <48718FF4.4030200@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:50625 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456AbYGGG31 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2008 02:29:27 -0400
In-Reply-To: message from Shehjar Tikoo on Monday July 7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday July 7, shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org wrote:
> Hi All
> 
> Is there a document that enumerates which files and functions I need 
> to add stuff to, for adding a new server-side export option?

No.  I think the theory is that unless you have read and understood
the code, you should really be thinking about adding new options.
And if you have, then you don't need any documentations.
:-)

> 
> I've tried adding it to some of the functions in the exportfs related 
> code in nfs-utils and also in the kernel's export related headers but 
> I dont think that is all there is to it.

That sounds good, but without details, it is hard to be sure.
Don't be afraid to send a patch which shows what you are trying to do.

> 
> I ask this because without my new option, I am able to mount the 
> export correctly but with it, the mount command fails with the 
> following message:
> 
> mount.nfs: 192.168.10.5:/data/nfstest failed, reason given by server: 
> Permission denied

So what exactly is this new export option that you want to add?

NeilBrown
