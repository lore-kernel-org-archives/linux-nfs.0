From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: fs/nfs_common/Makefile: fix the C file name
Date: Mon, 27 Oct 2008 15:01:53 -0400
Message-ID: <1225134113.14242.28.camel@heimdal.trondhjem.org>
References: <20081027170737.GA1027@hack.voiplan.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:34272 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464AbYJ0TB6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Oct 2008 15:01:58 -0400
In-Reply-To: <20081027170737.GA1027-Tc2f1T0IvFNdsri2l9pqgg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-10-27 at 17:07 +0000, Am=C3=A9rico Wang wrote:
> There's no file named 'nfs_acl.c' in that directory, it is 'nfsacl.c'=
=2E
>=20
> Signed-off-by: WANG Cong <wangcong-va7F5g4oNmbYtjvyW6yDsg@public.gmane.org>
> Cc: J. Bruce Fields <bfields@fieldses.org>
>=20
> ---
> diff --git a/fs/nfs_common/Makefile b/fs/nfs_common/Makefile
> index f689ed8..5cb60c5 100644
> --- a/fs/nfs_common/Makefile
> +++ b/fs/nfs_common/Makefile
> @@ -2,6 +2,6 @@
>  # Makefile for Linux filesystem routines that are shared by client a=
nd server.
>  #
> =20
> -obj-$(CONFIG_NFS_ACL_SUPPORT) +=3D nfs_acl.o
> +obj-$(CONFIG_NFS_ACL_SUPPORT) +=3D nfsacl.o
> =20
>  nfs_acl-objs :=3D nfsacl.o

NAK. The existing line is correct because the _module_ is called
nfs_acl.ko.

  Trond

