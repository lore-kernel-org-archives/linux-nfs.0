From: Hurf Sheldon <linux@graphics.cornell.edu>
Subject: NFS on linux (Redhat) questions
Date: Fri, 09 Aug 2002 13:55:00 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.1.0.14.2.20020809132700.01b34798@pop.graphics.cornell.edu>
References: <E17dAjG-0002Sd-00@usw-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="=====================_356589109==_.ALT"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bach.graphics.cornell.edu ([128.84.247.50])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17dDzf-00049c-00
	for <nfs@lists.sourceforge.net>; Fri, 09 Aug 2002 10:56:11 -0700
Received: from barn.graphics.cornell.edu (barn.graphics.cornell.edu [128.84.247.210])
	by bach.graphics.cornell.edu (8.12.1/8.12.1) with ESMTP id g79HuL0k079657
	for <nfs@lists.sourceforge.net>; Fri, 9 Aug 2002 13:56:21 -0400 (EDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <E17dAjG-0002Sd-00@usw-sf-list2.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

--=====================_356589109==_.ALT
Content-Type: text/plain; charset="us-ascii"; format=flowed

Hi Folks,
We have a few 4cpu Xeon 550 servers we wanted to make
central file servers, each with .5tb of ide->scsi raid on them.
We currently run FreeBSD on our servers; for several reasons,
Rh7.3 looked like a good replacement.
Using the standard iso's for Rh 7.3
Rh 7.3 installed nicely, picking up the Intel 1000 gb interface,
the 4 cpu's  the ncr and  adaptec scsi interfaces, etc.

Mounting our existing servers on the Rh7.3  (2.4.18-3smp kernel)
from various FreeBSD systems resulted in timeouts and
poor performance. Making the Rh7.3 system the server, mounts to
other Rh7.3 systems and to the FreeBSD systems were not workable.
Setting rsize, wsize to 1024 made the connections workable but
trying to set up Rh7.3 nfs install server, where the parameters on the
boot client can't be set didn't work.
So, in quick summary:
Default NFS from FreeBSD systems to the Rh7.3 requires rsize,wsize=1024,
NFS betwixt Rh7.3 systems also required this to work.

We found your resource pages, subscribed to the newsgroup
and read the archives. What we found was disconcerting - it appears that
NFS under Linux is problematic at best.

We would like to use Rh7.3 for our server platforms but we need some guidance
re: setting up a reliable production machine that we didn't find in the 
resources - how
best to get & keep current the pertinent code, build & replace kernels, etc.

What do IBM, HP & Dell do for their Linux server line? Do we want to get Rh
Enterprise or some other Linux flavor? (reminds me of the "All Unix systems are
alike, only different" from a decade ago) Or should we stick with the FreeBSD
for NFS reliability?

We are digesting so if you care to respond directly, please do.

kind regards,

hurf
Hurf Sheldon
Program of Computer Graphics
580 Rhodes Hall, Hoy Rd.
Cornell University
Ithaca, N.Y. 14853

voice:607 255 6713 fax:607 255 0806
email: hurf@graphics.cornell.edu
http://www.graphics.cornell.edu/~hurf/




--=====================_356589109==_.ALT
Content-Type: text/html; charset="us-ascii"

<html>
Hi Folks,<br>
We have a few 4cpu Xeon 550 servers we wanted to make <br>
central file servers, each with .5tb of ide-&gt;scsi raid on them.<br>
We currently run FreeBSD on our servers; for several reasons,<br>
Rh7.3 looked like a good replacement. <br>
Using the standard iso's for Rh 7.3<br>
Rh 7.3 installed nicely, picking up the Intel 1000 gb interface,<br>
the 4 cpu's&nbsp; the ncr and&nbsp; adaptec scsi interfaces, etc.
<br><br>
Mounting our existing servers on the Rh7.3&nbsp; (2.4.18-3smp
kernel)<br>
from various FreeBSD systems resulted in timeouts and <br>
poor performance. Making the Rh7.3 system the server, mounts to<br>
other Rh7.3 systems and to the FreeBSD systems were not workable.<br>
Setting rsize, wsize to 1024 made the connections workable but<br>
trying to set up Rh7.3 nfs install server, where the parameters on
the<br>
boot client can't be set didn't work. <br>
So, in quick summary:<br>
Default NFS from FreeBSD systems to the Rh7.3 requires
rsize,wsize=1024,<br>
NFS betwixt Rh7.3 systems also required this to work.<br><br>
We found your resource pages, subscribed to the newsgroup<br>
and read the archives. What we found was disconcerting - it appears
that<br>
NFS under Linux is problematic at best.<br><br>
We would like to use Rh7.3 for our server platforms but we need some
guidance<br>
re: setting up a reliable production machine that we didn't find in the
resources - how<br>
best to get &amp; keep current the pertinent code, build &amp; replace
kernels, etc.<br><br>
What do IBM, HP &amp; Dell do for their Linux server line? Do we want to
get Rh<br>
Enterprise or some other Linux flavor? (reminds me of the &quot;All Unix
systems are<br>
alike, only different&quot; from a decade ago) Or should we stick with
the FreeBSD<br>
for NFS reliability?<br><br>
We are digesting so if you care to respond directly, please do.<br><br>
kind regards,<br><br>
hurf<br>
<font face="Courier New, Courier">Hurf Sheldon <br>
Program of Computer Graphics<x-tab>&nbsp;&nbsp;&nbsp;&nbsp;</x-tab>&nbsp;
<br>
580 Rhodes Hall, Hoy Rd. <br>
Cornell University&nbsp; <br>
Ithaca, N.Y. 14853&nbsp; <br><br>
voice:607 255 6713 fax:607 255 0806<br>
email: hurf@graphics.cornell.edu<br>
<a href="http://www.graphics.cornell.edu/~hurf/" eudora="autourl">http://www.graphics.cornell.edu/~hurf/</a><br><br>
<br><br>
</font></html>

--=====================_356589109==_.ALT--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
