From: "Chris Carlson" <c.carlson@aristoslogic.com>
Subject: NFS won't mount rw
Date: Fri, 21 Sep 2007 17:24:57 -0700
Message-ID: <46F460D9.1000105@aristoslogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYso8-0000kH-OJ
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 17:25:19 -0700
Received: from 65-119-21-40.dia.static.qwest.net ([65.119.21.40]
	helo=gabriel.aristoslogic.com)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IYsoB-0003YD-BG
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 17:25:20 -0700
Received: from gabriel.aristoslogic.com (localhost [127.0.0.1])
	by localhost.aristoslogic.com (Postfix) with ESMTP id 02A7E220A
	for <nfs@lists.sourceforge.net>; Fri, 21 Sep 2007 17:25:10 -0700 (PDT)
Received: from daak.aristoslogic.com (unknown [172.31.1.2])
	by gabriel.aristoslogic.com (Postfix) with SMTP id BF2BF2204
	for <nfs@lists.sourceforge.net>; Fri, 21 Sep 2007 17:25:10 -0700 (PDT)
Received: from [172.31.10.74] ([172.31.10.74]) by
	daak.aristoslogic.com (Netscape Messaging Server 4.1) with ESMTP
	id JOQUHY00.8RE for <nfs@lists.sourceforge.net>; Fri, 21 Sep
	2007 17:25:10 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


We have a new problem that I was hoping someone could help with.

We have a Snap Appliance NFS server.  It has been recently upgraded, so 
it should have good NFS server software on it (though this isn't a 
guarantee).

We have a couple dozen Linux 2.4 systems that have it mounted (via 
automount).  No problem.  All mount is with root_squash and rw (not sure 
of the other options).

We just tried to "automount" it to a RedHat Linux Enterprise 5 system, 
and it mounted fine - except it is read-only.  Why would Linux 2.6 not 
mount it rw like the other systems?  Is it some security thing that we 
don't know?  Is there a bug in the NFS client on RH Linux?

If anybody knows what we're missing, I'd appreciate a clue.

Thanks a lot.
Chris Carlson


CONFIDENTIALITY NOTICE:

This email, together with any attachments, is intended only for use by Aristos Logic Corporation and the
individual(s) to which it is addressed and may contain information that is privileged, confidential or 
exempt from disclosure. If you are not the intended recipient, you are hereby notified that any dissemination,
distribution, or copying of this email, or any attachment, is strictly prohibited. If you have received this
email in error, please notify Aristos Logic Corporation by sending an email to sysadm@aristoslogic.com
and delete this email, along with any attachments, from your computer.

Thank you.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
