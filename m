Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14273 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142AbaAIQC0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jan 2014 11:02:26 -0500
Message-ID: <52CEC879.8000805@RedHat.com>
Date: Thu, 09 Jan 2014 11:04:09 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] statd: include stdlib.h in simu.c
References: <1389225273-24273-1-git-send-email-rees@umich.edu> <20140109003618.GA6055@umich.edu>
In-Reply-To: <20140109003618.GA6055@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/01/14 19:36, Jim Rees wrote:
> Jim Rees wrote:
> 
>   Prevents undefined ref to NULL.
>   
> You can probably ignore this. I missed an autogen.
Considered ignored! ;-) 

steved.
> 
