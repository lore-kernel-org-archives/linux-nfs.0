From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.32.16 - NFS still having trouble (nfsd: peername failed
 (err 107)!)
Date: Tue, 20 Jul 2010 16:23:53 -0400
Message-ID: <20100720202353.GA11367@fieldses.org>
References: <20100714110020.GB10153@develbox.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux NFS list <linux-nfs@vger.kernel.org>,
	nikola.ciprich-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org, mzik-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org
To: Nikola Ciprich <extmaillist-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50649 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932525Ab0GTUYg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 16:24:36 -0400
In-Reply-To: <20100714110020.GB10153-K8br+RTdgN68z6Q06MQEFCF40CQGThNF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 14, 2010 at 01:00:20PM +0200, Nikola Ciprich wrote:
> Hi,
> 
> I just updated one of my NFS boxes to 2.6.32.16, but NFS is still not in
> top condition.

Sorry, I'm missing some history: was NFS doing OK in some previous
kernel version, or has this always been a problem?

> Clients are hanging during copying, and following messages 
> are appearing in dmesg:
> 
...
> 
> machine is x86_64, what is certainly important to note is that
> NFS share sits on top of (large) dm-crypted ext4 volume.
> Could somebody please help me to track the source of problems?

Hangs appear to be in ext4, and my first impulse would be to blame
dm-crypt and/or ext4; have you asked them?

--b.

> 
> Thanks a lot in advance...
> 
> with best regards
> 
> nikola ciprich
> 
> 
> -- 
> -------------------------------------
> Ing. Nikola CIPRICH
> LinuxBox.cz, s.r.o.
> 28. rijna 168, 709 01 Ostrava
> 
> tel.:   +420 596 603 142
> fax:    +420 596 621 273
> mobil:  +420 777 093 799
> www.linuxbox.cz
> 
> mobil servis: +420 737 238 656
> email servis: servis-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org
> -------------------------------------
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
