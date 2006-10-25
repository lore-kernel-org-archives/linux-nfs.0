From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/2] mountd: clean up rmtab handling
Date: Wed, 25 Oct 2006 09:07:00 -0400
Message-ID: <1161781620.7078.50.camel@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GciTQ-0006c7-0I
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 06:07:12 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GciTN-00089z-OR
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 06:07:13 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9PD702d002029
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 09:07:01 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id k9PD70nP001636
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 09:07:00 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [172.16.57.196])
	by pobox.corp.redhat.com (8.13.1/8.12.8) with ESMTP id k9PD70rd012114
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 09:07:00 -0400
To: nfs@lists.sourceforge.net
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

We have had a few reports from customers that showmount -a is just plain
broken. The manpage says that it should "List both the client hostname
and mounted directory in  host:dir format". Instead, when used with
recent kernels, the output can look something like this (after mounts
from several hosts):

*:/foo
*:/scratch
*,foo.bar.baz:/scratch
10.10.1.41:*
172.16.33.192:*
172.16.33.192:*,foo.bar.baz

The output here varies somewhat depending on how the export table on the
server is configured, but the key is that we're getting multiple lines
here for every mount (some that don't even contain a path), and the
hostname field is often not a hostname or IP address.

The problem seems to be in how the rmtab is being managed and in how
mountd handles the hostname of the client when checking permissions and
such.

The following two patches remedy this. They both should only affect the
case where new_cache is set.

-- Jeff



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
