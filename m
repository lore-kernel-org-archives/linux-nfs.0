Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EB21C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 04:53:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 337872070C
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 04:53:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726779AbfACExz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 23:53:55 -0500
Received: from mx2.suse.de ([195.135.220.15]:33398 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726058AbfACExz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Jan 2019 23:53:55 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 849F1ABCB;
        Thu,  3 Jan 2019 04:53:53 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Linus Torvalds <torvalds@linux-foundation.org>,
        "Schumaker\, Anna" <Anna.Schumaker@netapp.com>
Date:   Thu, 03 Jan 2019 15:53:46 +1100
Cc:     "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client updates for 4.21
In-Reply-To: <CAHk-=whZkaZn1UQLad6v9vmfx8+BB3m8cvT0wcKdtg=k=FDbGw@mail.gmail.com>
References: <02d3ecd37f9390e7b8a7be8ec0e1cafb7fdbed26.camel@netapp.com> <CAHk-=whZkaZn1UQLad6v9vmfx8+BB3m8cvT0wcKdtg=k=FDbGw@mail.gmail.com>
Message-ID: <87bm4yl4th.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain

On Wed, Jan 02 2019, Linus Torvalds wrote:

> On Wed, Jan 2, 2019 at 2:42 PM Schumaker, Anna
> <Anna.Schumaker@netapp.com> wrote:
>>
>> We also were unable to track down a maintainer for Neil Brown's changes to
>> the generic cred code that are prerequisites to his RPC cred cleanup patches.
>> We've been asking around for several months without any response, so
>> hopefully it's okay to include those patches in this pull request.
>
> Looks ok to me, although I wonder what the semantics of cred_fscmp()
> are across namespaces?
>
> IOW, it seems potentially a bit suspicious to do cred_fscmp() if the
> two creds have different namnespaces? Hmm?
>
> Is there some reason that can't happen, or some reason it doesn't matter?
>
>                   Linus

Interesting question.
For the current use in NFS, it is consistent with existing practice to
ignore the name space.
NFS file accesses (when using the normal uid-based access checks) always
use the manifest uid of the process - the one returned by getuid() (or
more accurately, getfsuid()).
Maybe this is wrong?  Maybe we should always use from_kuid() or whatever
to get the uid/gid to send over the wire?

Anna/Trond: do you have thoughts on this?  If a process in a user
namespace accesses a file over NFS, should the UID presented to the
server be the one in that name-space, or the one you get by mapping to
the global name-space?
Or should we map to the namespace that was active when the filesystem
was mounted?

I don't think cred_fscmp() should do any of this mapping, but maybe it
should treat creds from different namespaces as different - as a
precaution.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlwtlVoACgkQOeye3VZi
gbm/ixAAktdfJtR1DCg61/XBAcZ8oyAfYkamWYl3El3pkVwqIqtDCmMVG+N7pH2/
57ZM9cAKjRW97kyC/2c6+8vNxj02X35r6BcYw4wCZr8j4DUzv1y2fiowVTsg+0sd
BMwMCPqBjwOP4++6+ZSUYy7odE5HCwNrLkhmfbbM/Uoe/ScKmkhGZna6l11JI3Uy
CuvnSL9jNRc5VFsrr5gYld/MqBxUWvlLqk4VhMpvIUUrDnF2dcx/nOTwKzEMWndw
MjU1C4Qi/NQfKI/HpiyAqcMvZZh40dkaHXtdt+z05/DBRkXHjRASqDh2cezA9yUt
3dcRWiRCGwT1O4IJxYbFOp09P8I15q/l7R4JuJ8QH6WllAqGcJxI0ZU7uHmNVIV+
/mA8j2D/W3J5E/A1S0zPTY4y3uh5U9Pn+DyqRy4rc/ahpKLv465WXrkH4GK/y4JD
YI8Za/tzE2vUQvpHouAflqzZO6A2EcYynMTimZBGIxszAqaWu+AKgCIxcw35hopl
NnIe7YCLjSUTGYL0eBLIoSaeImCx/088YRzH64LMIyfWfuxHbGJsxogeN+pqqC4E
EyZrJMUSWsqOzObt2Uet1/IksKZ3uDcXsSxe3J+goRxoHSyLKzbXKaH5nRlkd2q6
LGqtK001/M+A+2Ujs60jcXLgRHAXlRUr6po595fkk/HpmkRPPeU=
=GsrE
-----END PGP SIGNATURE-----
--=-=-=--
