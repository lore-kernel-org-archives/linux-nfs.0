Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751339AbbCZRTq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2015 13:19:46 -0400
Message-ID: <55143FAF.7090200@RedHat.com>
Date: Thu, 26 Mar 2015 13:19:43 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Rupert Dance <rsdance@soft-forge.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Connectathon Issues
References: <009501d060e6$b54c3780$1fe4a680$@soft-forge.com> <5508AC34.3030508@RedHat.com> <64DCD95C-CD5C-4A16-B6EC-49661576C466@mindspring.com> <550AE575.4000104@RedHat.com> <003701d06265$b85ce8e0$2916baa0$@soft-forge.com>
In-Reply-To: <003701d06265$b85ce8e0$2916baa0$@soft-forge.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delayed response 

On 03/19/2015 12:57 PM, Rupert Dance wrote:
> We tried uncommenting the code but we are still seeing failures. We are
> running Connectathon on a variety of systems pairs testing both Mellanox and
> Intel Hardware. Most of the combinations pass the Connectathon Basic,
> Locking and Special tests but fail the General tests with the error message
> "Nroff ./stat: no data in nroff.time" 
What does output from the time command look like?

> 
> There are several other combinations that cause other errors:
> 
> 1. The test hangs and no error is reported.  In these cases the client
> system MUST be restarted before it becomes usable again. The server system
> is restarted to get back to a known good state and clear the exports before
> restarting testing
> 
> 2. Connectathon Basic test hangs with the client system displaying: ./test5:
> read and write
Is it really hung or is it just slow? On the client, use tshark host <server> 
to see if there is anything going over the wire...

steved.
