Received: from dvalin.narfation.org (dvalin.narfation.org [213.160.73.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1BE63AB287;
	Thu, 10 Sep 2026 16:56:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.160.73.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789059398; cv=none; b=HJKzcnIDFkhoe2QBCp4RxSTXdLSZklQ9lA/9o3r4EJbU4/6sH5UwhYUuVXrQEoO7fSrNWea+cHCIxc/Qfqf4pPUi/8oDOJm80RXR1yFLHOzpz4m8v/isCThWEb1l8zYTYfsxrA6srBeImTyMR3QOedjgMUC9SYR2HoN4BBpWtKU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789059398; c=relaxed/simple;
	bh=ScSG9WBXfS4Wo/8HDgWfWshTRFigOP1Fj1R22XjxUT0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=UWG/PNPJ3BOcvwcfagXSU5JivU87sfjf2cx6FcYoTCFWl0wNuwEZSLwW9sLabzu0qLR28NYvsJY6cGHLkvWU1j69BJreRSEeS0xdeIr2+UJX2LF43AjAHYCjZ9j+XGhTmUCUJ5k9HqQ7O96L32Mp19IDj55B/oD4tCFgd68PayU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=narfation.org; spf=pass smtp.mailfrom=narfation.org; dkim=pass (1024-bit key) header.d=narfation.org header.i=@narfation.org header.b=nwEXBdcA; arc=none smtp.client-ip=213.160.73.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=narfation.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=narfation.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=narfation.org header.i=@narfation.org header.b="nwEXBdcA"
Received: by dvalin.narfation.org (Postfix) id 2356320394;
	Thu, 10 Sep 2026 16:56:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=narfation.org;
	s=20121; t=1789059391;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=jpfKdfRhIDieddP8CnPCmiOpHujz9qF8RTfexgVbXU8=;
	b=nwEXBdcAy3Bpov4VOY4e9xQIUo1PQ2X9HlwxbfnLeQfMjABTkXF73qIcnksvyZ+lcbcS0g
	2rPkDRnl7UQZFmPrLPM9uczBVt0vyDhtL/31BVXskbZBb26AOMkMrYm6WaedfzaSpjh5hq
	RYBqqwgy91rok1+/oD3mlpj7KKJQqzg=
From: Sven Eckelmann <sven@narfation.org>
To: netdev@vger.kernel.org, Fernando Fernandez Mancera <fmancera@suse.de>
Cc: horms@kernel.org, kuba@kernel.org, pabeni@redhat.com, edumazet@google.com,
 davem@davemloft.net, Fernando Fernandez Mancera <fmancera@suse.de>,
 Jason Gunthorpe <jgg@ziepe.ca>, Leon Romanovsky <leon@kernel.org>,
 Andrew Lunn <andrew+netdev@lunn.ch>,
 Tony Nguyen <anthony.l.nguyen@intel.com>,
 Przemek Kitszel <przemyslaw.kitszel@intel.com>,
 Elad Nachman <enachman@marvell.com>, Saeed Mahameed <saeedm@nvidia.com>,
 Tariq Toukan <tariqt@nvidia.com>, Mark Bloch <mbloch@nvidia.com>,
 Ido Schimmel <idosch@nvidia.com>, Petr Machata <petrm@nvidia.com>,
 Edward Cree <ecree.xilinx@gmail.com>,
 Maxime Chevallier <maxime.chevallier@bootlin.com>,
 Maxime Coquelin <mcoquelin.stm32@gmail.com>,
 Alexandre Torgue <alexandre.torgue@foss.st.com>,
 Arend van Spriel <arend.vanspriel@broadcom.com>,
 Miri Korenblit <miriam.rachel.korenblit@intel.com>,
 Keith Busch <kbusch@kernel.org>, Jens Axboe <axboe@kernel.dk>,
 Christoph Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>,
 Chaitanya Kulkarni <kch@nvidia.com>, Saurav Kashyap <skashyap@marvell.com>,
 Javed Hasan <jhasan@marvell.com>, GR-QLogic-Storage-Upstream@marvell.com,
 "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>,
 "Martin K. Petersen" <mkp@kernel.org>, Nilesh Javali <njavali@marvell.com>,
 Manish Rangankar <mrangankar@marvell.com>, Varun Prakash <varun@chelsio.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
 David Howells <dhowells@redhat.com>, Marc Dionne <marc.dionne@auristor.com>,
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 Marek Lindner <marek.lindner@mailbox.org>,
 Simon Wunderlich <sw@simonwunderlich.de>,
 Antonio Quartulli <antonio@mandelbit.com>,
 Nikolay Aleksandrov <razor@blackwall.org>,
 Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
 Phil Sutter <phil@nwl.cc>, Johannes Berg <johannes@sipsolutions.net>,
 Matthieu Baerts <matttbe@kernel.org>, Mat Martineau <martineau@kernel.org>,
 Geliang Tang <geliang@kernel.org>, Julian Anastasov <ja@ssi.bg>,
 Aaron Conole <aconole@redhat.com>, Eelco Chaudron <echaudro@redhat.com>,
 Ilya Maximets <i.maximets@ovn.org>, Allison Henderson <achender@kernel.org>,
 Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
 Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
 Xin Long <lucien.xin@gmail.com>, "D. Wythe" <alibuda@linux.alibaba.com>,
 Dust Li <dust.li@linux.alibaba.com>,
 Sidraya Jayagond <sidraya@linux.ibm.com>,
 Mahanta Jambigi <mjambigi@linux.ibm.com>, Tony Lu <tonylu@linux.alibaba.com>,
 Wen Gu <guwen@linux.alibaba.com>, Jon Maloy <jmaloy@redhat.com>,
 Tung Quang Nguyen <tung.quang.nguyen@est.tech>,
 Steffen Klassert <steffen.klassert@secunet.com>,
 Herbert Xu <herbert@gondor.apana.org.au>,
 Casey Schaufler <casey@schaufler-ca.com>, Paul Moore <paul@paul-moore.com>,
 James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>,
 Vikas Gupta <vikas.gupta@broadcom.com>,
 Bhargava Marreddy <bhargava.marreddy@broadcom.com>,
 Rajashekar Hudumula <rajashekar.hudumula@broadcom.com>,
 Nicolai Buchwitz <nb@tipi-net.de>,
 Markus =?UTF-8?B?QmzDtmNobA==?= <markus@blochl.de>,
 Arnd Bergmann <arnd@arndb.de>, Heiner Kallweit <hkallweit1@gmail.com>,
 Florian Fainelli <florian.fainelli@broadcom.com>,
 Krzysztof Kozlowski <krzk@kernel.org>,
 Qingfang Deng <qingfang.deng@linux.dev>,
 Julian Braha <julianbraha@gmail.com>,
 Ethan Nelson-Moore <enelsonmoore@gmail.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ardb@kernel.org>,
 Neal Cardwell <ncardwell@google.com>, Kuniyuki Iwashima <kuniyu@google.com>,
 Willem de Bruijn <willemb@google.com>, Alyssa Ross <hi@alyssa.is>,
 Joel Granados <joel.granados@kernel.org>, Oleg Nesterov <oleg@redhat.com>,
 linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
 intel-wired-lan@lists.osuosl.org, oss-drivers@corigine.com,
 linux-net-drivers@amd.com, linux-stm32@st-md-mailman.stormreply.com,
 linux-arm-kernel@lists.infradead.org, linux-wireless@vger.kernel.org,
 brcm80211@lists.linux.dev, brcm80211-dev-list.pdl@broadcom.com,
 linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org,
 target-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
 b.a.t.m.a.n@lists.open-mesh.org, bridge@lists.linux.dev,
 netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
 mptcp@lists.linux.dev, lvs-devel@vger.kernel.org, dev@openvswitch.org,
 rds-devel@oss.oracle.com, linux-sctp@vger.kernel.org,
 linux-s390@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
 linux-security-module@vger.kernel.org
Subject:
 Re: [PATCH 01/13 net-next] net: ipv4: introduce CONFIG_IPV4 to decouple the
 IPv4 stack
Date: Thu, 10 Sep 2026 18:56:26 +0200
Message-ID: <2927239.BEx9A2HvPv@ripper>
In-Reply-To: <20260910144914.8025-2-fmancera@suse.de>
References:
 <20260910144914.8025-1-fmancera@suse.de>
 <20260910144914.8025-2-fmancera@suse.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart15836323.tv2OnDr8pf";
 micalg="pgp-sha512"; protocol="application/pgp-signature"

--nextPart15836323.tv2OnDr8pf
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"; protected-headers="v1"
From: Sven Eckelmann <sven@narfation.org>
Date: Thu, 10 Sep 2026 18:56:26 +0200
Message-ID: <2927239.BEx9A2HvPv@ripper>
In-Reply-To: <20260910144914.8025-2-fmancera@suse.de>
MIME-Version: 1.0

On Thursday, 10 September 2026 16:48:26 CEST Fernando Fernandez Mancera wrote:
> diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
> index 58c408b7a7d9..60ad4b09be6e 100644
> --- a/net/batman-adv/Kconfig
> +++ b/net/batman-adv/Kconfig
> @@ -9,6 +9,7 @@
>  
>  config BATMAN_ADV
>         tristate "B.A.T.M.A.N. Advanced Meshing Protocol"
> +       depends on IPV4
>         select CRC32
>         help
>           B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is

This doesn't make a lot of sense to me IPV4 is not a requirement for 
batman-adv. Only very specific features will require symbols from IPv4:

* CONFIG_BATMAN_ADV_BLA

  - arp_create

* CONFIG_BATMAN_ADV_DAT

  - arp_create

* CONFIG_BATMAN_ADV_MCAST

  - ip_mc_check_igmp


Basically things which currently depend on INET in net/batman-adv/Kconfig

Or am I missing something here?

Regards,
	Sven
--nextPart15836323.tv2OnDr8pf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQS81G/PswftH/OW8cVND3cr0xT1ywUCaqLhOgAKCRBND3cr0xT1
y0QVAQCluQcX0gr2MIQxC1VBX8WP3ecVDFqIOBKX04RTLEdoGQD+LCZ3LWDtGBbG
zKG3h3F96XOApdHINtJ4L0x6nSSviww=
=kxMI
-----END PGP SIGNATURE-----

--nextPart15836323.tv2OnDr8pf--



