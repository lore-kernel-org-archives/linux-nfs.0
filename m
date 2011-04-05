Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49480 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752904Ab1DEMUa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Apr 2011 08:20:30 -0400
Date: Tue, 5 Apr 2011 22:20:19 +1000
From: NeilBrown <neilb@suse.de>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Use of READDIRPLUS on large directories
Message-ID: <20110405222019.6c4d2997@notabene.brown>
In-Reply-To: <4D9A26B8.6080504@netapp.com>
References: <20110316155528.31913c58@notabene.brown>
	<24085EE6-EF0B-4F36-8F6A-100AB863F408@oracle.com>
	<4D80C5C6.2060003@netapp.com>
	<1300285203.16266.46.camel@lade.trondhjem.org>
	<20110317083034.479ecb5f@notabene.brown>
	<1300311755.30551.17.camel@lade.trondhjem.org>
	<20110317094019.23f31f53@notabene.brown>
	<20110317171831.GA30180@fieldses.org>
	<4D9A26B8.6080504@netapp.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 04 Apr 2011 16:14:48 -0400 Bryan Schumaker <bjschuma@netapp.com>
wrote:

> I've done some more testing and posted my initial results here: https://wiki.linux-nfs.org/wiki/index.php/Readdir_performance_results.  If anybody has suggestions for better ways to organize the data, please let me know.  I'll also try to post some graphs in the next couple of days.

I think graphs would certainly help.
Also it might be good to be explicit about the server hardware/config as that
can make a real performance difference.

No bright ideas about how to organise the graphs...
I'd probably try just graphing the 'real' time against kernel version
with one line for each different directory size.

Then you get 16 graphs, 4 different configs (v3/v4 x rddirplus/norddirplus)
and 4 different tests (ls -f, ls -lU, ls -U, rm -r... though I can't see how
"ls -U" is different from "ls -f").

NeilBrown
