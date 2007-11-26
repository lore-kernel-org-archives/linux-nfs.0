From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] NFS Digest, Vol 18, Issue 70 (NFS performance problems)
Date: Mon, 26 Nov 2007 05:02:30 +0000
Message-ID: <20071126050230.GD21120@fieldses.org>
References: <mailman.194659.1195581701.26582.nfs@lists.sourceforge.net>
	<BAY104-W43766F661E50E7FFCDA8EBA7F0@phx.gbl>
	<47434ED7.4010100@redhat.com> <47435049.1010800@redhat.com>
	<47445727.5090705@oracle.com> <474A3D6B.2060208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: chuck.lever@oracle.com, nfs@lists.sourceforge.net
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IwW7A-0008D8-SR
	for nfs@lists.sourceforge.net; Sun, 25 Nov 2007 21:02:36 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IwW7G-0003Zk-Kw
	for nfs@lists.sourceforge.net; Sun, 25 Nov 2007 21:02:43 -0800
In-Reply-To: <474A3D6B.2060208@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sun, Nov 25, 2007 at 10:28:43PM -0500, Wendy Cheng wrote:
> Chuck Lever wrote:
> 
> > Hi Wendy-
> >
> > That means his old system would have been exposed to data corruption 
> > issues if it crashes (panic, power outage, etc).  Using "sync" became 
> > default because async is inherently careless about data integrity.  
> > The data loss is often entirely silent.
> >
> > This is explained in the Linux NFS FAQ, question B6.
> >
> > See http://nfs.sourceforge.net/index.php#faq_b6
> 
> 
> Setting aside NFS for a moment...  for a locally mounted filesystem, the 
> file data stays in the cache until write-back occurs. Upon crashing, 
> there are always possibilities that the data could be lost. Journaling 
> filesystems such as EXT3 can only ensure no meta-data corruption, there 
> is no guarantee that data would be saved unless the filesystem is 
> mounted with "sync" option. With non-trivial performance hits, most of 
> the filesystems are hardly mounted with "sync" option. Applications 
> normally understand the problem and whenever required, fsync() and/or 
> similar mechanisms are applied.

As far as I know, even an explicit fsync() is ineffective in the case of
NFSv2 when the async export option is set.  (With v3 and v4 I think it
still works, since (from a quick check of the code) it does respect the
stable flag even on async exports.)

An application on a local disk goes down when the system goes down,
whereas an NFS server can reboot without the applications using it
exiting.

So while a well-designed application might be built to deal with the
situation where a mkdir() that a previous instance performed is no
longer there when it starts up again, it may not be ready to deal with a
directory it just created simply diseappearing out from under it while
it's running.

(Stupid question: what would it take to give NFS the equivalent to
COMMIT for directory operations?)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

