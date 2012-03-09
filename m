Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:55218 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584Ab2CIVcA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Mar 2012 16:32:00 -0500
Message-ID: <4F5A76CD.9080809@fifthhorseman.net>
Date: Fri, 09 Mar 2012 16:31:57 -0500
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] Kill SPKM3 auth method
References: <1331322586-4631-1-git-send-email-simo@redhat.com>
In-Reply-To: <1331322586-4631-1-git-send-email-simo@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/09/2012 02:49 PM, Simo Sorce wrote:
> This authentication method is obsolete and it is time it dies for good.

Can i ask what it has been obsoleted by?

Neither https://tools.ietf.org/html/rfc2025 [SPKM] nor 
https://tools.ietf.org/html/rfc2847 [LIPKEY] seem to suggest an 
inheritor, and kerberos5 does not provide direct public-key-based 
authentication (it's still reliant on an active and trusted third-party).

So it seems like SPKM and LIPKEY offer a cryptographic model that is 
otherwise unavailable for authentication between NFS endpoints.  What's 
the urgency for removal?

	--dkg
