From: "Fredrik Lindgren" <fli@swip.net>
Subject: NFS corruption in 2.6.18.2?
Date: Tue, 14 Nov 2006 19:09:17 +0100
Message-ID: <50e235a50d0f2b4fb34eed1c840565e3@swip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gk2j7-0007OY-4p
	for nfs@lists.sourceforge.net; Tue, 14 Nov 2006 10:09:41 -0800
Received: from mailfe06.swip.net ([212.247.154.161] helo=swip.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gk2j5-0000AT-4t
	for nfs@lists.sourceforge.net; Tue, 14 Nov 2006 10:09:42 -0800
Received: from [130.244.255.2] (account fli@swip.net)
	by mailbe05.swip.net (CommuniGate Pro IMAP 5.0.8)
	with XMIT id 46251222 for nfs@lists.sourceforge.net;
	Tue, 14 Nov 2006 19:09:25 +0100
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello

We're running a mail system with Linux machines being served by two
NetApps. (Debian stable, our "own" kernel off kernel.org)

At present we're running 2.6.13 kernels, we had some corruption issues
before that was fixed in 2.6.13. However when we tried to upgrade
to 2.6.18.2 the we see corruption again.

pre 2.6.13 the problem seemed to be that the file size was being
cached, which meant that sometimes there were blocks of NULL
characters in the files.

With 2.6.18.2 we see blocks of NULL chars in the data again, this time
it's sometimes in the middle of a message. pre 2.6.13 that didn't
happen,
then there were just big blocks of NULL chars between two messages. 
The only consistent thing is that it only occurs when the 1 machine
running 2.6.18.2 (out of 5) has delivered a message to the spool-file.

I don't know if it's relevant, but when checking the NFS stats I see
the 2.6.18.2 machine doing almost precisely half the amount of "GetAttr"
calls compared to the 2.6.13 machines.

Is this something anyone else has seen?

Also on a side note, the statistics still seem to be using signed
values, so we're seeing negative numbers on some stats after some
uptime. This is true for both using "nfsstat" and "cat
/proc/net/rpc/nfs.

Regards,
  Fredrik Lindgren





-------------------------------------------------------------------------
SF.net email is sponsored by: A Better Job is Waiting for You - Find it Now.
Check out Slashdot's new job board. Browse through tons of technical jobs
posted by companies looking to hire people just like you.
http://jobs.slashdot.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
