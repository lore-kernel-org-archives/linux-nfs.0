Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64172 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752741Ab1DGO26 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Apr 2011 10:28:58 -0400
Message-ID: <4D9DCA19.6060008@netapp.com>
Date: Thu, 07 Apr 2011 10:28:41 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: NeilBrown <neilb@suse.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Use of READDIRPLUS on large directories
References: <20110316155528.31913c58@notabene.brown>	<24085EE6-EF0B-4F36-8F6A-100AB863F408@oracle.com>	<4D80C5C6.2060003@netapp.com>	<1300285203.16266.46.camel@lade.trondhjem.org>	<20110317083034.479ecb5f@notabene.brown>	<1300311755.30551.17.camel@lade.trondhjem.org>	<20110317094019.23f31f53@notabene.brown>	<20110317171831.GA30180@fieldses.org>	<4D9A26B8.6080504@netapp.com> <20110405222019.6c4d2997@notabene.brown>
In-Reply-To: <20110405222019.6c4d2997@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/05/2011 08:20 AM, NeilBrown wrote:
> On Mon, 04 Apr 2011 16:14:48 -0400 Bryan Schumaker <bjschuma@netapp.com>
> wrote:
> 
>> I've done some more testing and posted my initial results here: https://wiki.linux-nfs.org/wiki/index.php/Readdir_performance_results.  If anybody has suggestions for better ways to organize the data, please let me know.  I'll also try to post some graphs in the next couple of days.
> 
> I think graphs would certainly help.
> Also it might be good to be explicit about the server hardware/config as that
> can make a real performance difference.

I've aded this to the readdir performance page.  Is there anything else I should put up about the server?

> No bright ideas about how to organise the graphs...
> I'd probably try just graphing the 'real' time against kernel version
> with one line for each different directory size.
> 
> Then you get 16 graphs, 4 different configs (v3/v4 x rddirplus/norddirplus)
> and 4 different tests (ls -f, ls -lU, ls -U, rm -r... though I can't see how
> "ls -U" is different from "ls -f").

I've added graphs showing real time.  I'll be putting up graphs showing sys time and total number of RPC calls throughout the day.

> NeilBrown
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

