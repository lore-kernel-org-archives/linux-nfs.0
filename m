Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49567 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754620AbbDJQsj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 12:48:39 -0400
Message-ID: <1428684512.2980.336.camel@redhat.com>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
From: Doug Ledford <dledford@redhat.com>
To: Michael Wang <yun.wang@profitbricks.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Tom Tucker <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        Mike Marciniszyn <infinipath@intel.com>, Eli Cohen <eli@mellanox.com>,
        Faisal Latif <faisal.latif@intel.com>,
        Upinder Malhi <umalhi@cisco.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Ira Weiny <ira.weiny@intel.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Haggai Eran <haggaie@mellanox.com>,
        Ilya Nelkenbaum <ilyan@mellanox.com>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Bart Van Assche <bvanassche@acm.org>,
        Shachar Raindel <raindel@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Devesh Sharma <devesh.sharma@emulex.com>,
        Matan Barak <matanb@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        Jiri Kosina <jkosina@suse.cz>,
        Selvin Xavier <selvin.xavier@emulex.com>,
        Mitesh Ahuja <mitesh.ahuja@emulex.com>,
        Li RongQing <roy.qing.li@gmail.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        Alex Estrin <alex.estrin@intel.com>,
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Tom Gundersen <teg@jklm.no>, Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 10 Apr 2015 12:48:32 -0400
In-Reply-To: <55277FE8.50107@profitbricks.com>
References: <5523CCD5.6030401@profitbricks.com>
		 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>
		 <20150408201015.GB28666@obsidianresearch.com>
		 <1428590070.2980.190.camel@redhat.com>
		 <20150409160123.GA31353@obsidianresearch.com>
	 <1428614348.2980.287.camel@redhat.com> <55277FE8.50107@profitbricks.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-QuncKVKZ/VwFHW4+TW57"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-QuncKVKZ/VwFHW4+TW57
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-10 at 09:46 +0200, Michael Wang wrote:
> On 04/09/2015 11:19 PM, Doug Ledford wrote:
> [snip]
> >>
> >> I've written this before: The mess here is that it is too hard to know
> >> what the call sites are actually checking for when it is some baroque
> >> conditional.
> >=20
> > The two goals: being specific about what the test is returning and
> > minimizing the bitmap footprint; are not necessarily opposed.  One can
> > do both at the same time.
>=20
> This could be internal reforming after the cap_XX() stuff works for core
> layer, at that time we don't need to touch core layer anymore, just
> introducing this bitmap stuff in verb layer, replacing the implementation
> of these helpers with the bitmap check, and following the semantic (descr=
iption).

Agreed.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-QuncKVKZ/VwFHW4+TW57
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVJ/7gAAoJELgmozMOVy/dNs8P/iMI5mMLG7Tpr4qB4UWJfTXr
AUsEynKowlf/xQtqU0kJn1jITyl3HttN7QJfrtx66PnJ0kj+Qg5WN17mVP36Vicu
CJ6sxO9b5Rp1nwCTL5+OHdNVMeuxfrch7/pMb729PuRwpGrTzpUf7SDXI55zOVk1
z55HmezbE82dUC7DpRx3+NE/BBX2V51/eCJpim6Cf6MMyPq4FkGfPNldvzaxnPb3
HQ4ZGkA+JvtLLdNpqOb0dXZcTg0XMK0KmgAJrr9eEwkGu3c+noP3heYQE8ROHfw/
IPLhTW7DOc8G8U1WoGWWKyYshpc3SlmvKuQUM362Jf9IyGY4Lv7DnOhnXdDjVEV4
ew+CeluxoeXfJhynntrvaT87+I5aYEDYYglEkgrC4eSEzlaHwtX0KPC0E6Ck7inR
aKr+YMaZMG5cB6tncdNoKPr7E3WlYwRiLmqTBVorFNwsqu4vYX9R9GZmfbWFv2/u
6udLt76al7Kp1LbCb9u+e0H/g3Ld+OESwPhKG/vQCzbc9LqD/EybmReJoxyOmRJe
lL8fMZ7IyXu8CTNkqo4YVKiIqXLAZAIZnx14AgxG697sU3BwNoh12bOpeJXKilxy
597z2Y4XmL8TOvN66dMhdSku7KB8KGjqZDfPlBfcvnYRkHPDa3qcZgFQRPx2k1Bl
8efZl6lKwCuPAFhv0dCN
=F4q2
-----END PGP SIGNATURE-----

--=-QuncKVKZ/VwFHW4+TW57--

