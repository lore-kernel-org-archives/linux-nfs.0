From: Nicolas Williams <Nicolas.Williams-xsfywfwIY+M@public.gmane.org>
Subject: Re: [nfs-discuss] mount.nfs: access denied by server
Date: Tue, 25 Aug 2009 18:37:58 -0500
Message-ID: <20090825233758.GZ1033@Sun.COM>
References: <1251133618.6325.262.camel@heimdal.trondhjem.org> <20090824174129.GD4985@fieldses.org> <1EEDD90B-709F-4C78-97B4-6107AE100162@oracle.com> <4A94162C.20904@sun.com> <1251219492.25372.3.camel@heimdal.trondhjem.org> <4A942ACF.4030502@sun.com> <1251225543.25372.22.camel@heimdal.trondhjem.org> <1251225797.25372.25.camel@heimdal.trondhjem.org> <4A9462E4.5020404@sun.com> <1251242416.5403.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Haynes <Thomas.Haynes-xsfywfwIY+M@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	nfs-discuss-xZgeD5Kw2fzokhkdeNNY6A@public.gmane.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brmea-mail-1.Sun.COM ([192.18.98.31]:46996 "EHLO
	brmea-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820AbZHZAZ7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 20:25:59 -0400
Received: from dm-central-01.central.sun.com ([129.147.62.4])
	by brmea-mail-1.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n7Q03mLb008588
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2009 00:03:48 GMT
Received: from binky.Central.Sun.COM (binky.Central.Sun.COM [129.153.128.104])
	by dm-central-01.central.sun.com (8.13.8+Sun/8.13.8/ENSMAIL,v2.2) with ESMTP id n7Q03m0b024817
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2009 18:03:48 -0600 (MDT)
In-Reply-To: <1251242416.5403.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 25, 2009 at 07:20:16PM -0400, Trond Myklebust wrote:
> I was thinking of the case in which /foo/bar is not actually a mount
> point. :-)

Looking at code we have

    nfs4_secinfo_recov() ->
       nfs4_secinfo_vnode() ->
          nfs4_secinfo_fh_otw() ->
	     secinfo_update()

And as you can see nfs4_secinfo_vnode() calls nfs4_secinfo_fh_otw() to
get the SECINFO for the affected FH, but, nfs4_secinfo_fh_otw() updates
the mount's server info.

Which means that WRONGSEC -> SECINFO -> updates the entire mount's sec.

I.e., if you have:

 - server:/foo w/ sec=krb5
 - server:/foo/bar in the _same_ filesystem (i.e., with same fsid) and
   sec=krb5i

the client will probably thrash if you mount server:/foo because each
WRONGSEC from accessing server:/foo/baz will cause the client to update
the entire mount, which will lead to WRONGSEC from accessing
server:/foo/bar, which will lead to WRONGSEC from accessing
server:/foo/baz, which ...

> If we all agree that the server can only remove security flavours when
> crossing a mount point, then all is well, however the protocol doesn't
> strictly speaking say that has to be the case.

I agree, that sounds like a very good rule for now.

One could also argue that clients should handle this on a per-directory
basis, not per-mount.  But first we'd have to agree that it's a good
idea to have nested "shares" in the same filesystem.

> That worries me...

Me too.

Nico
-- 
