From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH] NFS: possible NULL pointer deref in
	nfs_sillyrename()
Date: Thu, 17 Aug 2006 12:05:41 +0200
Message-ID: <9a8748490608170305v53a2fd20q29d12e2a7b7229d4@mail.gmail.com>
References: <200608170022.29168.jesper.juhl@gmail.com>
	<1155773801.6739.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Rick Sladkey <jrs@world.std.com>, Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GDeky-0002z6-TQ
	for nfs@lists.sourceforge.net; Thu, 17 Aug 2006 03:05:44 -0700
Received: from nf-out-0910.google.com ([64.233.182.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GDekw-0003ul-Ip
	for nfs@lists.sourceforge.net; Thu, 17 Aug 2006 03:05:45 -0700
Received: by nf-out-0910.google.com with SMTP id m19so1025372nfc
	for <nfs@lists.sourceforge.net>; Thu, 17 Aug 2006 03:05:42 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1155773801.6739.5.camel@localhost>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 17/08/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Thu, 2006-08-17 at 00:22 +0200, Jesper Juhl wrote:
> > The coverity checker spotted this as bug #1013.
> >
> > If we get a NULL dentry->d_inode, then regardless of
> > NFS_PARANOIA or no NFS_PARANOIA, then if
> >    if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
> > turns out to be false we'll end up dereferencing
> > that NULL d_inode in two places below.
> >
> > And since the check for "(!dentry->d_inode)" even exists
> > (although inside #ifdef NFS_PARANOIA) I take that to mean
> > that this is a possibility.
>
> Sorry, but it isn't possible. See the checks in may_delete() (which is
> called before ->unlink()) and nfs_rename().
>
Thanks, that was useful info.

> IOW: Feel free to kill the NFS_PARANOIA crap. It looks like legacy code
> from a debugging session about a decade or so ago.
>
Sure thing, I'll cook up a patch to do that.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
