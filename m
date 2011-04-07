Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51763 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756750Ab1DGDCq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 23:02:46 -0400
Message-ID: <4D9D29A5.7000507@cn.fujitsu.com>
Date: Thu, 07 Apr 2011 11:04:05 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Rob Landley <rlandley@parallels.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: What's nlmsvc_proc_share() for?
References: <4D9C7916.5030907@parallels.com>
In-Reply-To: <4D9C7916.5030907@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Rob Landley:
> I'm reading through the fs/lockd code, and I read grace.c and svcshare.c
> and code such as nlmsvc_share_file() only seems to get called from
> nlmsvc_proc_share() (and its cut-and-paste twin nlm4svc_proc_share())...
> 
> And as far as I can grep, those last two functions are never called from
> anywhere in the kernel source.
> 
> The comments say this is for "DOS shares", which presumably doesn't mean
> what I think it means because DOS used netbios, not NFS...
> 
> What's this code for, and where does it get used?  Is it something out
> of tree, or some header #define that's glued##together that I'm not
> picking up via grep...?

  Maybe you can get some info from the following code at fs/lockd/svc4proc.c:

 462 
 463 #define PROC(name, xargt, xrest, argt, rest, respsize)  \
 464  { .pc_func     = (svc_procfunc) nlm4svc_proc_##name,   \
 465    .pc_decode   = (kxdrproc_t) nlm4svc_decode_##xargt,  \
 466    .pc_encode   = (kxdrproc_t) nlm4svc_encode_##xrest,  \
 467    .pc_release  = NULL,                                 \
 468    .pc_argsize  = sizeof(struct nlm_##argt),            \
 469    .pc_ressize  = sizeof(struct nlm_##rest),            \
 470    .pc_xdrressize = respsize,                           \
 471  }
 472 #define Ck      (1+XDR_QUADLEN(NLM_MAXCOOKIELEN))       /* cookie */
 473 #define No      (1+1024/4)                              /* netobj */
 474 #define St      1                                       /* status */
 475 #define Rg      4                                       /* range (offset + length) */
 476 struct svc_procedure            nlmsvc_procedures4[] = {
 477   PROC(null,            void,           void,           void,   void, 1),
     .. ... 
 497   PROC(none,            void,           void,           void,   void, 0),
 498   PROC(share,           shareargs,      shareres,       args,   res, Ck+St+1),
 499   PROC(unshare,         shareargs,      shareres,       args,   res, Ck+St+1),
 500   PROC(nm_lock,         lockargs,       res,            args,   res, Ck+St),
 501   PROC(free_all,        notify,         void,           args,   void, 1),
 502 
 503 };

-- 
----
thanks
Mi Jinlong

