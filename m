Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:37242 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064Ab1HYUP0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Aug 2011 16:15:26 -0400
Date: Thu, 25 Aug 2011 16:15:23 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Peng Tao <bergwolf@gmail.com>, "Isaman, Fred" <Fred.Isaman@netapp.com>,
        Andy Adamson <andros@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@tonian.com>, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH] pnfsblock: init pg_bsize properly
Message-ID: <20110825201523.GA6901@merit.edu>
References: <1313197450-4595-1-git-send-email-bergwolf@gmail.com>
 <4E4ADBA1.1000005@panasas.com>
 <4E4B6A81.2010204@tonian.com>
 <CA+a=Yy6BSmEWurZuFN-8axTS0gfeXaguw5tcayeVjJmcFAztOQ@mail.gmail.com>
 <4E52EBAC.8070908@panasas.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AC9DF79@SACMVEXC2-PRD.hq.netapp.com>
 <CA+a=Yy4gm3789v0w-dGpZO1w9RrpC7ELgeM9=qNsf4tYigdw2A@mail.gmail.com>
 <4E541945.6@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E541945.6@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Boaz Harrosh wrote:

  On 08/23/2011 08:01 AM, Peng Tao wrote:
  > So this is a generic issue. For file and object layout, do you need to
  > use partial read/write rpc ops in any case? For block layout, we would
  > like to never use it in LD. But I'm not sure about file and object
  > case. Could you confirm?
  > 
  
  For objects it is like blocks. NEVER (ever) use partial rpc ops. r/wsize
  are not relevant for obj-LD IO.
  
  (As I understand from Trond also with files the LD should inspect the
   situation and have the final disposition. But someone will need to write
   some files-LD code for that, Fred, Andy?)
  
  > Thanks,
  > Tao

We discussed this on the call today.  Boaz is going to write a brief
description of how to fix this in the generic layer, then I'm going to
implement it.
