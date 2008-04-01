From: Quentin Godfroy <godfroy-7pss2ddYZfWsyDt4atOG6g@public.gmane.org>
Subject: Re: NFS3+KRB5 question
Date: Wed, 2 Apr 2008 00:58:45 +0200
Message-ID: <20080401225844.GB985@goelette.ens.fr>
References: <35b652ed9c3ac37ca9dc102b1bb65a83@localhost> <20080401123643.GA18475@goelette.ens.fr> <20080401205629.GC21343@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nef2.ens.fr ([129.199.96.40]:3361 "EHLO nef2.ens.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923AbYDAW7F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Apr 2008 18:59:05 -0400
In-Reply-To: <20080401205629.GC21343@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 01, 2008 at 04:56:29PM -0400, J. Bruce Fields wrote:
> > AFAICS I experience the same behavior[#]. Wile mounting a fs with
> > sec=krb5i:krb5p,rw,sec=sys,ro works, disabling the sec=sys option returns an
> > EACCES to the mount syscall (for binary mount as well as text based mount).
> > And of course the rest is working correctly, I indeed have write enabled if
> > with krb5i.
> > 
> > Looks like the client does a FSINFO call with AUTH_UNIX credentials instead
> > of using machine credentials, which is rejected by the server.
> 
> The client here is within its rights, and the server is wrong; see:
> 
> 	http://www.ietf.org/rfc/rfc2623.txt
> 
> (especially 2.3.2, "NFS Procedures Used at Mount Time").  The kernel
> changes on the server side should not be too difficult after the export
> changes we made a few versions ago.

The server is indeed wrong to reject the fsinfo call with only AUTH_SYS
credentials (and the rfc does not mandate it to accept it as far as i can
see), but the client could wait a session for machine credentials before
doing the call, since administrative credentials are available.
