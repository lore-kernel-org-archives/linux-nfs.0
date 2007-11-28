From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] NFS Digest, Vol 18, Issue 70 (NFS performance problems)
Date: Tue, 27 Nov 2007 20:50:12 -0500
Message-ID: <B0812F5A-2580-444A-930B-E45C1D6C1D9A@oracle.com>
References: <20071127184050.GA13791@dolly1.mat.uc.pt>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Rui Pedro Mendes Salgueiro <rps-G7wE2RHCdwNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxC4w-0004cT-1N
	for nfs@lists.sourceforge.net; Tue, 27 Nov 2007 17:51:06 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IxC51-00025d-PE
	for nfs@lists.sourceforge.net; Tue, 27 Nov 2007 17:51:12 -0800
In-Reply-To: <20071127184050.GA13791-/uZbGGhPd8Gmv2Aub4FSgw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Nov 27, 2007, at 1:40 PM, Rui Pedro Mendes Salgueiro wrote:
> Thanks for the replies, everyone. Last week I didn't had the time to
> send this mail. Some comments below:
>
> On Wed, Nov 21, 2007 at 11:04:55AM -0500, Chuck Lever wrote:
>> Wendy Cheng wrote:
>>> Peter Staubach wrote:
>>>> Wendy Cheng wrote:

>>>>> So go to your
>>>>> /etc/exports file and explicitly set the export option to  
>>>>> "async" to
>>>>> see whether you can get the performance back.
>
>>>> While this may or may not restore your performance aspects, it
>>>> is not safe to make this change.  The change was made for a
>>>> reason.
>
>> That means his old system would have been exposed to data corruption
>> issues if it crashes (panic,
>
> Luckly it has been reliable. Some years ago (a previous server)  
> crashed
> a lot but that was due to an obscure bug (XFS + SMP kernel + NFS =  
> crash,
> IIRC) which I don't know if it was ever fixed:
>
> http://groups.google.com/group/alt.os.linux.suse/browse_frm/thread/ 
> f24dd8f878bb3ea3/7e6ffa45f3873716?hl=en&lnk=st#7e6ffa45f3873716
>
>> power outage,
>
> Of course, the server is on an UPS.
>
> And of course, some hours after I wrote the above, the UPS had an  
> hickup
> and the server crashed during the middle of the night.  We had to  
> change
> its batteries.
>
>> It's another case of where we perform better in older kernels but  
>> we are
>> more correct in recent kernels... but our users don't appreciate the
>> correctness improvement :-)
>
> The correctness improvement doesn't matter if the performance is so  
> low
> that you can't use it.

I was being a bit facetious.

We won't ever make something "so correct it performs terribly" (on  
purpose, anyway).  There have been many cases where performance  
regressed significantly in certain corner cases where we don't have  
adequate testing, however.

In this case, async behavior in the worst case was so egregious that  
it had to be changed.  For NFSv3, the use of UNSTABLE writes usually  
mitigates the performance lost by using the "sync" export option.

> BTW, is what I am doing rare ? I have about 50 linux computers  
> (including
> the mail server) mounting user areas from the NFS server. (Most of the
> time only some of them are being used.) The users use mostly KDE  
> (because
> it has been the default option in SUSE for the past few years). This
> sort of setup allows an user to login in any of the computers and to
> have the same environment. So I would expect it to be widely used. But
> when I asked about this in other places I never got a reply of the  
> kind
> "I am doing the same, and it works for me".

50 clients shouldn't be a strain for the protocol itself.  However,  
your server may be just powerful enough for the old load, but the  
extra file activity during KDE login was just enough to push it over  
the edge to become unusable.

Further analysis of exactly how the clients are now behaving during  
login might be helpful in diagnosing how the server needs to change  
to handle the new load.  The fact that switching to "async" made a  
difference suggests that the new KDE login process adds a healthy  
write workload (as opposed to adding more READs or GETATTRs).  That  
is a helpful clue!

RAID 5 and NFS are particularly finicky together.  Lots of small  
random access writes, for instance, will quickly drive RAID 5 into  
the ground.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

