From: Douglas Furlong <douglas.furlong@firebox.com>
Subject: Re: NFS server not responding
Date: Fri, 28 Nov 2003 10:48:41 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1070016521.3615.26.camel@wibbit.firebox.com>
References: <1069934421.4677.77.camel@wibbit.firebox.com>
	 <200311280946.06755.jojo@automatix.de>
	 <1070012227.3615.7.camel@wibbit.firebox.com>
	 <200311281111.49153.jojo@automatix.de>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APgBI-0002h0-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 02:49:01 -0800
Received: from dsl-217-155-91-196.zen.co.uk ([217.155.91.196] helo=helium.firebox.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.24)
	id 1APgBI-0001Dc-Bm
	for nfs@lists.sourceforge.net; Fri, 28 Nov 2003 02:49:00 -0800
Received: from localhost (helium.firebox.com [127.0.0.1])
	by helium.firebox.com (8.12.8/8.12.8) with ESMTP id hASAfZ9e011061
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 10:41:35 GMT
Received: from helium.firebox.com ([127.0.0.1])
 by localhost (helium.firebox.com [127.0.0.1]) (amavisd-new, port 10024)
 with LMTP id 10514-05 for <nfs@lists.sourceforge.net>;
 Fri, 28 Nov 2003 10:41:35 +0000 (GMT)
Received: from [192.168.0.150] (wibbit.firebox.com [192.168.0.150])
	by helium.firebox.com (8.12.8/8.12.8) with ESMTP id hASAfIUh011052
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 10:41:18 GMT
To: nfs@lists.sourceforge.net
In-Reply-To: <200311281111.49153.jojo@automatix.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, 2003-11-28 at 10:11, Juergen Sauer wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Am Freitag, 28. November 2003 10:37 schrieb Douglas Furlong:
> MKoin doug,
> 
> > I do indeed have an nvidia card in the machine which is a nVidia
> > Corporation NV11 [GeForce2 MX/MX 400] (rev b2).
>  
> > However on an lsmod the nv.o driver is not being loaded (the machine
> > goes to run level 3 not 5.
> Is the kernel module "nvidia" loaded ?
> Mathew McNally reported the same thing, problems with Nvidia Graphic disturbs
> NFS/Network.
> 
> Perhaps I should be more exactly, my client here has an ASUS A7N8X
> board. This have Nvidia NFORCE2 Chipset, Nvidia Network Chip, 
> and a AGP-Nvidia Gforce 4X Card.
> Using 2.4.18-XFS all is fine, except the speed of the IDE System,
> Using 2.4.22-XFS mostly IDE Speed is fine, System runs fine, 
> except "NFS Server not responding", those errors are fast comming and
> going. nfsstat shows a lot of retrans.

What in your opinion is a lot of retransmissions? Today I am seeing
around 0.7%.
Client rpc stats:
calls      retrans    authrefrsh
23695      166        0       

I am using the standard kernel provided by redhat for this machine.

> 
> > Am I right in saying this should mean the problem does not exist?
> The Problem exists - definitely.
> But it's possible to configure that it does not hurt too much, by lowering
> rsize=4096,wsize=4096 I got a compromise between speed and "NFS server ...".
> 
> I think the only solution is to send bugreports to NVIDIA.
> (Shit closed source, in OSS we had already fixed this junk).
>  
> > I will go and have a look at those archives (only been on the list for a
> > week).
Neither the open-source nor closed source drivers appear to be loaded,
are these drivers only loaded when going to runlevel 5 (or starting x
manually?)?

I have also started to mount the NFS volumes using TCP, I am no longer
getting the NFS server not responding error messages.

However, if this is just hiding a problem i would like to find out for
future reference.

doug



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
