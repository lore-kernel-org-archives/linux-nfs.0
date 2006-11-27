From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: 2.6.17.8 - do_vfs_lock: VFS is out of sync with lock
	manager!
Date: Mon, 27 Nov 2006 10:19:29 +0100
Message-ID: <9a8748490611270119pc812377veec5a4de7c27337@mail.gmail.com>
References: <9a8748490608080739w2e14e5ceg44a7bf0a3b475704@mail.gmail.com>
	<17636.4462.975774.528003@cse.unsw.edu.au>
	<9a8748490608170258s32df0272r60c8c540e5871485@mail.gmail.com>
	<17641.10665.116168.867041@cse.unsw.edu.au>
	<1156190098.6158.109.camel@localhost>
	<9a8748490611210443w7711b962u3fb35aef14746582@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GoceA-0005B5-WE
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 01:19:31 -0800
Received: from nz-out-0102.google.com ([64.233.162.198])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GoceB-0005kC-0X
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 01:19:32 -0800
Received: by nz-out-0102.google.com with SMTP id i11so979860nzi
	for <nfs@lists.sourceforge.net>; Mon, 27 Nov 2006 01:19:30 -0800 (PST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <9a8748490611210443w7711b962u3fb35aef14746582@mail.gmail.com>
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

Any chance we could get the patch below (or something similar) pushed
into 2.6.19?


On 21/11/06, Jesper Juhl <jesper.juhl@gmail.com> wrote:
> On 21/08/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > On Mon, 2006-08-21 at 13:34 +1000, Neil Brown wrote:
> > > Looking in fs/nfs/file.c (at 2.6.18-rc4-mm1 if it matters, but 2.6.17
> > > is much the same)
> > >
> > >  - do_vfs_lock is only called when the filesystem was mounted with
> > >     -o nolock  EXCEPT
> > >  - If a lock request to the server in interrupted (when mounted with
> > >      -o intr) then do_vfs_lock is called to try to get the lock
> > >     locally.  Normally equivalent code will be called inside
> > >     fs/lockd/clntproc.c when the server replies that the lock has been
> > >     gained.  In the case of an interrupt though this doesn't happen
> > >     but the lock may still have happened on the server.  So we record
> > >     locally that the lock was gained, to ensure that it gets unlocked
> > >     when the process exits.
> > >
> > > As you don't have '-o nolocks' you must be hitting the second case.
> > > The lock call to the server returns -EINTR or -ERESTARTSYS and
> > > do_vfs_lock is called just-in-case.
> > > As this is a just-in-case call, it is quite possible that the lock is
> > > held by some other process, so getting an error is entirely possible.
> > > So printing the message in this case seems wrong.
> > >
> > > On the other hand, printing the message in any other case seems wrong
> > > too, as server locking is not being used, so there is nothing to get
> > > out of sync with.
> > >
> > > As a further complication, I don't think that in the just-in-case
> > > situation that it should risk waiting for the lock.
> > > Now maybe we can be sure there is a pending signal which will break
> > > out of any wait (though I'm worried about -ERESTARTSYS - that doesn't
> > > imply a signal does it?), but I would feel more comfortable if
> > > FL_SLEEP were turned off in that path.
> > >
> > > So: Trond:  Any obvious errors in the above?
> > > Is the following patch ok?
> >
> > Could we instead replace it with a dprintk() that returns the value of
> > "res"? That will keep it useful for debugging purposes.
> >
>
> How about the below?
> (compile tested only)
>
> Neil: I left your Signed-off-by line since I just modified your patch slightly.
>
> Since Gmail will probably mangle the inline patch, it is attached as well.
>
>
> Signed-off-by: Neil Brown <neilb@suse.de>
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
> --
>
>  fs/nfs/file.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index cc93865..22572af 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -428,8 +428,8 @@ static int do_vfs_lock(struct file *file
>                         BUG();
>         }
>         if (res < 0)
> -               printk(KERN_WARNING "%s: VFS is out of sync with lock
> manager!\n",
> -                               __FUNCTION__);
> +               dprintk("%s: VFS is out of sync with lock manager (res
> = %d)!\n",
> +                               __FUNCTION__, res);
>         return res;
>  }
>
> @@ -479,10 +479,13 @@ static int do_setlk(struct file *filp, i
>                  * we clean up any state on the server. We therefore
>                  * record the lock call as having succeeded in order to
>                  * ensure that locks_remove_posix() cleans it out when
> -                * the process exits.
> +                * the process exits. Make sure not to sleep if
> +                * someone else holds the lock.
>                  */
> -               if (status == -EINTR || status == -ERESTARTSYS)
> +               if (status == -EINTR || status == -ERESTARTSYS) {
> +                       fl->fl_flags &= ~FL_SLEEP;
>                         do_vfs_lock(filp, fl);
> +               }
>         } else
>                 status = do_vfs_lock(filp, fl);
>         unlock_kernel();
>



-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
