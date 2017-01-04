Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36206 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753610AbdADTsq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 14:48:46 -0500
Date: Wed, 4 Jan 2017 14:48:44 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Dave Jones <davej@codemonkey.org.uk>,
        Steve Dickson <SteveD@redhat.com>, jlayton@poochiereds.net,
        Linux Kernel <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com
Subject: Re: NFS: SECINFO: security flavor 390003 is not supported
Message-ID: <20170104194843.GD29539@parsley.fieldses.org>
References: <20170104190327.v3wbpcbqtfa5jy7d@codemonkey.org.uk>
 <0ad14385-401a-9ec7-9b0e-711da9fe1f59@RedHat.com>
 <20170104192901.oi6cygib32eteqpy@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170104192901.oi6cygib32eteqpy@codemonkey.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 04, 2017 at 02:29:01PM -0500, Dave Jones wrote:
> On Wed, Jan 04, 2017 at 02:23:58PM -0500, Steve Dickson wrote:
>  > 
>  > 
>  > On 01/04/2017 02:03 PM, Dave Jones wrote:
>  > > Since upgrading to 4.10-rc2, my nfs server has started printing these..
>  > > 
>  > > [  161.668635] NFS: SECINFO: security flavor 390003 is not supported
>  > > [  161.668655] NFS: SECINFO: security flavor 390004 is not supported
>  > > [  161.668670] NFS: SECINFO: security flavor 390005 is not supported
>  > > 
>  > > Client is debian's 4.8 kernel with default mount options, so sec=sys
>  > > 
>  > > What should I be doing to suppress these ? What causes them ?
>  > The auth_rpcgss or rpcsec_gss_krb5 kernel modules not being loaded??
> 
> I don't use kerberos, and CONFIG_SUNRPC_GSS=y

Hm, looks like that warning's from 676e4ebd5f2c "NFSD: SECINFO doesn't
handle unsupported pseudoflavors correctly", which went into 3.10-rc1.

So mountd is probably telling us that krb5/krb5i/krb5p are permitted on
some exports, though your kernel doesn't think it supports those for
some reason.

The exports are probably the v4 pseudoroot exports (I don't think normal
exports get the krb5 flavors unless you explicitly ask for them).  So
this is partly also the fault of nfs-utils 4a1ad4aa3028 "mountd: Enable
all auth flavors on pseudofs exports".

I don't know why your kernel doesn't think it supports those....  Is it
possible to have have CONFIG_SUNRPC_GSS set and not
CONFIG_RPCSEC_GSS_KRB5?

Maybe simplest is just demote that printk to a debugging thing.  It was
intended to help debug the case when somebody tries to, say, add
sec=krb5 exports but doesn't get the kernel configuration right, but
with mountd passing everything down in some cases it's not so helpful.

--b.

> 
> 	Dave
> 
