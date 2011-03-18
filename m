Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:35416 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757036Ab1CRQg2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Mar 2011 12:36:28 -0400
Received: by qwk3 with SMTP id 3so2941796qwk.19
        for <linux-nfs@vger.kernel.org>; Fri, 18 Mar 2011 09:36:27 -0700 (PDT)
In-Reply-To: <20110318164828.943007egbodjy3t8@vovan.nl>
References: <1300387690.2684.23.camel@vovan.net.home>
	<AANLkTim6nptBM40b5Zt2fhr7aiQ47kqX+_RBprnCokRD@mail.gmail.com>
	<1300427036.30472.11.camel@vovan.net.home>
	<AANLkTim7q+-ijBnzWs+zW9X-gfxyrt5kw4Vj_pcrWJFw@mail.gmail.com>
	<20110318145204.20621su4mostcrk4@vovan.nl>
	<AANLkTimLE7gJ_tzi5JOCgM+RA4-8EnHcW8hqB++a5X8X@mail.gmail.com>
	<20110318164828.943007egbodjy3t8@vovan.nl>
Date: Fri, 18 Mar 2011 12:36:23 -0400
Message-ID: <AANLkTinGHaeF-G+XGj8--+m2NygX7fZ49gdf7sAepN=+@mail.gmail.com>
Subject: Re: rpc.svcgssd problem after updating client 1.2.2->1.2.3
From: Kevin Coffman <kwc@citi.umich.edu>
To: Vladimir Elisseev <vovan@vovan.nl>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 18, 2011 at 11:48 AM, Vladimir Elisseev <vovan@vovan.nl> wrote:
> Kevin,
>
> First of all, thank you for helping me with this issue.
>
> Quoting Kevin Coffman <kwc@citi.umich.edu>:
>
>> Re: the change to krb5.conf, yes I think you need to restart svcgssd.
>> And yes, it does have global effect (limiting all Kerberos connections
>> on the machine to DES), which is not optimal.
>
> I'll try to reproduce this later then if needed.

Sounds good.

>> Offhand, I'm not aware of any changes to gssd or svcgssd between
>> nfs-utils 1.2.2 and 1.2.3 that would affect this.  Moving from
>> Kerberos 1.6 to something later would bring in the acceptor subkey
>> issue.  (I believe both sides need to have krb5-1.7 or later libraries
>> for the subkey to be used.)  But again, your server's kernel _should_
>> have RPC GSS support for AES.
>
> The version of mit-kerberos used on all machines is 1.9. As for the change
> in nfs-utils, the only one I've found related to kerberos is the one below:
> commit 76be349d5dd07f55797cb9920cc275667258f10f
> Author: Kevin Coffman <kwc@citi.umich.edu>
> Date:   Thu Apr 15 08:32:20 2010 -0400
>
>    Try to use kernel function to determine supported Kerberos enctypes.
>
>    This patch replaces a hard-coded list with a function to obtain
>    the Kerberos encryption types that the kernel's rpcsec_gss code
>    can support.  Defaults to old behavior if kernel does not supply
>    information.

Wow! I've totally lost track of what version of nfs-utils this stuff
went into.  That patch deals only with limiting the encryption types
from the client side.  We assumed at that time that limiting the
enctypes in the server's keytab was all that would be needed to limit
the negotiated enctypes on the server side.

Looking back at the Changelog, the other important patch is this:

commit 4c5ff6d48021731128c4fc13d51610645a6fcf5c
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Mon Apr 12 17:13:25 2010 -0400

    Add support for non-DES encryption types.

    Sends a new format of context information to the kernel.
    (Requires kernel support to do anything useful.)

>> The patch here, http://www.spinics.net/lists/linux-nfs/msg19999.html,
>> along with the Kerberos patch referenced there, should limit the
>> negotiation to DES.  (w/o the kernel patch, it will use a default list
>> of only DES enctypes).
>
> After you mentioned this "acceptor subkey" patch, I took a look at both
> patches already.
>
>>
>> However, it might be better to figure out why your kernel doesn't like
>> the AES key.  Looking back at the other issues like this, the error
>> returned when the kernel doesn't have RPC GSS support for AES was
>> "function not implemented", not "invalid argument".  Just as a sanity
>> check, you've verified that the rpcsec_gss_krb5 kernel module is
>> loaded?
>
> I'm quite sure, that the rpcsec_gss_krb5 is in the kernel:
> zcat /proc/config.gz| grep -i krb
> CONFIG_RPCSEC_GSS_KRB5=y
> However, as I recently understand, the nfs-utils package for servers has
> been compiled against linus-header-2.6.32. Could it be the root of my
> problem? If that so, simply recompiling nfs-utils will solw the issue ;-)

That would be nice if it was the case.  I am really not sure whether
there are kernel header dependencies that could cause this.

K.C.
