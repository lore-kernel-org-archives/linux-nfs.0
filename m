From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/2] gssd patches
Date: Tue, 11 Sep 2007 17:20:45 +0200
Message-ID: <18150.45645.242629.726957@notabene.brown>
References: <20070907141603.16229.68150.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IV7Z1-00048l-1P
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 08:22:10 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IV7Z3-0001TH-9p
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 08:22:11 -0700
In-Reply-To: message from Kevin Coffman on Friday September 7
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

On Friday September 7, kwc@citi.umich.edu wrote:
> Hi Neil,
> The first patch fixes the dependency checks to now look for
> libgssglue rather than libgssapi.
> The second patch fixes the usage message for gssd to reflect
> the new -M option.
> 
> Thanks,
> K.C.

Thanks.  Applied.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
