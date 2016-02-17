Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:32836 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422903AbcBQQex convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Feb 2016 11:34:53 -0500
Date: Wed, 17 Feb 2016 11:34:51 -0500
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: Martin Houry <martinhoury@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: "Re: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1
 Session Trunking"
Message-ID: <20160217163451.GD10401@fieldses.org>
References: <CAEUt8V+L3hV1tQTzanVjGyZ1qoG8qJk7ZnS5HM1_3+Nc4mpO3A@mail.gmail.com>
 <F6DC5176-6340-4945-9EBD-537410882E1D@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <F6DC5176-6340-4945-9EBD-537410882E1D@netapp.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 17, 2016 at 02:50:44PM +0000, Adamson, Andy wrote:
> 
> > On Feb 17, 2016, at 5:31 AM, Martin Houry <martinhoury@gmail.com> wrote:
> > 
> > ----- Original Message -----
> > 
> >> From: andros@xxxxxxxxxx
> >> To: "trond myklebust" <trond.myklebust@xxxxxxxxxxxxxxx>
> >> Cc: linux-nfs@xxxxxxxxxxxxxxx, "Andy Adamson" <andros@xxxxxxxxxx>
> >> Sent: Friday, February 5, 2016 4:08:32 PM
> >> Subject: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1 Session Trunking
> >> 
> >> From: Andy Adamson <andros@xxxxxxxxxx>
> >> 
> >> This early patch set implements NFSv4.1 session trunking utilizing Tronds
> >> multipath feature.  This works against an upstream linux server with
> >> two NICs as the EXCHANGE_ID info is the same for both NICs.
> >> 
> >> Unmodified code will create a new nfs_client structure for the mount as
> >> nfs_match_client fails due to the different full server address.
> >> Tunking is detected by comparing the eir_server_owner.major/minor/scope
> >> and the eir_server_impl_id to an existing mount. When trunking is detected,
> >> the 2nd mount point uses the existing  (not new) nfs_client for the new
> >> mount point.
> >> 
> >> When trunking is detected, this patch set adds an rpc_xprt for the new server
> >> address to the exisiting mount, calls BIND_CONN_TO_SESSION, and destroys
> >> the new clientid (no second mount).
> >> 
> >> We then get round robin use of the two NICs off one mount point all
> >> using a single session.
> >> 
> >> 
> >> Is using mount a good way to setup NFSv4.1 session trunking?
> >> 
> >> The first two patches fix issues with the multipath code.
> >> 
> >> SUNRPC: allow rpc_xprt_switch_add_xprt to add xprts on the same net
> >>    This patch adds a flag to allow multipathing within the origial net.
> >>    I don't understand why this was not allowed, so I expect a different
> >>    solution for this issue.
> >> 
> >> 
> >> Comments please.
> >> 
> >> Thanks
> >> 
> >> -->Andy
> >> 
> >> Andy Adamson (6):
> >>  SUNRPC fix rpc_clnt_add_xprt setup return
> >>  SUNRPC fix rpc_clnt_xprt_iter_init infinite loop
> >>  SUNRPC: allow rpc_xprt_switch_add_xprt to add xprts on the same net
> >>  NFS session trunking support: add trunk xprt to nfs4.1 mount
> >>  NFS add callback_ops to nfs4_proc_bind_conn_to_session_callback
> >>  NFS schedule bind_conn_to_session for new NFSv4.1 transport
> >> 
> >> fs/nfs/client.c                      |  2 ++
> >> fs/nfs/nfs4client.c                  | 29 +++++++++++++++++++++++++++--
> >> fs/nfs/nfs4proc.c                    | 10 ++++++++++
> >> include/linux/nfs_fs_sb.h            |  1 +
> >> include/linux/sunrpc/clnt.h          |  1 +
> >> include/linux/sunrpc/xprtmultipath.h |  6 +++++-
> >> net/sunrpc/clnt.c                    | 20 +++++++++++++-------
> >> net/sunrpc/xprtmultipath.c           | 35
> >> +++++++++++++++++++++++++++++++++--
> >> 8 files changed, 92 insertions(+), 12 deletions(-)
> >> 
> >> --
> >> 1.8.3.1
> >> 
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@xxxxxxxxxxxxxxx
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> 
> > 
> > Tried and approved!
> 
> Thanks for testing. As Trond pointed out, the correct way to indicate multiple hostnames is on the mount command line
> 
> mount -o minorversion=1 host1,host2,…,hostn:/<export>  /<mntdir>
> 
> I have a new patch set that is working and that I am testing and cleaning up that adds multiple hostname support to mount.nfs for NFSv4.1, and that kicks off an EXCHANGE_ID for each multi-host address. If the EXCHANGE_ID succeeds, a BIND_CONN_TO_SESSION is also called.

I'm surprised there's  BIND_CONN_TO_SESSION in the case Martin's
testing.  I didn't think it was necessary unless you were using
kerberos.  Maybe I'm forgetting some subtlety....

--b.

> 
> —>Andy
> 
> 
> > 
> > Here is the steps to make it works for those who wants to try it. :
> > 
> > Test configuration :
> > 
> > Running Server Kernel Version : 3.2.0
> > Running Client Kernel Version : 3.2.0
> > Patch deployment Client Kernel Version : 4.5.0 rc4+
> > Debian 7.9
> > GNS3 1.4.1
> > Wireshark 1.12.3
> > VirtualBox 5.0.14
> > Client and Server are Virtualbox VM's conected each other with a GNS3 Switch
> > 
> > NO AUTHENTIFICATION - this is only for test purpose
> > 
> > +----------+                                              +----------+
> > |          | 192.168.1.2 /24 +----------+ 192.168.1.3 /24 |          |
> > |          +-----------------+          +-----------------+          |
> > |  Client  |                 |  Switch  |                 |  Server  |
> > |          +-----------------+          +-----------------+          |
> > |          | 192.168.2.20/24 +----------+ 192.168.2.30 /24|          |
> > +----------+                                              +----------+
> > 
> > 
> > Steps :
> > -------------------------------------------------------------------
> > Server NFS4.1 configuration :
> > 
> > Make sure you have an internet connection.
> > 
> > Commands assuming you are root:
> > 
> > apt-get update && apt-get upgrade
> > apt-get install nfs-kernel-server
> > mkdir home/testnfs
> > chmod 777 home/testnfs
> > nano etc/exports
> > #Add these line in the "exports" file to set the "testnfs" folder available
> >    /home/testnfs    192.168.1.2(rw,sync)
> >    /home/testnfs    192.168.2.20(rw,sync)
> > #end
> > 
> > #Enable NFSv4.1
> > etc/init.d/nfs-kernel-server stop
> > nano proc/fs/nfsd/versions
> > #set +2 +3 +4 -4.1 to +2 +3 +4 +4.1
> > etc/init.d/nfs-kernel-server start
> > 
> > #server ready
> > #end server configuration
> > -------------------------------------------------------------------
> > Client NFS4.1 configuration :
> > 
> > Commands assuming you are root:
> > #------------Prepare new Kernel with new patches----------
> > apt-get install libncurses5-dev gcc make git exuberant-ctags bc libssl-dev
> > mkdir kernels
> > cd kernels
> > git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
> > #it takes a while...
> > cd linux-stable
> > cp /boot/config-`uname -r`* .config
> > #the -j4 stand for 4 jobs running at the same time, ideal for
> > multi-core processor.
> > make -j4
> > #It takes a while
> > 
> > #--------------------Install the patches------------------
> > apt-get install patch
> > cd /
> > mkdir patch
> > cd patch
> > mkdir rpcmultipathpatch
> > mkdir sessiontrunkingpatch
> > #Get the Trond Myklebust's patch :
> > http://www.spinics.net/lists/linux-nfs/msg56365.html
> > nano rpcmultipathpatch/patch1.patch
> > .
> > .
> > .
> > nano rpcmultipathpatch/patch13.patch
> > #Get the Andy Adamson's patches :
> > http://www.spinics.net/lists/linux-nfs/msg56437.html
> > nano sessiontrunkingpatch/patch1.patch
> > .
> > .
> > .
> > nano sessiontrunkingpatch/patch6.patch
> > 
> > 
> > cd /
> > 
> > #Apply rpc multipath patch
> > patch -p1 < rpcmultipathpatch/patch1.patch
> > patch -p1 < rpcmultipathpatch/patch2.patch
> > patch -p1 < rpcmultipathpatch/patch3.patch
> > patch -p1 < rpcmultipathpatch/patch4.patch
> > patch -p1 < rpcmultipathpatch/patch5.patch
> > patch -p1 < rpcmultipathpatch/patch6.patch
> > patch -p1 < rpcmultipathpatch/patch7.patch
> > patch -p1 < rpcmultipathpatch/patch8.patch
> > patch -p1 < rpcmultipathpatch/patch9.patch
> > patch -p1 < rpcmultipathpatch/patch10.patch
> > patch -p1 < rpcmultipathpatch/patch11.patch
> > patch -p1 < rpcmultipathpatch/patch12.patch
> > patch -p1 < rpcmultipathpatch/patch13.patch
> > 
> > #Apply client session trunking patches
> > patch -p1 < sessiontrunkingpatch/patch1.patch
> > patch -p1 < sessiontrunkingpatch/patch2.patch
> > patch -p1 < sessiontrunkingpatch/patch3.patch
> > patch -p1 < sessiontrunkingpatch/patch4.patch
> > patch -p1 < sessiontrunkingpatch/patch5.patch
> > patch -p1 < sessiontrunkingpatch/patch6.patch
> > 
> > make -j4
> > 
> > #I got a compilation error in the "net/sunrpc/xprtmultipath.c" line 220
> > #at WRITE_ONCE(&xpi->xpi_cursor,NULL);
> > #error: lvalue required as unary ‘&’ operand
> > #I remove the "&"
> > 
> > make -j4 M=net/sunrpc
> > 
> > make modules_install install
> > #reboot and boot on the new kernel (with GRUB)
> > 
> > 
> > #--------------------Mount--------------------
> > mkdir testmount
> > mount -tnfs4 -ominorversion=1 192.168.1.3:/home/testnfs testmount
> > mount -tnfs4 -ominorversion=1 192.168.2.30:/home/testnfs testmount
> > 
> > #end client configuration
> > 
> > The round-robin implementation distribute correctly the operations
> > between the two interfaces and the BIND_CONN_TO_SESSION seems to work.
> > 
> > 
> > If you cut a cable, the client continue to send nfs packets on it, so
> > you loose one operation on two.
> > 
> > 
> > 
> > 
> > 
> > Thanks to http://kernelnewbies.org/.
> > Thanks to Trond Myklebust and Andy Adamson for the patches
> 
> N?????r??y????b?X??ǧv?^?)޺{.n?+????{???"??^n?r???z???h?????&???G???h?(?階?ݢj"???m??????z?ޖ???f???h???~?m
