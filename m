Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21081 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855Ab3ELSUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 May 2013 14:20:23 -0400
Message-ID: <518FDD65.5080800@RedHat.com>
Date: Sun, 12 May 2013 14:20:21 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Doug Nazar <nazard.michi@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Fix gssd ignore machine credentials for root
References: <518E316A.8050002@gmail.com>
In-Reply-To: <518E316A.8050002@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

On 11/05/13 07:54, Doug Nazar wrote:
> Commit 1c787f14 [gssd: scan for DIR: ccaches, too] changed the default prefix for the credential cache files. Update the check to ignore the machine credential file when running with -n (root ignores machine credentials).
Thank you very much for point this bug out but could you please
resubmit the patch using the proper Signed-off-by format define section 
12 of https://www.kernel.org/doc/Documentation/SubmittingPatches

Sections 1, 7, 11, 15 are also some what important.... Thanks! 

steved.
