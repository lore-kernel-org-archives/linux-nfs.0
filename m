From: Scott Mcdermott <smcdermott@questra.com>
Subject: (autofs) Re: Direct mounts on Linux
Date: Mon, 20 Jan 2003 22:08:51 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030121030851.GG10369@questra.com>
References: <15916.14776.460148.770017@lemming.engeast.baynetworks.com> <20030120214134.GE1042@questra.com> <p5vg0jz08z.fsf@lemming.engeast.baynetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18aomS-00020Z-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Jan 2003 19:08:53 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id 9861CAB772
	for <nfs@lists.sourceforge.net>; Mon, 20 Jan 2003 22:08:51 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <p5vg0jz08z.fsf@lemming.engeast.baynetworks.com>
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

Paul Smith on Mon 20/01 21:48 -0500:
> I know that am-utils doesn't support it,

hmm direct mounts? well according to the docs:

        The Linux kernels don't support Amd's direct mounts very well,
        leading to erratic behavior: shares that don't get remounted
        after the first timeout, inability to restart Amd because its
        mount points cannot be unmounted, etc. There are some kernel
        patches on the am-utils Web site, which solve these problems.

(I think this is talking about using the autofs support in beta
am-utils)

so I guess you need a patch, hmph.

> Well... except for direct mounts.  We can all agree that they are evil
> and they suck, but the fact remains there are a lot of them out there
> and they are often hard to get rid of...

I don't agree that they are evil or that they suck.  Some mounts are
static and won't change, and just a simple mount will suffice.  What's
wrong with using a direct mount in this case (maybe /home/ or
/var/spool/mail/)? Is there a real argument against this besides "the
performance sucks when the directory gets large" (which is an admin
decision I think).  I don't really know, we don't have large enough
directories that it becomes a problem.  One other good thing about
direct mounts is that you can immediately `ls' the directory and see all
the possible entries, but this could be implemented in other ways.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
