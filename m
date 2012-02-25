Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52476 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756766Ab2BYAcd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Feb 2012 19:32:33 -0500
Received: by eekc4 with SMTP id c4so1172349eek.19
        for <linux-nfs@vger.kernel.org>; Fri, 24 Feb 2012 16:32:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHHaOuasyyQY7p+HCRwyYuJDT0mmmXUpUCivfp9D8nNRUQ9qDg@mail.gmail.com>
References: <CAMgFM3CXWEXqo+Nr1tt6XS6XrhJVfW9a5Dx=iSACriCOxfXjkw@mail.gmail.com>
 <20120223115206.662b325c@redhat.com> <CAMgFM3DgWBSUsoSzcvn=2V+eFwj6wUdmb-XQjyyXGfCq9GD-=A@mail.gmail.com>
 <CAHHaOuasyyQY7p+HCRwyYuJDT0mmmXUpUCivfp9D8nNRUQ9qDg@mail.gmail.com>
From: Louie <snikrep@gmail.com>
Date: Fri, 24 Feb 2012 16:32:12 -0800
Message-ID: <CAMgFM3BT104oF5p2FDMK7ofrnLESUSVAsWnsk4iweF5L61SLrQ@mail.gmail.com>
Subject: Re: v4recovery client id lockup
To: David Brodbeck <brodbd@uw.edu>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good idea, went ahead and implemented this, and everything appears to
be working.

Sure glad to solve this, was driving us absolutely nuts (it would
freeze the NFS connections to our lab computers, which would crash
everything).

Many thanks!!
-Louie

On Fri, Feb 24, 2012 at 2:29 PM, David Brodbeck <brodbd@uw.edu> wrote:
>
>
> On Fri, Feb 24, 2012 at 1:08 PM, Louie <snikrep@gmail.com> wrote:
>>
>> I'm guessing there is no solution and our setup just isn't supported.
>> I'm leaning towards ditching the SSH tunnels and going with
>> unencrypted traffic for now, as it's not strictly necessary. But if
>> anybody has a tip on how to fix, would love to hear.
>>
>
> You could always switch to a VPN solution of some kind, such as OpenVPN.
>  This would let your clients have different IPs while still preserving the
> security advantages of an SSH tunnel.
>
> --
> David Brodbeck
> System Administrator, Linguistics
> University of Washington
>
