From: Neil Brown <neilb@suse.de>
Subject: Re: wonky autotools question
Date: Sat, 28 Jul 2007 08:31:57 +1000
Message-ID: <18090.29277.10351.295141@notabene.brown>
References: <46AA4BF6.6090002@oracle.com> <20070727200856.GI13965@fieldses.org>
	<46AA52C0.8060209@oracle.com> <f606ea2d46f0.46a9f33f@usc.edu>
	<46AA66A7.1050304@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Garrick Staples <garrick@usc.edu>, nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEYLs-0005IU-QH
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 15:32:05 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEYLt-0005V8-QJ
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 15:32:08 -0700
In-Reply-To: message from Chuck Lever on Friday July 27
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

On Friday July 27, chuck.lever@oracle.com wrote:
> 
> Though really, it does make sense to set -Wall for the whole package. 
> Would anyone mind if I sent a patch that did that?

I'd be keen on
   -Wall -Werror -Wstrict-prototypes

though I suspect we need a lot of cleanup before all of those can
pass, and we -Werror would have to be conditional on using the
internal rpcgen as the libc one generates code that produced warning.
I guess I really should try pushing those rpcgen fixes upstream to
glibc...

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
