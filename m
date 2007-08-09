From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 7/7] nfsstat: add -D/--diff-stat
Date: Thu, 9 Aug 2007 11:25:04 +1000
Message-ID: <18106.27888.935842.557269@notabene.brown>
References: <Pine.BSO.4.64.0707311719160.13370@citi.umich.edu>
	<20070807211920.GA16557@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>,
	"david m. richter" <richterd@citi.umich.edu>
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIwmC-0007ig-1w
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 18:25:24 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIwmD-0001Rq-V4
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 18:25:27 -0700
In-Reply-To: message from Steinar H. Gunderson on Tuesday August 7
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

On Tuesday August 7, sgunderson@bigfoot.com wrote:
> On Tue, Jul 31, 2007 at 05:39:49PM -0400, david m. richter wrote:
> > +	double time_diff;
> 
> Unfortunately, this breaks the build on alpha. For some reason, configure.ac
> does
> 
>   case $host in
>     alpha*)
>       ARCHFLAGS="-mno-fp-regs -ffixed-8" ;;
>     *)
>       ARCHFLAGS="" ;;
>   esac
> 
> which essentially means that you cannot use any floating-point in the program
> at all, according to the Debian alpha porters.
> 
> Either this snippet must be removed for alpha (I presume it was put in for a
> reason at some point, but I have no idea what this reason was, and if it's
> still valid), or the code must be rewritten not to use floating-point.


I have removed this snippet.  It is clearly only needed for kernel
code, not for regular user-space programs.

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
