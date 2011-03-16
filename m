Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:65399 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab1CPNn2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2011 09:43:28 -0400
Subject: Re: Use of READDIRPLUS on large directories
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110316155528.31913c58@notabene.brown>
Date: Wed, 16 Mar 2011 09:43:19 -0400
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <24085EE6-EF0B-4F36-8F6A-100AB863F408@oracle.com>
References: <20110316155528.31913c58@notabene.brown>
To: NeilBrown <neilb@suse.de>, Bryan Schumaker <bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 16, 2011, at 12:55 AM, NeilBrown wrote:

> Hi Trond / Bryan et al.
> 
> Now that openSUSE 11.4 is out I have started getting a few reports
> of regressions that can be traced to 
> 
> commit 0715dc632a271fc0fedf3ef4779fe28ac1e53ef4
> Author: Bryan Schumaker <bjschuma@netapp.com>
> Date:   Fri Sep 24 18:50:01 2010 -0400
> 
>    NFS: remove readdir plus limit
> 
>    We will now use readdir plus even on directories that are very large.
> 
>    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> 
> This particularly affects users with their home directory over
> NFS, and with largish maildir mail folders.
> 
> Where it used to take a smallish number of seconds for (e.g.)
> xbiff to start up and read through the various directories, it now
> takes multiple minutes.
> 
> I can confirm that the slow down is due to readdirplus by mounting the
> filesystem with nordirplus.

Back in the dark ages, I discovered that this kind of slowdown was often the result of server slowness.  The problem is that a simple readdir is often a sequential read from physical media.  When you include attribute information, the server has to pick up the inodes, which is a series of small random reads.  It could cause each readdir request to become slower by a factor of 10.  This is a problem on NFS servers where the inode cache is turning over often (small home directory servers, for instance).

In addition, as more information per file is delivered by READDIRPLUS, each request can hold fewer entries, so more requests and more packets are needed to read a directory.  We hold the request count down now by allowing multi-page directory reads, if the server supports it.

In any event, applications will see this slow down immediately, but it can also be a significant scalability problem for servers.

> While I can understand that there are sometime benefits in using
> readdirplus for very large directories, there are also obviously real
> costs.  So I think we have to see this patch as a regression that should
> be reverted.

It would be useful to understand what it is about these workloads that is causing slow downs.  Is it simply the size of the directory?  Or is there a bug on the server or client that is causing the issue?  Is it a problem only on certain servers or with certain configurations?

> It would quite possibly make sense to create a tunable (mount option or
> sysctl I guess) to set the max size for directories to use readdirplus,
> but I think it really should be an opt-in situation.

Giving users another knob usually results in higher support costs and confused users.  ;-)

> [[ It would also be really nice if the change-log for such a significant
> change contained a little more justification.... :-(   ]]

I had asked, before this series was included in upstream, for some tests to discover where the knee of the performance curve between readdir and readdirplus was.  Bryan, can you publish the results of those tests?  I had hoped the test results would appear in the patch description to help justify this change.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




