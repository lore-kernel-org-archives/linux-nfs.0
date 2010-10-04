From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: hang on existing systems when exporting NFS share to new
 systems
Date: Mon, 4 Oct 2010 11:52:19 -0400
Message-ID: <20101004155219.GB17380@fieldses.org>
References: <4C503450.1010609@cse.yorku.ca>
 <20100728174241.GB19362@fieldses.org>
 <4C53855F.5060201@cse.yorku.ca>
 <20101003211322.GC15339@fieldses.org>
 <4CA9D4BC.1060201@cse.yorku.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jason Keltz <jas-Au2wK/vbkGRbjDw2KniTvg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58178 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756374Ab0JDPwn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Oct 2010 11:52:43 -0400
In-Reply-To: <4CA9D4BC.1060201-Au2wK/vbkGRbjDw2KniTvg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 04, 2010 at 09:21:00AM -0400, Jason Keltz wrote:
> Actually, since I was sharing out over a private network, I did not
> need to include every address in the list, and was able to use an IP
> range. Now, I share out to pretty much the same host list, but
> export is instantaneous.  I still believe that I *should* have been
> able to export to the large number of hosts without the tremendous
> delay, but I was not able to solve the problem with my current
> (RHEL4) installation.  We will upgrade to RHEL6 when it's available,
> so I might try again with that just for fun.

OK, thanks--let us know of any results you get, positive or negative.

--b.
