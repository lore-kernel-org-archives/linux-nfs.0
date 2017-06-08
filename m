Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49766 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751478AbdFHVyU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 17:54:20 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 09 Jun 2017 07:54:09 +1000
Cc: Steve Dickson <SteveD@RedHat.com>,
        Lennart Poettering <mzxreary@0pointer.de>,
        systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option and systemd.
In-Reply-To: <20170608153649.GB8625@fieldses.org>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name> <20170529133814.GC17967@gardel-login> <87tw43fgrf.fsf@notabene.neil.brown.name> <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com> <87lgp4dbx7.fsf@notabene.neil.brown.name> <2a7fd6d4-a965-02e0-3b7b-97c5743d7083@RedHat.com> <20170607120221.GJ27006@gardel-login> <ce5c37b4-a81b-4eaf-c1ac-7f36488bdaa9@RedHat.com> <87mv9jawjf.fsf@notabene.neil.brown.name> <20170608153649.GB8625@fieldses.org>
Message-ID: <874lvqb0xq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Thu, Jun 08 2017, J. Bruce Fields wrote:

> On Thu, Jun 08, 2017 at 03:16:52PM +1000, NeilBrown wrote:
>> So I think I've found a solution for systemd to handle "bg" nfs mounts
>> correctly.   I'll submit some pull requests for consideration.
>
> Out of curiosity, after that change is there still any reason you'd
> recommend any new user actually use "bg" (as opposed to an automount)?

Me? Recommend?  Who would listen?  Who would even hear?
For the last few years I've been recommending that automount should
be used for *all* NFS mounts at every opportunity.  I think I've had two
opportunities.

But no, I would not recommend "bg".  I would recommend automount and
then when they reported problems,  I would help fix them.

I would be much happier recommending automount if it were easier.
Setting up /etc/auto.direct with automountd is fairly easy, but you need
to actually enable it but modifying auto.master or auto.master.d, which
is slightly annoying.

systemd does make it easier to do direct mounts, but it is ugly.
You need to include "comment=systemd.automount" or "x-systemd.automount"
in /etc/fstab instead of just "automount" or "ondemand".  I understand
exactly why they did that and I cannot fault the logic.  But it still
looks clumsy.

With systemd, you cannot divorce the timeout that an application has to
wait when accessing the mountpoint while the server is down, from the
timeout imposed on the mount program.  i.e., mount cannot keep trying
in the background. - that could be useful if you want really-short
timeouts... at least it seems to me that they should be separate.

The timeout is configured differently if mounting from a device, or
mounting from anything else such as NFS.  The first uses
x-systemd.device-timeout.  The other needs x-systemd.mount-timeout.


But I'm ranting... I should probably shut up and send patches.
A generator for /etc/fstab.auto??

>
> I appreciate the effort to keep existing systems working, I'm just
> curious.

Compatibility with existing practice is certainly the main driver.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk5x4MACgkQOeye3VZi
gblSnA/+P84Y27LT0NRjTfBXASMCHoUcfO7WXlQjabWfW4DtWoqlfGHCAQuPd8z0
TudbyW0WvRHW+i/TDnlhkDnTdD8rzVM+RscfFhO4x7v4JbUbVAUXTWXBjgvjmMXd
LsTpu6Z539EkYlNMJ/CMin8Q64bsAQ7yTCOG5PILnU1SlW6HLQFD3Sij1rWWYXa4
UsCe7B1qNDO0qVu9qhUjg5FZBlJoHppkYsgI9q0id5/9BCGRq0ylZRCAGih+lTnr
OBDvPsZmRSZ1uEnojNsKaXd2J3mIEaa0Qxs+6it114ycAWxbxsutUGX0Yw0NjNGK
gCm+i2zO6y3Q1W96+bDhJ5sKs0F9IT82ZYvagO5tmqWrLnkLDk4RcQiksGAwJgT0
ptWY5xmF+wqRMsTepohYVFcb6QQFchgbaqbpwmq6a1T7M+DAAJb+5SqJQwroFA/t
MbsiG/TvavCL7xrsVGw7H7pIi5T7VHceg/EbxZirRda5SxA4vPrrYdRDsmEIMU3k
3Kr+4lRF3fJmuRV3inTzMNDI8yBFjj0TLCnaly83sR4iePU34tz5pLROsJJSnxVl
NQRA+8FhQF/GSs5Ke1kiabnlhNqSISOLagZzPqq6Zd6ydv04R/p+6f2yHjifG4ro
wOsh0Qie+E0bKmne7sfFK1l7u1AIWtaXmo5YIr3s1dAj/PnCDyg=
=/AxH
-----END PGP SIGNATURE-----
--=-=-=--
