Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp06.online.nl ([194.134.42.51]:55884 "EHLO smtp06.online.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919Ab1CRGAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Mar 2011 02:00:44 -0400
Subject: Re: rpc.svcgssd problem after updating client 1.2.2->1.2.3
From: Vladimir Elisseev <vovan@vovan.nl>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4D8275AE.5030001@RedHat.com>
References: <1300387690.2684.23.camel@vovan.net.home>
	 <4D8275AE.5030001@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Mar 2011 06:49:47 +0100
Message-ID: <1300427387.30472.15.camel@vovan.net.home>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

You're right, I saw about the same error with mountd, but the problem I
have is most likely related to the change: 

commit 76be349d5dd07f55797cb9920cc275667258f10f
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Thu Apr 15 08:32:20 2010 -0400

    Try to use kernel function to determine supported Kerberos enctypes.

    This patch replaces a hard-coded list with a function to obtain
    the Kerberos encryption types that the kernel's rpcsec_gss code
    can support.  Defaults to old behavior if kernel does not supply
    information.

Regards,
Vladimir.

On Thu, 2011-03-17 at 16:57 -0400, Steve Dickson wrote:
> 
> On 03/17/2011 02:48 PM, Vladimir Elisseev wrote:
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
> I've seen this before but I believe it was in mountd. The fflush(3) call 
> is failing with EINVAL on the upcall fd... I forget how it cleared its
> self up..... 
> 
> steved.
> 
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
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: sending null reply
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: writing message: \x
> > \x6082025106092a864886f71201020201006e8202403082023ca003020105a10302010ea20703050020000000a38201486182014430820140a003020105a10a1b084e45542e484f4d45a21e301ca003020103a11530131b036e66731b0c6e66732e6e65742e686f6d65a382010b30820107a003020112a103020103a281fa0481f76d51de4ee749be6f5662e84fd91220874cd512114a52a7dbb0d1fb96da4768ec9d9f967a9664cc3a27626e0383a6a2e6930123efd709525a41420a68fdaa8fafabfab642f00c4e7d6dc4f075d900adf92f339d02b8ad1a162efeefa7501417280c553a430056634f4771a9bfa86c80eb758e7d530bff6dba5a112ca6b2412123e496a10ef93ac5af820b8751ec53db527acc059fcaee551edab8adc61f1dbc61ed9d16b65157974bd572d25ce62fd8c2e9d30650ef8cd35b12e315535cc1e53895bbd0a9589e02e2de1e62ca61e50e99f2b9f0456157bd3b3d739c6b6899b62f681f91e6072033e62e665ade4c366a1369315f19ca2e7da481da3081d7a003020112a281cf0481cc224de9a1f61431a8aee2b5a4f9fb6260230a0220c87c32030c528c80756b779eea25b272164e1c5e29b4d5be07557039cb7a9e230a5a8572dbe5bec750b952d57022d61ce29643f1110fece4e3c07ba027461e3e865f30a5ed29068cbec2e7a8d1dd18
 f6
> 6!
> >  50e6f2a565b7d779220c9c5c40c504533de623c63e3f229749f34e4d64cfc050083c09b3913371d0203994d3893a6640b6d9e1a5c43949f0b6567b755c99c4876f6987e7c3886d2eddd5cca1775ae4b0cde83910ddd786706c34fdbc18eca86206d42c05fd4fda4 1300378023 0 0 \x2d000000 \x60819906092a864886f71201020202006f8189308186a003020105a10302010fa27a3078a003020112a271046f5b995dfc1da7fffbad590382fac5637845400ac2b3d3943196e2c4ab8d55edfccfaf99b27d5e06ca56df734d817378c16a4b0c0fee21ecffd1be76b0cdffb8715e0cfe8659e3344407312e18194df2acd1795f8285f6f60ac31658d6bc678750f0fa0bb9e8d41ea2846832f8c7bc91
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: finished handling null request
> > Mar 17 17:06:03 srv2 rpc.svcgssd[15159]: entering poll
> > 
> > On the client side mount ends with "access denied" error, the full log
> > is below:
> > Mar 17 17:09:06 user rpc.gssd[32238]: handling gssd upcall
> > (/var/lib/nfs/rpc_pipefs/nfs/clnt37) 
> > Mar 17 17:09:06 user rpc.gssd[32238]: handle_gssd_upcall: 'mech=krb5
> > uid=0 enctypes=18,17,16,23,3,1,2 ' 
> > Mar 17 17:09:06 user rpc.gssd[32238]: handling krb5 upcall
> > (/var/lib/nfs/rpc_pipefs/nfs/clnt37) 
> > Mar 17 17:09:06 user rpc.gssd[32238]: process_krb5_upcall: service is
> > '<null>' 
> > Mar 17 17:09:06 user rpc.gssd[32238]: Full hostname for 'nfs.x.x' is
> > 'nfs.x.x' 
> > Mar 17 17:09:06 user rpc.gssd[32238]: Full hostname for 'user.x.x' is
> > 'user.x.x' 
> > Mar 17 17:09:06 user rpc.gssd[32238]: No key table entry found for
> > root/user.x.x@X.X while getting keytab entry for 'root/user.x.x@X.X' 
> > Mar 17 17:09:06 user rpc.gssd[32238]: No key table entry found for
> > nfs/user.x.x@X.X while getting keytab entry for 'nfs/user.x.x@X.X' 
> > Mar 17 17:09:06 user rpc.gssd[32238]: Success getting keytab entry for
> > 'host/user.x.x@X.X' 
> > Mar 17 17:09:06 user rpc.gssd[32238]: Successfully obtained machine
> > credentials for principal 'host/user.x.x@X.X' stored in ccache
> > 'FILE:/tmp/krb5cc_machine_x.x'    
> > Mar 17 17:09:06 user rpc.gssd[32238]: INFO: Credentials in CC
> > 'FILE:/tmp/krb5cc_machine_x.x' are good until 1300464546 
> > Mar 17 17:09:06 user rpc.gssd[32238]: using FILE:/tmp/krb5cc_machine_x.x
> > as credentials cache for machine creds 
> > Mar 17 17:09:06 user rpc.gssd[32238]: using environment variable to
> > select krb5 ccache FILE:/tmp/krb5cc_machine_x.x 
> > Mar 17 17:09:06 user rpc.gssd[32238]: creating context using fsuid 0
> > (save_uid 0) 
> > Mar 17 17:09:06 user rpc.gssd[32238]: creating tcp client for server
> > nfs.x.x 
> > Mar 17 17:09:06 user rpc.gssd[32238]: DEBUG: port already set to 2049 
> > Mar 17 17:09:06 user rpc.gssd[32238]: creating context with server
> > nfs@nfs.x.x 
> > Mar 17 17:09:06 user rpc.gssd[32238]: WARNING: Failed to create krb5
> > context for user with uid 0 for server nfs.x.x 
> > Mar 17 17:09:06 user rpc.gssd[32238]: WARNING: Failed to create machine
> > krb5 context with credentials cache FILE:/tmp/krb5cc_machine_X.X for
> > server nfs.x.x 
> > Mar 17 17:09:06 user rpc.gssd[32238]: WARNING: Machine cache is
> > prematurely expired or corrupted trying to recreate cache for server
> > nfs.x.x 
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

