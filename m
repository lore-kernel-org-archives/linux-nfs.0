From: Martin Pool <mbp@sourcefrog.net>
Subject: Re: no_subtree_check questions
Date: Fri, 29 Aug 2003 15:13:40 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030829151340.150a0ae5.mbp@sourcefrog.net>
References: <20030828110309.0e0eff6f.mbp@sourcefrog.net>
	<20030828121410.4ccc4b45.mbp@sourcefrog.net>
	<16206.3062.480403.590086@charged.uio.no>
	<200308290206.49232.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19sba5-0007kk-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 22:13:53 -0700
Received: from sngrel4.hp.com ([192.6.86.110])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19sba4-00034Y-GY
	for nfs@lists.sourceforge.net; Thu, 28 Aug 2003 22:13:52 -0700
Received: from XAUBRG2.AUS.HP.COM (xaubrg2.aus.hp.com [15.23.69.43])
	by sngrel4.hp.com (Postfix) with SMTP id 3DA26E4
	for <nfs@lists.sourceforge.net>; Fri, 29 Aug 2003 13:13:46 +0800 (SST)
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200308290206.49232.bernd-schubert@web.de>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On 29 Aug 2003 Bernd Schubert <bernd-schubert@web.de> wrote:

> Hello,
> 
> as I understand it, the sub_tree_check is only neccessary if the
> filesystem is not exported at its root. Wouldn't it make sense to let
> the nfs-utils automatically recognise that and then automatically set
> the option no_subtree_check? I mean this could be implemented
> easily...

Of course that would just make the behaviour incosistent and hard to
debug.  (I might not have been able to work out what was wrong in the
original bug report, for example.)  I'm not really a fan of fixes that
just fix some circumstances.

> Also, I would like to know what happens if one sets the 
> no_subtree_check-option and re-exports the /etc/exportfs on the server
> or restarts the nfsd, but the clients still have mounted the
> directory? I'm a bit scared since the man-page says that the
> filehandle is modified for this check.

I think the clients need to remount the filesystem, because all the
filehandles become invalid.  Even the root of the filesystem can't be
found.  Perhaps I just did something wrong though.

-- 
Martin 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
