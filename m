Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48594 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751544AbeDGCqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Apr 2018 22:46:55 -0400
Date: Fri, 6 Apr 2018 22:46:55 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS troubles
Message-ID: <20180407024655.GD5306@fieldses.org>
References: <a6548640-bc0c-3bdd-7a0c-b1996978a26d@nwra.com>
 <A5B6EFB3-239C-420C-91F4-2B8D1BCBA85A@redhat.com>
 <efe6d26f-d1e9-bf16-e608-a2595e4fdbdf@nwra.com>
 <fa393c5e-a18c-2963-3aa8-f56ba35e8baf@nwra.com>
 <D16F3893-3A2C-46B0-A05A-52C8155C66AB@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D16F3893-3A2C-46B0-A05A-52C8155C66AB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 06, 2018 at 08:15:35PM -0400, Chuck Lever wrote:
> 
> > On Apr 6, 2018, at 12:07 PM, Orion Poplawski <orion@nwra.com> wrote:
> > 
> > On 04/03/2018 09:44 AM, Orion Poplawski wrote:
> >> Kernel is 3.10.0-693.21.1.el7.x86_64  I don't have Red Hat support for these
> >> systems.
> >> 
> >> I discovered that I'd been forcing vers=4.0 mounts in order to work around a
> >> mounting issue.  
> > 
> > And I'm back to seeing the mount issue at boot.  Here's the situation - we're
> > forcing kerberos on the public network, but allowing sec=sys on some private
> > networks:
> > 
> > /etc/exports:
> > /               -ro,async,fsid=0 192.168.1.0/24(sec=sys)
> > 192.168.2.0/24(sec=sys) *.nwra.com(sec=krb5)
> > /export/home    -rw,async,nohide 192.168.1.0/24(sec=sys)
> > 192.168.2.0/24(sec=sys) *.nwra.com(sec=krb5)
> > 
> > So for a while after boot, attempts to mount with sec=sys fail:
> > 
> > # mount -t nfs4 -s -o
> > sec=sys,intr,rsize=262144,wsize=262144,noatime,lookupcache=positive,actimeo=1
> > earthib.cora.nwra.com:/export/home/greg /mnt
> > mount.nfs4: Operation not permitted
> > 
> > But then later they work:
> > 
> > # mount -t nfs4 -s -o
> > sec=sys,intr,rsize=262144,wsize=262144,noatime,lookupcache=positive,actimeo=1
> > earthib.cora.nwra.com:/export/home/greg /mnt
> > # umount /mnt
> > 
> > This can cycle back and forth.
> > 
> > I've attached a packet capture of some failed mount attempts.  It seems that
> > even with specifying sec=sys, some kerberos stuff is going on.
> 
> > It appears to be related to mounting a different sec=krb5 mount over the
> > public network from the same server.  While that mount is active, the sec=sys
> > mounts fail.  When it is unmounted, they work.  At least now I think I can
> > work around this...
> 
> Bruce-
> 
> I examined the attached network capture. There are two attempts to do an
> EXCHANGE_ID operation. Both times:
> 
> - a fresh GSS context is established successfully
> - a fresh TCP connection is established by the client
> - EXCHANGE_ID is sent using krb5i and the previously established GSS context
> -- client owner verifier is 0x5ac794e81d0a1d81
> -- client owner is "Linux NFSv4.1 qcomp1.cora.nwra.com"
> -- state protection is SP4_MACH_CRED
> - the server responds NFS4_OK; the CONFIRMED_R, PNFS_MDS, and MOVED_REFER flags are set
> - the client destroys the GSS context
> - the client closes the TCP connection

Huh.  If this is a second mount to the same server, it shouldn't need to
do another EXCHANGE_ID at all, should it?  I suppose the trunking
detection code's being overzealous.  Anyway, doesn't sound like the
trace tells us much.  Sounds easy to reproduce, so maybe we just need to
try it and see where exactly the client code is failing.

--b.
