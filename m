From: Nils Goroll <slink-fLMQ21Bj+IYb1SvskN2V4Q@public.gmane.org>
Subject: Re: nfs4 locks: What happens when a lease can't get renewed?
Date: Thu, 17 Jun 2010 12:08:56 +0200
Message-ID: <4C19F438.6060800@schokola.de>
References: <4C12A779.6010005@schokola.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mcs.de ([212.1.60.21]:56809 "EHLO smtp.mcs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065Ab0FQKI7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 06:08:59 -0400
Received: from p5dd5112e.dip0.t-ipconnect.de ([93.213.17.46]:39440 helo=[192.168.77.36])
	by smtp.mcs.de with esmtpa (Exim 4.71)
	(envelope-from <slink-fLMQ21Bj+IYb1SvskN2V4Q@public.gmane.org>)
	id 1OPC1p-0005Ze-CQ
	for linux-nfs@vger.kernel.org; Thu, 17 Jun 2010 12:08:57 +0200
In-Reply-To: <4C12A779.6010005-fLMQ21Bj+IYb1SvskN2V4Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am reposting my question because I feel it is quite substantial. IMHO, some
mechanism to ensure data integrity is needed for "lost locks".

On 06/11/10 11:15 PM, Nils Goroll wrote:
> Hi,
> 
> I wonder what happens if a lock on nfs4 has been acquired by an application (for
> instance, using fcntl(fd, F_SETLK, F_WRLCK)) and the lock can't be RENEWed, for
> instance due to a network outage preventing communication between the client and
> the server.
> 
> I would have thought that some notification mechanism was useful, for instance
> my means of delivery of a signal as set using F_SETOWN / F_SETSIG for leases.
> 
> I would highly appreciate helpful pointers should this question have already
> been discussed of if there exists any other helpful documentation on it.
> 
> Thank you,
> 
> Nils
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
