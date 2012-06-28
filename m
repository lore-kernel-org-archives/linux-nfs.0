Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12743 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693Ab2F1Qb6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jun 2012 12:31:58 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/1] SUNRPC handle EKEYEXPIRED in call_refreshresult
Date: Thu, 28 Jun 2012 16:31:41 +0000
Message-ID: <19150370-D1BD-4CC1-90BD-383805DE9557@netapp.com>
References: <1340827535-3062-1-git-send-email-andros@netapp.com>
 <20120628114353.4f75aabc@tlielax.poochiereds.net>
In-Reply-To: <20120628114353.4f75aabc@tlielax.poochiereds.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 28, 2012, at 11:43 AM, Jeff Layton wrote:

> On Wed, 27 Jun 2012 16:05:34 -0400
> andros@netapp.com wrote:
> 
>> From: Andy Adamson <andros@netapp.com>
>> 
>> Without this patch attempting to access a Kerberos mount with expired or no
>> credentials resulted in the NFS client hanging while retrying to refresh creds
>> for ever.
>> 
>> I tested NFSv3/v4/v4.1 sec=krb5 mounts. With expired or non-existent user
>> Kerberos credentials, trying to ls the mountpoint, or cd into the mountpoint
>> resulted in three failed upcalls to gssd (due to tk_cred_retry being set to 2)
>> then the 'Operation not permitted' message is returned to the user.
>> 
>> I think this patch should go into the stable kernel.
>> 
>> Andy Adamson (1):
>>  SUNRPC handle EKEYEXPIRED in call_refreshresult
>> 
>> fs/nfs/nfs4proc.c |    2 --
>> net/sunrpc/clnt.c |    4 ++++
>> 2 files changed, 4 insertions(+), 2 deletions(-)
>> 
> 
> Wait...is this really the behavior you want here?

Yes. Just having the client hang with no indication to the user is wrong.

> 
> We had many complaints from users of krb5 mounts where long-running
> jobs would routinely fail when the ticket expired.

That is a Kerberos ticket management issue, not an NFS kernel client issue.
You have long-running jobs, then kinit -l,  run krenew, or use a keytab with a cron job, 
or use some other credential management software package.


> The compromise behavior that we worked out at that time was to treat an
> expired credcache differently from a "no credcache" situation. gssd would
> return EKEYEXPIRED if the credcache existed but was expired, and
> EACCES otherwise. The kernel would then treat those errors
> differently:

In both cases, EPERM is the correct response from the Linux NFS client, as 
the user has no permissions to do anything in the file system.

> 
>    http://permalink.gmane.org/gmane.linux.nfsv4/11019
> 
> With EKEYEXPIRED, we'd want RPCs to hang indefinitely until the tickets
> were renewed.

Sounds like a good DOS attack.  Consider V4.1 and a multi-user machine. If a
users credentials expire during a heavy I/O run - that user could be using all of the
session slots, and no other user could make progress while the RPCs call rpc_delay 
and retry  indefinitely...


> With EACCES, the call would return an error. The idea
> there is that the user would kdestroy if he needed to unwedge his krb5
> mount.

Exactly how is the user supposed to know to kdestroy? All they see is a hung mount.
 
> 
> This patch makes it sound like you're wanting to revert that behavior.
> Is that the case?

Yes.

> If so, what about people trying to run long-running
> tasks on a kerberized mount? Are they just SOL if their ticket isn't
> renewed in time?

Yes - as with _any_ resource, you need to plan ahead.  As I said above, the administrator in such a situation
needs to setup krenew or the equivalent.

-->Andy


> 
> -- 
> Jeff Layton <jlayton@redhat.com>

