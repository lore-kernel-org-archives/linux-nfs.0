From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Re: [PATCH v2] reduce NFS stack usage
Date: Thu, 25 Sep 2003 17:10:52 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F7359DC.10301@RedHat.com>
References: <mailman.1064420466.30286.linux-kernel2news@redhat.com>	<3F7335B4.1070002@RedHat.com> <mailman.1064518981.2825.linux-kernel2news@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2dNz-0003Wm-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 14:10:51 -0700
Received: from pix-525-pool.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2dNy-0004kO-E4
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 14:10:50 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <mailman.1064518981.2825.linux-kernel2news@redhat.com>
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


Trond Myklebust wrote:
> 
> There are always alternatives...
> 
> If really this is a problem, how about slabifying the structs
> nfs_fattr and/or nfs_fh?
Why is allocating memory from a "private" slab is faster than
using a general purpose one (i.e. GFP_KERNEL)?
Something to do with lock contention?

> 
> Also, since nfs_entry is only large due to the fh and fattr fields
> which are unused unless you have READDIRPLUS (in which case they are
> converted to pointers anyhow), how about kicking them out of
> nfs_entry altogether?
That would take care of readdirs...

SteveD.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
