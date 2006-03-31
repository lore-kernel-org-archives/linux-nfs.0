From: "Grant Gossett" <ggossett@symantec.com>
Subject: Some NFS Documentation questions
Date: Fri, 31 Mar 2006 14:58:13 -0700
Message-ID: <C953858D5A2E564F920016570381C0F705B629@TUS1XCHCLUPIN03.enterprise.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FPRhR-0005oO-Hm
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 14:02:33 -0800
Received: from silver.veritas.com ([143.127.12.111])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FPRhQ-0007lA-5E
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 14:02:33 -0800
To: <nfs@lists.sourceforge.net>
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

Hello all,

Couple of nfs questions for you :)

How can I determine the version of "nfs" that is running on fedora core
4? I don't mean "is NFS version 4 running?" as in rpcinfo -p. I mean the
question as in "What version do I have to patch?" It is just a stock FC4
install with nfs selected at install time. Is it always the same as my
kernel version?

Is there any documentation that covers what options you can put in the
file (I am using FC4's placement as an example) /etc/sysconfig/nfs? For
example, I think it would be nice if I didn't have to recompile my
kernel to change block size so that UDP won't fragment in some
situations where I can't control the clients rsize and wsize (for
example - I'm having trouble with Solaris 10 "inetboot" not taking rsize
and wsize options from bootparams). I have seen people reference this
file via Google and every example I've seen of this file the creator
knows exactly what they need to put in it and never suggests where they
got that information. I have spent hours looking for this information
via Google, NFS FAQs, NFS mailing list archives, nfs-utils FAQs. Anyone
have a definitive list of options that can be placed in this file?

The fsid=3D0 "master nfs4 root thingy" in /etc/exports. This is a single
entire filesystem being exported and all of the directories are already
under what would be the "master nfs4 root thingy" to begin with so there
was never any need or use for any mounts to bind non-child directories
to child directory mount points. Since I must put an entry in
/etc/exports for the "master nfs4 root thingy" do subdirectories inherit
options from the "master nfs4 root thingy" or not? In other words, if I
have 1 subdirectory that I want to mount with the "rw" option and 3
subdirectories I want to mount "ro" does a "ro" option on the fsid=3D0
entry block the "rw" to that 1 writable subdirectory? It would be nice
if I could find clarification somewhere on this.

Thanks All, much appreciated.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
