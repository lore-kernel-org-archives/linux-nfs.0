From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 01 Aug 2007 07:55:14 -0400
Message-ID: <46B074A2.4010909@redhat.com>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net,
	Alex Soule <soule@umich.edu>
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGCnQ-00019q-NN
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 04:55:20 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGCnS-000664-8T
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 04:55:23 -0700
In-Reply-To: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
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

david m. richter wrote:
> 	Hello, Neil,
>
> 	This set of patches adds -D/--diff-stat to nfsstat.  When this 
> flag is used, instead of printing out the current total statistics and 
> exiting, nfsstat takes a snapshot of the current statistics and pauses 
> until the user types ^C, at which point a second snapshot is taken and 
> only the difference between the two is printed; i.e., only the statistics 
> gathered during the pause.

Hi.

Perhaps I am missing something, but is something that we really need
to complicate the nfsstat support with?  Is this not easy enough to
do with already existing tools or some easily written support in sh
or perl or awk or name your favorite administrative scripting language?

    Thanx...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
