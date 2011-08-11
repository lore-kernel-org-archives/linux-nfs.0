Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:44907 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933Ab1HKWNL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 18:13:11 -0400
Date: Thu, 11 Aug 2011 18:13:05 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@tonian.com>, Sorin Faibish <sfaibish@emc.com>,
        peter honeyman <honey@citi.umich.edu>, tao.peng@emc.com,
        torvalds@linux-foundation.org, rdunlap@xenotime.net,
        bergwolf@gmail.com, Trond.Myklebust@netapp.com,
        linux-raid@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, "Welch, Brent" <welch@panasas.com>
Subject: Re: [PATCH] pnfs: Automatically select blocks & objects layouts
Message-ID: <20110811221305.GA8608@merit.edu>
References: <CA+55aFwkJdyEpyNY64aAQ5ChrPZ8Kvx9iRUwy1J6_SRaxoN=zA@mail.gmail.com>
 <20110810122304.96b8be67.rdunlap@xenotime.net>
 <CA+a=Yy5izxiyvW5eYiWuute9E1vXwNTj4frdzNeEwsLDrszesg@mail.gmail.com>
 <20110810175829.a834d80f.rdunlap@xenotime.net>
 <CA+55aFzcSLrhkexEn=J7BN8F3P3Vy+EAjwgGwMQPdeoYoQG+Bw@mail.gmail.com>
 <F19688880B763E40B28B2B462677FBF805BF0EAC8A@MX09A.corp.emc.com>
 <4E43AAD1.7090806@tonian.com>
 <4E4422FD.3060706@panasas.com>
 <4E444552.9030105@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E444552.9030105@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Boaz Harrosh wrote:

  What about the below? based on v3.1-rc1
  
  ----
  From: Boaz Harrosh <bharrosh@panasas.com>
  Subject: [PATCH] pnfs: Automatically select blocks & objects layouts
  
  Just like files-layout, blocks & objects layouts are part of the
  NFS 4.1 protocol and should be automatically selected if NFS_4_1
  is selected. The small problem is that these depend on other
  Kernel support being present, while files only depends on NFS
  itself.
  
  This patch removes from the user choice the presence of objects
  and blocks layout. But makes sure these are selected only if
  the depended subsystems are present in the Kernel.
  
  Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Acked-by: Jim Rees <rees@umich.edu>

I think this is what we want.  There is no point allowing the user to pick
and choose various layout drivers.  If they have selected nfs4.1 they should
get all the layout drivers their kernel will support, based on the
dependencies.
