From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Possible NFS Bug | Kernel 2.6.26-rc8
Date: Sun, 29 Jun 2008 12:54:09 -0400
Message-ID: <1214758449.7557.18.camel@localhost>
References: <1214749048.14955.1.camel@stefan-ubuntu-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Stefan Mehnert <stefanmehnert@googlemail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:51543 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753592AbYF2QyN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Jun 2008 12:54:13 -0400
In-Reply-To: <1214749048.14955.1.camel@stefan-ubuntu-vm>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2008-06-29 at 16:17 +0200, Stefan Mehnert wrote:
> =EF=BB=BFHi,
>=20
> I've encountered the the problem a few times now that directory listi=
ng
> in my home folder hung. The problem occurs when I shut down my test
> web-server which provides an nfs share mounted into a folder in my ho=
me
> directory.
> When an application tries to get the directory listing of my home fol=
der
> it hangs until the server is online again. Umounting is not possible
> "device is busy...". The only way to get it fixed is to restart the
> system or bring the server back online.
> It's good that it's so fault tolerant and can restore the connection,
> but there should be a way to unmount the nfs share when the server is
> gone?

man 'umount': read all about the '-l' option.

Trond

