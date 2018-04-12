Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:43469 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753058AbeDLUFl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Apr 2018 16:05:41 -0400
Received: by mail-ua0-f173.google.com with SMTP id u4so4334668uaf.10
        for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2018 13:05:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180411173337.GQ16717@parsley.fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com> <20180220164229.65404-11-kolga@netapp.com>
 <20180308170511.GF10782@fieldses.org> <CAN-5tyFZR7nOKks7nA__rLE3p4Dr7uwm7dHyKb_obOn74NbnHw@mail.gmail.com>
 <20180410202123.GB5685@parsley.fieldses.org> <CAN-5tyHrO898GGFgtFELwidJM3O47HGJNHQ=HvFYv22ve51Q5g@mail.gmail.com>
 <20180410211307.GB314@fieldses.org> <20180411173337.GQ16717@parsley.fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 12 Apr 2018 16:05:39 -0400
Message-ID: <CAN-5tyFrwJeSGOt50euTCN_G9H5naiWSpyHLvFcQm8uV0YPUBg@mail.gmail.com>
Subject: Re: [PATCH v7 10/10] NFSD stop queued async copies on client shutdown
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 11, 2018 at 1:33 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> On Tue, Apr 10, 2018 at 05:13:07PM -0400, J. Bruce Fields wrote:
>> On Tue, Apr 10, 2018 at 05:07:02PM -0400, Olga Kornievskaia wrote:
>> > On Tue, Apr 10, 2018 at 4:21 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>> > > DESTROY_CLIENTID doesn't throw away all the client's state for it, it's
>> > > only meant to be called after the client has already cleaned up
>> > > everything else.  So:
>> > >
>> > >         https://tools.ietf.org/html/rfc5661#section-18.50.3
>> > >
>> > >         If there are sessions (both idle and non-idle), opens, locks,
>> > >         delegations, layouts, and/or wants (Section 18.49) associated
>> > >         with the unexpired lease of the client ID, the server MUST
>> > >         return NFS4ERR_CLIENTID_BUSY.
>> > >
>> > > My feeling is that "ongoing copies" also belongs on that list.
>
> And come to think of it we should actually be adding that check to
> client_has_state()--it should return clientid_busy if there are any
> copies in progress.
>
>> > > So the server behavior you're seeing sounds correct to me--the client
>> > > should cancel any ongoing copies before calling DESTROY_CLIENTID.
>> >
>> > If the behavior of returning ERR_DELAY until the copy is done is
>> > correct one, then I don't think I need this patch at all. Since copy
>> > takes a reference on the nfs4_client structure, then in
>> > __destroy_client() where nfsd4_shutdown_copy() is called the list will
>> > always be empty.
>>
>> Actually I guess it should be returning CLIENTID_BUSY.  Maybe that's a
>> preexisting bug.
>
> So the copy should be caught by the earlier client_has_state() check
> before it gets to the later mark_client_expired_locked().
>
> And after reminding myself how this works....  We only hold references
> on clients temporarily such as while we're actually processing an RPC
> from a client.
>
> An elevated cl_refcount prevents the server from removing the client
> even after the lease expires, or after the client reboots and attempts
> to clear its old state with a new EXCHANGE_ID/CREATE_SESSION.  I don't
> think that's what we want.  Clients still need to renew their lease in
> the usual way, a long-running async copy doesn't keep the lease renewed
> automatically.
>
> So, the asynchronous copy shouldn't hold a reference on the client.
>
> The copy thread can still safely use the client while it's running,
> because it knows that anyone destroying the client will first cancel the
> copy and wait for the thread to die.

Ok no reference on the client. I will add a check to
client_has_state() to check for on-going copies and then server would
return CLIENTID_BUSY. What was already in the patch was that during
client shutdown it would stop copies. I have tested for when the
server is expiring client's lease, it also shuts down any on-going
copies. I think I'm ready for the next version submission...
