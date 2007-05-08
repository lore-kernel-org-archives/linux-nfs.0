From: Neil Brown <neilb@suse.de>
Subject: Re: time_after cannot be used alone by NFS code	in 32bit
	architectures
Date: Tue, 8 May 2007 16:19:20 +1000
Message-ID: <17984.5736.617053.65429@notabene.brown>
References: <20070426043344.GO10449@sleipnir.redhat.com>
	<1178106770.5960.28.camel@raven.themaw.net>
	<1178591824.3918.10.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs <nfs@lists.sourceforge.net>
To: Ian Kent <raven@themaw.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlJ3D-00047s-Kg
	for nfs@lists.sourceforge.net; Mon, 07 May 2007 23:19:55 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HlJ3F-00034S-Ry
	for nfs@lists.sourceforge.net; Mon, 07 May 2007 23:19:58 -0700
In-Reply-To: message from Ian Kent on Tuesday May 8
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tuesday May 8, raven@themaw.net wrote:
> On Wed, 2007-05-02 at 19:52 +0800, Ian Kent wrote:
> > On Thu, 2007-04-26 at 01:33 -0300, Fabio Olive Leite wrote: 
> > > This leads to several problematic situations in long-lived NFS mounts.
> > > We can see old attributes not being updated, negative dentries that do
> > > not revalidate even after touching their parent dir, etc.
> > > 
> > 
> > This is quite an interesting issue and I'm still having trouble
> > understanding it so let me try and explain my understanding of part of
> > it.
> > 
> 
> snip ...
> 
> > So the problem you describe actually happens when the directory inode
> > cache_change_attribute warps and the dentry d_fstada timestamp is later
> > than inode cache_change_attribute. So updating the
> > cache_change_attribute field, as in the patch that Neil referred to,
> > will often not fix it.
> 
> I believe the patch that Neil refers to will ensure that the inode
> cache_change_attribute is updated to a reasonably recent time.
> 
> > 
> > Have I got this right yet?
> 
> No response so I guess so!

Maybe....

I'm still having trouble picturing the exact failure mode.

The only one I can see is:

   Perform a lookup of "foo/bar".
     Find that it doesn't exist.
     Create a negative dentry
   Wait 24 days (jiffie wrap time)
     During this time the negative dentry
     is never looked at, and doesn't fall out of cache.
   Some other access on 'foo' makes sure its
     change attributes is uptodate
   Now try to look at foo/bar again.  Due to
     jiffie wrap, it doesn't seem to be necessary to
     revalidate, so we don't.

Having the negative dentry remain in cache for 24 days while untouched
seems unlikely?

If this is the problem situation, then just updating the jiffie stamp
on the negative dentry whenever it is seem to be in the future
wouldn't work because we hardly ever look at it.  I think the best
solution would be to somehow to force dcache entries out before the
jiffie stamp had a chance to wrap.  But I not convinced that doesn't
happen already simply because 24days is a LONG time.
   

> 
> Then how about this patch.

As far as I can see, all it does is store the same number (jiffies) in
a larger field (a struct timespec) but doesn't actually do anything
different.



Are we sure this actually is a problem in practice??

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
