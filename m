Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34843 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab1BEPzU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Feb 2011 10:55:20 -0500
In-Reply-To: <20110205080332.4899b352@corrin.poochiereds.net>
References: <3599.1295624067@redhat.com>
	<20110205080332.4899b352@corrin.poochiereds.net>
Date: Sat, 5 Feb 2011 09:55:18 -0600
Message-ID: <AANLkTikpjKys0LEkhYNErN9_2_ker4xdzBLpCEHf4dyW@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Unified keys for NFS, CIFS and AFS for security data
From: Steve French <smfrench@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: David Howells <dhowells@redhat.com>, lsf-pc@lists.linuxfoundation.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Feb 5, 2011 at 7:03 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Fri, 21 Jan 2011 15:34:27 +0000
> David Howells <dhowells@redhat.com> wrote:
>
>>
>> I'd like to propose a discussion topic for the LSF: how best to implement a
>> common key type for use by NFS, CIFS and AFS such that, say, a kerberos key
>> can be encapsulated within one and then be pulled out by various filesystems.
>>
>> Furthermore, it would be necessary to allow the request_key() upcall mechanism
>> to perform GSSAPI queries.
>>
>
> I would be interested in discussing this as well. Currently CIFS
> "punts" to some degree and offloads almost all of the SPNEGO blob
> construction to userspace. So, for CIFS this would involve moving more
> of this code into the kernel. I think that's a good thing since it will
> make it easier to do mutual-authentication, etc...

Yes. I also agree, in part because the more the upcall has to go
to userspace the more likely a reconnect (network connection
drop) can cause problems when memory available to userspace
is constrained by a large amount of cached data on the network mount.


> This would make it more plausible to store krb5 credcaches in the
> kernel keyring too. Modern MIT krb5 libs can do this today (I think),

yes

> The difficulty here is that request_key() is "stateless", so we need to
> think about how to manage GSSAPI contexts across multiple upcalls...or
> plan to implement large swaths of the GSSAPI in-kernel.

> It might also be helpful to couple this with some consolidation and
> cleanup of the ASN.1 parsing code in the kernel. There are at least 3
> separate implementations in the kernel today (one in cifs, one in
> sunrpc, and one in iptables).

This is harder, but would also simplify future work as well
(such as SMB2, which will require this more often in
sessionsetup than cifs)



-- 
Thanks,

Steve
