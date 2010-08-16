Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:46260 "EHLO
	emergent.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752108Ab0HPSSY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Aug 2010 14:18:24 -0400
Date: Mon, 16 Aug 2010 14:17:51 -0400
From: Nick Bowler <nbowler@elliptictech.com>
To: Takashi Iwai <tiwai@suse.de>
Cc: Shaohua Li <shaohua.li@intel.com>, Trond.Myklebust@netapp.com, rjw@sisk.pl,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: nfs regression 2.6.35+
Message-ID: <20100816181751.GA2439@elliptictech.com>
References: <20100816070626.GA10503@sli10-desk.sh.intel.com>
 <s5h39uedg3b.wl%tiwai@suse.de>
 <s5hfwyelu28.wl%tiwai@suse.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <s5hfwyelu28.wl%tiwai@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-08-16 12:40 +0200, Takashi Iwai wrote:
> At Mon, 16 Aug 2010 12:09:12 +0200, Takashi Iwai wrote:
> > This hits me, too.  Reverting it cures the problem.
> > (BTW, the correct commit id of the affecting patch is
> >  af7fa16506bf9b6323e862a61e14c20555152bb3
> >  "NFS: Fix up the fsync code")
> > 
> > Reproduced on 2.6.36-rc1.
> > 
> > So, fsync() returns 1 wrongly.

Apparently this breaks NFS file locks as well:  

  fetchmail: starting fetchmail 6.3.17 daemon
  /home/nbowler/.fetchmail.pid: Bad file descriptor
  fetchmail: lock creation failed.

> How about a band-aid fix below?
[...]
> Subject: [PATCH] NFS: fix fsync return code

and this fixes all the problems for me.

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
