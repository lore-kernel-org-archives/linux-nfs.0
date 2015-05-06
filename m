Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44270 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbbEFU2z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2015 16:28:55 -0400
Message-ID: <554A7982.50604@RedHat.com>
Date: Wed, 06 May 2015 16:28:50 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Calvin Walton <calvin.walton@kepstin.ca>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: Substitute sbindir in systemd unit files.
References: <1429638029-13637-1-git-send-email-calvin.walton@kepstin.ca>
In-Reply-To: <1429638029-13637-1-git-send-email-calvin.walton@kepstin.ca>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/21/2015 01:40 PM, Calvin Walton wrote:
> The systemd unit files now include the correct full paths to the
> executables when nfs-utils is configured with an alternate value
> for e.g. --prefix or --sbindir
> 
> Signed-off-by: Calvin Walton <calvin.walton@kepstin.ca>
This kind of major change always makes me a bit nervous and
unfortunately I'm not going to have the cycles to give
it the testing I would like because I'm going on holiday 
all next week...

I'll keep it on my TODO list because it sound like it makes
sense... but probably will not get to it for a couple weeks.

Also, would you mind breaking the patch up to show what you
are doing to each script? It would make it a lot easier 
to review... 

steved.
 
