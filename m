From: Ion Badulescu <ionut@badula.org>
Subject: Re: Sun's privileged port settings vs NFS
Date: Sat, 25 Jan 2003 11:48:37 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200301251648.h0PGmbM16651@moisil.badula.org>
References: <p5iswey4fw.fsf@lemming.engeast.baynetworks.com>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=buggy.badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18cTUQ-0002B2-00
	for <nfs@lists.sourceforge.net>; Sat, 25 Jan 2003 08:49:06 -0800
To: "Paul Smith" <pausmith@nortelnetworks.com>
In-Reply-To: <p5iswey4fw.fsf@lemming.engeast.baynetworks.com>
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

On 24 Jan 2003 10:04:35 -0500, Paul Smith <pausmith@nortelnetworks.com> wrote:
> 
> Also, I have a user running Red Hat 8.0 (Linux 2.4.18-14) and (although
> I haven't rigorously verified this yet) although they're running the
> same version of am-utils they don't appear to be having this problem.
> Maybe there was an NFS fix between 2.4.9 and 2.4.18 that relates to
> this?  Or a flag or parameter that can be set?

The addition of these two lines to net/sunrpc/xprt.c:xprt_reconnect(),
somewhere between 2.4.10 and 2.4.18, is probably what fixed it:

        if (xprt_connected(xprt))
                goto out_write;

+       if (sock && sock->state != SS_UNCONNECTED)
+               xprt_close(xprt);
        status = -ENOTCONN;
        if (!(inet = xprt->inet)) {

If you can't upgrade the client kernels (2.4.9-34 is no longer the latest
errata kernel for any RedHat version, was replaced by 2.4.18-19.7.x), then
forcing all rh7.x clients to use UDP mounts should cure the problem.

Ion
[am-utils co-maintainer]

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
