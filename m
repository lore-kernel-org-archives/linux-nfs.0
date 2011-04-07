Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cpmx.mail.saic.com ([139.121.17.160]:46186 "EHLO
	cpmx.mail.saic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755687Ab1DGXDb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2011 19:03:31 -0400
Content-Type: text/plain;
	charset="iso-8859-1"
Subject: RE: Prioritizing readdirplus/getattr/lookup
Date: Thu, 7 Apr 2011 15:48:22 -0700
Message-Id: <620E93B2E5CC3B46BD811165E3335B870B8B0E09@0461-its-exmb02.us.saic.com>
In-Reply-To: <770047.76192.qm@web65409.mail.ac4.yahoo.com>
References: <514401.95922.qm@web65408.mail.ac4.yahoo.com> <770047.76192.qm@web65409.mail.ac4.yahoo.com>
From: "Murata, Dennis" <DENNIS.MURATA@saic.com>
To: "Andrew Klaassen" <clawsoon@yahoo.com>,
        "Chuck Lever" <chuck.lever@oracle.com>
Cc: "Benny Halevy" <bhalevy@panasas.com>, "Jim Rees" <rees@umich.edu>,
        "Garth Gibson" <garth@cs.cmu.edu>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Did you set each ksoftirqd to a specific cpu?
Wayne 

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org 
> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Andrew Klaassen
> Sent: Thursday, April 07, 2011 4:50 PM
> To: Chuck Lever
> Cc: Benny Halevy; Jim Rees; Garth Gibson; linux-nfs@vger.kernel.org
> Subject: Re: Prioritizing readdirplus/getattr/lookup
> 
> --- On Thu, 4/7/11, Andrew Klaassen <clawsoon@yahoo.com> wrote:
> 
> > I do notice that ksoftirqd is eating up 100% of a core when I'm 
> > loading the server heavily.  I assume that's because I'm not using 
> > jumbo frames and the ethernet cards are spitting out interrupts as 
> > fast as they're able.
> 
> I just got myself edjumicated on smp_affinity, and now I'm 
> able to achieve 99% CPU usage by 8 nfsd processes on 8 cores 
> on a read-only, fully-cached workload, with ksoftirqd 
> processes only using 1% CPU per core.
> 
> Unfortunately, this doesn't help the "ls -l" speed.
> 
> Andrew
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe 
> linux-nfs" in the body of a message to 
> majordomo@vger.kernel.org More majordomo info at  
> http://vger.kernel.org/majordomo-info.html
> 
