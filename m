From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Fri, 1 Nov 2002 11:54:39 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15809.53455.211796.730215@notabene.cse.unsw.edu.au>
References: <20021031.082927.74744491.taka@valinux.co.jp>
	<15808.28897.595522.855723@notabene.cse.unsw.edu.au>
	<20021031.110659.42769812.taka@valinux.co.jp>
	<20021101.004052.85418463.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187Q5Q-0001gn-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 16:54:56 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Fri, 1 Nov 2002 11:54:43 +1100
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Friday November 1
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

On Friday November 1, taka@valinux.co.jp wrote:
> Hello,
> 
> > The rest of the zero copy stuff should fit in quite easily, with the
> > possible exception of single-copy writes: I haven't looked very hard
> > at that yet.
> 
> I just ported part of the zero copy stuff against linux-2.5.45.
> single-copy writes and per-cpu sokcets are not included yet.
> And I fixed a problem that NFS over TCP wouldn't work. 
> 
> 
> va-nfsd-sendpage.patch        ....use sendpage instead of sock_sendmsg.
> va-sunrpc-zeropage.patch      ....zero filled page for padding.
> va-nfsd-vfsread.patch         ....zero-copy nfsd_read/nfsd_readdir.

A lot of this looks fine.

I would like to leave the tail pointing into the end of the first page
(just after the head) rather than using the sunrpc_zero_page thing as
the later doesn't seem necessary.
Also, I would like to send the head and tail with sendpage rather
than using sock_sendmsg.
To give the destination address, you can call sock_sendmsg with
a length of 0, and then call ->sendpage for each page or page
fragment.


You should be able to remove the calls to svcbuf_reserve in
nfsd_proc_readdir and nfsd3_proc_readdir, and then discard the
'buffer' variable as well.


If you could make those changes (or convince me otherwise), I will
forward the patches to Linus,
Thanks.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
