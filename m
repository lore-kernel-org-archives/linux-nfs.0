From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 13:21:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40895096.9020507@RedHat.com>
References: <40892507.2030004@RedHat.com>	 <1082730973.2617.23.camel@lade.trondhjem.org> <40893DEF.3010506@RedHat.com> <1082737270.2617.80.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH4MT-0005OF-G7
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 10:21:13 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BH4MT-0002qQ-1g
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 10:21:13 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1082737270.2617.80.camel@lade.trondhjem.org>
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

>Even if you do solve the above race, you still have another bug: you are
>changing the object that the "struct file" refers to, and hence at best
>you are going to cause all the existing open files to start reading
>from/writing to the new file (which is a bug!) instead of returning
>ESTALE.
>  
>
Ok... this is the silver bullet that got me... :(

Question: if (atomic_read(&dentry->d_count) < 2)
can I assume that the current process is the only one
attached to the dentry and it would be safe reinstantiate
the dentry?

SteveD.



-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
