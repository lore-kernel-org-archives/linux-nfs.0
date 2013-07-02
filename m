Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751945Ab3GBMsG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jul 2013 08:48:06 -0400
Message-ID: <51D2CC03.9070303@RedHat.com>
Date: Tue, 02 Jul 2013 08:48:03 -0400
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



On 11/05/13 07:54, Doug Nazar wrote:
> Commit 1c787f14 [gssd: scan for DIR: ccaches, too] changed the default prefix for the credential cache files. Update the check to ignore the machine credential file when running with -n (root ignores machine credentials).
Committed...

In the future please send patches in line and with the work "[PATCH]" in the subject. 

steved.
