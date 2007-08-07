From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH 7/7] nfsstat: add -D/--diff-stat
Date: Tue, 7 Aug 2007 18:08:15 -0400
Message-ID: <4d569c330708071508l37c03338x5f4d77f9182ed04e@mail.gmail.com>
References: <Pine.BSO.4.64.0707311719160.13370@citi.umich.edu>
	<20070807211920.GA16557@uio.no>
	<Pine.BSO.4.64.0708071721280.26009@citi.umich.edu>
	<20070807215359.GA16870@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net,
	Alex Soule <soule@umich.edu>,
	"david m. richter" <richterd@citi.umich.edu>
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIXDt-00046k-6g
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 15:08:17 -0700
Received: from rv-out-0910.google.com ([209.85.198.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IIXDw-0005RD-55
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 15:08:21 -0700
Received: by rv-out-0910.google.com with SMTP id g11so5184992rvb
	for <nfs@lists.sourceforge.net>; Tue, 07 Aug 2007 15:08:19 -0700 (PDT)
In-Reply-To: <20070807215359.GA16870@uio.no>
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

On 8/7/07, Steinar H. Gunderson <sgunderson@bigfoot.com> wrote:
> On Tue, Aug 07, 2007 at 05:26:13PM -0400, david m. richter wrote:
> >       does anyone know the reason behind no-floating-point-on-Alpha?
>
> It seems to have been added as part of this changelog entry (slightly munged
> in git, perhaps something went wrong from the CVS import):
>
>   2005-12-20 Kevin Coffman <kwc@citi.umich.edu> NeilBrown <neilb@suse.de>
>           Substantial Makefile/configure rewrite.
>           Run 'autogen.sh' to create "Makefile.in" etc.
>
>           Also add -D_FILE_OFFSET_BITS=64 to CPP_FLAGS so that mountd can
>           stat and export files larger than 2Gig.
>
>           1.0.8-rc2 released
>
> I sort of suspect it was just copied blindly from somewhere...

Actually, it was copied carefully from the old config.mk.in :-)
It was in config.mk.in from the beginning, AFAICT.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
