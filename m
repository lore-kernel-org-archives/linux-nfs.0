From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfs export switchs to readonly
Date: Wed, 7 Aug 2002 20:47:42 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15696.64206.236004.309806@notabene.cse.unsw.edu.au>
References: <20020802140019.D26C5352D0@credativ.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cOLP-0006sx-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 03:47:11 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <oliver.korff@credativ.de>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 7 Aug 2002 20:47:01 +1000
To: Oliver Korff <oliver.korff@credativ.de>
In-Reply-To: message from Oliver Korff on Friday August 2
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

On Friday August 2, oliver.korff@credativ.de wrote:
> Hi, 
> 
> I've the following trouble: 
> after some hard traffic or a nfs restart my exports sometimes switches to 
> "ro". I don't have that problem if I boot the server first and all clients 
> connect afterwards. But that gets a little messy because I've got 110 
> clients....
> If I use "exportfs -rv" this usually solves the problem, but not always. 
> 
> 
> kernelversion 2.4.18
> nfs Version 1.0
> distribution: debian/woody
>  
> cat /var/lib/nfs/xtab | grep myotherhost
>  /data01 
> myotherhost.foo.bar(ro,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,
> secure_locks,mapping=identity,anonuid=-2,anongid=-2)
> 
> # /etc/exports: the access control list for filesystems which may be exported
> #		to NFS clients.  See exports(5).
> #
> /data01	myhost.foo.bar(rw,no_root_squash)
> /data01	my*.foo.bar(rw)
> /data01	www-linux.foo.bar(rw)
> /data01	*.foo.bar(ro)

You have an ambiguity here.  You have three different rules that apply
to myhost.for.bar.  One is clearly more explicit and so is used.
But myotherhost.foo.bar could clearly match two rules, and it is not
obvious (to a computer) that one match is more explicit than another.
So I guess you get pot-luck.
You need to find a way to be more explicit.
Maybe:
> /data01	myhost.foo.bar(rw,no_root_squash)
> /data01	my*.foo.bar(rw)
> /data01	www-linux.foo.bar(rw)
> /data01	[^m]*.foo.bar(ro)
> /data01	?[^y]*.foo.bar(ro)

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
