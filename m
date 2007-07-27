From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Exportfs not showing exported file systems (was RE: stdio
 and nfs-utils)
Date: Fri, 27 Jul 2007 10:40:33 -0400
Message-ID: <46AA03E1.4060100@RedHat.com>
References: <20070725223723.GH7943@fieldses.org><20070726000700.GK7943@fieldses.org><18088.3581.647761.879253@notabene.brown><20070726031755.GB19901@fieldses.org><01AE8AF878612047A442668306EAEB05D02161@SACEXMV01.hq.netapp.com><20070726154806.ed0afdfd.jlayton@redhat.com><01AE8AF878612047A442668306EAEB05D0219C@SACEXMV01.hq.netapp.com>	<20070726171209.6fbccdd3.jlayton@redhat.com>
	<01AE8AF878612047A442668306EAEB05D021C8@SACEXMV01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEQzc-0001Ot-VN
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 07:40:40 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEQzg-0003ol-Bx
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 07:40:40 -0700
In-Reply-To: <01AE8AF878612047A442668306EAEB05D021C8@SACEXMV01.hq.netapp.com>
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



Muntz, Daniel wrote:
> Yep, disabling selinux fixed it on my FC6 machine.
A better idea might be to simply 'yum update  selinux-policy'

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
