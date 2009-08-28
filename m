From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] svcgss: reply AUTH_BADCRED to RPCSEC_GSS with unkown
	services
Date: Fri, 28 Aug 2009 12:11:04 -0400
Message-ID: <20090828161104.GC682@fieldses.org>
References: <4A77FF18.4040804@cn.fujitsu.com> <20090825214002.GD32708@fieldses.org> <4A94831F.8060508@cn.fujitsu.com> <20090826205705.GA22723@fieldses.org> <4A95EE2B.60108@cn.fujitsu.com> <20090827162623.GD7055@fieldses.org> <20090827210530.GC11721@fieldses.org> <4A972A98.2030406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org, iisaman@citi.umich.edu
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47350 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750961AbZH1QLG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Aug 2009 12:11:06 -0400
In-Reply-To: <4A972A98.2030406@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 28, 2009 at 08:53:44AM +0800, Wei Yongjun wrote:
> When I test, I just fixed the GSS8 with this patch:
> 
> diff --git a/lib/nfs4/servertests/st_gss.py b/lib/nfs4/servertests/st_gss.py
> index 6ad3e3e..dfff598 100644
> --- a/lib/nfs4/servertests/st_gss.py
> +++ b/lib/nfs4/servertests/st_gss.py
> @@ -330,4 +330,5 @@ def testBadService(t, env):
>                         "should return AUTH_BADCRED, instead got %s" %
>                         (service, e))
>      finally:
> +        orig.gss_seq_num = c.security.gss_seq_num
>          c.security = orig

It might make sense just to apply something like this to upstream pynfs.

The choice of whether to increment the sequence id here isn't obvious,
but I actually think the server's more likely to be right (the rfc says
to increment when the checksum is succesfully verified, which it was in
this case.  At that point we know the contents of the header are what
the client intended.)

--b.

> 
> 
> I am not have a test of all the case with --security=krb5, just test
> the gss. This is because the krb server does not always works well.^_^
> 
> 
> > (This is the problem with spending a lot of time on pynfs tests.
> > They've been useful for catching regressions, but there's a risk of
> > spending too much time tracking down "problems" that won't actually show
> > up in real situations.  Time would usually be better spent on bugs
> > (and/or performance problems) found in actual use.)
> >   
> 
> 
