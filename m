From: "Pascal A. Dupuis" <Pascal.Dupuis-s1sOSHjJPfVpcTqYljSg7g@public.gmane.org>
Subject: Re: [NFS] troubles with nohide -- crossmnt
Date: Thu, 7 Feb 2008 22:52:52 +0100
Message-ID: <20080207215251.GC3034@example.org>
References: <20080207213605.GB3034@example.org>
	<20080207164110.374a5ab0@tleilax.poochiereds.net>
Reply-To: Pascal.Dupuis-s1sOSHjJPfVpcTqYljSg7g@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:49952 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753787AbYBGVxX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 16:53:23 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JNEgG-0004RA-Ld
	for linux-nfs@vger.kernel.org; Fri, 08 Feb 2008 08:53:16 +1100
In-Reply-To: <20080207164110.374a5ab0-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 07, 2008 at 04:41:10PM -0500, Jeff Layton wrote:

> > /home/user/archive	192.168.1.10(rw,subtree_check,fsid=0) 
> > /home/user           	192.168.1.10(rw,subtree_check,fsid=0,crossmnt) 
> > 
> 
> You shouldn't have 2 exports with the same fsid= option. They
> should be different. I'd suggest giving /home/user fsid=0
> and /home/user/archive fsid=1 (or something else).
> 

OK. It made the trick. I didn't notice that both exported FS had the
same fsid. Thanks. Maybe this should be included in the FAQS ?

Regards

Pascal Dupuis

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

