Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:40462 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab1G0U6A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 16:58:00 -0400
Date: Wed, 27 Jul 2011 16:58:04 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v3 03/25] NFS41: Let layoutcommit handle multiple segments
Message-ID: <20110727205804.GA13698@merit.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
 <1311792048-12551-4-git-send-email-rees@umich.edu>
 <4E306F84.6030808@panasas.com>
 <1311798159.25645.32.camel@lade.trondhjem.org>
 <4E30762E.4000508@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E30762E.4000508@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Boaz Harrosh wrote:

  On 07/27/2011 01:22 PM, Trond Myklebust wrote:
  > On Wed, 2011-07-27 at 13:05 -0700, Boaz Harrosh wrote: 
  >> On 07/27/2011 11:40 AM, Jim Rees wrote:
  >>> From: Peng Tao <bergwolf@gmail.com>
  >>>
  >>> Some layout drivers like block will have multiple segments.  Generic code
  >>> should be able to handle it.  Layoutcommit takes a list of segments and last
  >>> write offset is saved at inode level.
  >>>
  >>> Signed-off-by: Peng Tao <peng_tao@emc.com>
  >>
  >> Trond Hi
  >>
  >> Could you please add this patch to the current Merge window? And also include
  >>
  >> CC: Stable <stable@vger.kernel.org>
  > 
  > Nope.
  > 
  > Firstly it exacerbates an existing bug in the current code (see my
  > comments).
  > 
  > Secondly, it does several things at once (adding multiple segment
  > handling, fixing last-byte handling in layoutcommit and credential
  > handling). Which of these features are actually needed for stable?
  > 
  
  OK, I agree I thought of that too. My bakethon post had a narrower scope
  to just the "adding multiple segment handling" & "last-byte handling"
  (I think let me check)
  
  But I thought for simplicity since this patchset was reviewed then, I've
  tested with this patch and it works good as well. If you are going to
  break things up, I can test with the minimal patches and report what is
  need in Stable. (Is anyone working on it?)

We may have over-squashed that one for block layout.  I can dig up the
original patches if necessary, but I'm guessing you probably have them.
