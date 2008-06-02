From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH] update NFS/RDMA documentation
Date: Mon, 2 Jun 2008 18:30:25 -0400
Message-ID: <76bd70e30806021530w46ec3889y4017a76bd5343705@mail.gmail.com>
References: <alpine.LFD.1.10.0806021530560.26788@jlentini-linux.nane.netapp.com>
	 <4B7D1A89-DB85-4E33-91AB-F93901A55CA1@oracle.com>
	 <alpine.LFD.1.10.0806021653360.26788@jlentini-linux.nane.netapp.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Thomas Talpey" <talpey@netapp.com>,
	"Tom Tucker" <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org
To: "James Lentini" <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:39599 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbYFBWa1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2008 18:30:27 -0400
Received: by wx-out-0506.google.com with SMTP id h29so824157wxd.4
        for <linux-nfs@vger.kernel.org>; Mon, 02 Jun 2008 15:30:26 -0700 (PDT)
In-Reply-To: <alpine.LFD.1.10.0806021653360.26788-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 2, 2008 at 5:13 PM, James Lentini <jlentini@netapp.com> wrote:
> On Mon, 2 Jun 2008, Chuck Lever wrote:
>> > @@ -77,22 +79,32 @@ Installation
>> >
>> >    Uncompress the package and follow the installation instructions.
>> >
>> > -    If you will not be using GSS and NFSv4, the installation process
>> > -    can be simplified by disabling these features when running configure:
>> > +    If you will not need the idmapper and gssd executables (you do not need
>> > +    these to create an NFS/RDMA enabled mount command), the installation
>> > +    process can be simplified by disabling these features when running
>> > +    configure:
>>
>> This explanation still seems confusing.
>>
>> idmapper *is* required for NFSv4 (and I assume you can mount an
>> NFSv4 server over RDMA),
>
> Yes, NFSv4 works over RDMA.
>
>> and gssd *is* required to support secure mounts, all of which may
>> co-exist with the RDMA capability.
>
> I agree. The intent of the text is to inform the reader that the
> idmapper and gssd are not need if all they need is a
> NFS/RDMA-compatible (aka string mount API enabled) mount.nfs command.
>
>> I think you would be much better off providing a recipe for building
>> and installing mount.nfs instead of trying to "insert" bits into the
>> instructions in the nfs-utils README.
>
> I'm open to suggestions on how to improve the text.
>
> Can send an example of such a recipe?

Here's a stab at it.  It's a little wordy, but it spells out the necessary
steps, which someone can even copy-n-paste, recipe style, to build
and install the mount.nfs command, in most cases.  Part of the
problem is the nfs-utils README is a little sparse in some of these
areas.

Naturally you should test these instructions before publishing them :-)

  - Install nfs-utils-1.1.2 or later on the client

    To mount an NFS server over RDMA, you must have the
    mount.nfs subcommand from nfs-utils-1.1.2 or later installed on
    your client.  For the purposes of this discussion, we will assume
    that your distribution keeps the mount subcommands under /sbin.

    To see which version of mount.nfs is installed on your client,
    type:

    $ /sbin/mount.nfs -V
    mount.nfs (linux nfs-utils 1.1.2)
    $

    If the reported version is less than 1.1.2, or the command does
    not exist, then you will need to install the latest version of the
    NFS mount.nfs subcommand.

    Your distributor may provide an update that brings the nfs-utils
    package up to 1.1.2 or later, but if your client's packages are
    completely up-to-date and you still don't have nfs-utils 1.1.2,
    you will need to build nfs-utils from the latest upstream version.

    Download the latest nfs-utils package from:

        http://www.kernel.org/pub/linux/utils/nfs

    Uncompress the package into a convenient place.

    Building nfs-utils also requires that the tcp_wrapper-devel
    package is installed on your build system.  For example, on a
    typical Fedora system, you can use yum to install it:

    $ sudo yum install tcp_wrappers-devel

    On other systems, use an appropriate native package
    management facility to retrieve and install tcp_wrappers-devel.

    Now cd to the top level directory of the uncompressed nfs-utils
    tarball.

    $ cd /tmp/nfs-utils-1.1.2

    Set up the autotools scripts.  Since we only need to build the
    mount.nfs command, let's disable other components of nfs-utils
    that might depend on packages that are not typically available
    on most systems.

    $ ./configure --disable-gss --disable-nfsv4
    $ make

    If all has gone well, there should be a mount.nfs executable
    under the utils/mount directory when the build is finished.

    You can invoke the mount.nfs subcommand directly if desired,
    but the usual practice is to place the subcommand where your
    system's mount command can find it, and then it will be invoked
    automatically during NFS mount requests.  This way you can
    add NFS/RDMA mount points to your client's /etc/fstab or
    automounter maps.

    We haven't made any special changes here, so this version of
    the mount.nfs subcommand can safely replace your system's
    original mount.nfs subcommand.  When you are satisfied it is
    working as expected, install it.

    $ cd utils/mount
    $ sudo make install-exec

    Some features require that the mount.nfs subcommand is
    setuid root, but this is entirely optional.

    $ sudo chown root /sbin/mount.nfs
    $ sudo chmod u+s /sbin/mount.nfs

    You do not need to replace the mount.nfs command on your NFS
    server to support NFS over RDMA.

    More information on the mount.nfs command is available in the
    nfs-utils package's README and INSTALL files.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
