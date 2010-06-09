From: RaSca <rasca-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org>
Subject: Re: Problem using exportfs in an active-active nfs cluster
Date: Wed, 09 Jun 2010 09:43:48 +0200
Message-ID: <4C0F4634.8090102@miamammausalinux.org>
References: <4C0E6ED0.60200@miamammausalinux.org> <20100609075425.7ec4ccd9@notabene.brown>
Reply-To: rasca-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from crash-1.cutaway.it ([89.186.66.80]:58414 "EHLO mail.cutaway.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755777Ab0FIHnw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 03:43:52 -0400
In-Reply-To: <20100609075425.7ec4ccd9-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Il giorno Mar 08 Giu 2010 23:54:25 CET, Neil Brown ha scritto:
[...]
> Try
>    exportfs -f

Already tried, it didn't work. The file system is still locked by nfsd.

--=20
RaSca
Mia Mamma Usa Linux: Niente =E8 impossibile da capire, se lo spieghi be=
ne!
rasca-9B074fXSGsOr88ip1nKoZ2D2FQJk+8+b@public.gmane.org
http://www.miamammausalinux.org
