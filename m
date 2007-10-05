From: Jeff Layton <jlayton@redhat.com>
Subject: Re: What's slated for inclusion in 2.6.24-rc1 from the NFS
 client git tree...
Date: Fri, 5 Oct 2007 14:00:37 -0400
Message-ID: <20071005140037.1309a8d3.jlayton@redhat.com>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
	<20071004085206.0a8e37b5@poseidon.drzeus.cx>
	<1191506450.6685.17.camel@heimdal.trondhjem.org>
	<30494.1191605410@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>,
	Andrew@sc8-sf-spam2.sourceforge.net, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, Pierre Ossman <drzeus-list@drzeus.cx>,
	Morton <akpm@linux-foundation.org>
To: Valdis.Kletnieks@vt.edu
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdrUN-0006sd-Hm
	for nfs@lists.sourceforge.net; Fri, 05 Oct 2007 11:01:27 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IdrUS-0006CN-F3
	for nfs@lists.sourceforge.net; Fri, 05 Oct 2007 11:01:32 -0700
In-Reply-To: <30494.1191605410@turing-police.cc.vt.edu>
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

On Fri, 05 Oct 2007 13:30:10 -0400
Valdis.Kletnieks@vt.edu wrote:
>
> How does Joe Sysadmin tell if he has an affected legacy app or not?
> 
> (The obvious "try it and see what breaks" is a non-starter for many places,
> because you too easily end up in a loop of "enable it, find 4-5 show stoppers,
> turn it off, fix them, lather rinse repease".  Been there, done that, got
> the tshirt - a project I got dragged into involves a large storage array that
> appears to insist on exporting 64-bit stuff, and a large farm of clients that
> are very 64-bit unclean....)
> 

In addition to Trond's suggestion, you might be able to use "nm" or
something like it and see if there are references to non-LFS (f)stat
calls in your binaries. For instance, if you see references to stat()
(and not stat64()), then the app is probably not built with 64-bit file
offsets.

This is probably not as reliable as Trond's method, but it might be
less invasive and reasonable for a first pass when looking for these
sorts of apps...

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
