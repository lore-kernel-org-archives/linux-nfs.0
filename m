Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33827 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753148Ab1G0UWl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 16:22:41 -0400
Subject: Re: [PATCH v3 03/25] NFS41: Let layoutcommit handle multiple
 segments
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Date: Wed, 27 Jul 2011 16:22:39 -0400
In-Reply-To: <4E306F84.6030808@panasas.com>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
	 <1311792048-12551-4-git-send-email-rees@umich.edu>
	 <4E306F84.6030808@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311798159.25645.32.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 13:05 -0700, Boaz Harrosh wrote: 
> On 07/27/2011 11:40 AM, Jim Rees wrote:
> > From: Peng Tao <bergwolf@gmail.com>
> > 
> > Some layout drivers like block will have multiple segments.  Generic code
> > should be able to handle it.  Layoutcommit takes a list of segments and last
> > write offset is saved at inode level.
> > 
> > Signed-off-by: Peng Tao <peng_tao@emc.com>
> 
> Trond Hi
> 
> Could you please add this patch to the current Merge window? And also include
> 
> CC: Stable <stable@vger.kernel.org>

Nope.

Firstly it exacerbates an existing bug in the current code (see my
comments).

Secondly, it does several things at once (adding multiple segment
handling, fixing last-byte handling in layoutcommit and credential
handling). Which of these features are actually needed for stable?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

