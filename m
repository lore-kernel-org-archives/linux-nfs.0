Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37702 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755919Ab0JNS2Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Oct 2010 14:28:25 -0400
Date: Thu, 14 Oct 2010 14:28:24 -0400
To: zoolook <nbensa@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs4 all_squash: does it work at all?
Message-ID: <20101014182824.GB1913@fieldses.org>
References: <AANLkTi=rzJXAPc17ggmw0LPS_Hn9HG15syLOtSN=nWdp@mail.gmail.com>
 <AANLkTimNH+YuR2fHo3Sz1sO434oOag9ON-omTXBQ0_2Z@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTimNH+YuR2fHo3Sz1sO434oOag9ON-omTXBQ0_2Z@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Oct 13, 2010 at 12:41:50AM -0300, zoolook wrote:
> 2010/10/12 zoolook <nbensa@gmail.com>:
> > Why uid:1000 with nfs4 and uid:65534 with nfs3? What am I missing?
> > Note that I would like nfs4 behave like nfs3.
> 
> I've been struggling with this for two weeks. I've read lots of docs,
> posts, forums, faqs... and I hate when I find the answer just after
> clicking send to a mailing list.
> 
> For the record, what I missed was the fact that I need to do bind
> mount for nfs4 to work properly.

Careful--if /NFSROOT/shares and /NFSROOT/shares/Sistemas are on the same
filesystem partition, then the all_squash on Sistemas is easily bypassed
by a malicious client.

With new kernel & nfs-utils, you really should just be able to do

	/shares/systemas *(rw,sync,no_subtree_check,all_squash,anongid=1002)

and it should just work with v3 and v4.

--b.

> 
> Server:
> $ ls -lnd /shares/sistemas/
> drwxrws--- 2 65534 1002 4096 2010-10-12 23:25 /shares/sistemas/
> 
> $ mount | grep NFSROOT
> /shares/sistemas on /NFSROOT/shares/Sistemas type none (rw,bind)
> 
> $ cat /etc/exports
> /NFSROOT			*(ro,sync,no_subtree_check,fsid=root)
> /NFSROOT/shares/Sistemas	*(rw,sync,no_subtree_check,all_squash,anongid=1002)
> 
> Client:
> $ mount | grep nfsserver
> nfsserver:/shares/Sistemas on /compartidos/sistemas type nfs4
> (rw,clientaddr=10.11.101.124,addr=10.11.101.126)
> 
> $ touch /compartidos/sistemas/q
> 
> $ ls -ln /compartidos/sistemas/
> total 0
> -rw-r--r-- 1 65534 1002 0 2010-10-13 00:37 q
> 
> 
> 
> Thanks to all who have read. And I'm sorry for the noise.
> 
> Best regards,
> Norberto
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
