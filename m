From: Chris Adams <chris@improbable.org>
Subject: Re: Linux NFS client against Auspex server crashes
Date: Thu, 23 Jan 2003 00:47:55 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5DAD3C3C-2EAF-11D7-9E9B-000393965D98@improbable.org>
References: <5CA6F03EF05E0046AC5594562398B9160C780A@POEXMB3.conoco.net>
Mime-Version: 1.0 (Apple Message framework v551)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from fed1mtao02.cox.net ([68.6.19.243])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18bd2D-0004RK-00
	for <nfs@lists.sourceforge.net>; Thu, 23 Jan 2003 00:48:29 -0800
To: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B9160C780A@POEXMB3.conoco.net>
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

On Tuesday, January 21, 2003, at 07:54  AM, Heflin, Roger A. wrote:
> 	I have a group I work with that is using Linux 2.4.19,
> 	NFSALL (Oct-Nov timeframe), they are reporting that their machines
> 	lock up (process space quits responding) on multiple machines running
> 	almost identical jobs (with almost identical start times) at the 
> about same
> 	time.  They are running against a Auspex server of some sort.

I don't know if you've already tried this, but try using UDP mounts if 
you aren't. TCP with our NS2000 was a nightmare with 2.4.x kernels - 
hung processes, odd mount behaviour, hard freezes, etc.

Chris



-------------------------------------------------------
This SF.net email is sponsored by: Scholarships for Techies!
Can't afford IT training? All 2003 ictp students receive scholarships.
Get hands-on training in Microsoft, Cisco, Sun, Linux/UNIX, and more.
www.ictp.com/training/sourceforge.asp
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
