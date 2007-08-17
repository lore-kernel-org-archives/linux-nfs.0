From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/4] Intro: Fix buffer overflow when using large
 numbers of netgroups
Date: Fri, 17 Aug 2007 08:25:02 -0400
Message-ID: <20070817082502.4512f4ef.jlayton@redhat.com>
References: <200708141332.l7EDWhdi032134@dantu.rdu.redhat.com>
	<18115.36853.73250.813046@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IM0t0-0004C2-B1
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 05:25:06 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IM0t3-0006wJ-QX
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 05:25:10 -0700
In-Reply-To: <18115.36853.73250.813046@notabene.brown>
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

On Thu, 16 Aug 2007 09:44:53 +1000
Neil Brown <neilb@suse.de> wrote:

> On Tuesday August 14, jlayton@redhat.com wrote:
> > 
> > It's only had very simple testing and so should be considered an RFC. At
> > this point, I'm mostly interested in feedback on the general approach.
> > 
> 
> I cannot fault anything.
> I particularly like patch 3.  There are some nice improvements wrt
> hostname lookups.
> 
> Just let me know when you think they are ready.
> 

Thanks for the review, Neil.

I think the first 3 patches are in good shape as-is. You should be OK to
commit them. I've respun the 4th patch and will post there here in a bit.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
