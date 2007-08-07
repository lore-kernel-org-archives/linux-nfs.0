From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: [PATCH 7/7] nfsstat: add -D/--diff-stat
Date: Tue, 7 Aug 2007 17:26:13 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708071721280.26009@citi.umich.edu>
References: <Pine.BSO.4.64.0707311719160.13370@citi.umich.edu>
	<20070807211920.GA16557@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net,
	Alex Soule <soule@umich.edu>
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIWcZ-0007jL-Jg
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 14:29:45 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIWZD-0005GW-8S
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 14:26:17 -0700
In-Reply-To: <20070807211920.GA16557@uio.no>
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

On Tue, 7 Aug 2007, Steinar H. Gunderson wrote:

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
> 
> /* Steinar */

	
	ach, that's too bad; thanks for finding it.  that double is only 
used in one spot, in a "helpful" message that isn't important; we could 
remove it.  i'll look at it right now.

	does anyone know the reason behind no-floating-point-on-Alpha?

	thanks,

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
