From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] Rename log() to note() due to conflict with ISO standard
Date: Fri, 22 Aug 2003 20:08:40 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16197.60328.487765.298563@gargle.gargle.HOWL>
References: <20030820215835.GA14355@perlsupport.com>
	<20030821161815.GI14355@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19q8qk-0005gV-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Aug 2003 03:08:54 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 22 Aug 2003 20:08:49 +1000
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Thursday August 21
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

On Thursday August 21, chip@pobox.com wrote:
> As I wrote before:
> > ISO C reserves the names of standard functions.  It's not legal to
> > define a function called log(), and even though gcc happens to permit
> > it, the permission comes only with obnoxious warnings.
> 
> So this is a patch to rename log() to note().  I'm not totally fond of
> the name note(); and if we keep it I'll also rename the L_ constants to
> N_ for consistency.  Comments?

lprintf printl Log mesg 

None significantly better than 'note', some worse.
I did think of "pxe" (exp backwards) or "branch", but those are just
sick puns.

Is it really illegal even if you don't #include <math.h> ??

But I am happy with you patch,
thanks,
NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
