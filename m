From: Leandro Lucarella <llucax@gmail.com>
Subject: Re: 2.6.29+ NFS-Server Problem "reconnect_path: npd != pd"
Date: Sat, 27 Jun 2009 16:39:27 -0300
Message-ID: <20090627193927.GB25375@homero.springfield.home>
References: <20090521142026.GA5566@geggus.net> <20090528202803.GF13860@fieldses.org> <20090528203228.GA6056@geggus.net> <200906191414.02674.mathias@blx4.net> <20090619124611.GA16337@geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathias Kretschmer <mathias-ZcF2+9dVbKo@public.gmane.org>,
	"J\. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [200.117.86.35] ([200.117.86.35]:38918 "EHLO
	burns.springfield.home" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751257AbZF0UC4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Jun 2009 16:02:56 -0400
In-Reply-To: <20090619124611.GA16337-6gBBswh35yKsTnJN9+BGXg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sven Geggus, el 19 de junio a las 14:46 me escribiste:
> Mathias Kretschmer schrieb am Freitag, den 19. Juni um 14:14 Uhr:
> 
> > For a while my server has been running fine after the upgrade to 2.6.30.
> > My NFS/diskless desktop worked just fine. Then yesterday evening suddenly the 
> > first "reconnect_path: npd != pd" messages popped up.  Sometime during the 
> > night the frequency of those messages showing up increased to > 100 msgs/sec 
> > in average.
> 
> More or less the same here. My client machine (2.6.30) however worked just
> for a few hours. It does however work fine using the older Kernel (2.6.27.x)
> on the Server.
> 
> This is also XFS+NFS here. I will also attach the associated .config of the
> Kernel.

Hi, I want to confirm that I'm still having this problem in 2.6.30. I'm
using Debian (unstable) too, and the exported fs is XFS.

Here is a related bug report:
http://bugzilla.kernel.org/show_bug.cgi?id=13375

-- 
Leandro Lucarella (luca) | Blog colectivo: http://www.mazziblog.com.ar/blog/
----------------------------------------------------------------------------
GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
