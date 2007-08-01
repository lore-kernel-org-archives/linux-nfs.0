From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 14:38:56 -0400
Message-ID: <20070801183856.GF13441@fieldses.org>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<Pine.BSO.4.64.0708011347200.25204@citi.umich.edu>
	<01AE8AF878612047A442668306EAEB05DD298B@SACEXMV01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, Neil Brown <neilb@suse.de>,
	Alex Soule <soule@umich.edu>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net,
	"david m. richter" <richterd@citi.umich.edu>
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGJ6F-0004vI-Dw
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:39:11 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGJ6J-0002OH-5c
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:39:15 -0700
In-Reply-To: <01AE8AF878612047A442668306EAEB05DD298B@SACEXMV01.hq.netapp.com>
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

On Wed, Aug 01, 2007 at 11:15:23AM -0700, Muntz, Daniel wrote:
> i think you're answering your own question.  being able to zero the
> stats with 'nfsstat -z' allows you to avoid unmounting, while giving you
> the ability to, um, zero the stats...  instead of being a pain, it's
> trivial.
> 
> if you don't want to zero your stats, i agree with others here, that a
> simple script

I'm sure contributions of simple scripts would be welcome.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
