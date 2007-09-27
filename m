From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/5] rpc.mountd: Fix mountd buffer overflow when using
	large numbers of netgroups (resend)
Date: Thu, 27 Sep 2007 06:53:38 -0400
Message-ID: <200709271053.l8RArcOw031610@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iar07-0006va-Fj
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 03:53:47 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iar09-0003Ez-AD
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 03:53:49 -0700
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

This patchset is intended to address the buffer overrun reported by
Stefan Walter when a client matches a large number of netgroups. The
main problem is that the string returned by client_compose can be any
length, and that is strcpy()'ed into a fixed-length array.

The first four patches are cleanup patches. They also take care of the
actual buffer overrun. The last patch implements Neil Brown's suggestion
to allow mountd to conditionally map ipaddr to ipaddr in the
auth.unix.ip cache and to only check mount requests against exports that
match the path.

Unlike earlier versions of this patch, there is no way to select this
mode manually. The reason is that explaining when an admin should select
this mode is difficult and adding an option would be very confusing. If
it becomes desirable to do so, however, we can always add one later.

Neil, I think this patchset is ready whenever you are...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Steve Dickson <steved@redhat.com>


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
