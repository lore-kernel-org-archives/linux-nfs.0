From: Raphael Clifford <cliffor@rockefeller.edu>
Subject: jumbo frames and performance
Date: Mon, 17 Jun 2002 15:12:17 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D0E3491.10309@rockefeller.edu>
References: <E17K1pY-00014i-00@usw-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.rockefeller.edu ([129.85.1.21])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17K1vG-0004se-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Jun 2002 12:12:18 -0700
Received: from rockefeller.edu (willa.rockefeller.edu [129.85.52.204])
	by mail.rockefeller.edu (8.11.6/8.11.6) with ESMTP id g5HJCEo26665
	for <nfs@lists.sourceforge.net>; Mon, 17 Jun 2002 15:12:14 -0400 (EDT)
To: nfs@lists.sourceforge.net
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

Would you mind explaining the two performance points below a bit further 
and maybe putting them in the FAQ?  They look very interesting. 
 Regarding the "sync" option, why does not having it incur extra costs 
at the server?
Cheers,
Raphael


>It also looks like you are not using jumbo frames, which 
>Trond has mentioned as a big performance boost for tcp in 
>100 baseT full duplex environments.
>
>Also, since you're using 0.3.3 utils, I assume you are 
>using sync exports; otherwise there are costs at the server 
>which are hidden from the benchmark data.
>
>Tom
>
>  
>




_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
