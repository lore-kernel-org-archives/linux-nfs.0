Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13161 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750809Ab1ISPTg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 11:19:36 -0400
Message-ID: <4E775D80.9010902@RedHat.com>
Date: Mon, 19 Sep 2011 11:19:28 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] nfs-utils/blkmapd: Add complex block layout discovery
 and mapping daemon
References: <1313086848-7435-1-git-send-email-rees@umich.edu> <4E749FBC.5090609@RedHat.com> <20110917145217.GA15540@merit.edu>
In-Reply-To: <20110917145217.GA15540@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/17/2011 10:52 AM, Jim Rees wrote:
> Steve Dickson wrote:
> 
>   So I will make the enable_nfsv41 ==> enable_nfsdv41 change in 
>   the next rc release, alone with some other outstanding changes.
>   After that rc release, I'll commit this code and then make a minor 
>   release, 1.2.5, that will have this code on by default.
>   
>   Sound reasonable?
> 
> Sounds good to me.  About when could I expect to see 1.2.5 with blkmapd?
I'm hoping by the end of this week... I would like to get it into the 
Fedora 16 beta..

steved.
