From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [NFS] NFS Digest, Vol 18, Issue 70 (NFS performance problems)
Date: Sun, 25 Nov 2007 22:28:43 -0500
Message-ID: <474A3D6B.2060208@redhat.com>
References: <mailman.194659.1195581701.26582.nfs@lists.sourceforge.net>	<BAY104-W43766F661E50E7FFCDA8EBA7F0@phx.gbl>	<47434ED7.4010100@redhat.com>
	<47435049.1010800@redhat.com> <47445727.5090705@oracle.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IwUOW-0002A2-MH
	for nfs@lists.sourceforge.net; Sun, 25 Nov 2007 19:12:24 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IwUOc-0002Wp-G9
	for nfs@lists.sourceforge.net; Sun, 25 Nov 2007 19:12:30 -0800
In-Reply-To: <47445727.5090705@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Chuck Lever wrote:

> Hi Wendy-
>
> That means his old system would have been exposed to data corruption 
> issues if it crashes (panic, power outage, etc).  Using "sync" became 
> default because async is inherently careless about data integrity.  
> The data loss is often entirely silent.
>
> This is explained in the Linux NFS FAQ, question B6.
>
> See http://nfs.sourceforge.net/index.php#faq_b6


Setting aside NFS for a moment...  for a locally mounted filesystem, the 
file data stays in the cache until write-back occurs. Upon crashing, 
there are always possibilities that the data could be lost. Journaling 
filesystems such as EXT3 can only ensure no meta-data corruption, there 
is no guarantee that data would be saved unless the filesystem is 
mounted with "sync" option. With non-trivial performance hits, most of 
the filesystems are hardly mounted with "sync" option. Applications 
normally understand the problem and whenever required, fsync() and/or 
similar mechanisms are applied.

For Linux NFS servers to deviate from this common practice, by reading 
the FAQ, I assume something has been done (particularly from client 
ends) to alleviate the performance hit ? Could you elaborate more about 
this ?

Again, I'm not trying to argue and/or start a flamewar. I have a need to 
understand more about this issue. The "sync" operation is very expensive 
for us (cluster filesystem) and I'm under the gun to improve our NFS 
file serving performance at this moment.

-- Wendy



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

