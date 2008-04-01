From: Quentin Godfroy <godfroy-7pss2ddYZfWsyDt4atOG6g@public.gmane.org>
Subject: Re: NFS3+KRB5 question
Date: Tue, 1 Apr 2008 15:18:26 +0200
Message-ID: <20080401131826.GA19598@goelette.ens.fr>
References: <35b652ed9c3ac37ca9dc102b1bb65a83@localhost> <20080401123643.GA18475@goelette.ens.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nef2.ens.fr ([129.199.96.40]:2846 "EHLO nef2.ens.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753890AbYDANTy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Apr 2008 09:19:54 -0400
In-Reply-To: <20080401123643.GA18475-Gn1em/8t8udFYcqGaMRPHA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 01, 2008 at 02:36:44PM +0200, Quentin Godfroy wrote:
> AFAICS I experience the same behavior[#]. Wile mounting a fs with
> sec=krb5i:krb5p,rw,sec=sys,ro works, disabling the sec=sys option returns an
> EACCES to the mount syscall (for binary mount as well as text based mount).
> And of course the rest is working correctly, I indeed have write enabled if
> with krb5i.
> 
> Looks like the client does a FSINFO call with AUTH_UNIX credentials instead
> of using machine credentials, which is rejected by the server.

By the way, I would like to know why does this call is rejected at the NFS
layer with a NFS3ERR_ACCES instead of being rejected at the RPC layer with
AUTH_TOOWEAK in a rejected_reply struct ? I would expect more an
NFS3ERR_ACCES when the filehandle is outside an export (with
subtree_checking enabled) or when the client is not in the list of exported
filesystems. 

Maybe the answer is that the RPC layer has large parts of it which are
unadequate with current needs and that either the server does not answer at
all (and close the underlying connection) or returns accepted_reply structures
with SUCCESS and delegate error management to the upper level.
