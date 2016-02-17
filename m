Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:32954 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422746AbcBQSoJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Feb 2016 13:44:09 -0500
Date: Wed, 17 Feb 2016 13:44:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: Martin Houry <martinhoury@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: "Re: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1
 Session Trunking"
Message-ID: <20160217184406.GE10401@fieldses.org>
References: <CAEUt8V+L3hV1tQTzanVjGyZ1qoG8qJk7ZnS5HM1_3+Nc4mpO3A@mail.gmail.com>
 <F6DC5176-6340-4945-9EBD-537410882E1D@netapp.com>
 <20160217163451.GD10401@fieldses.org>
 <F2FB08E3-FAB6-4035-A85A-D70CF5387D30@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <F2FB08E3-FAB6-4035-A85A-D70CF5387D30@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 17, 2016 at 05:49:39PM +0000, Adamson, Andy wrote:
> On Feb 17, 2016, at 11:34 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > I'm surprised there's  BIND_CONN_TO_SESSION in the case Martin's
> > testing.  I didn't think it was necessary unless you were using
> > kerberos.  Maybe I'm forgetting some subtlety….
> 
> The first host (host1 above) is the mount host. Each additional host is a new connection. An EXCHANGE_ID is sent on the new connection, and the resultant serverscope, server owner, clientid, etc from the new connection EXCHANGE_ID reply is compared to the mount exchange_id args stored in the nfs_client struct. If it passes the session trunking requirements, then the connection needs to be bound to the session to enable session trunking.

That all makes sense to me, but:

	"If, when the client ID was created, the client opted for
	SP4_NONE state protection, the client is not required to use
	BIND_CONN_TO_SESSION to associate the connection with the
	session, unless the client wishes to associate the connection
	with the backchannel.  When SP4_NONE protection is used, simply
	sending a COMPOUND request with a SEQUENCE operation is
	sufficient to associate the connection with the session
	specified in SEQUENCE."

Well, but maybe that's academic, there's probably no harm in sending the
BIND_CONN_TO_SESSION.

--b.

> 
> —>Andy
> 
> RFC5661 2.10.5
> ……
>  Session Trunking.  If the eia_clientowner argument is the same in two
>       different EXCHANGE_ID requests, and the eir_clientid,
>       eir_server_owner.so_major_id, eir_server_owner.so_minor_id, and
>       eir_server_scope results match in both EXCHANGE_ID results, then
>       the client is permitted to perform session trunking.  If the
>       client has no session mapping to the tuple of eir_clientid,
>       eir_server_owner.so_major_id, eir_server_scope, and
>       eir_server_owner.so_minor_id, then it creates the session via a
>       CREATE_SESSION operation over one of the connections, which
>       associates the connection to the session.  If there is a session
>       for the tuple, the client can send BIND_CONN_TO_SESSION to
>       associate the connection to the session.
> 
>       Of course, if the client does not desire to use session trunking,
>       it is not required to do so.  It can invoke CREATE_SESSION on the
>       connection.  This will result in client ID trunking as described
>       below.  It can also decide to drop the connection if it does not
>       choose to use trunking.
> > 
> > --b.
> > 
> >> 
> >> —>Andy
> >> 
> >> 
> >>> 
> >>> Here is the steps to make it works for those who wants to try it. :
> >>> 
> >>> Test configuration :
> >>> 
> >>> Running Server Kernel Version : 3.2.0
> >>> Running Client Kernel Version : 3.2.0
> >>> Patch deployment Client Kernel Version : 4.5.0 rc4+
> >>> Debian 7.9
> >>> GNS3 1.4.1
> >>> Wireshark 1.12.3
> >>> VirtualBox 5.0.14
> >>> Client and Server are Virtualbox VM's conected each other with a GNS3 Switch
> >>> 
> >>> NO AUTHENTIFICATION - this is only for test purpose
> >>> 
> >>> +----------+                                              +----------+
> >>> |          | 192.168.1.2 /24 +----------+ 192.168.1.3 /24 |          |
> >>> |          +-----------------+          +-----------------+          |
> >>> |  Client  |                 |  Switch  |                 |  Server  |
> >>> |          +-----------------+          +-----------------+          |
> >>> |          | 192.168.2.20/24 +----------+ 192.168.2.30 /24|          |
> >>> +----------+                                              +----------+
> >>> 
> >>> 
> >>> Steps :
> >>> -------------------------------------------------------------------
> >>> Server NFS4.1 configuration :
> >>> 
> >>> Make sure you have an internet connection.
> >>> 
> >>> Commands assuming you are root:
> >>> 
> >>> apt-get update && apt-get upgrade
> >>> apt-get install nfs-kernel-server
> >>> mkdir home/testnfs
> >>> chmod 777 home/testnfs
> >>> nano etc/exports
> >>> #Add these line in the "exports" file to set the "testnfs" folder available
> >>>   /home/testnfs    192.168.1.2(rw,sync)
> >>>   /home/testnfs    192.168.2.20(rw,sync)
> >>> #end
> >>> 
> >>> #Enable NFSv4.1
> >>> etc/init.d/nfs-kernel-server stop
> >>> nano proc/fs/nfsd/versions
> >>> #set +2 +3 +4 -4.1 to +2 +3 +4 +4.1
> >>> etc/init.d/nfs-kernel-server start
> >>> 
> >>> #server ready
> >>> #end server configuration
> >>> -------------------------------------------------------------------
> >>> Client NFS4.1 configuration :
> >>> 
> >>> Commands assuming you are root:
> >>> #------------Prepare new Kernel with new patches----------
> >>> apt-get install libncurses5-dev gcc make git exuberant-ctags bc libssl-dev
> >>> mkdir kernels
> >>> cd kernels
> >>> git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
> >>> #it takes a while...
> >>> cd linux-stable
> >>> cp /boot/config-`uname -r`* .config
> >>> #the -j4 stand for 4 jobs running at the same time, ideal for
> >>> multi-core processor.
> >>> make -j4
> >>> #It takes a while
> >>> 
> >>> #--------------------Install the patches------------------
> >>> apt-get install patch
> >>> cd /
> >>> mkdir patch
> >>> cd patch
> >>> mkdir rpcmultipathpatch
> >>> mkdir sessiontrunkingpatch
> >>> #Get the Trond Myklebust's patch :
> >>> http://www.spinics.net/lists/linux-nfs/msg56365.html
> >>> nano rpcmultipathpatch/patch1.patch
> >>> .
> >>> .
> >>> .
> >>> nano rpcmultipathpatch/patch13.patch
> >>> #Get the Andy Adamson's patches :
> >>> http://www.spinics.net/lists/linux-nfs/msg56437.html
> >>> nano sessiontrunkingpatch/patch1.patch
> >>> .
> >>> .
> >>> .
> >>> nano sessiontrunkingpatch/patch6.patch
> >>> 
> >>> 
> >>> cd /
> >>> 
> >>> #Apply rpc multipath patch
> >>> patch -p1 < rpcmultipathpatch/patch1.patch
> >>> patch -p1 < rpcmultipathpatch/patch2.patch
> >>> patch -p1 < rpcmultipathpatch/patch3.patch
> >>> patch -p1 < rpcmultipathpatch/patch4.patch
> >>> patch -p1 < rpcmultipathpatch/patch5.patch
> >>> patch -p1 < rpcmultipathpatch/patch6.patch
> >>> patch -p1 < rpcmultipathpatch/patch7.patch
> >>> patch -p1 < rpcmultipathpatch/patch8.patch
> >>> patch -p1 < rpcmultipathpatch/patch9.patch
> >>> patch -p1 < rpcmultipathpatch/patch10.patch
> >>> patch -p1 < rpcmultipathpatch/patch11.patch
> >>> patch -p1 < rpcmultipathpatch/patch12.patch
> >>> patch -p1 < rpcmultipathpatch/patch13.patch
> >>> 
> >>> #Apply client session trunking patches
> >>> patch -p1 < sessiontrunkingpatch/patch1.patch
> >>> patch -p1 < sessiontrunkingpatch/patch2.patch
> >>> patch -p1 < sessiontrunkingpatch/patch3.patch
> >>> patch -p1 < sessiontrunkingpatch/patch4.patch
> >>> patch -p1 < sessiontrunkingpatch/patch5.patch
> >>> patch -p1 < sessiontrunkingpatch/patch6.patch
> >>> 
> >>> make -j4
> >>> 
> >>> #I got a compilation error in the "net/sunrpc/xprtmultipath.c" line 220
> >>> #at WRITE_ONCE(&xpi->xpi_cursor,NULL);
> >>> #error: lvalue required as unary ‘&’ operand
> >>> #I remove the "&"
> >>> 
> >>> make -j4 M=net/sunrpc
> >>> 
> >>> make modules_install install
> >>> #reboot and boot on the new kernel (with GRUB)
> >>> 
> >>> 
> >>> #--------------------Mount--------------------
> >>> mkdir testmount
> >>> mount -tnfs4 -ominorversion=1 192.168.1.3:/home/testnfs testmount
> >>> mount -tnfs4 -ominorversion=1 192.168.2.30:/home/testnfs testmount
> >>> 
> >>> #end client configuration
> >>> 
> >>> The round-robin implementation distribute correctly the operations
> >>> between the two interfaces and the BIND_CONN_TO_SESSION seems to work.
> >>> 
> >>> 
> >>> If you cut a cable, the client continue to send nfs packets on it, so
> >>> you loose one operation on two.
> >>> 
> >>> 
> >>> 
> >>> 
> >>> 
> >>> Thanks to http://kernelnewbies.org/.
> >>> Thanks to Trond Myklebust and Andy Adamson for the patches
> >> 
> >> N?????r??y????b?X??ǧv?^?)޺{.n?+????{???"??^n?r???z???h?????&???G???h?(?階?ݢj"???m??????z?ޖ???f???h???~?m
> 
