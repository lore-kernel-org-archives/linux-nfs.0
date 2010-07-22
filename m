From: Nikola Ciprich <extmaillist-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org>
Subject: Re: 2.6.32.16 - NFS still having trouble (nfsd: peername failed (err
 107)!)
Date: Thu, 22 Jul 2010 13:03:42 +0200
Message-ID: <20100722110342.GA30078@develbox.linuxbox.cz>
References: <20100714110020.GB10153@develbox.linuxbox.cz>
 <20100720202353.GA11367@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux NFS list <linux-nfs@vger.kernel.org>,
	nikola.ciprich-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org, mzik-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:36994 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759211Ab0GVLCP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 07:02:15 -0400
In-Reply-To: <20100720202353.GA11367@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 20, 2010 at 04:23:53PM -0400, J. Bruce Fields wrote:
> Sorry, I'm missing some history: was NFS doing OK in some previous
> kernel version, or has this always been a problem?
well,
I was having this kind of rouble for a long time with 2.6.32, but latest
stable versions were quite OK. but 2.6.32.16 seem to be worse again :(

> Hangs appear to be in ext4, and my first impulse would be to blame
> dm-crypt and/or ext4; have you asked them?
not Yet, but I'll try.
thanks a lot
BR
nik



> 
> --b.
> 
> > 
> > Thanks a lot in advance...
> > 
> > with best regards
> > 
> > nikola ciprich
> > 
> > 
> > -- 
> > -------------------------------------
> > Ing. Nikola CIPRICH
> > LinuxBox.cz, s.r.o.
> > 28. rijna 168, 709 01 Ostrava
> > 
> > tel.:   +420 596 603 142
> > fax:    +420 596 621 273
> > mobil:  +420 777 093 799
> > www.linuxbox.cz
> > 
> > mobil servis: +420 737 238 656
> > email servis: servis-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org
> > -------------------------------------
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28. rijna 168, 709 01 Ostrava

tel.:   +420 596 603 142
fax:    +420 596 621 273
mobil:  +420 777 093 799
www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org
-------------------------------------
