From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/9] nfs-utils logging and extra code clean-up
Date: Mon, 15 Oct 2007 09:53:32 +1000
Message-ID: <18194.44028.982728.126111@notabene.brown>
References: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhDHD-00077Q-At
	for nfs@lists.sourceforge.net; Sun, 14 Oct 2007 16:53:43 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IhDHD-00061F-Ep
	for nfs@lists.sourceforge.net; Sun, 14 Oct 2007 16:53:43 -0700
In-Reply-To: message from Kevin Coffman on Friday October 12
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

On Friday October 12, kwc@citi.umich.edu wrote:
> Hi Neil,
> 
> These patches clean up logging code and eliminate duplicate and
> unused code.

All applied, thanks.

NeilBrown

> 
> 01 svcgssd_fix_prototype_warning
>     Cleans up a new compiler warning that appeared after
>     -Wstrict-prototypes was added to the compile options
> 
> 02 svcgssd_print_hexl_debug_stdout
>     Change debugging to use printf instead of logging
>     function.  (In preparation of David's patches below.)
> 
> 03 svcgssd_debug_downcall_info
>     Change svcgssd to print its own debug info rather
>     than relying on modified qword_ functions.
> 
> 04 nfslib_cacheio_updates_for_svcgssd
>     Move local cacheio functions from svcgssd into the
>     common library.
>     Modify the library read function to use a bigger
>     buffer as needed by svcgssd.
> 
> 05 svcgssd_use_common_cacheio_support
>     svcgssd now uses the common functions rather than
>     local modified copies.
> 
> 06 svcgssd_remove_private_cacheio
>     Remove the private copies in svcgssd
> 
> 07 xlog_logging_code_cleanup
> 08 idmapd_gssd_use_xlog
> 09 idmapd_remove_setproctitle
> 
>     These patches are from David P. Quigley <dpquigl@tycho.nsa.gov>
>     07 clean up the xlog code
>     08 modify idmapd and gssd to use the cleaned up code, and
>     09 remove unused code from idmapd.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
