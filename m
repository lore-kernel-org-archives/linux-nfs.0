From: Neil Brown <neilb@suse.de>
Subject: Re: Status of mount.nfs
Date: Tue, 10 Jul 2007 10:08:17 +1000
Message-ID: <18066.52721.834619.269830@notabene.brown>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
	<20070709095511.GA17815@uio.no> <4692661B.7080701@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: lamont@debian.org, nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I83HB-00081T-7e
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 17:08:21 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I83HD-0007XO-DJ
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 17:08:24 -0700
In-Reply-To: message from Chuck Lever on Monday July 9
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

On Monday July 9, chuck.lever@oracle.com wrote:
> 
> I just noticed this morning that "./configure --help" in the latest git 
> repo still says this:
> 
>    --enable-mount          Create mount.nfs and don't use the util-linux
>                            mount(8) functionality. [default=no]
>                                                    ^^^^^^^^^^^^

Thanks for noticing that.  It is now fixed in current git.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
