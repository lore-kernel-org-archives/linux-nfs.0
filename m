From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [NFS] nfs2/3 ESTALE bug on mount point (v2.6.24-rc8)
Date: Mon, 28 Jan 2008 10:35:14 -0500
Message-ID: <4d569c330801280735r73f24cadn95c1b8f6c863f8a1@mail.gmail.com>
References: <20080122164111.GA24697@fieldses.org>
	 <200801280437.m0S4bxcE001453@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, linux-nfs@vger.kernel.org,
	Trond.Myklebust@netapp.com
To: "Erez Zadok" <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.190]:25468 "EHLO
	rn-out-0102.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751444AbYA1PfR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 10:35:17 -0500
Received: by rn-out-0102.google.com with SMTP id i24so322649rng.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2008 07:35:15 -0800 (PST)
In-Reply-To: <200801280437.m0S4bxcE001453-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 27, 2008 11:37 PM, Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org> wrote:
>
> I tried to bisect nfs-utils but it didn't work.  First, the latest version
> of nfs-utils didn't configure for me.  It complained
>
>         Unable to locate information required to use librpcsecgss.  If you
>       have pkgconfig installed, you might try setting environment variable
>       PKG_CONFIG_PATH to /usr/local/lib/pkgconfig
>
> The above appears to be an error if you don't have librpcsecgss API >=
> 0.10.  But mine, on FC7. is 0.11.  (I'm using a vanilla FC7.)

Argh.  The dependencies changed recently because libgssapi was renamed
to libgssglue to avoid a conflict with other libraries with the same
name.  librpcsecgss has a dependency on libgssapi/libgssglue.

> So I ran configure --disable-gss and was finally able to build the utils.
> But then, I was having mount.nfs hanging often; stracing it revealed that
> mount(2) was getting EACESS as if the dir wasn't exported (but exportfs said
> it was).  I don't know if disabling gss at configure time could have
> resulted in these hangs.

I see you aren't using Kerberos mounts, so gssd shouldn't be involved or needed.

> I continued and tried a few more intermediate versions in the bisection, and
> several of them failed to compile and/or configure and/or autogen.sh.

Yes, there were other dependency changes that might cause problems.  I
know of at least one other problem that causes git bisect to fail.

I'm sorry for my part in the git bisection problem.

Short of narrowing it down to a particular commit, perhaps you can
narrow it down to a released version of nfs-utils?  (Assuming it might
be nfs-utils related.)

K.C.
