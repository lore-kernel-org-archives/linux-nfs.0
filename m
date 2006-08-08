From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: Can we flush directory data when the ctime changes?
Date: Tue, 8 Aug 2006 09:28:50 -0400
Message-ID: <76bd70e30608080628o616b6f42sc1d559ed2414cb46@mail.gmail.com>
References: <17624.15554.514216.623190@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GARdc-00051K-8x
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 06:28:52 -0700
Received: from wx-out-0506.google.com ([66.249.82.233])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GARdc-0007JJ-J3
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 06:28:52 -0700
Received: by wx-out-0506.google.com with SMTP id r21so794869wxc
	for <nfs@lists.sourceforge.net>; Tue, 08 Aug 2006 06:28:51 -0700 (PDT)
To: "Neil Brown" <neilb@suse.de>
In-Reply-To: <17624.15554.514216.623190@cse.unsw.edu.au>
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

On 8/8/06, Neil Brown <neilb@suse.de> wrote:
>  We have a scenario where readdir in the linux client gets confused by
> responses from a Netapp fileserver.
>
> What happens is that a readdir collects and caches the directory.
> Then a subsequent readdir finds the first page is still in the cache
> but the second page is missing.
> The nfs client uses a cookie from the first page to request subsequent
> entries and received a list of entries starting from the beginning of
> the directory rather than from the point that it was up to.   It seems
> that the cookies have changed.
>
> The GETATTR call that the client makes to validate the cache reports
> that the mtime hasn't change, *but the ctime has*.
>
> I patched the (SLES9) kernel to invalidate the cache for directories
> when the ctime changes and this fixed the problem (which was quite
> repeatable).
>
> While it seems that it should be necessary to flush the dir cache on a
> ctime change, it doesn't seem harmful either.
>
> So: would it be acceptable to do this.  The following patch should
> achieve this in current -mm (which is quite different from the 2.6.5
> kernel where I tested this).
>
> In case it is interesting, I have this commentary from one of our
> support personnel.  I'm not sure if the content comes from someone at
> Netapp or elsewhere, but it sounds plausible.
>
> Thanks,
> NeilBrown
>
>   ......
>
>   For example, NetApp filer support NFS but their file system is not
>   simply a true unix/linux style file system.  They emulate that for
>   NFS purposes but they also handle the file system in special ways
>   for account for CIFS and other access.
>
>   Things go on like files name conversions to unicode, for other name
>   spaces.  These events can take place at much later times than the
>   original file name creation through NFS.  This results in changes in
>   the ctime stamp, without changes to mtime, and it also results in
>   new cookie indexes being generated for the NFS file system.  If an
>   NFS client does not invalidate it's cache upon such a condition, if
>   can result in inconsistent cache information, as it has in the
>   example for which this bug report was filed.

This is reasonable.  Another scenario where ctime could change but
mtime might not is during a restore -- either snaprestore, NDMP copy,
or even an rsync.

However, I thought the latest kernels actually did account for ctime
changes like this....

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
