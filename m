From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 12:01:51 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40893DEF.3010506@RedHat.com>
References: <40892507.2030004@RedHat.com> <1082730973.2617.23.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH37T-0003I7-Ry
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 09:01:39 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BH37T-0002B9-EA
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 09:01:39 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1082730973.2617.23.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>There are several problems here, but the main one is that you have no
>guarantees that you are the exclusive user of that dentry.
>  
>
True, there are no guarantees the user has exclusive access but
what does it matter? Its a stale inode if they try to used its
going to fail...

>This again means that people who think they have open files on the "old"
>inode may suddenly find their program Oopsing or corrupting the new
>file. 
>
Again, this new fh is only gotten on getattrs any other ops will still
fail with ESTALE...


SteveD


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
