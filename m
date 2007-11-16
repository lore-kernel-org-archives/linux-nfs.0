From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: Re: [PATCH 1/2] nfsd: move nfsd/auth.h into fs/nfsd
Date: Fri, 16 Nov 2007 04:15:14 -0500 (EST)
Message-ID: <alpine.LFD.0.9999.0711160414150.27074@localhost.localdomain>
References: <1195167232-30238-1-git-send-email-bfields@citi.umich.edu>
	<18236.58569.175370.275493@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <18236.58569.175370.275493@notabene.brown>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 16 Nov 2007, Neil Brown wrote:

> On Thursday November 15, bfields@citi.umich.edu wrote:
> > This header is used only in a few places in fs/nfsd, so there seems to
> > be little point to having it in include/.  (Thanks to Robert Day for
> > pointing this out.)
> >
> > Cc: Robert P. J. Day <rpjday@crashcourse.ca>
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>
>
> Yes, good.

and i'm sure i don't need to point this out but, if you move headers
out from under include/linux, make sure you delete their references
from the Kbuild files as well.

rday
--

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs
