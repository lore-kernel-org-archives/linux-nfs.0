Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BAE9C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 20:48:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 088C0217F5
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 20:48:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726563AbfACUsP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 15:48:15 -0500
Received: from out03.mta.xmission.com ([166.70.13.233]:60810 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726174AbfACUsP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 15:48:15 -0500
Received: from in02.mta.xmission.com ([166.70.13.52])
        by out03.mta.xmission.com with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.87)
        (envelope-from <ebiederm@xmission.com>)
        id 1gf9uW-0002XB-0r; Thu, 03 Jan 2019 13:48:12 -0700
Received: from ip68-227-174-240.om.om.cox.net ([68.227.174.240] helo=x220.xmission.com)
        by in02.mta.xmission.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.87)
        (envelope-from <ebiederm@xmission.com>)
        id 1gf9uU-0008Cu-0K; Thu, 03 Jan 2019 13:48:11 -0700
From:   ebiederm@xmission.com (Eric W. Biederman)
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "torvalds\@linux-foundation.org" <torvalds@linux-foundation.org>,
        "Anna.Schumaker\@netapp.com" <Anna.Schumaker@netapp.com>,
        "neilb\@suse.com" <neilb@suse.com>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <02d3ecd37f9390e7b8a7be8ec0e1cafb7fdbed26.camel@netapp.com>
        <CAHk-=whZkaZn1UQLad6v9vmfx8+BB3m8cvT0wcKdtg=k=FDbGw@mail.gmail.com>
        <87bm4yl4th.fsf@notabene.neil.brown.name>
        <55e9d0eb47662f2d6c308eba8b9a84fbba978ac8.camel@hammerspace.com>
Date:   Thu, 03 Jan 2019 14:47:53 -0600
In-Reply-To: <55e9d0eb47662f2d6c308eba8b9a84fbba978ac8.camel@hammerspace.com>
        (Trond Myklebust's message of "Thu, 3 Jan 2019 06:09:58 +0000")
Message-ID: <87muoheadi.fsf@xmission.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/25.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1gf9uU-0008Cu-0K;;;mid=<87muoheadi.fsf@xmission.com>;;;hst=in02.mta.xmission.com;;;ip=68.227.174.240;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX1/KMirJ3iq42GqXvsb7fA/3BRMML8ShoTA=
X-SA-Exim-Connect-IP: 68.227.174.240
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [GIT PULL] Please pull NFS client updates for 4.21
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Trond Myklebust <trondmy@hammerspace.com> writes:

> On Thu, 2019-01-03 at 15:53 +1100, NeilBrown wrote:
>> On Wed, Jan 02 2019, Linus Torvalds wrote:
>> 
>> > On Wed, Jan 2, 2019 at 2:42 PM Schumaker, Anna
>> > <Anna.Schumaker@netapp.com> wrote:
>> > > We also were unable to track down a maintainer for Neil Brown's
>> > > changes to
>> > > the generic cred code that are prerequisites to his RPC cred
>> > > cleanup patches.
>> > > We've been asking around for several months without any response,
>> > > so
>> > > hopefully it's okay to include those patches in this pull
>> > > request.
>> > 
>> > Looks ok to me, although I wonder what the semantics of
>> > cred_fscmp()
>> > are across namespaces?
>> > 
>> > IOW, it seems potentially a bit suspicious to do cred_fscmp() if
>> > the
>> > two creds have different namnespaces? Hmm?
>> > 
>> > Is there some reason that can't happen, or some reason it doesn't
>> > matter?

I think the function might be better named cred_uidgid_cmp to make
it clear that the comparison only cares about the uid and gid values
in the cred.  As  Trond points out all of the values are of kuid_t
and kgid_t so are namespace independent at that point.


>> Interesting question.
>> For the current use in NFS, it is consistent with existing practice
>> to
>> ignore the name space.
>> NFS file accesses (when using the normal uid-based access checks)
>> always
>> use the manifest uid of the process - the one returned by getuid()
>> (or
>> more accurately, getfsuid()).
>> Maybe this is wrong?  Maybe we should always use from_kuid() or
>> whatever
>> to get the uid/gid to send over the wire?
>> 
>> Anna/Trond: do you have thoughts on this?  If a process in a user
>> namespace accesses a file over NFS, should the UID presented to the
>> server be the one in that name-space, or the one you get by mapping
>> to
>> the global name-space?
>> Or should we map to the namespace that was active when the filesystem
>> was mounted?
>> 
>> I don't think cred_fscmp() should do any of this mapping, but maybe
>> it
>> should treat creds from different namespaces as different - as a
>> precaution.
>> 
>> Thanks,
>> NeilBrown
>
> The values being compared are in cred_fscmp() are all of type kuid_t or
> kgid_t so that means they have already been mapped from the user
> namespace into the kernel uid/gid space.
> When we put those kuid/kgid values onto the wire, we currently always
> use the init namespace rather than the user namespace of the mount
> process.

It happens that mounts of nfs are still limited to mounter in the
initial user namespace.  While it seems plausible that we could allow
unprivileged users to mount nfs filesystems the auditing of the code
base has not been done to confirm that is safe.  The nfs code base is a
large attack surface so this something that must be done with quite a
bit of caution.

> When using strong authentication (i.e. krb5) then none of this matters,
> since the server performs its own mapping of the presented RPCSEC_GSS
> session into a credential. That mapping is independent of the user
> namespace on the client, it just depends on which krb5 principal the
> process used to identify itself.
>
> The problem case is limited to when we're using the weak AUTH_UNIX
> authentication, since the server is then implicitly trusting the client
> to protect against identity spoofing. This is particularly true if the
> NFS server is being accessed through NAT, in which case it has very
> limited possibilities for discriminating between containers on the same
> client using the export table because they will all originate from the
> same source IP address. I think that for these cases, using the init
> namespace is the right thing to do for the same reason we use it with
> local filesystems: if we try to use a different namespace then
> unprivileged userspace processes might be able to manipulate the
> mapping to spoof the identities of privileged users or groups, or
> otherwise gain access to files to which they normally should not have
> access.
>
> Does that argument make sense?

I think the NAT case is something to be concerned about.  However I
believe the same attack is possible with an ordinary UDP or TCP socket
bound for the same server.  So I don't know if we can protect the
server.

In general I believe we should put things on the wire that match
sb->s_user_ns.  Matching the mounter of the filesystem.  Because that
means behavior on the wire is independent of if you are running
in a container or not.  That seems to be the least surprising thing to
do, and would match what a userspace nfs client would do.  But again
that is not an immediate concern.

Eric

