From: Nicolas Kowalski <Nicolas.Kowalski@imag.fr>
Subject: Re: high server load when quotas exceeded
Date: Thu, 30 Oct 2003 16:51:13 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <vqoznfibu6m.fsf@astazou.imag.fr>
References: <vqowuaotjec.fsf@astazou.imag.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AFF4y-0002CO-00
	for <nfs@lists.sourceforge.net>; Thu, 30 Oct 2003 07:51:20 -0800
Received: from imag.imag.fr ([129.88.30.1])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AFF4x-0000bD-GD
	for nfs@lists.sourceforge.net; Thu, 30 Oct 2003 07:51:19 -0800
Received: from rechasse.imag.fr (rechasse.imag.fr [129.88.43.87])
	by imag.imag.fr (8.12.10/8.12.10) with ESMTP id h9UFpEWQ028231
	for <nfs@lists.sourceforge.net>; Thu, 30 Oct 2003 16:51:14 +0100 (CET)
Received: from astazou.imag.fr.imag.fr (kowalski@astazou.imag.fr [129.88.43.102])
	by rechasse.imag.fr (8.12.10+Sun/8.12.10/ImagV2.1.pm) with ESMTP id h9UFpD8M000225
	for <nfs@lists.sourceforge.net>; Thu, 30 Oct 2003 16:51:14 +0100 (MET)
To: nfs@lists.sourceforge.net
In-Reply-To: <vqowuaotjec.fsf@astazou.imag.fr> (Nicolas Kowalski's message
 of "Wed, 29 Oct 2003 11:42:19 +0100")
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

Nicolas Kowalski <Nicolas.Kowalski@imag.fr> writes:

> When a user on a NFS client (Linux or Solaris) exceeds his quota on
> the home directory, but continues to write data on it, the nfsd
> processes on the server takes almost all CPU and the server becomes
> irresponsive, until the user stop his writes.
>
> The NFS server is running 2.4.22-xfs, Debian GNU/Linux 3.0.
> The NFS mounts do not have any particular options (intr).
>
> Any tips about this ?

Anyone? 
What additional information can I provide for debugging this?

Thanks.

-- 
Nicolas



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
