Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47307 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756026Ab1EXNRi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 May 2011 09:17:38 -0400
Date: Tue, 24 May 2011 09:17:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Taousif_Ansari@DELLTEAM.com, Shyam_Iyer@Dell.com,
        linux-nfs@vger.kernel.org, Ashokan_Vellimalai@Dell.com,
        cluster-devel@redhat.com
Subject: Re: Performance Issue with multiple dataserver
Message-ID: <20110524131737.GA1934@fieldses.org>
References: <A1A98FD909DC5248811A65C5D18E9C761DF69B2188@BLRX7MCDC202.AMER.DELL.COM>
 <20110519115018.GA31978@fieldses.org>
 <A1A98FD909DC5248811A65C5D18E9C761DF69B2432@BLRX7MCDC202.AMER.DELL.COM>
 <20110519131236.GA32648@fieldses.org>
 <A1A98FD909DC5248811A65C5D18E9C761DF69B244C@BLRX7MCDC202.AMER.DELL.COM>
 <20110519134356.GB32648@fieldses.org>
 <A1A98FD909DC5248811A65C5D18E9C761DF69B247B@BLRX7MCDC202.AMER.DELL.COM>
 <DBFB1B45AF80394ABD1C807E9F28D157032A7822A8@BLRX7MCDC203.AMER.DELL.COM>
 <A1A98FD909DC5248811A65C5D18E9C761DF6A1CC2F@BLRX7MCDC202.AMER.DELL.COM>
 <1306237459.2896.5.camel@menhir>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1306237459.2896.5.camel@menhir>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 24, 2011 at 12:44:19PM +0100, Steven Whitehouse wrote:
> /Hi,
> 
> On Tue, 2011-05-24 at 17:09 +0530, Taousif_Ansari@DELLTEAM.com wrote:
> > Hi Bruce, Shyam
> > 
> >  As mentioned here http://wiki.linux-nfs.org/wiki/index.php/PNFS_server_projects gfs2 is also having issues(crashes, performance), so instead of going for gfs2 can we debug spNFS itself to get high performance?
> > 
> > 
> > -Taousif
> > 
> As far as I'm aware that is historical information. If there are still
> problems with GFS2, then please report them so we can work on them,

Well, they may be nfs problems rather than gfs2 problems.

In either case, neither pnfs/gfs2 nor spnfs is a particularly mature
project; you will find bugs and performance problems in both.

I think a cluster-filesystem-based approach probably has the better
chance of getting merged earlier, as it solves a number of thorny
problems (such as how to do IO through the MDS) for you.  But it all
depends on what your goals are.  Either will require significant
development work to get into acceptable shape.

--b.
