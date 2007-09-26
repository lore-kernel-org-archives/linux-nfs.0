From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/7] Add mount option parsing facility to
	text-based mount.nfs
Date: Wed, 26 Sep 2007 10:59:28 +1000
Message-ID: <18169.44784.512106.346767@notabene.brown>
References: <20070925172637.4845.51938.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaLFa-0004B8-Tq
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 17:59:39 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IaLFd-0008SA-MV
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 17:59:44 -0700
In-Reply-To: message from Chuck Lever on Tuesday September 25
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

On Tuesday September 25, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> Seven more patches for text-based mount.nfs.
> 
> I found that it is necessary to do some rather advanced lexical parsing of
> the mount option string in order to handle version/protocol fallback.  So I've
> implemented a data structure that can handle the parsing requirements, and
> some wrapper logic to convert the mount option string to the new data
> structure and then convert it back to a string before calling mount(2).
> 
> This series introduces the new facility and makes use of it for existing text-
> based mount option processing (like adding "addr=" and so on).  In subsequent
> patches I will make more use of the new facility.

Nice.

However: The current parsing of mount options (parse_opts,
parse_options) allows for "quotes" around options so that an option
can contain a comma (Gumble SELinux Grumble  context=foo,bar Grumble).
Your mount option parsing doesn't allow for this.  Should it?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
