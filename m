Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37585 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1030622AbdI0Apc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Sep 2017 20:45:32 -0400
From: NeilBrown <neilb@suse.com>
To: Stefan Hajnoczi <stefanha@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 27 Sep 2017 10:45:17 +1000
Cc: "Daniel P. Berrange" <berrange@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Justin Mitchell <jumitche@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
In-Reply-To: <20170926105626.GH16834@stefanha-x1.localdomain>
References: <20170919151051.GS9536@redhat.com> <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com> <20170919164427.GV9536@redhat.com> <20170919172452.GB29104@fieldses.org> <20170921170017.GK32364@stefanha-x1.localdomain> <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com> <E5B4D2FF-0DB4-417D-998A-6BBFC36C35C5@oracle.com> <20170922115524.GN12725@redhat.com> <87efqu6wl4.fsf@notabene.neil.brown.name> <20170926034026.GA19283@fieldses.org> <20170926105626.GH16834@stefanha-x1.localdomain>
Message-ID: <87bmlx6kbm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 26 2017, Stefan Hajnoczi wrote:

> On Mon, Sep 25, 2017 at 11:40:26PM -0400, J. Bruce Fields wrote:
>> On Tue, Sep 26, 2017 at 12:08:07PM +1000, NeilBrown wrote:
>> > On Fri, Sep 22 2017, Daniel P. Berrange wrote:
>> > Rather than a flag, it might work to use network namespaces.
>> > Very early in the init sequence the filesystem gets mounted using the
>> > IPv6 link-local address on a client->host interface, and then a new
>> > network namespace is created which does not include that interface, and
>> > which everything else including firewall code runs in.  Maybe.
>>=20
>> That seems closer, since it allows you to hide the interface from most
>> of the guest while letting some special software--qemu guest agent?--
>> still work with it.  That agent would also need to be the one to do the
>> mount, and would need to be able to make that mount usable to the rest
>> of the guest.
>>=20
>> Sounds doable to me?
>>=20
>> There's still the problem of the paranoid security bureaucracy.
>>=20
>> It should be pretty easy to demonstrate that the host only allows
>> point-to-point traffic on these interfaces.  I'd hope that that, plus
>> the appeal of the feature, would be enough to win out in the end.  This
>> is not a class of problem that I have experience dealing with, though!
>
> Programs wishing to use host<->guest networking might still need the
> main network namespace for UNIX domain sockets and other
> communication.

Did I miss something.... the whole premise of this work seems to be that
programs (nfs in particular) cannot rely on host<->guest networking
because some rogue firewall might interfere with it, but now you say
that some programs might rely on it....

However I think you missed the important point - maybe I didn't explain
it clearly.

My idea is that the "root" network namespace is only available in early
boot.  An NFS mount happens then (and possibly a daemon hangs around in
this network namespace to refresh the NFS mount).  A new network
namespace is created and *everthing*else* runs in that subordinate
namespace.

If you want host<->guest networking in this subordinate namespace you
are quite welcome to configure that - maybe a vethX interface which
bridges out to the host interface.
But the important point is that any iptables rules configured in the
subordinate namespace will not affect the primary namespace and so will
not hurt the NFS mount. They will be entirely local.

There should be no need to move between namespaces once they have been
set up.

NeilBrown


>
> For example, the QEMU guest agent has a command to report the IP
> addresses of the guest.  It must access the main network namespace to
> collect this information while using a host<->guest socket to
> communicate with the hypervisor.
>
> I think this can be achieved as follows:
> 1. open /proc/self/ns/net (stash the file descriptor)
> 2. open /var/run/netns/hvnet & call setns(2) to switch namespaces
> 3. socket(AF_INET6, SOCK_STREAM, 0) to create host<->guest socket
> 4. call setns(2) to switch back to main namespace
>
> In other words, the program stays mostly in the main network namespace
> and only enters the host<->guest namespace to create sockets.
>
> setns(2) with a network namespace requires CAP_SYS_ADMIN so it's not
> very practical.
>
> Is there an alternative that makes using the host<->guest network
> namespace less clunky?
>
> Stefan
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlnK9KAACgkQOeye3VZi
gbmZvg/+OlCQitxAm2BCzURqr21/yHtpLmK3clv1TsP768KnI6fqSUCEuphYey9V
Rww6aPWcOv6uk2xNkNYQWwevXgBKqeyEzgPig+4Cs132cF8B+8V77GwsuZI7levY
HgMjWbiff71Rp4JzWf4ODHt18ooCajy27qz2LyBnI2Wgdp5eCkNcHq8T+KJzlpBV
nTdgQ6VBKf5NodzPl8xo1S+ajEIjOceu4K/+k1T12FrhL4NbzsJEBOpkitMcBHcv
gfHJDtvgP/P+IXVid73STs3QMeahZKE4+0tFvKw7030spx82O7TW87MENuGp2jOv
hrnZ/QGQ0pDS7LNKBnxCqP927wcrhSpEVY4dEAEVClZcRaqW23OSpeU4TN0VW+g2
ZHKu4aV4w8Qdj36G3KVCVOk9Z8LNsp3jmB9Tqpo+Y21rlidLGXcPvKuNrwAjdFlT
x6AzFqWn1W+mRCuJK0eyiUr9fMU1EJefK+N32LzZtJg2N8ti0bB0jH+Xf/0yKVgb
woJd9PrIdwBiHzwr5N+5T+rOCW7JwOCut2xPOypbxdmWAHhk1iRNW2AUhfVqq0hE
95EsmQjEIBVzX4eUPYLue8e7U3yjBeN+lECXz/jtW84tEoI0zA8opflf+ZYJqiHn
sQP//LPyA1zFdN+WL7fMqDOMZxpwHcKXex9cEhSF8nV1A56ZcRg=
=V9aY
-----END PGP SIGNATURE-----
--=-=-=--
