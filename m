From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/2] nfsd: move nfsd/auth.h into fs/nfsd
Date: Fri, 16 Nov 2007 11:31:05 +1100
Message-ID: <18236.58569.175370.275493@notabene.brown>
References: <1195167232-30238-1-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org,
	"Robert P. J. Day" <rpjday@crashcourse.ca>, nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: message from J. Bruce Fields on Thursday November 15
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

On Thursday November 15, bfields@citi.umich.edu wrote:
> This header is used only in a few places in fs/nfsd, so there seems to
> be little point to having it in include/.  (Thanks to Robert Day for
> pointing this out.)
> 
> Cc: Robert P. J. Day <rpjday@crashcourse.ca>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>


Yes, good.

 Acked-by: NeilBrown <neilb@suse.de>

But it does beg the question: what other include files could/should be
moved?
 cache.h and xdr*.h all seem like good candidates.

Is it worth doing?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
