From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.17.8 - do_vfs_lock: VFS is out of sync with
	lock	manager!
Date: Mon, 21 Aug 2006 15:54:58 -0400
Message-ID: <1156190098.6158.109.camel@localhost>
References: <9a8748490608080739w2e14e5ceg44a7bf0a3b475704@mail.gmail.com>
	<17636.4462.975774.528003@cse.unsw.edu.au>
	<9a8748490608170258s32df0272r60c8c540e5871485@mail.gmail.com>
	<17641.10665.116168.867041@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jesper Juhl <jesper.juhl@gmail.com>, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GFFrh-0000jt-2O
	for nfs@lists.sourceforge.net; Mon, 21 Aug 2006 12:55:17 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GFFrf-0000EF-BF
	for nfs@lists.sourceforge.net; Mon, 21 Aug 2006 12:55:17 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17641.10665.116168.867041@cse.unsw.edu.au>
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

On Mon, 2006-08-21 at 13:34 +1000, Neil Brown wrote:
> Looking in fs/nfs/file.c (at 2.6.18-rc4-mm1 if it matters, but 2.6.17
> is much the same)
> 
>  - do_vfs_lock is only called when the filesystem was mounted with
>     -o nolock  EXCEPT
>  - If a lock request to the server in interrupted (when mounted with
>      -o intr) then do_vfs_lock is called to try to get the lock
>     locally.  Normally equivalent code will be called inside
>     fs/lockd/clntproc.c when the server replies that the lock has been
>     gained.  In the case of an interrupt though this doesn't happen
>     but the lock may still have happened on the server.  So we record
>     locally that the lock was gained, to ensure that it gets unlocked
>     when the process exits.
> 
> As you don't have '-o nolocks' you must be hitting the second case.
> The lock call to the server returns -EINTR or -ERESTARTSYS and
> do_vfs_lock is called just-in-case.  
> As this is a just-in-case call, it is quite possible that the lock is
> held by some other process, so getting an error is entirely possible.
> So printing the message in this case seems wrong.
> 
> On the other hand, printing the message in any other case seems wrong
> too, as server locking is not being used, so there is nothing to get
> out of sync with.
> 
> As a further complication, I don't think that in the just-in-case
> situation that it should risk waiting for the lock.
> Now maybe we can be sure there is a pending signal which will break
> out of any wait (though I'm worried about -ERESTARTSYS - that doesn't
> imply a signal does it?), but I would feel more comfortable if
> FL_SLEEP were turned off in that path.
> 
> So: Trond:  Any obvious errors in the above?
> Is the following patch ok?

Could we instead replace it with a dprintk() that returns the value of
"res"? That will keep it useful for debugging purposes.

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
