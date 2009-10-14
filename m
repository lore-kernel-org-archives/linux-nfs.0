From: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Subject: Re: [pnfs] [PATCH 1/1] nfs41: resolve some race conditions with
	queued SEQUENCE operations when unmounting
Date: Wed, 14 Oct 2009 15:09:52 -0700
Message-ID: <5e24e8930910141509j3fad98afr66e25c465ced1e42@mail.gmail.com>
References: <1255561029-2925-1-git-send-email-batsakis@netapp.com>
	 <1255555809.6308.34.camel@heimdal.trondhjem.org>
	 <5e24e8930910141450h11e677bbr17ebe3441a8742d8@mail.gmail.com>
	 <1255557198.6308.36.camel@heimdal.trondhjem.org>
	 <1255557476.6308.39.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:32918 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231AbZJNWK2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2009 18:10:28 -0400
Received: by pzk26 with SMTP id 26so202732pzk.4
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2009 15:09:52 -0700 (PDT)
In-Reply-To: <1255557476.6308.39.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 14, 2009 at 2:57 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Wed, 2009-10-14 at 17:53 -0400, Trond Myklebust wrote:
>> On Wed, 2009-10-14 at 14:50 -0700, Alexandros Batsakis wrote:
>> > a) nfs41_sequence_done() called after destroy_session() that leads=
 to
>> > a NULL pointer dereference
>> > b) a BADSESSION reply to a sequence operation triggers a
>> > reset_session() at the same time with destroy_session() (called by
>> > umount) that leads to another NULL pointer dereference.
>>
>> This would mean that nfs41_sequence_done is being called _after_ the
>> nfs_client (and hence the session) has been destroyed. That sounds l=
ike
>> the real bug that needs to be fixed.
>
> Correction: it means that nfs41_sequence_done is being called after t=
he
> superblock that "owns" those rpc calls has been destroyed. (Which is =
a
> bug... :-))
>

Agreed. FWIW and from a conceptual point of view, the patch above is a
bit orthogonal to that as it deals with the problem within the session
scope. It treats the umount just as a session destroyer that happens
to always destroy the super-block in the current
one-session-per-client implementation. The latter may change, but the
patch will remain relevant (obviously with few adjustments).
Anyway, as long as we fix the bug I am happy :)

-alexandros

> Cheers
> =A0Trond
>
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
