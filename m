From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 14:47:59 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708011446581.25204@citi.umich.edu>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<46B074A2.4010909@redhat.com>
	<Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>
	<20070801165033.GA13441@fieldses.org>
	<Pine.BSO.4.64.0708011333100.25204@citi.umich.edu>
	<1185990384.6700.188.camel@localhost>
	<Pine.BSO.4.64.0708011347200.25204@citi.umich.edu>
	<01AE8AF878612047A442668306EAEB05DD298B@SACEXMV01.hq.netapp.com>
	<Pine.BSO.4.64.0708011425580.25204@citi.umich.edu>
	<1185993678.6700.215.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, Neil Brown <neilb@suse.de>,
	"Muntz,  Daniel" <Dan.Muntz@netapp.com>,
	Alex Soule <soule@umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGJEi-0005lq-CU
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:49:13 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGJEl-0001sZ-T4
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:48:00 -0700
In-Reply-To: <1185993678.6700.215.camel@localhost>
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

On Wed, 1 Aug 2007, Trond Myklebust wrote:

> On Wed, 2007-08-01 at 14:37 -0400, david m. richter wrote:
> 
> > 	i think that zeroing all the counters is too much of a "big 
> > hammer" approach to what was intended to be a quick and simple use-case.  
> > if there's a kernel interface for zeroing stuff, then maybe that could be 
> > added, too; someone should have-at.
> 
> No! I see no reason to add such an interface when it can be emulated in
> userland.

	i completely agree; have no desire to add new kernel interfaces.

	d
	.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
