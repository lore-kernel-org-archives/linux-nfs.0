From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: may be a bug?
Date: Thu, 28 Aug 2008 13:43:33 -0400
Message-ID: <20080828174333.GB3529@fieldses.org>
References: <200808281652540341291@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Payphone LIOU <lioupayphone@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40657 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756157AbYH1Rnf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Aug 2008 13:43:35 -0400
In-Reply-To: <200808281652540341291@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 28, 2008 at 04:52:58PM +0800, Payphone LIOU wrote:
> Hi, ALL.
> 
> in moutd.h of nfs-utils-1.1.3, an union object was defined  below.
> union mountd_results {
> 	fhstatus		fstatus;
> 	mountlist		mountlist;
> 	exports			exports;
> };
> 
> the space size of mountd_results is the maximum one among fsstaus,mountlist and exports, and all of them are the output arguments of mountd procedures.
> in nfsv3, mount_mnt_3_svc takes "mountres3" as its output. so i think it may be :
> 
> union mountd_results {
> 	fhstatus		fstatus;
> 	mountlist		mountlist;
> 	exports			exports;
> 	mountres3    mountres3;
> };
> 
> because the size of fstatus is larger than mountres3, no erros happens. but i think semantically  "mountres3" should be added into this union structure. am i wrong?

>From a quick glance..... Yes, I agree, that looks suspicious.  Perhaps
you could send a patch?  (Address it to steved@redhat.com, cc'd to this
list.)

--b.

> 
> thansk a lot.
> 
> Best regards. :-)
> 
> Payphone LIOU 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
