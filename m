From: Bill Johnstone <beejstone3@yahoo.com>
Subject: Expected NFS behavior?
Date: Fri, 17 Feb 2006 13:48:00 -0800 (PST)
Message-ID: <20060217214800.9612.qmail@web37415.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FADSR-0002g9-Is
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 13:48:07 -0800
Received: from web37415.mail.mud.yahoo.com ([209.191.87.68])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FADSQ-0005dH-6x
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 13:48:07 -0800
To: nfs@lists.sourceforge.net
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

Hello.

I've got a network wherein the machines are all running kernel 2.6.12,
and NFSv3 is exclusively being used.  The exports / mounts are all
'sync'.  I'm seeing some behavior that doesn't seem to be correct to
me, and I want to see if this is expected or if I'm hitting a bug or
perhaps hardware failure/flakiness along the way.

The scenario:

A user has an existing set of files on the server, on an XFS volume.

If he is on the server (i.e. logged in via ssh) and runs a cp command
to overwrite existing file "a" with file "b", then file "a" appears to
be correctly overwritten as verified from the command-line on the
server.  However, when any of the client machines opens file "a" after
this, they see the previous contents.  It seems like an incoherent
cache issue.

If the user instead runs the cp command on one of the client machines,
then all the client machines now see the updated file.

Does this sound like it should be expected behavior, i.e. if the file
changes "underneath" NFS (direct to the volume via command-line) will
NFS have stale information, or should it explicitly handle this case?

Thanks.

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D103432&bid=3D230486&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
