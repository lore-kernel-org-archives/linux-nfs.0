From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [PATCH 7/7] nfsstat: add -D/--diff-stat
Date: Tue, 7 Aug 2007 23:19:20 +0200
Message-ID: <20070807211920.GA16557@uio.no>
References: <Pine.BSO.4.64.0707311719160.13370@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net,
	Alex Soule <soule@umich.edu>
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIWSe-0007J6-DE
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 14:19:28 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIWSg-0003YG-6V
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 14:19:32 -0700
In-Reply-To: <Pine.BSO.4.64.0707311719160.13370@citi.umich.edu>
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

On Tue, Jul 31, 2007 at 05:39:49PM -0400, david m. richter wrote:
> +	double time_diff;

Unfortunately, this breaks the build on alpha. For some reason, configure.ac
does

  case $host in
    alpha*)
      ARCHFLAGS="-mno-fp-regs -ffixed-8" ;;
    *)
      ARCHFLAGS="" ;;
  esac

which essentially means that you cannot use any floating-point in the program
at all, according to the Debian alpha porters.

Either this snippet must be removed for alpha (I presume it was put in for a
reason at some point, but I have no idea what this reason was, and if it's
still valid), or the code must be rewritten not to use floating-point.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
