From: Christoph Hellwig <hch@infradead.org>
Subject: Re: patch 01/38: switches in fs/Config.in, fs/Config.help
Date: Wed, 14 Aug 2002 13:37:12 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <14361.5291956396$1029328893@news.gmane.org>
References: <Pine.SOL.4.44.0208131854000.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from phoenix.infradead.org ([195.224.96.167])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17exOr-00027u-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 05:37:21 -0700
To: "Kendrick M. Smith" <kmsmith@umich.edu>
In-Reply-To: <Pine.SOL.4.44.0208131854000.25942-100000@rastan.gpcc.itd.umich.edu>; from kmsmith@umich.edu on Tue, Aug 13, 2002 at 06:55:35PM -0400
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

On Tue, Aug 13, 2002 at 06:55:35PM -0400, Kendrick M. Smith wrote:
> This patch defines new switches in fs/Config.in -
>   CONFIG_NFS_V4:  enables nfsv4 client
>   CONFIG_NFSD_V4: enables nfsv4 server
>   CONFIG_SUNRPC_GSSD_CLNT: enables in-kernel client for GSSD

This should be the last patch after the code got in..



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
