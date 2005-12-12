From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH kNFSd ] Check error status from vfs_getattr and
 i_op->fsync
Date: Mon, 12 Dec 2005 16:11:44 +1100
Message-ID: <17309.1680.482774.920851@cse.unsw.edu.au>
References: <1051128014127.24572@cse.unsw.edu.au>
	<1134087942.500655.14993.nullmailer@yamt.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Elfyo-0003mK-A1
	for nfs@lists.sourceforge.net; Sun, 11 Dec 2005 21:12:06 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Elfym-0003Qz-Sn
	for nfs@lists.sourceforge.net; Sun, 11 Dec 2005 21:12:06 -0800
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
In-Reply-To: message from YAMAMOTO Takashi on Friday December 9
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday December 9, yamamoto@valinux.co.jp wrote:
> 
> it reminded me of a similar diff in our local tree.  (attached)
> it's fsync part only but more complete.
> 

Thanks.  I've merged and revised it a bit and will submit it shortly.

Are there any other nfs patches in your local tree that you would like
to share ?? ;-)

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
