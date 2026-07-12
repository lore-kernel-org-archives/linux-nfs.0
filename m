Received: from fhigh-a6-smtp.messagingengine.com (fhigh-a6-smtp.messagingengine.com [103.168.172.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 955E7149DF1;
	Sun, 12 Jul 2026 11:02:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783854159; cv=none; b=qfR97Md3x03z4XsjxwSfQOSlgkA4VB4cyZjZv3RaebcL1h61Vtp820wjBGfsXSqogsmBgLoqBF3br6ni9Mf82WBzmNAANviLGhpU9VO2LVmFe6GwF5U4k5otZFglnf6gheTc1IrJ2UpQVcise745g5FKBwz8BVxWQaXg2k1QFnc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783854159; c=relaxed/simple;
	bh=QFAERGkwm7FFeWB0LrovUamDAkSprs7aihtdoZvXuKE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=NKoWjzE/U9Cg81q8x/q+xGMA4Dju/BDKtzUlmXLX0P+/vgeMv2dgD7brrPKZqRPslrVfKKuG/wygnWi2EbpqE7SpjguHA8X987epUkETbAPw3BX/AP4rrrvLI7lz9cujWCucBJ4cd0qgsBWNkvrEucHW0ECWq80VWQu4vKXYC3I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arndb.de; spf=pass smtp.mailfrom=arndb.de; dkim=pass (2048-bit key) header.d=arndb.de header.i=@arndb.de header.b=zpHRfiC5; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=l6PtvRhd; arc=none smtp.client-ip=103.168.172.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arndb.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arndb.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=arndb.de header.i=@arndb.de header.b="zpHRfiC5";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="l6PtvRhd"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.phl.internal (Postfix) with ESMTP id B209314000F9;
	Sun, 12 Jul 2026 07:02:36 -0400 (EDT)
Received: from phl-imap-05 ([10.202.2.95])
  by phl-compute-04.internal (MEProxy); Sun, 12 Jul 2026 07:02:36 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arndb.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm1; t=1783854156;
	 x=1783940556; bh=VmtnK3tqoDU1aIaol+aWaActTb6DTRuQA5S8IlUXC6U=; b=
	zpHRfiC5EPwl520ahCHYKKw5slNvnULR9f0KFrRT9y/2496pQCwk5KRBRbFgaYwK
	qG5F+qyc+u6zQHl69ceJPRiSScFtXeE7ZyRSVgJSuprmdrpegDBkSA7FMJ5iWHIW
	SWlwkvdzIryhehvQjfxl6CaW2ssS7P7s2gf6gPSaRBitFcji6E7w6O+D9MGOTq8e
	KhN1cpA/Tqcli21P3rrlWr0Xxua3FpQ5R7OFYe9FPdjPs6R+VvBCiyDkT0HtPl2f
	qii8ZEdh5SWDrMrxQFPHLV29au4QVk00LL5Ct/0KCqib5HX/6aJG4Up8UlRvgkJY
	nRorXxeir3laErJG81MisA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1783854156; x=
	1783940556; bh=VmtnK3tqoDU1aIaol+aWaActTb6DTRuQA5S8IlUXC6U=; b=l
	6PtvRhdAV0qi2d8e9JUkK2fFLlwxNVY88bcJ+5Aj5gdngpmAYCMSgprFJ8wo710r
	L3GX7fLDfky6/oZ5HVFMbvr3LfslQE3A4w7QmId8Pn6hgVlensKX8wbHDxXJXMEw
	ljaGdMaWuSttqpLIh1kRGvTz2JKn9ccjs3FegrO0y+RbRlkAzKbQ2dqj069GeO+7
	KiNB7ReoNHH0ZUF3RSAIMtQSTjbO3t+zGQmSf4gQWGO8/uy+Wvbs6Xl2gDkoDMV7
	CmCc8Ljjg46b8emiC9vxMTJkV1Aw2OeUhRq5fNYVA+WvlRG7ZcpAMzEUPYx0xvod
	o+8ewgiMwgBexztrVjN5Q==
X-ME-Sender: <xms:SXRTar8WT3jXuGcKhip6v_oZ_ev_MYJ3TiCDPsHDGOy_4qyk61nOpA>
    <xme:SXRTaigdv70_fhLJe4evVFXvY38h-PROEIkCw6nfAYtcRrN4q0volhQFULkdIqZ6L
    z8_glaP7Vjxtth72FHcVVja1cD22b3GdPb5JUl06P7cs54F9UBgiclm>
X-ME-Proxy-Cause: dmFkZTGLo78njPg/nVe+uHWg3AzWojEtguj4DH8KNv19gE9YnhOLAIWMCTf4qhQuAaKC9P
    oqyQsM8pSAEKHb797BqDSo1aNsM3rLblcv7PG7RotKu6L/VmYg2dW8zs2GiGwBQBqITK1u
    X7zWoJgFJCv+6+BhbAHafVgja8Z3pTN2uEr2UPDO/nE22eQsOCXiJJSQPkNMNg99Cf35b5
    J+tdL50vwyZ/VB0b7S4W+UsY7ZTc+cfBHJYz0U/kX691quZfggwKD0RgbG/U6czrjHfrvF
    6fq/4yXwXeSj8YJFVVakjVNKSPD+23ViVy8tbJNIxUaNcajIR7AH0T/de5rCVSDzK344tx
    U0x24Up+ufBa9p+NAvwC4cO2T9HS+kz0KnK//dY/mOxOe/QpD8tgteUxcBF++TLDigfVC1
    C3EJFOtWxRFUioYMCn8qg0rQx+yCJX0thmaTY7UEVDucc/9mhpzue03w8Dp+CxjgmXdcGu
    RSCzsnIT3+hEirvAmIyFtq70pAE1IonG2VSteXv8IfwRKlnb463XanbbZobuFZ9GMPY1GC
    8nsnv82zjPtzkRalpSto4MmL5kHeehrV6iIR1EmzKUc5FkQFY5TKbxBu61Nz8jJ7suNzU3
    Cyvv5MNgqU18rt3jpb2tgZMGlm2/SgzvbBaj3jXxb82AJ7qi2ot7EKTwTDoQ
X-ME-Proxy: <xmx:SXRTapHAhWRiFbB-4amYjFgmwydjtOdojLMQlh0VZZlQEErKhomHig>
    <xmx:SXRTaoKLDK9Ecbgry1ger4QfqGLLQ1xOkTzua4qZzvVI-kaPbzgKWw>
    <xmx:SXRTap8dLyvqloUGHlP29AnEVqPiM2OIYq0126wYr_cBo0x_TFVHVA>
    <xmx:SXRTaqegpYaBne9K3glgOErxceihkfr_b7_lWpHaESTvei9pJ8qgGA>
    <xmx:THRTagApbQu8pd3LegvnC51UZb7KkVStZc2jhlRfHD_OxzYfyYsDaYFF>
Feedback-ID: i56a14606:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 29B00182007E; Sun, 12 Jul 2026 07:02:33 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ARmmoW1aQeCk
Date: Sun, 12 Jul 2026 13:01:52 +0200
From: "Arnd Bergmann" <arnd@arndb.de>
To: "Fernando Fernandez Mancera" <fmancera@suse.de>,
 Netdev <netdev@vger.kernel.org>
Cc: "David S . Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "David Ahern" <dsahern@kernel.org>,
 "Simon Horman" <horms@kernel.org>, "Ido Schimmel" <idosch@nvidia.com>,
 "Jason Gunthorpe" <jgg@ziepe.ca>, "Leon Romanovsky" <leon@kernel.org>,
 "Andrew Lunn" <andrew+netdev@lunn.ch>,
 "Anthony L Nguyen" <anthony.l.nguyen@intel.com>,
 "Przemek Kitszel" <przemyslaw.kitszel@intel.com>,
 "Elad Nachman" <enachman@marvell.com>,
 "Saeed Mahameed" <saeedm@nvidia.com>, "Tariq Toukan" <tariqt@nvidia.com>,
 "Mark Bloch" <mbloch@nvidia.com>, "Petr Machata" <petrm@nvidia.com>,
 "Edward Cree" <ecree.xilinx@gmail.com>,
 "Maxime Coquelin" <mcoquelin.stm32@gmail.com>,
 "Alexandre Torgue" <alexandre.torgue@foss.st.com>,
 "Arend van Spriel" <arend.vanspriel@broadcom.com>,
 "Miri Korenblit" <miriam.rachel.korenblit@intel.com>,
 "Keith Busch" <kbusch@kernel.org>, "Jens Axboe" <axboe@kernel.dk>,
 "Christoph Hellwig" <hch@lst.de>, "Sagi Grimberg" <sagi@grimberg.me>,
 "Chaitanya Kulkarni" <kch@nvidia.com>,
 "Saurav Kashyap" <skashyap@marvell.com>,
 "Javed Hasan" <jhasan@marvell.com>,
 GR-QLogic-Storage-Upstream@marvell.com,
 "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>,
 "Martin K. Petersen" <martin.petersen@oracle.com>,
 "Nilesh Javali" <njavali@marvell.com>,
 "Manish Rangankar" <mrangankar@marvell.com>,
 "Varun Prakash" <varun@chelsio.com>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jan Kara" <jack@suse.cz>,
 "David Howells" <dhowells@redhat.com>,
 "Marc Dionne" <marc.dionne@auristor.com>,
 "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Marek Lindner" <marek.lindner@mailbox.org>,
 "Simon Wunderlich" <sw@simonwunderlich.de>,
 "Antonio Quartulli" <antonio@mandelbit.com>,
 "Sven Eckelmann" <sven@narfation.org>,
 "Nikolay Aleksandrov" <razor@blackwall.org>,
 "Pablo Neira Ayuso" <pablo@netfilter.org>,
 "Florian Westphal" <fw@strlen.de>, "Phil Sutter" <phil@nwl.cc>,
 "Johannes Berg" <johannes@sipsolutions.net>,
 "Matthieu Baerts" <matttbe@kernel.org>,
 "Mat Martineau" <martineau@kernel.org>,
 "Geliang Tang" <geliang@kernel.org>, "Julian Anastasov" <ja@ssi.bg>,
 "Aaron Conole" <aconole@redhat.com>,
 "Eelco Chaudron" <echaudro@redhat.com>,
 "Ilya Maximets" <i.maximets@ovn.org>,
 "Allison Henderson" <achender@kernel.org>,
 "Jamal Hadi Salim" <jhs@mojatatu.com>, "Jiri Pirko" <jiri@resnulli.us>,
 "Marcelo Ricardo Leitner" <marcelo.leitner@gmail.com>,
 "Xin Long" <lucien.xin@gmail.com>,
 "D. Wythe" <alibuda@linux.alibaba.com>,
 "Dust Li" <dust.li@linux.alibaba.com>,
 "Sidraya Jayagond" <sidraya@linux.ibm.com>,
 "Wenjia Zhang" <wenjia@linux.ibm.com>,
 "Mahanta Jambigi" <mjambigi@linux.ibm.com>,
 "Tony Lu" <tonylu@linux.alibaba.com>, "Wen Gu" <guwen@linux.alibaba.com>,
 "Jon Maloy" <jmaloy@redhat.com>,
 "Steffen Klassert" <steffen.klassert@secunet.com>,
 "Herbert Xu" <herbert@gondor.apana.org.au>,
 "Vikas Gupta" <vikas.gupta@broadcom.com>,
 "Rajashekar Hudumula" <rajashekar.hudumula@broadcom.com>,
 "Justin Chen" <justin.chen@broadcom.com>,
 "Bhargava Marreddy" <bhargava.marreddy@broadcom.com>,
 "Nicolai Buchwitz" <nb@tipi-net.de>,
 "Florian Fainelli" <florian.fainelli@broadcom.com>,
 "Heiner Kallweit" <hkallweit1@gmail.com>,
 "Krzysztof Kozlowski" <krzk@kernel.org>,
 "Russell King" <rmk+kernel@armlinux.org.uk>, "Yao Zi" <me@ziyao.cc>,
 "Yanteng Si" <siyanteng@cqsoftware.com.cn>,
 "Maxime Chevallier" <maxime.chevallier@bootlin.com>,
 "Julian Braha" <julianbraha@gmail.com>,
 "Joey Lu" <a0987203069@gmail.com>,
 "Shangjuan Wei" <weishangjuan@eswincomputing.com>,
 "Chen-Yu Tsai" <wens@kernel.org>, "Inochi Amaoto" <inochiama@gmail.com>,
 "Lad, Prabhakar" <prabhakar.mahadev-lad.rj@bp.renesas.com>,
 "Qingfang Deng" <qingfang.deng@linux.dev>,
 "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
 "Eric Biggers" <ebiggers@kernel.org>,
 "Ethan Nelson-Moore" <enelsonmoore@gmail.com>,
 "Ard Biesheuvel" <ardb@kernel.org>,
 "Dmitry Safonov" <0x7f454c46@gmail.com>,
 "Kuniyuki Iwashima" <kuniyu@google.com>, "Alyssa Ross" <hi@alyssa.is>,
 linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
 "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
 "open list:NETRONOME ETHERNET DRIVERS" <oss-drivers@corigine.com>,
 linux-net-drivers@amd.com, linux-stm32@st-md-mailman.stormreply.com,
 linux-arm-kernel@lists.infradead.org, linux-wireless@vger.kernel.org,
 brcm80211@lists.linux.dev, brcm80211-dev-list.pdl@broadcom.com,
 linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org,
 target-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
 b.a.t.m.a.n@lists.open-mesh.org,
 "open list:ETHERNET BRIDGE" <bridge@lists.linux.dev>,
 netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
 mptcp@lists.linux.dev, lvs-devel@vger.kernel.org, dev@openvswitch.org,
 rds-devel@oss.oracle.com, linux-sctp@vger.kernel.org,
 linux-s390@vger.kernel.org,
 "open list:TIPC NETWORK LAYER" <tipc-discussion@lists.sourceforge.net>
Message-Id: <12ffac6a-649a-4e4a-8d12-0b48171e1d95@app.fastmail.com>
In-Reply-To: <20260712013941.4570-2-fmancera@suse.de>
References: <20260712013941.4570-1-fmancera@suse.de>
 <20260712013941.4570-2-fmancera@suse.de>
Subject: Re: [PATCH 01/13 RFC net-next] net: ipv4: introduce CONFIG_IPV4 to decouple
 the IPv4 stack
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, Jul 12, 2026, at 03:38, Fernando Fernandez Mancera wrote:
> Historically, the IPv4 protocol has been linked to the core INET
> subsystem. Because shared infrastructure like the TCP/UDP engine,
> routing or INET hashtables live inside net/ipv4/, it has been impossible
> to compile a kernel with only IPv6 support.
>
> This patch introduces the CONFIG_IPV4 Kconfig symbol, which is set to
> 'def_bool y' for now. This does not allow to completely disable the
> IPv4 stack yet but it lays the necessary build-system work for that
> goal.

I expect this will cause additional (trivial) build regression in the
next step when randconfig builds run into obscure corner cases, either
with INET=y IPV4=n IPV6=y or with INET=y IPV4=n IPV6=n.

I can probably give your patch (with IPV4 visible or disabled) an
early go on the randconfig tree to find these more quickly.
If I run into regressions, should I just add more 'depends on IPV4',
or do you have other plans?

Should we have some logic to ensure that at least one of IPV4 or
IPV6 is enabled? I think this would work

config IPV4
      bool "The IPv4 protocol" if IPV6
      default INET

which only allows turning IPV4 off if IPV6 has enabled.

       Arnd
