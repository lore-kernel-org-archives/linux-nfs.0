From: Neil Brown <neilb@suse.de>
Subject: Re: Possible jiffy wrap-around problem in NFS client.
Date: Sat, 3 Feb 2007 15:23:26 +1100
Message-ID: <17860.3646.225734.104702@notabene.brown>
References: <17858.40219.500690.988191@notabene.brown>
	<1170438835.5890.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDCRU-0003wE-3K
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 20:24:39 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HDCRV-0001rP-7e
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 20:24:02 -0800
In-Reply-To: message from Trond Myklebust on Friday February 2
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

On Friday February 2, trond.myklebust@fys.uio.no wrote:
> On Fri, 2007-02-02 at 13:08 +1100, Neil Brown wrote:
> > Hi Trond (and anyone else who might know...)
> > 
> >  I'm chasing an apparent NFS client problem, and I'm wondering if it
> >  could be a jiffy-wrap around problem.
> > 
> >  In particular, ->cache_change_attribute.
> > 
> >  This seems to be set to 'jiffies' only when the inode is first
> >  allocated, or when we have changed the file, or when a GETATTR or wcc
> >  shows that the file has changed.
> >  So if a file is unchanged on the server, cache_change_attribute will
> >  not change after it is first assigned.
> > 
> >  If the file remains in cache for 24 days (2^31 jiffies at 1000Hz),
> > 	data_stable = nfs_verify_change_attribute(inode, fattr->time_start);
> > 	if (data_stable)
> > 		nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_ATIME);
> >  in nfs_update_inode will start clearing those flags (as
> >  cache_change_attribute will always be in the future) and so will
> >  trigger more GETATTR requests.
> > 
> >  Could this be correct?
> 
> ...but if the file isn't changing on the server, why would any of the
> above flags be set in the first place? Is this a situation in which the
> client is writing to the file?

Thanks for the reality check...  there were several aspects of this I
got wrong.

No, the client isn't writing to the file.  

I said that clearing the flags would trigger  a getattr, but of course
*not* clearing the flags with trigger a getattr *only* if they are set
already.
And as the files aren't changed, the flags won't get set.... almost.

The one thing that can change is the atime.  If NFS_INO_INVALID_ATIME
gets set, then any 'stat' or 'fstat' call will trigger a GETATTR.

If just once, nfs_refresh_inode discovers that fattr->time_start is
after nfsi->last_updated(*), it will call nfs_check_inode_attributes
and a changed atime will cause NFS_INO_INVALID_ATIME to be set.

This can only be cleared by nfs_update_inode if 'data_stable', but if
we have jiffie wraparound on cache_change_attribute, that doesn't
happen. (I checked with the customer and things go bad at 24 days -
2^31 milliseconds).

So once you get jiffie wrap on ->cache_change_attribute, and then a
call to nfs_check_inode_attributes after an atime update, every fstat
will trigger a GETATTR.

Looking that the debug trace again, it looks like the client is
opening a file, 'fstat'ing it a few times, then closing it.  There is
no mmap or read or anything.
The application on the client is a webserver and many of the files are
application libraries (I'm guessing a scripting language, but I'm not
certain).  So maybe the webserver caches the parsed script and just
checks periodically that the file hasn't changed.
(There are a bunch of image files that get hit a lot too, but I have
reason to believe they are being used by the application rather than
just served out).

Some of these files typically get 4 fstats per open (all within one
second).  When the NFS client is working 'properly', this generates
one GETATTR to the server.  When we hit jiffie wrap-around, this
increases to 5 GETATTRS to the server (assuming my guesses are
correct).
This is enough to double the getattr rate.

So: I still think we need to check for jiffie-wrap on
cache_change_attribute,  but I think now I'm a little clearer on why
:-)

BTW, I discovered that none of the dprintks or dfprintks in file.c
are working.  I think we need
   #include <linux/sunrpc/debug.h>
in nfs_fh.h, but I just saw mail that suggests you already know this :-)


(*) I was having trouble seeing how nfs_refresh_inode would ever see
time_start as after last_updated, but it only needs to see it
after-or-equal.  Maybe if nfs_update_inode ran in the same jiffie that
someone opens the file and causes another GETATTR request to start
....  I think I'll just get the patch tested and let you know in 3
weeks how it went.


Thanks,

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
