From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/4] Intro: Fix buffer overflow when using
	large	numbers of netgroups
Date: Thu, 16 Aug 2007 09:44:53 +1000
Message-ID: <18115.36853.73250.813046@notabene.brown>
References: <200708141332.l7EDWhdi032134@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILSXq-0001zC-2K
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 16:44:58 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ILSXt-00085U-NM
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 16:45:02 -0700
In-Reply-To: message from Jeff Layton on Tuesday August 14
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

On Tuesday August 14, jlayton@redhat.com wrote:
> 
> It's only had very simple testing and so should be considered an RFC. At
> this point, I'm mostly interested in feedback on the general approach.
> 

I cannot fault anything.
I particularly like patch 3.  There are some nice improvements wrt
hostname lookups.

Just let me know when you think they are ready.

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
