From: Ion Badulescu <ionut@badula.org>
Subject: Re: Re: [autofs] Server/client mismatch over status of a mount ...
Date: Wed, 19 Feb 2003 08:58:14 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302191358.h1JDwECX026719@buggy.badula.org>
References: <1199.195.252.45.39.1045648619.squirrel@www.zytor.com>
Cc: <nfs@lists.sourceforge.net>, <autofs@linux.kernel.org>,
   <trond.myklebust@fys.uio.no>, <james-p@moving-picture.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lUk9-0006O2-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 05:58:37 -0800
To: "H. Peter Anvin" <hpa@zytor.com>
In-Reply-To: <1199.195.252.45.39.1045648619.squirrel@www.zytor.com>
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

On Wed, 19 Feb 2003 01:56:59 -0800 (PST), H. Peter Anvin <hpa@zytor.com> wrote:

> Well, it does, but the test is a sieve, rather than a true test, as there
> is no protection against race conditions.  It's mostly there to avoid the
> high overheard of the umount operation when it's not necessary or
> desirable.
> 
> A user can come in between the test and the umount request, and autofs
> depends on /bin/umount signalling error without harmful side effects.

Isn't autofs v4 supposed to fix this? I remember Jeremy mentioning that
the filesystem would lock all accesses to a dentry scheduled to be 
unmounted until the daemon replied to the request.

In fact, from his web page:

Previously, when the kernel sent an expire message to the daemon it was 
more an hint than anything else. Now the kernel makes certain that the 
tree isn't busy before sending an expire message to the daemon. It also 
blocks all new users of the tree until the umount is complete, so that 
they can't see a partially mounted tree.

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
