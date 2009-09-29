From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [Ocfs2-devel]  Trouble exporting OCFS2 via NFS
Date: Tue, 29 Sep 2009 17:20:42 -0400
Message-ID: <20090929212042.GG3155__35109.0376302183$1254259274$gmane$org@fieldses.org>
References: <710118.59930.qm@web43139.mail.sp1.yahoo.com>
	<20090929153126.GA388@fieldses.org>
	<20090929210011.GB24249@mail.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Tim Cullen <timcullen2001@yahoo.com>, nfs@lists.sourceforge.net,
	ocfs2-devel@oss.oracle.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:56342 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959AbZI2VU7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Sep 2009 17:20:59 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Msk86-0005vk-AZ
	for linux-nfs@vger.kernel.org; Wed, 30 Sep 2009 07:21:02 +1000
In-Reply-To: <20090929210011.GB24249-0Ol/1UON5C7fiIqoQl7HmA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 29, 2009 at 02:00:11PM -0700, Joel Becker wrote:
> On Tue, Sep 29, 2009 at 11:31:26AM -0400, J. Bruce Fields wrote:
> > On Mon, Sep 28, 2009 at 07:15:40PM +0000, Tim Cullen wrote:
> > > I've been attempting to export an OCFS2 filesystem via NFS without success. My NFS client mounts the exported filesystem without problem but all subsequent access to the mount point results in Stale NFS File Handle error. On the NFS server in /var/log/messages I see error messages like the ones below complaining about attempts to access beyond the end of the disk.
> > > 
> > > I've spoken with a supporting engineer at Oracle who didn't know what the problem might be and suggested I try this list. I'm hoping somebody here might be familiar with this problem.
> > 
> > If I had to guess I would've said it was an ocfs2 problem; maybe
> > somebody on ocfs2-devel (cc'd) can help?
> 
> 	Can you file a bug report at oss.oracle.com/bugzilla?  We could
> use the message files, your export and mount options, and anything you
> do to reproduce it.

And maybe cc: that here too.

--b.

> 	Walking off the end of the device is weird.
> 
> Joel
> 
> -- 
> 
> "Conservative, n.  A statesman who is enamoured of existing evils,
>  as distinguished from the Liberal, who wishes to replace them
>  with others."
> 	- Ambrose Bierce, The Devil's Dictionary
> 
> Joel Becker
> Principal Software Developer
> Oracle
> E-mail: joel.becker@oracle.com
> Phone: (650) 506-8127

------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

