Return-Path: <bfields@fieldses.org>
Date: Fri, 6 Apr 2018 14:16:42 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Orion Poplawski <orion@nwra.com>,
	Benjamin Coddington <bcodding@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS troubles
Message-ID: <20180406181642.GB30591@fieldses.org>
References: <a6548640-bc0c-3bdd-7a0c-b1996978a26d@nwra.com>
 <A5B6EFB3-239C-420C-91F4-2B8D1BCBA85A@redhat.com>
 <efe6d26f-d1e9-bf16-e608-a2595e4fdbdf@nwra.com>
 <fa393c5e-a18c-2963-3aa8-f56ba35e8baf@nwra.com>
 <7A560163-BA54-4051-9BB4-12087952987D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7A560163-BA54-4051-9BB4-12087952987D@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 06, 2018 at 12:24:21PM -0400, Chuck Lever wrote:
> 
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
> > 
> > It appears to be related to mounting a different sec=krb5 mount over the
> > public network from the same server.  While that mount is active, the sec=sys
> > mounts fail.  When it is unmounted, they work.  At least now I think I can
> > work around this...
> 
> For NFSv4, the client is going to use krb5i to do lease management even
> on sec=sys mounts. An NFSv4 server has to know for sure when it is talking
> to the same client on different network interfaces or with different
> security flavors. Thus the client has to use the same security flavor for
> lease management on all of its mounts of that server. That's not controlled
> by the sec= mount option.
> 
> I assume that "but then later" lasts only a few multiples of the server's
> lease time (90 seconds by default)?
> 
> Clients that use only the private network interface should be able to use
> sec=sys. But clients that use both the public and private interfaces should
> need to use sec=krb5 on both.

Are you saying that the behavior he's seeing is expected?

I'd expect sec=sys and sec=krb5 mounts to the same server to coexist and
both use krb5i to manage the (shared) lease state.

--b.
