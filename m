From: gms8994@dp.cx
Subject: NFS Automount homedir with email
Date: Thu, 18 Dec 2003 15:36:48 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031218203648.GB8363@gigabyte6bxd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AX4tA-0001FP-4C
	for nfs@lists.sourceforge.net; Thu, 18 Dec 2003 12:36:52 -0800
Received: from 12-220-136-22.client.insightbb.com ([12.220.136.22] helo=dp.cx)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AX4t9-0000Xk-JS
	for nfs@lists.sourceforge.net; Thu, 18 Dec 2003 12:36:51 -0800
To: nfs@lists.sourceforge.net
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

If I'm asking this on the wrong list, please let me know.

I'm currently attempting to setup nfs automounted home directories for my
machines.  I have this working on one of the test boxes, from the server.
However, I've run into a little bit of a snag.  One of the machines that I'd
really like to use for the automounting is my main machine, which runs qmai=
l.
Some of the users on said machine only login (via shell) once a week or so,=
 but
check their email via squirrelmail daily.  I have qmail setup to use Maildi=
r, so
the mail directories are in the users homedir.

So my question is:  will an imaplogin be enough to trigger automount so tha=
t the
users can get their mail, or will I have to do some more trickery?

--=20

Glen Solsberry
Please note that all messages are signed by my GPG key (0xBF0C1C33).
If you received a message from me that wasn't signed, it probably wasn't fr=
om me.

IRC at irc.aknarra.net:6667 #lobby
http://www.dp.cx
The first half of our lives is ruined by our parents and the second half
by our children.				   --- Clarence Darrow



-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
