From: Ion Badulescu <ionut@badula.org>
Subject: Re: Too many mounts
Date: Thu, 6 Mar 2003 09:07:00 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200303061407.h26E70ts023427@buggy.badula.org>
References: <87adg8iovd.fsf@fiona.informatik.gu.se>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=buggy.badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18qw1n-0000Xs-00
	for <nfs@lists.sourceforge.net>; Thu, 06 Mar 2003 06:07:20 -0800
To: Jonas Oberg <jonas@informatik.gu.se>
In-Reply-To: <87adg8iovd.fsf@fiona.informatik.gu.se>
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

On Thu, 06 Mar 2003 14:52:22 +0100, Jonas Oberg <jonas@informatik.gu.se> wrote:
> In our department we have a problem with our student server. It
> appears that the Linux kernel limits the number of anonymous (nfs
> et. al) mounts to 256. This is a problem for us, since we use
> automount to mount home directories from our fileserver via NFS. We
> are frequently in the range of 190-220 active mounts (we have set the
> automount timeout to be about 30 seconds to get rid of idle mounts
> quickly).
> 
> Does anyone have a solution for this problem? Would using devfs
> perhaps solve the problem by allowing more anonymous mounts?

The solution is to mount the entire home filesystem(s), not each 
student's home individually.

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
