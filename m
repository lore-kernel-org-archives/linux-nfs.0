Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:32904 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753045AbeCFSJD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2018 13:09:03 -0500
Received: by mail-ua0-f178.google.com with SMTP id f6so8434492ual.0
        for <linux-nfs@vger.kernel.org>; Tue, 06 Mar 2018 10:09:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <D9BFFDFE-B80F-4220-9A54-F09F882BD0A1@gmail.com>
References: <20180110004920.11100-1-gjover@sipwise.com> <e18f29cd-639d-be9d-ee93-80df592468db@RedHat.com>
 <20180112184151.GA10261@thunder.hadrons.org> <9a53753a-56bf-12b5-f328-ff1f3a72249d@talpey.com>
 <CAFMMQGv03UmmsyXF4BOrwgW9ngpeO=dLjv=Qt=YiPpvgxfo85A@mail.gmail.com> <D9BFFDFE-B80F-4220-9A54-F09F882BD0A1@gmail.com>
From: Chuck Lever <chucklever@gmail.com>
Date: Tue, 6 Mar 2018 13:09:01 -0500
Message-ID: <CAFMMQGtt_u19RoCyQAQEaSZRXu3WQ-YSKu4u1BtKtJnaTQbKYw@mail.gmail.com>
Subject: Re: [PATCH] Do not bind to reserved ports registered in /etc/services
To: Guillem Jover <gjover@sipwise.com>
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 8, 2018 at 1:36 PM, Chuck Lever <chucklever@gmail.com> wrote:
>
>
>> On Feb 8, 2018, at 1:07 PM, Chuck Lever <chucklever@gmail.com> wrote:
>>
>> At Steve's request, I've filed a bug against libtirpc:
>>
>> https://bugzilla.linux-nfs.org/show_bug.cgi?id=320
>>
>> to document the issue and the rationales for alternate solutions.
>>
>> I'm fairly confident that bindresvport(3) is never necessary for
>> svc_tli_create(3). It is arguably also not appropriate for
>> clnt_tli_create(3). Therefore IMO it should be removed from those code
>> paths. That by itself would provide some relief and would eliminate
>> the need to alter the current bindresvport(3) implementation (say, by
>> introducing a blacklisting mechanism).
>>
>> As Tom mentioned above, RFC 6335 describes a port range that will
>> never interfere with service ports allocated by IANA. This range is
>> known as the Dynamic or Private port range (49152 - 65535). On my
>> systems, bind(3) already frequently allocates from the Dynamic port
>> range purely by chance.
>>
>> To completely prevent the accidental allocation of a well-known
>> service port, a special internal wrapper for the bind(3) system call
>> (similar to bindresvport(3)) can be constructed for libtirpc that
>> allocates only from the Dynamic port range whenever a caller does not
>> specify a port, making libtirpc adhere to the Best Common Practices
>> outlined in RFC 6335, and thereby closing this window for user space
>> RPC services completely.
>>
>> A more thorough solution IMO would be to fix up the bind(3) system
>> call to allocate only from the Dynamic port range whenever a caller
>> does not specify a port. This would take care of not only user space
>> RPC services but of all dynamically allocated ports on the system,
>> including ports dynamically allocated in the kernel.
>
> Replace "bind(3)" with "bind(2)" throughout. Oops.
>
> --
> Chuck Lever
> chucklever@gmail.com

As a first step, Steve has committed patches that address bugzilla 320.
This makes libtirpc avoid allocating reserved ports for RPC service
listeners and long-running clients that request a dynamically assigned
port. svc_tli_create(3) and clnt_tli_create(3) were wrong to use
bindresvport(3) for this purpose.

IMO this addresses the two cases Guillem Jover reported explicitly:
rpc.statd's listener, and the rpcbind CALLIT client. mountd on RHEL
systems appears to use 20048 (though it can use any dynamically-
assigned port) and lockd's service port is assigned by the kernel, so
it is typically outside the reserved port range.

Even so, I can see that making bindresvport(3) more particular
about skipping IANA-assigned ports in the reserved port range might
provide additional benefit/relief.

I checked with a pal on the Solaris NFS team to see if their user
space bindresvport(3) implementation was careful to avoid IANA-
assigned ports. He said it does not currently, but they have
considered it and probably will consider it again because there are
occasional requests for such functionality.

The question now is whether to consult /etc/services, a separate
blacklist, or both, when trolling for an unused reserved port. It seems
easiest to start with /etc/services; then perhaps introduce a blacklist
file/directory later if that is desirable. Other opinions?

Note that neither of these solutions addresses the largest consumer
of dynamically-assigned reserved ports: the kernel NFS client. The
only way we have to address that today is the "noresvport" mount
option. (We could make that the default for Kerberos mounts).

-- 
"We cannot take our next breath without the exhale."
 -- Ellen Scott Grable
