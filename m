From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [nfs-discuss] mount.nfs: access denied by server
Date: Tue, 25 Aug 2009 20:21:45 -0400
Message-ID: <1251246105.5403.12.camel@heimdal.trondhjem.org>
References: <1251133618.6325.262.camel@heimdal.trondhjem.org>
	 <20090824174129.GD4985@fieldses.org>
	 <1EEDD90B-709F-4C78-97B4-6107AE100162@oracle.com> <4A94162C.20904@sun.com>
	 <1251219492.25372.3.camel@heimdal.trondhjem.org> <4A942ACF.4030502@sun.com>
	 <1251225543.25372.22.camel@heimdal.trondhjem.org>
	 <1251225797.25372.25.camel@heimdal.trondhjem.org>
	 <4A9462E4.5020404@sun.com> <1251242416.5403.3.camel@heimdal.trondhjem.org>
	 <20090825233758.GZ1033@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tom Haynes <Thomas.Haynes-xsfywfwIY+M@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	nfs-discuss-xZgeD5Kw2fzokhkdeNNY6A@public.gmane.org
To: Nicolas Williams <Nicolas.Williams-xsfywfwIY+M@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7039 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756546AbZHZAVp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 20:21:45 -0400
In-Reply-To: <20090825233758.GZ1033-UdXhSnd/wVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-25 at 18:37 -0500, Nicolas Williams wrote:
> On Tue, Aug 25, 2009 at 07:20:16PM -0400, Trond Myklebust wrote:
> > I was thinking of the case in which /foo/bar is not actually a mount
> > point. :-)
> 
> Looking at code we have
> 
>     nfs4_secinfo_recov() ->
>        nfs4_secinfo_vnode() ->
>           nfs4_secinfo_fh_otw() ->
> 	     secinfo_update()
> 
> And as you can see nfs4_secinfo_vnode() calls nfs4_secinfo_fh_otw() to
> get the SECINFO for the affected FH, but, nfs4_secinfo_fh_otw() updates
> the mount's server info.

Sorry. I didn't mean to force you into detailed explanations of the
code. As a NetApp employee, I'm not sure I'm licensed to even run
OpenSolaris at this point, let alone look at the code. :-)

> Which means that WRONGSEC -> SECINFO -> updates the entire mount's sec.
> 
> I.e., if you have:
> 
>  - server:/foo w/ sec=krb5
>  - server:/foo/bar in the _same_ filesystem (i.e., with same fsid) and
>    sec=krb5i
> 
> the client will probably thrash if you mount server:/foo because each
> WRONGSEC from accessing server:/foo/baz will cause the client to update
> the entire mount, which will lead to WRONGSEC from accessing
> server:/foo/bar, which will lead to WRONGSEC from accessing
> server:/foo/baz, which ...

OK. This is sort of what I expect we will do for Linux too.

> > If we all agree that the server can only remove security flavours when
> > crossing a mount point, then all is well, however the protocol doesn't
> > strictly speaking say that has to be the case.
> 
> I agree, that sounds like a very good rule for now.
> 
> One could also argue that clients should handle this on a per-directory
> basis, not per-mount.  But first we'd have to agree that it's a good
> idea to have nested "shares" in the same filesystem.

The protocol will even allow you to set the secinfo on a per-file basis.
That sounds insane to me, but...

Anyhow, I think our Linux client should go with the 'remove security
flavours only on mountpoints' rule for now, and then we'll see in time
if any users can justify a more fine grained implementation.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
