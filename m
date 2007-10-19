From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: nfsv2 ref leak in 2.6.24?
Date: Fri, 19 Oct 2007 17:40:21 -0400
Message-ID: <200710192140.l9JLeLEO004110@agora.fsl.cs.sunysb.edu>
References: <1192801277.7073.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de,
	Erez Zadok <ezk@cs.sunysb.edu>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IizaE-0005TB-QJ
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:40:42 -0700
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IizaH-0006wb-U6
	for nfs@lists.sourceforge.net; Fri, 19 Oct 2007 14:40:48 -0700
In-reply-to: Your message of "Fri, 19 Oct 2007 09:41:16 EDT."
	<1192801277.7073.4.camel@heimdal.trondhjem.org>
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

In message <1192801277.7073.4.camel@heimdal.trondhjem.org>, Trond Myklebust writes:
> 
> On Fri, 2007-10-19 at 01:49 -0400, Erez Zadok wrote:
> > I'm testing unionfs on top of nfsv2/3/4, using 2.6.24 as of linus's commit
> > 4fa4d23fa20de67df919030c1216295664866ad7.  A lot of my unionfs regression
> > tests are failing on nfs2, b/c files that should be deleted, aren't.  It
> > feels like there may be a ref leak that prevents the files from being
> > deleted, or maybe an unlink issue.  It doesn't happen in all of my previous
> > kernels w/ identical unionfs (code 2.6.9--2.6.23).  And in 2.6.24 it happens
> > only w/ nfs2 -- nfs3/4 are fine.
> > 
> > I'm not sure if this is a client or server issue, and I'm only starting to
> > dig deeper.  But I thought I'd ask you in case this is a known problem and
> > you have a fix.  If this is the first you hear of this problem, let me know
> > and I'll try to narrow it down further.
> 
> A couple of questions:
> 
>       * Are these files being sillyrenamed?
>       * Are they shown as being removed by the server?
> 
> Cheers
>   Trond

Trond, I was able to narrow down the problem w/o using unionfs at all (yay!
:-).  All I do is setup a loop device, mkfs it as ext2, mount it, then
export it to localhost and mount it locally as nfs2.  I go and touch a new
file in the ext2 directory.  Then I readdir the export point to find the new
file indeed.  Then I stat(1) the new file, and get the appropriate stat
output.  Now the strange thing is that right after the stat through the
export point, the file DISAPPEARS from the lower ext2 dir, but REAPPEARS a
few seconds later.

It doesn't happen all the time, so it feels like some sort of a race or
timing-related bug.  And it only happens w/ nfs2 on 2.6.24 (v3/4 work fine;
v2/3/4 work find in previous kernels).

I'm trying to get a script that'll be able to reproduce this for you more
deterministically.

BTW, does your just-posted set of patches, subject "[GIT] NFS client fixes
for 2.6.23++" possibly fix this?  I can try it and let you know.

Hope this helps for now.

Erez.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
