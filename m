Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp04.online.nl ([194.134.41.34]:57976 "EHLO smtp04.online.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919Ab1CRFoA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Mar 2011 01:44:00 -0400
Subject: Re: rpc.svcgssd problem after updating client 1.2.2->1.2.3
From: Vladimir Elisseev <vovan@vovan.nl>
To: Kevin Coffman <kwc@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTim6nptBM40b5Zt2fhr7aiQ47kqX+_RBprnCokRD@mail.gmail.com>
References: <1300387690.2684.23.camel@vovan.net.home>
	 <AANLkTim6nptBM40b5Zt2fhr7aiQ47kqX+_RBprnCokRD@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Mar 2011 06:43:56 +0100
Message-ID: <1300427036.30472.11.camel@vovan.net.home>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Kevin,

I think the kernel configuration on server include AES encryption:
zcat /proc/config.gz| grep -i aes 
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
IMO, this is sufficient. As for the kerberos version on the client it's
1.9 with patches: CVE-2010-4022, CVE-2011-0281,0282,0283,0284.
Changing server's krb5.conf with default_tgs_enctypes = des-cbc-crc
doesn't solve this problem.
As you suggested I'm going to check patches regarding "acceptor subkey".

Regards,
Vladimir.

On Thu, 2011-03-17 at 18:13 -0400, Kevin Coffman wrote:
> On Thu, Mar 17, 2011 at 2:48 PM, Vladimir Elisseev <vovan@vovan.nl> wrote:
> > Hello,
> >
> > I've got a problem after updating NFS client. I've been trying to find
> > possible solution without a success for a while, so I'd appreciate any
> > help. All the info is below. Client has kernel 2.6.37 and server 2.6.36.
> >
> > Regards,
> > Vladimir.
> >
> > On the server side the error is "rpc.svcgssd[15159]: qword_eol: fflush
> > failed: errno 22 (Invalid argument)", the full track is below:
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: leaving poll
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: handling null request
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: sname = host/x.x.x@X.X
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids: calling
> > umich_ldap->princ_to_ids
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: ldap_init_and_bind: version
> > mismatch between API information and protocol version. Setting protocol
> > version to 3
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids:
> > umich_ldap->princ_to_ids returned -2
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids: calling
> > nsswitch->princ_to_ids
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nss_getpwnam: name
> > 'host/x.x.x@X.X' domain '(null)': resulting localname
> > 'host/user.net.home'
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids:
> > nsswitch->princ_to_ids returned -2
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids: final
> > return value is -2
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: DEBUG: serialize_krb5_ctx:
> > lucid version!
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: prepare_krb5_rfc4121_buffer:
> > protocol 1
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: prepare_krb5_rfc4121_buffer:
> > serializing key with enctype 18 and size 32
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: doing downcall
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: mech: krb5, hndl len: 4, ctx
> > len 52, timeout: 1300464362 (86399 from now), clnt: host@x.x.x, uid: -1,
> > gid: -1, num aux grps: 0:
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: qword_eol: fflush failed: errno
> > 22 (Invalid argument)
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: WARNING: error writing to
> > downcall channel /proc/net/rpc/auth.rpcsec.context/channel: Invalid
> > argument
> 
> I've seen this when the negotiated enctype is AES (18), and the kernel
> does not have AES support.  However, 2.6.36 should have AES support.
> Did the client update include a Kerberos version update as well?  (See
> recently submitted patches regarding "acceptor subkey".)
> 
> The immediate work-around for the acceptor subkey problem is to set
> 
>   default_tgs_enctypes = des-cbc-crc
> 
> in the server's /etc/krb5.conf file.  Could you try this and see if it helps?
> 
> K.C.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

