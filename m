Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:44454 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756359AbaDHMmN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Apr 2014 08:42:13 -0400
Received: by mail-ie0-f177.google.com with SMTP id rl12so820924iec.36
        for <linux-nfs@vger.kernel.org>; Tue, 08 Apr 2014 05:42:13 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: v4.0 CB_COMPOUND authentication failures
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140408123501.GA3532@fieldses.org>
Date: Tue, 8 Apr 2014 08:42:10 -0400
Cc: Layton Jeff <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        Adamson William Andros <androsadamson@gmail.com>,
        Lever Charles Edward <chuck.lever@oracle.com>
Message-Id: <E9D3EBB8-1458-4CB5-8754-EAD525E27D6C@primarydata.com>
References: <20140408082140.340c1328@tlielax.poochiereds.net> <20140408123501.GA3532@fieldses.org>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 8, 2014, at 8:35, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Tue, Apr 08, 2014 at 08:21:40AM -0400, Jeff Layton wrote:
>> I've recently been hunting down some problems with delegation handling
>> and have run across a problem with the client authenticates CB_COMPOUND
>> requests. I could use some advice on how best to fix it.
>> 
>> Specifically, check_gss_callback_principal() tries to look up the
>> callback client and then tries to compare the ticket in it against the
>> clp->cl_hostname:
>> 
>>        /* Expect a GSS_C_NT_HOSTBASED_NAME like "nfs@serverhostname" */
>> 
>>        if (memcmp(p, "nfs@", 4) != 0)
>>                return 0;
>>        p += 4;
>>        if (strcmp(p, clp->cl_hostname) != 0)
>>                return 0;
>>        return 1;
>> 
>> The problem is that there is no guarantee that those hostnames will be
>> the same. If, for instance, I mount "foo:/" and the SPN is
>> "nfs/foo.bar.baz" that strcmp will return true, and the CB_COMPOUND
>> request will get tossed out [1]. Ditto if I happen to mount a CNAME of the
>> server.
> 
> It sounds like a bug to me that the mount is succeeding without the name
> matching.
> 
> The security provided by krb5 is much weaker if we don't check that the
> name provided on the commandline matches what the server authenticates
> as.

Where would the client find that information? I don’t think that rpc.gssd passes that information down to us.

>> Now that we try to use krb5 on the callback channel even when sec=sys
>> is specified, this is very problematic.
> 
> And similarly I think the attempt to opportunistically use krb5 for
> state management should fail and fall back on auth_sys if the server's
> name doesn't match.
> 
>> I think that the ideal thing would be to stash the SPN that we use to
>> do the SETCLIENTID call and use that in the comparison above.
>> Unfortunately, the rpc_cred doesn't really seem to carry this info and
>> I don't see where we get enough information in the rpc.gssd downcall to
>> figure out what that SPN should be.
>> 
>> Anyone have thoughts or should we just remove the above check until we
>> come up with a better way to do this?
>> 
>> [1]: there's another bug that can cause the client to send a bogus
>>     reply instead of dropping the request as intended, but that's
>>     relatively simple to fix.
> 
> So I believe the matching really is a requirement and that it would be
> wrong to weaken it.
> 
> It sounds like there's also a server bug here if it's giving out
> delegations to a client that isn't responding to callbacks.
> 
> --b.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

