Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:34306 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754926Ab1CQWNo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2011 18:13:44 -0400
Received: by qwk3 with SMTP id 3so2434432qwk.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Mar 2011 15:13:43 -0700 (PDT)
In-Reply-To: <1300387690.2684.23.camel@vovan.net.home>
References: <1300387690.2684.23.camel@vovan.net.home>
Date: Thu, 17 Mar 2011 18:13:43 -0400
Message-ID: <AANLkTim6nptBM40b5Zt2fhr7aiQ47kqX+_RBprnCokRD@mail.gmail.com>
Subject: Re: rpc.svcgssd problem after updating client 1.2.2->1.2.3
From: Kevin Coffman <kwc@citi.umich.edu>
To: Vladimir Elisseev <vovan@vovan.nl>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 17, 2011 at 2:48 PM, Vladimir Elisseev <vovan@vovan.nl> wrote:
> Hello,
>
> I've got a problem after updating NFS client. I've been trying to find
> possible solution without a success for a while, so I'd appreciate any
> help. All the info is below. Client has kernel 2.6.37 and server 2.6.36.
>
> Regards,
> Vladimir.
>
> On the server side the error is "rpc.svcgssd[15159]: qword_eol: fflush
> failed: errno 22 (Invalid argument)", the full track is below:
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: leaving poll
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: handling null request
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: sname = host/x.x.x@X.X
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids: calling
> umich_ldap->princ_to_ids
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: ldap_init_and_bind: version
> mismatch between API information and protocol version. Setting protocol
> version to 3
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids:
> umich_ldap->princ_to_ids returned -2
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids: calling
> nsswitch->princ_to_ids
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nss_getpwnam: name
> 'host/x.x.x@X.X' domain '(null)': resulting localname
> 'host/user.net.home'
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids:
> nsswitch->princ_to_ids returned -2
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: nfs4_gss_princ_to_ids: final
> return value is -2
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: DEBUG: serialize_krb5_ctx:
> lucid version!
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: prepare_krb5_rfc4121_buffer:
> protocol 1
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: prepare_krb5_rfc4121_buffer:
> serializing key with enctype 18 and size 32
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: doing downcall
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: mech: krb5, hndl len: 4, ctx
> len 52, timeout: 1300464362 (86399 from now), clnt: host@x.x.x, uid: -1,
> gid: -1, num aux grps: 0:
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: qword_eol: fflush failed: errno
> 22 (Invalid argument)
> Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: WARNING: error writing to
> downcall channel /proc/net/rpc/auth.rpcsec.context/channel: Invalid
> argument

I've seen this when the negotiated enctype is AES (18), and the kernel
does not have AES support.  However, 2.6.36 should have AES support.
Did the client update include a Kerberos version update as well?  (See
recently submitted patches regarding "acceptor subkey".)

The immediate work-around for the acceptor subkey problem is to set

  default_tgs_enctypes = des-cbc-crc

in the server's /etc/krb5.conf file.  Could you try this and see if it helps?

K.C.
