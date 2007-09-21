From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/18] exportfs: add new methods
Date: Thu, 20 Sep 2007 17:18:40 -0700
Message-ID: <20070920171840.0c6949a6.akpm@linux-foundation.org>
References: <20070919163025.GC18952@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYWEJ-0002Wt-2x
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 17:18:47 -0700
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IYWEL-0004Hq-Rn
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 17:18:52 -0700
In-Reply-To: <20070919163025.GC18952@lst.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 19 Sep 2007 18:30:25 +0200
Christoph Hellwig <hch@lst.de> wrote:

> +		/*
> +		 * It's not a directory.  Life is a little more complicated.
> +		 */
> +		struct dentry *target_dir, *nresult;
> +		char nbuf[NAME_MAX+1];

Lots of stack usage there.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
