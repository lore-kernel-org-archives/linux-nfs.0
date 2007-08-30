From: Terry Spaulding <spauld@us.ibm.com>
Subject: Re: statd (status) port used when setting specific port for
 lockd - SLES9 SP3 Linux for System z.
Date: Thu, 30 Aug 2007 19:04:20 -0400
Message-ID: <OFB846E7E2.F0DD22AF-ON85257347.007EA140-85257347.007EBDA0@us.ibm.com>
References: <18135.15113.531784.217271@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQt3Q-0002rC-QX
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 16:04:01 -0700
Received: from e2.ny.us.ibm.com ([32.97.182.142])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQt3T-0001cs-Pj
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 16:04:05 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7UN3qHq030331
	for <nfs@lists.sourceforge.net>; Thu, 30 Aug 2007 19:03:52 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id
	l7UN3qCS693394
	for <nfs@lists.sourceforge.net>; Thu, 30 Aug 2007 19:03:52 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l7UN3pno014131
	for <nfs@lists.sourceforge.net>; Thu, 30 Aug 2007 19:03:51 -0400
In-Reply-To: <18135.15113.531784.217271@notabene.brown>
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

Thanks Neil....

----------------------------------------------------------------------------------------------------------------------------------------------------
On Thursday August 30, spauld@us.ibm.com wrote:
>
> I noticed that when I set the lockd ports to specific port that the statd
> port is set to the same port.

This behavior is specific to SLES9 and SLES10.  The kernels in those
distributions contain statd functionality and use the same port as
lockd uses.

>
> Should I also set statd to a specific unique port  different from lockd ?
>

You cannot in SLES9/10.  On other systems where statd is a user-space
program, they cannot be the same port.


> Is there any problem with statd using the same port as lockd ?

Not on SLES9/10.

NeilBrown
-----------------------------------------------------------------------------

Regards,
Terry L. Spaulding
spauld@us.ibm.com


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
