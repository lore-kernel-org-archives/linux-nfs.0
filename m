Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:29410 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753926Ab0G1OMI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jul 2010 10:12:08 -0400
Message-ID: <4C503AB5.1090204@panasas.com>
Date: Wed, 28 Jul 2010 17:12:05 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@umich.edu>
CC: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: pNFS client structure and function rename suggestions
References: <DD09EF29-A704-4F17-B917-C01051355CA3@netapp.com>	<4C500FFD.4000206@panasas.com> <AANLkTikf-9UDhi6_Jg0k8=wV64=JPGVm5T=scQk14xM1@mail.gmail.com>
In-Reply-To: <AANLkTikf-9UDhi6_Jg0k8=wV64=JPGVm5T=scQk14xM1@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/28/2010 04:48 PM, Fred Isaman wrote:
> On Wed, Jul 28, 2010 at 7:09 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>> struct nfs4_pnfs_layout_segment => pnfs_layout_range
>>
>> Isn't this a struct layout4 above?
> 
> No, this is probably the most confusingly named structure of them all,
> and one I would strongly urge be changed along the line of Andy's
> suggestion.
> 
> Fred
> 

We are like a married couple on a freezing night. Each pulling the blanket
to his/her side.

I'm trying to pull the blanket to the side. where all these are converted
to exactly the names and structures as stated by the standard.
That the Linux-pnfs-workgroup tried to invent their own STD is a misfortune
which I missed, getting so late into the game.

What side of the Bed are you pulling to?
I wish you elaborate more, and explain, instead of just saying "NO"

struct layout_content {
           layouttype4 loc_type;
           void      *loc_body;
};

struct layout {
           offset4                 lo_offset;
           length4                 lo_length;
           layoutiomode4           lo_iomode;
           layout_content4         lo_content;
};

struct layoutget_args {
           /* CURRENT_FH: file */
           bool                    loga_signal_layout_avail;
           layouttype4             loga_layout_type;
           layoutiomode4           loga_iomode;
           offset4                 loga_offset;
           length4                 loga_length;
           length4                 loga_minlength;
           stateid4                loga_stateid;
           count4                  loga_maxcount;
};

struct layoutget_res {
           bool               logr_return_on_close;
           stateid4           logr_stateid;
           layout             logr_layout;
};

How is the above less useful then the mess we have now?

Boaz
