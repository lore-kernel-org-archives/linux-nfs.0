From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: 3 NFS client panics in 2.4.21. Fixed in 2.4.22?
Date: Tue, 26 Aug 2003 11:38:39 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200308261138.39667.bernd-schubert@web.de>
References: <Pine.LNX.4.44.0308251617050.26067-400000@fubar.phlinux.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19raIN-00028v-00
	for <nfs@lists.sourceforge.net>; Tue, 26 Aug 2003 02:39:23 -0700
Received: from smtp02.web.de ([217.72.192.151] helo=smtp.web.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19raIL-0003jj-5Y
	for nfs@lists.sourceforge.net; Tue, 26 Aug 2003 02:39:21 -0700
To: Matt C <wago@phlinux.com>,
 NFS List <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.44.0308251617050.26067-400000@fubar.phlinux.com>
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

On Tuesday 26 August 2003 01:20, Matt C wrote:
> hey all-
>
> I've had 3 very similar panics on 3 seperate machines under 2.4.21. All
> appear to be in the NFS client stack. All are SMP/Bigmem machines, and the
> kernel was pretty close to vanilla. All machines are redhat-7.2 using ext3
> filesystems.
>
> Before I hop on the latest kernel out of the hopper for production
> systems, do you know if these are known/fixed bugs in 2.4.22 or in BK?
>
 
I'm afraid there is a critical bug in 2.4.22, please see the thread:

[NFS] nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10


I havn't tested it with 2.4.22-rc3 and rc4, but I didn't see anything in the 
changelog, that could fix it :-(


Regards,
	Bernd



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
