From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsroot problems on RedHat 8 with kernel linux-2.4.18-27.8.0
Date: 23 May 2003 14:51:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs4r3lx1ux.fsf@charged.uio.no>
References: <3ECE0EF3.5080004@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19JC1Q-00037c-00
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 05:51:44 -0700
To: martynas@ti.com
In-Reply-To: <3ECE0EF3.5080004@ti.com>
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

>>>>> " " == Martynas Buozis <martynas@ti.com> writes:

     > Hello I have problems with nfsroot module when root file system
     > is shared on EMC Cellerra. The problem is, that Celerra needs
     > the

     > client's name and IP address to authenticate the mount
     > request. This information is usually sent through the RPC
     > authentication data. But nfsroot module does not send this data
     > during mount, so Celerra denies request. This was a conclusion
     > by EMC support after analyzing network's traffic between disk
     > less station and Celerra.


     > I was looking what can be changed in
     > /usr/src/linux-2.4/fs/nfs/nfsroot.c code, but I am not very
     > experienced in this. Maybe somebody can help me to solve this
     > problem ? Maybe that's wrong file were too look for changes ? 
     > Is it possible to make changes like this and is it possible to
     > get official fix fro this problem ?

Look at Documentation/nfsroot.txt and/or the comments in
net/ipv4/ipconfig.c. That will tell you how to specify the hostname.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
