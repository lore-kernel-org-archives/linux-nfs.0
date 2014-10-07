Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:60622 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbaJGNgN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Oct 2014 09:36:13 -0400
Received: by mail-vc0-f180.google.com with SMTP id le20so4732199vcb.39
        for <linux-nfs@vger.kernel.org>; Tue, 07 Oct 2014 06:36:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.11.1410070849050.8059@sh-el6.eng.rdu2.redhat.com>
References: <ACC0FF8A2EDF4D42AC55DCCCC7FC1E0E30845CB8@MAIL01.fnal.gov>
	<alpine.LRH.2.11.1410070849050.8059@sh-el6.eng.rdu2.redhat.com>
Date: Tue, 7 Oct 2014 09:36:12 -0400
Message-ID: <CAHQdGtRF+_yJKiWHKTmZZ1gx3Y9LsSk62EtZNjkZFPOr5u=vYw@mail.gmail.com>
Subject: Re: Linux NFSv4 security issue: client presents wrong user's
 credentials to NFS server
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: "Andrew J. Romero" <romero@fnal.gov>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Michael K. Rosier" <mrosier@fnal.gov>,
        Briant S Lawson <blawson@fnal.gov>,
        Joseph W Klemencic <jklemenc@fnal.gov>,
        Lynn A Garren <garren@fnal.gov>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 7, 2014 at 9:10 AM, Benjamin Coddington <bcodding@redhat.com> wrote:
> On Tue, 7 Oct 2014, Andrew J. Romero wrote:
>
>> Hi
>>
>> It is common in certain cases for
>> a Linux workstation administrator to
>> create a shared account with a
>> corresponding .k5login file.
>>
>> Kerberos principal strings for users
>> are added to the .k5login and the corresponding
>> users can logon as the local shared account using
>> their Kerberos credentials.
>>
>> Once logged on to the workstation, the user's
>> local identity (local to the workstation) is
>> the UID of the local shared account; however,
>> when accessing kerberized resources external
>> to the workstation (for example NFSv4 volumes),
>> the user's identity is expected to be the
>> individual user's kerberos identity.
>>
>> I am seeing the following serious security issue:
>>
>> If N users (user1@REALM , user2@REALM ...userN@REALM)
>> (who are listed  sharusr's .k5login) all logon to
>> workstation1 as sharusr and are all running sessions
>> simultaneously, then, the GSS Context / kerberos credentials
>> stored in and used by the NFS-client kernel code when
>> processing NFS requests on behalf of a user,
>> will be correct for 1 user and incorrect for N-1 users.
>>
>> Each of the N-1 users will not be able to
>> access NFS server resources that only they have been
>> granted access to; but, they will be able
>> to access all NFS resources that the 1  user
>> has been granted access to. (even if their
>> kerberos identity has not been granted access).
>>
>> Even after each of the N-1 users destroys their credentials
>> they still retain access to all NFS resources
>> that the 1 user has been granted access to.
>> Access will not be denied until the 1 user also destroys
>> his / her credentials.
>>
>> It is my understanding that the RPC GSS kernel module
>> on an NFS client system, keeps a GSS security context
>> (copy of a user's credentials) that it uses when it
>> communicates with the NFS server on the user's behalf.
>>
>> I believe that the kernel security context
>> relates back to the user mode process solely by UID number.
>
>
> That is correct.
>
>> Would adding session ID to the relation resolve the issue ?
>> Each Session for each user would then have a unique tuple
>> (UID,SessionID) that would map to the *correct* GSS Security
>> context in the kernel.
>
>
> I think what could be done is to hang gss contexts off either session
> or process keyrings - then each process group would be able to own an
> identity independently of other processes running with the same UID.
>
> To do this the gssd upcall could be moved to a request-key mechanism, as
> there would need to be a way to pass along which krb5 credentials ought
> to be used to establish the context.  I suppose that if the process
> already has krb5 credentials in a keyring ccache, those could be used -
> but I don't think that we could count on always having a keyring ccache
> available, and the fallback would be to try to guess which ccache to use
> based on UID as things are today.  There would additionally be the
> situation where keyring ccaches cannot be used, and the main problem
> becomes how to have a process tell gssd which credential cache to use.

The problem with the request key interface is that it is completely
broken when applied to containers, since it only runs in the global
init namespace context. Fixing that is a non-trivial exercise; you'd
have to not only carry a full namespace context with the RPC
credential, but also somehow apply it to the upcall thread.

The rpc.gssd model is much easier to manage, since the daemon itself
is started from the container's local init process.

> Maybe instead of establishing contexts at file access time, they could
> be established deliberately beforehand with a userspace command that
> would specify which krb5 credential to use to create the context, and
> then the context would hang off the process keyrings.  The client could
> then check to see if there's an existing keyring context, and if so use
> that, and if not do the upcall.
>

The server is free to drop any GSS session at any time, depending on
internal resource management requirements. A client must be able to
recover from that scenario or risk being unable to write back data.

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
