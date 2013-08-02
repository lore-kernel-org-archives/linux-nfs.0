Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out03.mta.xmission.com ([166.70.13.233]:56136 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755423Ab3HBRpC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Aug 2013 13:45:02 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: David Howells <dhowells@redhat.com>
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org, krbdev@mit.edu,
        "Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
        linux-kernel@vger.kernel.org, simo@redhat.com
References: <87ob9hovop.fsf@xmission.com>
	<20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
	<20130801173902.28023.68819.stgit@warthog.procyon.org.uk>
	<7289.1375463126@warthog.procyon.org.uk>
Date: Fri, 02 Aug 2013 10:44:46 -0700
In-Reply-To: <7289.1375463126@warthog.procyon.org.uk> (David Howells's message
	of "Fri, 02 Aug 2013 18:05:26 +0100")
Message-ID: <871u6coult.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for persistent per-UID kerberos caches
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>
>> > The cache returned is a keyring named "_krb.<uid>" that the possessor can
>> > read, search, clear, invalidate, unlink from and add links to.  SELinux
>> > and co. get a say as to whether this call will succeed as the caller must
>> > have LINK permission on the cache keyring.
>> 
>> I think it would be more accurate to say you use the existing LSM
>> security hooks for security keys.
>
> Yes.
>
>> Calling out SELinux in particular just seems odd as there is absolutely
>> nothing SELinux specific in this patch.
>
> Sorry, I normally think of SELinux as that's what I usually deal with.  Yes,
> any and all LSMs.
>
>> > +		    !nsown_capable(CAP_SETUID))
>>
>> You you make this ns_capable(ns, CAP_SETUID);
>> 
>> nsown_capable is the right thing here but I am trying to remove the
>> function because it makes it too easy to not think about which
>> user namespace you are in.
>
> Okay.
>
>> > +	index_key.desc_len = sprintf(buf, "_krb.%u", __kuid_val(uid));
>> 
>> Please don't use the implementation detail __kuid_val.  Please use
>> from_kuid(&init_user_ns, uid) instead so it is explicitly documented
>> which user namespace you are using.
>
> Actually, I don't want that either.  I want the user-visible UID from the
> namespace.

Which is a definite reason to use from_kuid().  So you think about which
user namespace you want this to be seen in.

I guess if this is all in the user namespace from_kuid(ns, uid) is what
you are after.  I was thinking this was heading to the upcall which only
runs in the initial user namespace.  When passing things to the upcall
it makes sense to use values in the initial user namespace.

Eric
