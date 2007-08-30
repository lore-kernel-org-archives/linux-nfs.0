From: Neil Brown <neilb@suse.de>
Subject: Re: statd (status) port used when setting specific port for
 lockd - SLES9 SP3 Linux for System z.
Date: Fri, 31 Aug 2007 07:47:53 +1000
Message-ID: <18135.15113.531784.217271@notabene.brown>
References: <OFDE88F129.B785EDAA-ON85257347.0040488E-85257347.0040C993@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Terry Spaulding <spauld@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQrrt-0003zJ-Em
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 14:48:01 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQrrw-0006K6-NN
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 14:48:06 -0700
In-Reply-To: message from Terry Spaulding on Thursday August 30
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

On Thursday August 30, spauld@us.ibm.com wrote:
> 
> I noticed that when I set the lockd ports to specific port that the statd
> port is set to the same port.

This behaviour is specific to SLES9 and SLES10.  The kernels in those
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

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
