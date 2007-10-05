From: Jeff Layton <jlayton@redhat.com>
Subject: Re: What's slated for inclusion in 2.6.24-rc1 from the NFS
 client git tree...
Date: Fri, 5 Oct 2007 08:24:43 -0400
Message-ID: <20071005082443.ce34b904.jlayton@redhat.com>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
	<20071004085206.0a8e37b5@poseidon.drzeus.cx>
	<1191506450.6685.17.camel@heimdal.trondhjem.org>
	<20071004184304.6e71ab6d@poseidon.drzeus.cx>
	<20071004114243.3161af16.akpm@linux-foundation.org>
	<1191525363.6739.12.camel@heimdal.trondhjem.org>
	<47054205.8000908@redhat.com>
	<20071005082513.4b5a058c@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdmEZ-0000gW-9B
	for nfs@lists.sourceforge.net; Fri, 05 Oct 2007 05:24:47 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IdmEd-0002py-6z
	for nfs@lists.sourceforge.net; Fri, 05 Oct 2007 05:24:52 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id l95COi1p024224
	for <nfs@lists.sourceforge.net>; Fri, 5 Oct 2007 08:24:44 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l95COiZU007934
	for <nfs@lists.sourceforge.net>; Fri, 5 Oct 2007 08:24:44 -0400
Received: from tleilax.poochiereds.net (vpn-14-72.rdu.redhat.com [10.11.14.72])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l95COhhq010744
	for <nfs@lists.sourceforge.net>; Fri, 5 Oct 2007 08:24:43 -0400
In-Reply-To: <20071005082513.4b5a058c@poseidon.drzeus.cx>
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

On Fri, 5 Oct 2007 08:25:13 +0200
Pierre Ossman <drzeus-list@drzeus.cx> wrote:
>
> > It would be better to identify these applications and get them
> > fixed.  The world is evolving and it is time for them to do so.
> > 
> 
> Print a warning or something so that they can be found. Don't go
> breaking systems left and right. People have better things to do than
> to fix the build systems for ever program they use.
> 

Unfortunately, the kernel doesn't have any way to know that the app is
not built with LFS defines. glibc uses the same syscalls regardless of
how it's built. If you want to print a warning you'll have to modify
glibc to do so, and then you have the problem of where to send this
output...

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
