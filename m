From: Dan Yocum <yocum@fnal.gov>
Subject: RPC: Unable to allocate resbuf from cache! - revisited
Date: Fri, 03 Jan 2003 09:06:48 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E15A708.50102@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from heffalump.fnal.gov ([131.225.9.20] helo=fnal.gov)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18UTPO-0008N5-00
	for <nfs@lists.sourceforge.net>; Fri, 03 Jan 2003 07:06:50 -0800
Received: from fnal.gov ([131.225.7.82]) by smtp.fnal.gov (PMDF V6.0-24 #37519)
 with ESMTP id <0H85002FP8NCKJ@smtp.fnal.gov> for nfs@lists.sourceforge.net;
 Fri, 03 Jan 2003 09:06:49 -0600 (CST)
To: nfs list <nfs@lists.sourceforge.net>
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

Hi all,

Looking back at the archives=20
(http://marc.theaimsgroup.com/?t=3D101707335800002&r=3D1&w=3D2) I see tha=
t you=20
(Trond) say that these copious "RPC: Unable..." messages shouldn't be a=20
problem.  Could they be a problem?

The reason I ask is, occassionally, we're getting these strange files=20
created with 0 size, date, and some gobble-dee-gook names, and they just =
so=20
happen to show up when we get this error message in the logs.  Here's wha=
t=20
one looks like:

bash-2.04$ ls -l |egrep -v '(fit|ps|fp|mem)'
total 5742612
-rwxr-xr-x    1 jen_a    sdss            0 Dec 31  1969
:N=A8TL8=D5 =E4=F0=FF=FF=EB=FE=FF=F5@                                    =
  =A6,

The rest of the files are OK, but this is slightly disconcerting.

This is 2.4.18 + XFS + NFS_ALL - rpc_tweaks, IIRC (it's been a long time =

since I've built this kernel). The system has 2GB RAM and 4GB swap (himem=
 is=20
  enabled).

Any thoughts?

Thanks,
Dan



--=20
Dan Yocum
Sloan Digital Sky Survey, Fermilab  630.840.6509
yocum@fnal.gov, http://www.sdss.org
SDSS.  Mapping the Universe.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
