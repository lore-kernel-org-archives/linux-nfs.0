From: jladerm1 <jacob@jhu.edu>
Subject: Re: Group Permissions
Date: Mon, 10 Feb 2003 15:15:26 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.05.10302101512120.686-100000@dc02.clsp.jhu.edu>
References: <E18iK8N-0001BK-00@sc8-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.clsp.jhu.edu ([128.220.34.27])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18iKGm-0005Ay-00
	for <nfs@lists.sourceforge.net>; Mon, 10 Feb 2003 12:11:12 -0800
Received: from mailhost.clsp.jhu.edu (mailhost.clsp.jhu.edu [10.0.5.11])
	by mail.clsp.jhu.edu (8.9.3/8.9.3) with ESMTP id PAA11247
	for <nfs@lists.sourceforge.net>; Mon, 10 Feb 2003 15:11:09 -0500 (EST)
Received: from dc02.clsp.jhu.edu (dc02.clsp.jhu.edu [10.0.5.3])
	by mailhost.clsp.jhu.edu (8.9.3/8.9.3) with ESMTP id PAA00962
	for <nfs@lists.sourceforge.net>; Mon, 10 Feb 2003 15:14:27 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <E18iK8N-0001BK-00@sc8-sf-list2.sourceforge.net>
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

If you are using NIS or YP, use netgroup to restrict the group
access.  You can also use NIS to remap all the gids so that only
the ones you want are allowed.
---------------------------------------------------------------
Jacob, System Admin at Center for Language & Speech Processing 
mail: jacob@jhu.edu 			   voice: 410-516-4787 




-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
