From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 07/11] NFS: fix minor bug in new NFS symlink code
Date: Fri, 20 Oct 2006 00:57:49 -0400
Message-ID: <76bd70e30610192157q3c2252b4s62e7bf985b4b487d@mail.gmail.com>
References: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
	<20061019170432.8171.49033.stgit@lade.trondhjem.org>
	<20061019212541.b2adc4b2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Linus Torvalds <torvalds@osdl.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GamS7-0008Kg-UK
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 21:57:53 -0700
Received: from ug-out-1314.google.com ([66.249.92.170])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GamS7-0002dD-OH
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 21:57:53 -0700
Received: by ug-out-1314.google.com with SMTP id p27so601548ugc
	for <nfs@lists.sourceforge.net>; Thu, 19 Oct 2006 21:57:50 -0700 (PDT)
To: "Andrew Morton" <akpm@osdl.org>
In-Reply-To: <20061019212541.b2adc4b2.akpm@osdl.org>
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

On 10/20/06, Andrew Morton <akpm@osdl.org> wrote:
> On Thu, 19 Oct 2006 13:04:32 -0400
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
>
> > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > index 58d4405..c86a1ea 100644
> > --- a/fs/nfs/dir.c
> > +++ b/fs/nfs/dir.c
> > @@ -1519,8 +1519,8 @@ static int nfs_symlink(struct inode *dir
> >       pagevec_init(&lru_pvec, 0);
> >       if (!add_to_page_cache(page, dentry->d_inode->i_mapping, 0,
> >                                                       GFP_KERNEL)) {
> > -             if (!pagevec_add(&lru_pvec, page))
> > -                     __pagevec_lru_add(&lru_pvec);
> > +             pagevec_add(&lru_pvec, page);
> > +             pagevec_lru_add(&lru_pvec);
> >               SetPageUptodate(page);
> >               unlock_page(page);
> >       } else
>
> One could export add_to_page_cache_lru() to modules..

I assumed there was probably a good reason that this had not already been done.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
