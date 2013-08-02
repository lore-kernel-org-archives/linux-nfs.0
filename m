Return-Path: linux-nfs-owner@vger.kernel.org
Received: from caiajhbdccah.dreamhost.com ([208.97.132.207]:54133 "EHLO
	homiemail-a32.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751909Ab3HBUuv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Aug 2013 16:50:51 -0400
MIME-Version: 1.0
In-Reply-To: <CAK3OfOj6E_thwgwdZUDXrr_7XW4xJkzwxdGU6gKcEJ3twOsm=A@mail.gmail.com>
References: <20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
	<20130801173854.28023.82045.stgit@warthog.procyon.org.uk>
	<CAK3OfOj6E_thwgwdZUDXrr_7XW4xJkzwxdGU6gKcEJ3twOsm=A@mail.gmail.com>
Date: Fri, 2 Aug 2013 15:50:48 -0500
Message-ID: <CAK3OfOj2HV32=zE+hD8vrHHAj94cPVw-HtPKZCdRoYepE7O8Mg@mail.gmail.com>
Subject: Re: [PATCH 1/2] KEYS: Implement a big key type that can save to tmpfs
From: Nico Williams <nico@cryptonector.com>
To: David Howells <dhowells@redhat.com>
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org, simo@redhat.com,
        linux-kernel@vger.kernel.org, krbdev@mit.edu
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 2, 2013 at 3:49 PM, Nico Williams <nico@cryptonector.com> wrote:
> Solving (b) in a way that does not add a new ccache type (though
> having a KEYRING: ccache type that means "find the ccache URI in my
> keyring" is fine) is important because many of us run multiple
> implementations of Kerberos on any given host, and we do it because:
>
>  - vendors are always behind the curve
>  - legacy software linked with old versions of libkrb5 and friends
>  - third party software

I forgot to add:

 - special needs

Nico
--
