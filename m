From: pwitting@Cyveillance.com
Subject: RE: processes stuck in D state
Date: Tue, 6 May 2003 13:09:10 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <D38AFB3080F3D311807300B0D0203E53033A9572@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain
Cc: fsdeveloper@yahoo.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.100.163.50] (helo=mercury.cyveillance.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D5wZ-0002O8-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 10:09:32 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Actually, I have seen this on the server before, specifically
When using an older version of IBM's JFS for Linux with RH 7.3

I worked with the JFS team and JFS v1.1.0 and kernel 2.4.20 
seemed to stabilize it, at least I've seen no more "freezes"
as a result. Judging by your mail address this might be your 
problem as well.

One noticeable symptom is that cd'ing to an affected dir and 
attempting an ls would also freeze (I had a large (20GB+) file 
copy going, so I usually knew what the affected dir was.

Two other things that helped:
1) increasing the # of nfs threads (120 or more)
2) ensuring the uid/gid the remote thread was using existed on 
the server. (sounds stupid but it helped)

neither "cured" the issue, but it went from being reproducible 
to being occasional.

Good Luck.

> From: "Lever, Charles" <Charles.Lever@netapp.com>
>
> i'm not sure why you mailed neilb -- this appears to
> be NFS client related, not server related.
> 
> can you spell out the sequence of events that leads
> to the stuck processes?  it looks like the client
> is working-as-designed, but if you can provide more
> details, we can verify what's going on.
> 
>> -----Original Message-----
>> From: Michael Buesch [mailto:fsdeveloper@yahoo.de]
>> Sent: Tuesday, May 06, 2003 10:52 AM
>> To: neilb@cse.unsw.edu.au
>> Cc: nfs@lists.sourceforge.net
>> Subject: [NFS] processes stuck in D state
>>
>> Please take a look at this problem:
>>
>> [linux-kernel-mailing-list thread]
>> http://marc.theaimsgroup.com/?t=3D98639966100003&r=3D1&w=3D2
>>
>> thanks.
>> Please cc me, as I'm not subscribed to the nfs-list.



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
