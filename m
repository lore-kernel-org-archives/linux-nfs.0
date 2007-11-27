From: Rui Pedro Mendes Salgueiro <rps-G7wE2RHCdwNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [NFS] NFS Digest, Vol 18, Issue 70 (NFS performance problems)
Date: Tue, 27 Nov 2007 18:40:50 +0000
Message-ID: <20071127184050.GA13791@dolly1.mat.uc.pt>
References: <47445727.5090705@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ix5MW-0003gj-UU
	for nfs@lists.sourceforge.net; Tue, 27 Nov 2007 10:40:49 -0800
Received: from dolly1.mat.uc.pt ([193.137.102.5])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ix5Mc-0004mT-Fn
	for nfs@lists.sourceforge.net; Tue, 27 Nov 2007 10:40:55 -0800
In-Reply-To: <47445727.5090705@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Thanks for the replies, everyone. Last week I didn't had the time to
send this mail. Some comments below:

On Wed, Nov 21, 2007 at 11:04:55AM -0500, Chuck Lever wrote:
> Wendy Cheng wrote:
> >Peter Staubach wrote:
> >>Wendy Cheng wrote:

> >>>Intuitively (based on ext3's journal threads info above) I would 
> >>>suspect this is due to the change of the export default option from 
> >>>"async" to "sync" between 2.6.9 and 2.6.18 kernels.

The problem with that idea is that my /etc/exports file had (always ?) the
"sync" option on. (I checked a backup file from 2005-03-14). I think the
Suse management software already used the "sync" option in /etc/exports.
(probably when I first transitioned the server to linux I used whatever
YAST chose as default).

The default export might have been "async", but unless the option "sync"
in /etc/exports was being ignored I was already using "sync". Nevertheless
I will try to change to async and test if it makes a difference.

(one day later: )

I have now tried it and the load on the NFS server is much lower and KDE
logins seem to be reasonably fast now.

This doesn't mean that the drop in performance was due to "sync" versus
"async".  That is, the old version could be really using "sync" and for
some other change (not a change from "async" to "sync") the performance
dropped a lot between those versions.

One thing I suspected was quotas since the old version didn't seem to
handle them. But that was the first thing I tried, turn off quotas
and see if it made a difference. It didn't.

BTW, part of the problem is due to KDE doing a lot of file activity.
I already knew that fvwm (what I personally use) did not take a long
time to login and I have now tried gnome which also started fast enough
(with "sync"). But KDE used to work...

> >>> So go to your 
> >>>/etc/exports file and explicitly set the export option to "async" to 
> >>>see whether you can get the performance back.

> >>While this may or may not restore your performance aspects, it
> >>is not safe to make this change.  The change was made for a
> >>reason.

> That means his old system would have been exposed to data corruption 
> issues if it crashes (panic,

Luckly it has been reliable. Some years ago (a previous server) crashed
a lot but that was due to an obscure bug (XFS + SMP kernel + NFS = crash,
IIRC) which I don't know if it was ever fixed:

http://groups.google.com/group/alt.os.linux.suse/browse_frm/thread/f24dd8f878bb3ea3/7e6ffa45f3873716?hl=en&lnk=st#7e6ffa45f3873716

> power outage,

Of course, the server is on an UPS.

And of course, some hours after I wrote the above, the UPS had an hickup
and the server crashed during the middle of the night.  We had to change
its batteries.

> It's another case of where we perform better in older kernels but we are 
> more correct in recent kernels... but our users don't appreciate the 
> correctness improvement :-)

The correctness improvement doesn't matter if the performance is so low
that you can't use it. I hope this has solved the problem, because I was
getting desperate. I had thought about abandoning NFS in linux and trying
openBSD, but so many things would be different (RAID, filesystems, backups)
that I really didn't want to.

BTW, is what I am doing rare ? I have about 50 linux computers (including
the mail server) mounting user areas from the NFS server. (Most of the
time only some of them are being used.) The users use mostly KDE (because
it has been the default option in SUSE for the past few years). This
sort of setup allows an user to login in any of the computers and to
have the same environment. So I would expect it to be widely used. But
when I asked about this in other places I never got a reply of the kind
"I am doing the same, and it works for me".



Thanks again.
-- 
rps

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

