Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-2.desy.de ([131.169.56.85]:43811 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994Ab1GNHOO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2011 03:14:14 -0400
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id 036B9DA8
	for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2011 09:14:12 +0200 (MEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id E2847DA4
	for <linux-nfs@vger.kernel.org>; Thu, 14 Jul 2011 09:14:09 +0200 (MEST)
Message-ID: <4E1E9725.5020707@desy.de>
Date: Thu, 14 Jul 2011 09:13:41 +0200
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Reply-To: tigran.mkrtchyan@desy.de
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: krb5 failures with recent nfs-utils
References: <20110713225939.GA13000@fieldses.org>
In-Reply-To: <20110713225939.GA13000@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/14/2011 12:59 AM, J. Bruce Fields wrote:
> On Fedora 15 I'm seeing odd krb5 behavior: the context initialization
> appears to work fine, but then gssd sends a malformed RPCSEC_GSS_DESTROY
> packet just before closing the connection.  The client's first operation
> to the server using the context is rejected because the server's mic
> verification fails.
>
> Has anyone else seen this?

I have reported the same issue couple of weeks ago

http://www.spinics.net/lists/linux-nfs/msg22142.html

I use suse 11.4 x86_64 and can reproduce it with native kernel 
2.6.37.xxx and 3.0.0-rc5.

To me it looks like that in rpc packet missing verifier. Nevertheless
the message length is up to verifier. What I failed to find out it the 
message length did not take verifier in the account or verifier is 
missing in the first place. I was looking the the kernel code, but may 
be problem is in gssd. I don't know which part of gss handling in user 
space and which part is in the kernel.

Tigran.
>
> I'll keep investigating.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

