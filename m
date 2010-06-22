Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:32917 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755953Ab0FVMuZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jun 2010 08:50:25 -0400
Subject: Re: atime couldn't be set on a Linux NFSv4 client machine
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: =?UTF-8?Q?=E5=B0=8F=E5=80=89=E4=B8=80=E5=A4=AB?=
	<ka-ogura@bd6.so-net.ne.jp>
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
In-Reply-To: <44BE948077174909AABF995F03389198@034730a2df3c489>
References: <44BE948077174909AABF995F03389198@034730a2df3c489>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Jun 2010 08:50:17 -0400
Message-ID: <1277211017.3204.15.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-06-22 at 20:18 +0900, 小倉一夫 wrote:
> Hi, all...
> 
> I'm using a Linux NFSv4 client and I've recently noticed that the atime of
> an NFS file couldn't be set explicitly on my NFSv4 client machine.
> 
> So I looked into the Linux kernel code to find the reason.
> Now I believe that the following code is a bug inherited from older NFSv4
> kernel releases.
> 
> fs/nfs/nfs4xdr.c
> 
> static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
> const struct nfs_server *server) {
>         :
>         if (iap->ia_valid & ATTR_ATIME_SET) {
>                 bmval |= FATTR_WORD1_TIME_ACCESS_SET;
>                 *p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
>                 *p++ = cpu_to_be32(0);
>                 *p++ = cpu_to_be32(iap->ia_mtime.tv_sec);
>                 *p++ = cpu_to_be32(iap->ia_mtime.tv_usec);
> 
> Are they really ia_mtime?

Whoops! That's an embarassing typo. All the more so, since you are
correct in that this probably dates back to the very early 2.6.x kernel
series.

Thanks for noticing this!

Cheers
  Trond

