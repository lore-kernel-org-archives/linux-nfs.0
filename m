From: Bernd Schubert <bernd-schubert@web.de>
Subject: no_subtree_check questions
Date: Fri, 29 Aug 2003 02:06:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200308290206.49232.bernd-schubert@web.de>
References: <20030828110309.0e0eff6f.mbp@sourcefrog.net> <20030828121410.4ccc4b45.mbp@sourcefrog.net> <16206.3062.480403.590086@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19sWq6-0001Ea-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 17:10:06 -0700
Received: from smtp03.web.de ([217.72.192.158] helo=smtp.web.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19sWq6-0004HZ-BD
	for nfs@lists.sourceforge.net; Thu, 28 Aug 2003 17:10:06 -0700
To: trond.myklebust@fys.uio.no,
 Martin Pool <mbp@sourcefrog.net>
In-Reply-To: <16206.3062.480403.590086@charged.uio.no>
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

Hello,

as I understand it, the sub_tree_check is only neccessary if the filesystem is 
not exported at its root. Wouldn't it make sense to let the nfs-utils 
automatically recognise that and then automatically set the option 
no_subtree_check? I mean this could be implemented easily...

Also, I would like to know what happens if one sets the 
no_subtree_check-option and re-exports the /etc/exportfs on the server or 
restarts the nfsd, but the clients still have mounted the directory?
I'm a bit scared since the man-page says that the filehandle is modified for 
this check.
Though we never had problems like Martin (at least we didn't notice), I don't 
think this check makes sense in our environment.

Thanks,
	Bernd



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
