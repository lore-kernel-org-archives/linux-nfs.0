From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: atimes not updated over NFS
Date: Mon, 21 Jan 2008 14:31:05 -0500
Message-ID: <1200943865.25562.56.camel@heimdal.trondhjem.org>
References: <20080109101313.GG9212@aym.net2.nerim.net>
	 <1199892437.11141.2.camel@heimdal.trondhjem.org>
	 <20080109223748.GH9212@aym.net2.nerim.net>
	 <1199920996.7638.3.camel@heimdal.trondhjem.org>
	 <20080109235153.GI9212@aym.net2.nerim.net> <20080114083435.GA24215@janus>
	 <1200325393.7470.6.camel@heimdal.trondhjem.org>
	 <20080114175122.GB2768@janus>  <20080121190638.GL17468@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:59031 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751096AbYAUTbS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2008 14:31:18 -0500
In-Reply-To: <20080121190638.GL17468@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-21 at 14:06 -0500, J. Bruce Fields wrote:
> > > > Commands to reproduce this problem on the client:
> > > > 
> > > > 	dd </dev/zero >testfile count=1
> > > > 	ls -l --time=atime --full-time testfile
> > > > 	sleep 2
> > > > 	wc testfile
> > > > 	ls -l --time=atime --full-time testfile
> > > > 		(same atime, not good)
> > > 
> > > Can you confirm that it does not change on the server? If so, then we
> > > need to look at the server for a fix. The client should only be
> > > mirroring the server's idea of the correct atime.
> > 
> > It doesn't change on the server (2.6.23.12)
> 
> That still leaves open the question as to whether this is due to changes
> in the client that are causing it not to issue a read to the server when
> it would have before, or whether the server is just refusing to update
> the atime on read for some reason....

A script of the form

                ssh server 'dd </dev/zero >testfile count=1; ls -l --time=atime --full-time testfile'
                
                cat testfile >/dev/null
                
                ssh server 'ls -l --time=atime --full-time testfile'
                ls -l --time=atime --full-time testfile

should normally force the client to read the file, and should tell if
the atime is being updates correctly on both server and client.

Cheers
  Trond

