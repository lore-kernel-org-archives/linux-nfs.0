Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58961 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675Ab1BOCXJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Feb 2011 21:23:09 -0500
Subject: Re: NFS only mount with -o udp option
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Edgar Almonte <samudhio@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTim9zbEzKZ=RZbfZhcLovn6fWkdL-3eZp21-NDP+@mail.gmail.com>
References: <AANLkTik_Y4_UpBx-OMaedXz34qc+zuVzN1B5A5qnzW5y@mail.gmail.com>
	 <665D28F4-A8C9-47E8-AE27-E1D960A1830B@oracle.com>
	 <AANLkTi=dgyOmf+to8waRi+piomovMM-H7_7GdzyhYuEo@mail.gmail.com>
	 <0F40C51E-38A3-451B-9D88-586CFD82EF8F@oracle.com>
	 <AANLkTiksVebz5Pc+hH55hRUgvQ5PMFE1DG2X1JWbtSeD@mail.gmail.com>
	 <AANLkTinG0774DoYyM+2381Eyxdx0+29JUs_-dzfRp=vM@mail.gmail.com>
	 <1A31AB06-8518-427C-8D0B-0058AA613D0E@oracle.com>
	 <AANLkTimiACttSQ+=M0UNGs5nZrP=zs0zRFV+4HP8c-OP@mail.gmail.com>
	 <81853901-909D-4803-81A5-C01C0337CAE1@oracle.com>
	 <AANLkTim9zbEzKZ=RZbfZhcLovn6fWkdL-3eZp21-NDP+@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 14 Feb 2011 21:22:52 -0500
Message-ID: <1297736572.23841.60.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-02-14 at 22:09 -0400, Edgar Almonte wrote: 
> in debian dont exist a package called nfs-utils , i get nfs-common and
> say the same version of the nfs-utils of archlinux
> not sure about MNT version config , i dont remember intentionally
> changing this , where i can check it ?
> 
> pd: sorry for the double email i forget press reply all
> 
> On Mon, Feb 14, 2011 at 11:56 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > Hi Edgar-
> >
> > On Feb 11, 2011, at 6:46 PM, Edgar Almonte wrote:
> >
> >> hmm i will try update to the last version but is the lasted in
> >> official repository of my distro
> >
> > Yes, that could be a problem.  Out of curiosity, can you tell us what version of nfs-utils is running on the working Debian client you have?
> >
> >> the rpcinfo -p localhost output ( run at the server )
> >>
> >> rpcinfo -p localhost
> >>   program vers proto   port  service
> >>    100000    4   tcp    111  portmapper
> >>    100000    3   tcp    111  portmapper
> >>    100000    2   tcp    111  portmapper
> >>    100000    4   udp    111  portmapper
> >>    100000    3   udp    111  portmapper
> >>    100000    2   udp    111  portmapper
> >>    391002    2   tcp    661  sgi_fam
> >>    100024    1   udp  49216  status
> >>    100024    1   tcp  42903  status
> >>    100003    2   tcp   2049  nfs
> >>    100003    3   tcp   2049  nfs
> >>    100003    4   tcp   2049  nfs
> >>    100227    2   tcp   2049  nfs_acl
> >>    100227    3   tcp   2049  nfs_acl
> >>    100003    2   udp   2049  nfs
> >>    100003    3   udp   2049  nfs
> >>    100003    4   udp   2049  nfs
> >>    100227    2   udp   2049  nfs_acl
> >>    100227    3   udp   2049  nfs_acl
> >>    100021    1   udp  36092  nlockmgr
> >>    100021    3   udp  36092  nlockmgr
> >>    100021    4   udp  36092  nlockmgr
> >>    100021    1   tcp  52268  nlockmgr
> >>    100021    3   tcp  52268  nlockmgr
> >>    100021    4   tcp  52268  nlockmgr
> >>    100005    3   udp  41849  mountd
> >>    100005    3   tcp  46012  mountd

UDP and TCP appear to be running on different ports.

     1. Does running 'sudo netstat -anp' on the server show any other
        processes running on TCP port 41849 or UDP port 46012? 
     2. Does running 'sudo iptables -n -L' on the server show anything
        rejecting TCP connections on port 46012?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

