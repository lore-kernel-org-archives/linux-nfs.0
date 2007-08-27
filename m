From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/5] Intro: Fix mountd buffer overflow when using
	large numbers of netgroups
Date: Mon, 27 Aug 2007 11:21:25 -0400
Message-ID: <200708271521.l7RFLPnV019402@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPgSA-00040B-6A
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 08:24:34 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IPgPa-0007O0-Kb
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 08:21:55 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l7RFLRrl022549
	for <nfs@lists.sourceforge.net>; Mon, 27 Aug 2007 11:21:27 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7RFLQKG016383
	for <nfs@lists.sourceforge.net>; Mon, 27 Aug 2007 11:21:26 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [172.16.57.196])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7RFLP2O010192
	for <nfs@lists.sourceforge.net>; Mon, 27 Aug 2007 11:21:26 -0400
Received: from dantu.rdu.redhat.com (localhost.localdomain [127.0.0.1])
	by dantu.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id l7RFLPaG019403
	for <nfs@lists.sourceforge.net>; Mon, 27 Aug 2007 11:21:25 -0400
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

This mode is automatically selected when the total length of all of the
netgroup m_hostname fields is greater than 1/2 of NFSCLNT_IDMAX. I
decided on this scheme simply because it allowed for a long list of
netgroups with plenty of space at the end of the string for other
matches.

Unlike earlier versions of this patch, there is no way to select this
mode manually. The reason is that explaining when an admin should select
this mode is difficult and adding an option would be very confusing. If
it becomes desirable to do so, however, we can always add one later.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Steve Dickson <steved@redhat.com>


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
