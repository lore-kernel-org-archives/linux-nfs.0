From: Tobias Burnus <tobias.burnus@physik.fu-berlin.de>
Subject: Re: Heavy problems with NFS (2.4.20)
Date: Sat, 22 Feb 2003 13:15:36 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302221311530.4628-100000@g31.physik.fu-berlin.de>
References: <200302211842.h1LIgV5q013279@buggy.badula.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from down.physik.fu-berlin.de ([160.45.34.6])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18mYZf-000445-00
	for <nfs@lists.sourceforge.net>; Sat, 22 Feb 2003 04:16:11 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <200302211842.h1LIgV5q013279@buggy.badula.org>
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

Hi,

On Fri, 21 Feb 2003, Ion Badulescu wrote:
> You should never have to issue autofs reload, by the way. It rescans its
> maps whenever it detects a timestamp change on them.
Only if you don't change auto.master, since the init scripts
scans auto.master and for each entry starts a new automount process.

> > Seems as if we have to live with it :-(
> More or less, yes. If you *need* to run "df" and "quota" all the time,
> you really have no choice.
Well, we don't need to, but our users have the tendency to have to much
data - therefore we need to check the quota for $HOME.

> The best you can do is a manual lazy umount (umount -l), but it really
I will try this the next time a computer really crashes hard.

Thanks for the tips,

Tobias



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
