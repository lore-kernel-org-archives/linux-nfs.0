From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: Re: patch 01/38: switches in fs/Config.in, fs/Config.help
Date: Wed, 14 Aug 2002 15:13:27 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <10696.1970836439$1029352813@news.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f3aI-0004SQ-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 12:13:34 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


>>>>> " " == Christoph Hellwig <hch@infradead.org> writes:

     > On Tue, Aug 13, 2002 at 06:55:35PM -0400, Kendrick M. Smith
     > wrote:
    >> This patch defines new switches in fs/Config.in -
    >> CONFIG_NFS_V4: enables nfsv4 client CONFIG_NFSD_V4: enables
    >> nfsv4 server CONFIG_SUNRPC_GSSD_CLNT: enables in-kernel client
    >> for GSSD

     > This should be the last patch after the code got in..

I agree, patch 1/38 should be renumbered to 38/38, and everything else
shifted back by one.  If I have to repost the patchset (e.g. after rediff
to 2.5.32), I'll be sure to do this.

In the meantime, patch 1/38 does not conflict with any of the others;
the patches can be applied cleanly in the order
  2,3,4,....,38, 1
Maybe we can just consider this to be the patch ordering for purposes of
deciding which to apply to the 2.5.31 tree?  This way I won't have to
repost 200K of patches before 2.5.32 comes out...

Thanks,
 Kendrick



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
