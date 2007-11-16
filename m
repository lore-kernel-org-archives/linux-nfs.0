From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 8 patches cleaning up nfsd initialization
Date: Thu, 15 Nov 2007 22:19:40 -0500
Message-ID: <20071116031940.GB18909@fieldses.org>
References: <1195163823-24609-1-git-send-email-bfields@citi.umich.edu>
	<18236.59173.34694.832163@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <18236.59173.34694.832163@notabene.brown>
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

On Fri, Nov 16, 2007 at 11:41:09AM +1100, Neil Brown wrote:
> On Thursday November 15, bfields@citi.umich.edu wrote:
> > While working on something unrelated I noticed nfsd tends to ignore a
> > lot of memory allocation failures on initialization.  I don't think
> > we'eve seen a bug report here--such failures are probably nearly
> > nonexistant.  But still it seems a minor bug in most cases not to catch
> > such failures.
> > 
> > My guess is that one of the motivations for the current behavior, in the
> > case of failures to create /proc entries, was to continue to allow nfsd
> > to function in kernels with no proc support whatsoever.
> > 
> > However in kernels that do have proc support failure to create such
> > entries should be treated as fatal.  So, I add some #ifdef's to handle
> > this case explicitly.
> > 
> > I also add "select PROC_FS" when nfsv4 or gss are selected, since those
> > newer features don't function at all without proc.
> > 
> > Look reasonable?
> 
> Yes, all Acked-by: NeilBrown <neilb@suse.de>
> 
> The cleanup of the cache_unregister call sites is very nice.  It is a
> pity that the cache_register sites become more ugly, but I think it is
> the right thing to do.

OK, thanks.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
