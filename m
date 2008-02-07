From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] troubles with nohide -- crossmnt
Date: Thu, 7 Feb 2008 16:41:10 -0500
Message-ID: <20080207164110.374a5ab0@tleilax.poochiereds.net>
References: <20080207213605.GB3034@example.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Pascal.Dupuis-s1sOSHjJPfVpcTqYljSg7g@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:33540 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934292AbYBGVlr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 16:41:47 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JNEV7-0004PG-5e
	for linux-nfs@vger.kernel.org; Fri, 08 Feb 2008 08:41:45 +1100
In-Reply-To: <20080207213605.GB3034-hcDgGtZH8xNAfugRpC6u6w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 7 Feb 2008 22:36:05 +0100
"Pascal A. Dupuis" <Pascal.Dupuis-s1sOSHjJPfVpcTqYljSg7g@public.gmane.org> wrote:

> Hello,
> 
> I'd like to export two filesystems, mounted on one another. The setup is :
> 
> some partition mounted as /home/user  (parent)
> another one            as /home/user/archive  (child)
> 
> The export file contains:
> /home/user/archive	192.168.1.10(rw,subtree_check,fsid=0) 
> /home/user           	192.168.1.10(rw,subtree_check,fsid=0,crossmnt) 
> 

You shouldn't have 2 exports with the same fsid= option. They
should be different. I'd suggest giving /home/user fsid=0
and /home/user/archive fsid=1 (or something else).

> I tried:
> -setting the 'nohide' option on the child
> -setting the crossmnt on the parent
> -permuting the order 
> 
> Whatever case I try, on the client I ALWAYS see the child directory,
> and not the parent. Any clue ?
> 
> Both systems are linux-2.6.24, debian SID, nfs-kernel-package for the
> server, nfsv4 compiled as a module.
> 
> TIA
> 
> Pascal Dupuis 
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2008.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>     http://vger.kernel.org/vger-lists.html#linux-nfs
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Jeff Layton <jlayton@redhat.com>

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

