Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f46.google.com ([209.85.210.46]:61632 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232Ab2I1AVR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Sep 2012 20:21:17 -0400
Received: by dady13 with SMTP id y13so515951dad.19
        for <linux-nfs@vger.kernel.org>; Thu, 27 Sep 2012 17:21:17 -0700 (PDT)
Date: Thu, 27 Sep 2012 17:21:13 -0700
From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Richard Ems <richard.ems@cape-horn-eng.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Re: [PATCH] NFS: Fix Oopses in nfs_lookup_revalidate and
 nfs4_lookup_revalidate
Message-ID: <20120928002113.GN29949@kroah.com>
References: <503361AF.8030707@cape-horn-eng.com>
 <5059A9F0.2070409@cape-horn-eng.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FD7706@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FD7706@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 19, 2012 at 01:16:41PM +0000, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of Richard Ems
> > Sent: Wednesday, September 19, 2012 7:18 AM
> > To: Myklebust, Trond
> > Cc: linux-nfs@vger.kernel.org; linux-kernel@vger.kernel.org;
> > gregkh@linuxfoundation.org
> > Subject: Fwd: Re: [PATCH] NFS: Fix Oopses in nfs_lookup_revalidate and
> > nfs4_lookup_revalidate
> > 
> > Hi all,
> > 
> > I still don't see this patch in the 3.5.x series.
> > Will it make it into 3.5.5?
> > 
> > Thanks,
> > Richard
>  
> Hi Greg,
> 
> I believe you said that you would take this patch. Do you want me to resend?

I have it now, thanks, am finally catching up on stable patches...

greg k-h
