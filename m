From: Ion Badulescu <ionut@badula.org>
Subject: Re: Heavy problems with NFS (2.4.20)
Date: Fri, 21 Feb 2003 13:42:32 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302211842.h1LIgV5q013279@buggy.badula.org>
References: <Pine.LNX.4.44.0302211302001.5569-100000@g31.physik.fu-berlin.de>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18mI8L-0002yg-00
	for <nfs@lists.sourceforge.net>; Fri, 21 Feb 2003 10:42:53 -0800
To: Tobias Burnus <tobias.burnus@physik.fu-berlin.de>
In-Reply-To: <Pine.LNX.4.44.0302211302001.5569-100000@g31.physik.fu-berlin.de>
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

On Fri, 21 Feb 2003 13:06:25 +0100 (CET), Tobias Burnus <tobias.burnus@physik.fu-berlin.de> wrote:
> On 20 Feb 2003, Trond Myklebust wrote:
>> You might perhaps consider using an automounter. Either amd or autofs
>> should do the job.

Actually an automounter is not going to help you at all if the 
filesystem is already mounted. Certainly not if the culprits are "df" 
and "quota", since they both bypass the automounter.

> We actually us autofs (v4), but I suspect that some of the problems might
> even come from it (high kernel load), given the problems we have with it
> so far. (Such that `autofs reload' may start more than one userspace
> daemon per one mountpoint, which races causes similar problems (and huge
> logs).)

You should never have to issue autofs reload, by the way. It rescans its 
maps whenever it detects a timestamp change on them.

> Seems as if we have to live with it :-(

More or less, yes. If you *need* to run "df" and "quota" all the time, 
you really have no choice.

The best you can do is a manual lazy umount (umount -l), but it really
does have to be run manually on every machine. You can't (easily)
automate it, because umount -l always succeeds, even if the filesystem
is busy.

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
