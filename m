From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: Stale File handles keep coming back
Date: Fri, 29 Apr 2005 09:01:07 +0200
Message-ID: <4271DBB3.3090402@bio.ifi.lmu.de>
References: <1114463253.2487.73.camel@localhost.localdomain>	<17006.13241.129839.558300@cse.unsw.edu.au>	<1114554149.4470.5.camel@localhost.localdomain> <17006.64544.860436.620665@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Kris Vassallo <kris@linuxcertified.com>,
	nfs@lists.sourceforge.net, Olaf Kirch <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DRPUw-0007nM-68
	for nfs@lists.sourceforge.net; Fri, 29 Apr 2005 00:01:14 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DRPUt-0003bz-Jm
	for nfs@lists.sourceforge.net; Fri, 29 Apr 2005 00:01:14 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <17006.64544.860436.620665@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi all,

just for the records: I'm experiencing the same problem after
I upgraded from the SuSE kernel 2.6.8-24.11 to 2.6.8-24.14
(official SuSE update). The PC server and the client are running
the 2.6.8-24.14 kernel, we have an additional NFS server running
the SLES 9 kernel-pseries64-2.6.5-7.151.

Our users have exactly the same symptoms, either on their homes
or on directories mounted from the pSeries. It happens when
they e.g. have an xterm with a shell and chdir to a directory,
do sth. in there, and then leave the shell untouched for say 30
minutes. After this time, they do a "ls" and get

ls: .: Stale NFS file handle

Calling "cd .." and then "cd <former_directory>", the ls works
again.

I'm currently trying to the cut the environment down to a base
scenario by e.g. throwing out all other NFS mounts that we have
from other domains etc. I will try the things you proposed and
send the results here.

Just to report that... Maybe it makes it easier to find the bug when
it's known to happen in 2.4 and 2.6...

cu,
Frank


-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
