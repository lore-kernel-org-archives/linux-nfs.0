Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:27454 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933080Ab0KPLND (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2010 06:13:03 -0500
Message-ID: <4CE2673B.2010207@panasas.com>
Date: Tue, 16 Nov 2010 13:12:59 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        NFSv4 <nfsv4@ietf.org>
Subject: Re: [nfsv4] [PATCH 16/22] pnfs-submit: rewrite of layout state handling
 and cb_layoutrecall
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>	<1289551724-18575-17-git-send-email-iisaman@netapp.com>	<4CE003A6.2000606@panasas.com>	<AANLkTinMiVuKJB6b6C+nZO9bMevp_jkjwVobFv7di0jq@mail.gmail.com>	<4CE15D32.9070905@panasas.com>	<AANLkTint1tMO28-0+mdQdaRVO-eegBOvQutAuCFCmh1X@mail.gmail.com>	<4CE187D8.4090207@panasas.com> <AANLkTinj+F63q9V6LeuVSsLFziT6iBhudf_uvGB7KFM1@mail.gmail.com> <4CE254DD.808@panasas.com>
In-Reply-To: <4CE254DD.808@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/16/2010 11:54 AM, Boaz Harrosh wrote:
> 
> It's not clear cut lawyer proof. But the way I understand this sentence is
> that "If the client does not have a layout state eg. he did not request one
> or returned all previous layouts"
> 

To clarify, above "he did not request one"
should be "did not successfully received one" with a new layout-stateid
of course.

Thanks
Boaz
