Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33806 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753017Ab2ISNQn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Sep 2012 09:16:43 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Richard Ems <richard.ems@cape-horn-eng.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: RE: Re: [PATCH] NFS: Fix Oopses in nfs_lookup_revalidate and
 nfs4_lookup_revalidate
Date: Wed, 19 Sep 2012 13:16:41 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908FD7706@SACEXCMBX04-PRD.hq.netapp.com>
References: <503361AF.8030707@cape-horn-eng.com>
 <5059A9F0.2070409@cape-horn-eng.com>
In-Reply-To: <5059A9F0.2070409@cape-horn-eng.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Richard Ems
> Sent: Wednesday, September 19, 2012 7:18 AM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org; linux-kernel@vger.kernel.org;
> gregkh@linuxfoundation.org
> Subject: Fwd: Re: [PATCH] NFS: Fix Oopses in nfs_lookup_revalidate and
> nfs4_lookup_revalidate
> 
> Hi all,
> 
> I still don't see this patch in the 3.5.x series.
> Will it make it into 3.5.5?
> 
> Thanks,
> Richard
 
Hi Greg,

I believe you said that you would take this patch. Do you want me to resend?

Cheers,
   Trond
 
> -------- Original Message --------
> Subject: Re: [PATCH] NFS: Fix Oopses in nfs_lookup_revalidate and
> nfs4_lookup_revalidate
> Date: Tue, 21 Aug 2012 12:23:43 +0200
> From: Richard Ems <richard.ems@cape-horn-eng.com>
> To: Trond Myklebust <Trond.Myklebust@netapp.com>
> CC: linux-nfs@vger.kernel.org
> 
> On 08/15/2012 10:49 PM, Trond Myklebust wrote:
> > This Oops affects 3.5 kernels and older, and is due to
> > lookup_one_len() calling down to the dentry revalidation code with a
> > NULL pointer to struct nameidata.
> >
> > It is fixed upstream by commit 0b728e1911c (stop passing nameidata *
> > to ->d_revalidate())
> >
> > Reported-by: Richard Ems <richard.ems@cape-horn-eng.com>
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> 
> Hi Trond,
> 
> I don't see this patch going into 3.5.3 at
> http://www.kernel.org/pub/linux/kernel/v3.0/stable-review/patch-3.5.3-
> rc1.gz
> .
> Shouldn't it be included in 3.5.3 ?
> 
> Thanks,
> Richard
> 
> 
> --
> Richard Ems       mail: Richard.Ems@Cape-Horn-Eng.com
> 
> Cape Horn Engineering S.L.
> C/ Dr. J.J. Dómine 1, 5º piso
> 46011 Valencia
> Tel : +34 96 3242923 / Fax 924
> http://www.cape-horn-eng.com
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
