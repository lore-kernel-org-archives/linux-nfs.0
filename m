Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:40952 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185Ab2CPRmC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 13:42:02 -0400
Received: from [192.168.23.207] (dsl254-070-154.nyc1.dsl.speakeasy.net [216.254.70.154])
	by che.mayfirst.org (Postfix) with ESMTPSA id 983E9F970
	for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 13:41:58 -0400 (EDT)
Message-ID: <4F637B68.2000202@fifthhorseman.net>
Date: Fri, 16 Mar 2012 13:42:00 -0400
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Reply-To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Error: state manager encountered RPCSEC_GSS session expired against
 NFSv4 server
References: <1331912791.2336.3.camel@localhost> <1331919386.2518.44.camel@lade.trondhjem.org>
In-Reply-To: <1331919386.2518.44.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/16/2012 01:36 PM, Myklebust, Trond wrote:
> The problem is that if the client doesn't have a machine cred, then you
> end up taking a random user credential that may not currently be holding
> any OPEN files. In that case too the RENEW will fail.

So if i'm understanding this right:

Sachin's proposal fails when the machine has no machine creds.

The current implementation fails when the logged-in user's credentials 
are expired.

Can the NFS client's logic test for those different cases, use the 
appropriate creds for RENEW in their difference, and reduce the failure 
case to their intersection?

	--dkg
