From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/4] Intro: Fix buffer overflow when using large
	numbers of netgroups
Date: Tue, 14 Aug 2007 09:32:43 -0400
Message-ID: <200708141332.l7EDWhdi032134@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKwVq-0005u1-5i
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 06:32:47 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKwVu-0006pr-55
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 06:32:50 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l7EDWiCR030257
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 09:32:44 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7EDWiWJ006445
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 09:32:44 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [172.16.57.196])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7EDWhxf001750
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 09:32:43 -0400
Received: from dantu.rdu.redhat.com (localhost.localdomain [127.0.0.1])
	by dantu.rdu.redhat.com (8.14.1/8.13.8) with ESMTP id l7EDWhbd032135
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 09:32:43 -0400
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

This patch set is a first pass at fixing up the buffer overflow and
performance issues pointed out by Stefan Walter when using large numbers
of netgroups. The main problem is that the string returned by
client_compose can be any length, and that is strcpy()'ed into a
fixed-length array. Fixing this, however is a bit more involved than
just doing a strncpy().

The first three patches are cleanup patches. They also take care of the
actual buffer overrun. The last patch implements Neil Brown's suggestion
to allow mountd to conditionally map ipaddr to ipaddr in the
auth.unix.ip cache and to only check mount requests against exports that
match the path. Currently this is only selectable via a command line
option (-i), but we may want to consider enabling it automatically via
some other criteria.

When running mountd without the -i flag now with Stefan's reproducer,
the mount is simply refused. This is due to an -EINVAL returned when
writing to the cache channels (because the string is too long). With the
-i flag, the mount now works as it should. A cursory look makes it
appear that the number of netgroup lookups is greatly diminished as
well.

The changes here are probably a bit more than is actually needed to fix
this problem. Still, I think they are good cleanups to consider since
they should remove length limitations for the mclient->m_hostname string
in userspace, and should help reduce the number of hostname lookups
needed in some situations.

It's only had very simple testing and so should be considered an RFC. At
this point, I'm mostly interested in feedback on the general approach.

Signed-off-by: Jeff Layton <jlayton@redhat.com>


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
