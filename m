From: "Fortier,Vincent [Montreal]" <Vincent.Fortier1-TdIlj1wg2M0@public.gmane.org>
Subject: RE: RE: .Xauthority going stale (but not really)
Date: Tue, 19 Aug 2008 12:44:10 -0400
Message-ID: <D9EB0C553F14B441BE4F2CA9EB4D45C24EAE7E@ECQCMTLMAIL2.quebec.int.ec.gc.ca>
References: <D9EB0C553F14B441BE4F2CA9EB4D45C24EAE7A@ECQCMTLMAIL2.quebec.int.ec.gc.ca> <alpine.DEB.1.99.0808191627460.5165@sebohet.brgvxre.pu> <D9EB0C553F14B441BE4F2CA9EB4D45C24EAE7D@ECQCMTLMAIL2.quebec.int.ec.gc.ca> <alpine.DEB.1.99.0808191817280.32254@wbuna.brgvxre.pu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "Tobias Oetiker" <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fwstl1-1.wul.qc.ec.gc.ca ([205.211.132.24]:20174 "EHLO
	ecqcmtlbh.quebec.int.ec.gc.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752194AbYHSQob convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Aug 2008 12:44:31 -0400
In-Reply-To: <alpine.DEB.1.99.0808191817280.32254-ZxOFkyelvri73kmZFr1Urg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Message d'origine-----
> De : Tobias Oetiker [mailto:tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org] 
> 
> Hi Vincent,
> 
> Today Fortier,Vincent [Montreal] wrote:
> 
> > It has to be client-side... I have not seen this with any previous 
> > kernels on the client-side (either old redhat 7.3 with 2.4.20
kernels 
> > or Debian Sarge with 2.6.8 to 2.6.23.17).  Also my server side is 
> > unchanged with a RHEL 4 (2.6.9 based kernel).
> >
> > This is a totally new behaviour to me wich only occured with 
> > installation of 64bit 2.6.24 kernel based debian etch clients (have 
> > not yet tried 32bit to confirm wether it is 2.6.24 OR amd64 based).

> > Although I cannot reproduce it with a 2.6.23.17 32-bit.
> >
> > If the problem reside with 2.6.24 kernel (and not 64bit specific) it

> > should be "easy" to git bisect where it comes from 
> > (although did not catch the details of git bisect just yet :)
> 
> Well can you reproduce the problem 'on demand' ? We have not 
> yet found a pattern.

Yes.  We have a common startup script that is being used on the
client-side.  This script is being called with a keyword and, based on a
configuration file, it generate on the fly an execution string to
fire-up a remote (although sometimes local) application with a bunch of
required parameters depending of the language or login user per example.
The execution string is based on multiple connexion protocols since not
all servers yet work with ssh (we still have a old crappy hpux 10.20 K
box and we never took the time to install openssh on it!).  Also, since
we have a pool of workstation that can be used for different purpose
some of them, depending of that daily usage, need to recieve popups from
different servers hence a few xhost +serverABC somehow became necessary.

To conclude, using thoses scripts I can generate a Stale NFS file handle
within 1 or 2 remote application launch.  Now I have found a way to get
rid of the lock by forcing a read or write on the file (usually a simple
cat $HOME/.Xauthority works).  To do so a conjunction of theses commands
seems to solve the problem:
chmod 600 $HOME/.Xauthority
cat $HOME/.Xauthority
xauth list 1>/dev/null

- vin
