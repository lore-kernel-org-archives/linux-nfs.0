From: Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>
Subject: Re: RE: .Xauthority going stale (but not really)
Date: Tue, 19 Aug 2008 18:18:48 +0200 (CEST)
Message-ID: <alpine.DEB.1.99.0808191817280.32254@wbuna.brgvxre.pu>
References: <D9EB0C553F14B441BE4F2CA9EB4D45C24EAE7A@ECQCMTLMAIL2.quebec.int.ec.gc.ca> <alpine.DEB.1.99.0808191627460.5165@sebohet.brgvxre.pu> <D9EB0C553F14B441BE4F2CA9EB4D45C24EAE7D@ECQCMTLMAIL2.quebec.int.ec.gc.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "Fortier,Vincent [Montreal]" <Vincent.Fortier1-TdIlj1wg2M0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from james.oetiker.ch ([213.144.138.195]:46245 "EHLO
	james.oetiker.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbYHSQla (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 12:41:30 -0400
In-Reply-To: <D9EB0C553F14B441BE4F2CA9EB4D45C24EAE7D-1UPTX0Drp4spmvbiPTN+wSkwhI19GS2W5jPdWwX6g8k@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Vincent,

Today Fortier,Vincent [Montreal] wrote:

> It has to be client-side... I have not seen this with any
> previous kernels on the client-side (either old redhat 7.3 with
> 2.4.20 kernels or Debian Sarge with 2.6.8 to 2.6.23.17).  Also my
> server side is unchanged with a RHEL 4 (2.6.9 based kernel).
>
> This is a totally new behaviour to me wich only occured with
> installation of 64bit 2.6.24 kernel based debian etch clients
> (have not yet tried 32bit to confirm wether it is 2.6.24 OR amd64
> based).  Although I cannot reproduce it with a 2.6.23.17 32-bit.
>
> If the problem reside with 2.6.24 kernel (and not 64bit specific)
> it should be "easy" to git bisect where it comes from (although
> did not catch the details of git bisect just yet :)

Well can you reproduce the problem 'on demand' ? We have not yet
found a pattern.

cheers
tobi

-- 
Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten, Switzerland
http://it.oetiker.ch tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org ++41 62 775 9902 / sb: -9900
