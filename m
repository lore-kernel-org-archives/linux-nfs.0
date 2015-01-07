Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:55370 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753672AbbAGSr4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 13:47:56 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so1780578igi.12
        for <linux-nfs@vger.kernel.org>; Wed, 07 Jan 2015 10:47:55 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Subject: Re: [PATCH 0/3] Remove function macros from nfs4_fs.h
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20150106190800.GB28003@fieldses.org>
Date: Wed, 7 Jan 2015 13:47:53 -0500
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <2705333F-CCAE-44E2-BD42-76FEB452B764@primarydata.com>
References: <1420485444-20101-1-git-send-email-Anna.Schumaker@Netapp.com> <1C602278-4A23-4975-8339-7AFF0606B154@primarydata.com> <20150106190800.GB28003@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 6, 2015, at 2:08 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Mon, Jan 05, 2015 at 03:31:46PM -0500, Weston Andros Adamson wrote:
>> These patches look good to me, but have you tested them? ;)
>> 
>> I mean, does anyone have a server that implements SP4_MACH_CRED to test against?
>> When I originally developed this feature, I tested against a hacked nfsd…
>> that code was really ugly (not ready for upstreaming), but allowed me to test the client
>> feature.
>> 
>> IRRC the server side is difficult because the server has to keep stateid to credential
>> mappings, so when the machine cred was used it could check access against the acting cred. 
>> 
>> If there aren’t any servers to test this against, maybe we remove this feature? It can always
>> be revived once there is a server to test against.
> 
> The Linux server should support MACH_CRED as of
> 57266a6e916e2522ea61758a3ee5576b60156791 "nfsd4: implement minimal
> SP4_MACH_CRED".  (Well, plus some later bugfixes.)  But I think anything
> since 3.14 should be OK.
> 
> That said, I wouldn't be surprised if it has problems.  But please do
> test against that and let me know....
> 
> --b.

Ah, right, but only for state operations that don’t touch the filesystem:

OP_BIND_CONN_TO_SESSION
OP_EXCHANGE_ID
OP_CREATE_SESSION
OP_DESTROY_SESSION
OP_DESTROY_CLIENTID

Which is not that interesting, since the client should already be using the machine cred
with these operations.

What is interesting is supporting write and commit (and associated ops, i.e. sequence).
That way when a client is doing buffered writes and the user cred expires, it can flush the
locally cached data. This is what the linux client SP4_MACH_CRED feature focused on.

I think implementing SP4_MACH_CRED for these operations has the issue I mentioned
earlier: the fh_verify path will have to check credentials against some cached credential
(tied to the stateid), because request will contain the machine credential and not the user
credential that previous writes (before cred expiration) used.

-dros

