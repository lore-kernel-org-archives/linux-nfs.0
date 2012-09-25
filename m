Return-Path: linux-nfs-owner@vger.kernel.org
Received: from earth.cora.nwra.com ([4.28.99.180]:41080 "EHLO
	mail.cora.nwra.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755607Ab2IYULV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Sep 2012 16:11:21 -0400
Message-ID: <50620FE7.9020103@cora.nwra.com>
Date: Tue, 25 Sep 2012 14:11:19 -0600
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Any way to allow setuid daemon to access krb5 automounted nfs
 directories?
References: <5061DF69.8030606@cora.nwra.com> <20120925175025.GA8020@umich.edu>
In-Reply-To: <20120925175025.GA8020@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/25/2012 11:50 AM, Jim Rees wrote:
> Orion Poplawski wrote:
>
>    Is there any way to allow setuid daemon to access krb5 automounted
>    nfs directories?  Specifically I'm looking to run spamassassin's
>    spamd on a remote server and access user's home directories via krb5
>    nfs4.  spamd changes user to the user receiving the email being
>    processes and needs to modify files in the user's home directory.
>    Is there any reasonably secure way to give this daemon the ability
>    to do this?  Any way to tell rpc.gssd to use a specific credential
>    cache for this type of access rather than the default for that
>    effective uid?
>
> You don't want to give spamd the user's credentials. You want to acl the
> user's files so that spamd can do what it wants. Spamd will need its own
> krb5 principal.

Hmm, okay, I may be able to run spamd in non-setuid mode and get it to work. 
Thanks.

> But I hope you're not planning to deliver mail over nfs. I think that would
> be a mistake.
>

Oh no, but my mail host at the moment is woefully under-powered so I've moved 
spam scanning off of it.

-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com
