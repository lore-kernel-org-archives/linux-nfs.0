From: Chip Salzenberg <chip@pobox.com>
Subject: Kernel 2.4 and 2.6 disagree about NFSEXP_CROSSMNT - upward incompatibility, please fix
Date: Thu, 31 Jul 2003 11:23:32 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030731182332.GH18733@perlsupport.com>
References: <3F294DE3.9020304@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Neil F. Brown" <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3F294DE3.9020304@RedHat.com>
List-ID: <nfs.lists.sourceforge.net>

According to Steve Dickson:
> It seems in nfs-utils-1.05 (actually it happen in 1.0.4)
> the NFSEXP_CROSSMNT define was changed to 0x4000 ....

This looks like an actual kernel incompatibility 2.4 <-> 2.6, as
the 2.4 and 2.6 trees disagree about the value of NFSEXP_CROSSMNT.

> So could please add this patch that simply switchs the bits
> so NFSEXP_CROSSMNT stays the same and the new NFSEXP_NOHIDE define
> gets the higher bit?

And 2.6's include/linux/nfsd/export.h needs the same fix.  This needs
to go in before the 2.6.0 release or nfs-utils is in deep kimchi.
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K
