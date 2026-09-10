Received: from fout-b5-smtp.messagingengine.com (fout-b5-smtp.messagingengine.com [202.12.124.148])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20C0D38A73B;
	Thu, 10 Sep 2026 15:37:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.148
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789054652; cv=none; b=NR+lglqAzqKMjnNF6fqxmKWEMCNwj6QJcUpunJ8UEOnK5ZFZSoK5O0mFie8TsDYsMzETp1M7k6vhqaOa9ipa62H6PiKDGnBJHaru8Y5YGiB2UymmAFnaP0nDa8ukMlIs6ON49iqcQr1dqjvN0GHdYUH3JSCMRtXc1ZN8phStC5k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789054652; c=relaxed/simple;
	bh=tzfrxLbW18XBupQQO4Z4sOHkODX/2tTbZQV7+HM+Wto=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=o9gmHhbgfS7YaE4d0/rGWIVWtnCsIpAuTCOi80iM60upLPJl+eLqSYqlWQu3fdF8kQUFKHiVs/0jLYiyddPJ2vWPiAB20pr57UevVvmPxNozPvHqsuUrfa9zl2pLe0VSbdM99a7FcMbN87ERQ1qtZcucDjs/yl5xO9Djaiz2tUI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arndb.de; spf=pass smtp.mailfrom=arndb.de; dkim=pass (2048-bit key) header.d=arndb.de header.i=@arndb.de header.b=ikywC8+h; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=R8SmDbAP; arc=none smtp.client-ip=202.12.124.148
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arndb.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arndb.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=arndb.de header.i=@arndb.de header.b="ikywC8+h";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="R8SmDbAP"
Received: from ams-compute-02.internal (ams-compute-02.internal [10.64.2.62])
	by mailfout.stl.internal (Postfix) with ESMTP id 92D541D00107;
	Thu, 10 Sep 2026 11:37:25 -0400 (EDT)
Received: from ams-imap-03 ([10.64.2.23])
  by ams-compute-02.internal (MEProxy); Thu, 10 Sep 2026 11:37:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arndb.de; h=cc
	:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to; s=fm3; t=1789054644;
	 x=1789141044; bh=VJHi3AALrojUsaiH2K9JRyFh6yN6vM9XW4bo5EfCLvk=; b=
	ikywC8+hP0FbgWYJ7JpppZwhmFT+TaVIwwfxZl3vKzlLdmM0Nux3yd+Im/GnBBxf
	IsZhMPrU2CfaPOS3llPqcCh1/W6YupvRhqHnEPijgkiGE9FTjWByE5rH7xSz2+YS
	+dblIgCXim5mQ79MRnnVj+HTE2oO78sbNkVr8Q34RjdHugoTrgiFbcREeHekftYd
	aasBFCSTYq2bdjS9VoWdHFfCLjJ+zkroUH2SWQzQIfie7Rv6jWKaRIke0inoGzby
	3B6POzhhAouDRYljXpkPjgMNSje743iQ78SiKVtE7Ge4+Dx7VPOmk/C6xBZz2BmT
	VpnxDlhl6rU/FOoxhy83wA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789054644; x=
	1789141044; bh=VJHi3AALrojUsaiH2K9JRyFh6yN6vM9XW4bo5EfCLvk=; b=R
	8SmDbAPjSEISBwANGL6NRU+VAUlWXrSQUFPgdkRsPNjMk/TQ6vTirkIvq0MISnMb
	JKylqUisx/ovnCt8n5NY8n38p8Z0r7qneBX+3zXxCDi2CJwC02WhAFRI2seVrGL3
	Dht2ceJo7GLlQMaxoAoPjc+jE/IjH4l6GZIuGYTnjn702MzCG2sJXfo7DJD6Mu+D
	GdeuLOmK0EtS1BFwVrocZNEiHVquy2r7T6MQ/O53GTtfpHRB1FMWSHdFtJfVd492
	huhQSYBkjqtlp54u32TtmpwCcuYi2jrpIaJFlHxn0OmcDjswJ7KPJQwv8vayUgpM
	tlajKtuLqV1QATBx5g5yg==
X-ME-Sender: <xms:qs6iaoxcZdBS5-tZ6559r51Ysxn8ibK0iu94a23oAy3L7zkGsUDSIA>
    <xme:qs6ianED7WC-Q5vvqjBq8s_u2Wqo8da3kDi_H8X5KWUsVSaHxUeQXmRrU2dFDuKW5
    iSmQx6sT9tJCQ5Fwo1WTe4NJLY27B0TnB0PK74fvos-BO3OvrbH46Csjw>
X-ME-Proxy-Cause: dmFkZTGzGT8QWaj5+IaF+j+BCEPEbeETmKmrh3i3QL1egfRXUvJOsOFxmKhTHJ5EJ0IvJ/
    yrlbR57KqxmsqFYmHcxuNy7TxmyGimBY78fjpHyUy7vT/Q0OO0SF55UVJhaG/0alhtMMXP
    gjrK4qv4Oymi20VFNGCTKHWPZM5dFQKAOC2iaHsd5PeiJ4bs06wqZiiNHoe9XtdI3wlCFz
    dEvEW43MKZZojMIQ8Q2c5X4bpnwolr0T0c9O2qf0ntNk3rSE8d6qS+QV3WNpllSo8oIEPE
    0cc52GAipoXJvmvdUNZM110yBhTc2CiUmuHzJTc3cgyXm93V2vumdIDzmA8tmt3nNU7Ug9
    6+EvyqPEl/qJxhZSe/GxKdDq3P6XS8ocwRwYw1486eMhQ8woArvfJmN4iQRnrsRc0L86xi
    FUFH72TMYxAZF+4RLrewGwWAm7BC/aWgYoMWJVSKwJbmsjXvsdGICOjD+m5FtnEZ/5B3FP
    ahodQdjEW2UaaKlW69gdjKCiX5d3NjOm/upXNL0N5y/EL6C6fZpWiYQwvfBSI0XAN/+wiA
    Cg1M8xRvHSmGMT5y0DNGWni2mwje4hoY8BKcu/+UhH04cABAYvBHYbSRHFVgnSoVo66ZEv
    OhpSnSjBxC5zHMZ3qKuAHlvC9yX9G19i9o4NyzQqHNi8cGyFHrxA19niVE+A
X-ME-Proxy: <xmx:r86iavuQaXSkajUGbGTxZOGm2llWg7fiaco8bOamAUQDeRL2Pd6HAQ>
    <xmx:r86iavvdlBlZMz41c6a0PxU_zWsdsuHayQoajn_EtgnSKkrZC7QCwA>
    <xmx:r86iau-ali-YMTcHW9nYfAeB8WFBwz4N3Kf6nVVNyNffsE_5Xex2YA>
    <xmx:r86iao_ql0S4UwfTN7PSvF8rKrygtY-dHqzr4ZJBcaIKblcgxjNTZw>
    <xmx:tM6iaqEzjEAmXefpeuCydSJA9LXJ7HlJinKnl2fmwVfK7B-jCn25-y5y>
Feedback-ID: i56a14606:Fastmail
Received: by mailuser.ams.internal (Postfix, from userid 501)
	id A91DC32A007B; Thu, 10 Sep 2026 11:37:14 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Ay04W235egbV
Date: Thu, 10 Sep 2026 17:36:54 +0200
From: "Arnd Bergmann" <arnd@arndb.de>
To: "Nicolai Buchwitz" <nb@tipi-net.de>,
 "Fernando Fernandez Mancera" <fmancera@suse.de>
Cc: Netdev <netdev@vger.kernel.org>, "Simon Horman" <horms@kernel.org>,
 "Jakub Kicinski" <kuba@kernel.org>, "Paolo Abeni" <pabeni@redhat.com>,
 "Eric Dumazet" <edumazet@google.com>,
 "David S . Miller" <davem@davemloft.net>,
 "Jason Gunthorpe" <jgg@ziepe.ca>, "Leon Romanovsky" <leon@kernel.org>,
 "Andrew Lunn" <andrew+netdev@lunn.ch>,
 "Anthony L Nguyen" <anthony.l.nguyen@intel.com>,
 "Przemek Kitszel" <przemyslaw.kitszel@intel.com>,
 "Elad Nachman" <enachman@marvell.com>,
 "Saeed Mahameed" <saeedm@nvidia.com>, "Tariq Toukan" <tariqt@nvidia.com>,
 "Mark Bloch" <mbloch@nvidia.com>, "Ido Schimmel" <idosch@nvidia.com>,
 "Petr Machata" <petrm@nvidia.com>,
 "Edward Cree" <ecree.xilinx@gmail.com>,
 "Maxime Chevallier" <maxime.chevallier@bootlin.com>,
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
 "Martin K. Petersen" <mkp@kernel.org>,
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
 "Mahanta Jambigi" <mjambigi@linux.ibm.com>,
 "Tony Lu" <tonylu@linux.alibaba.com>, "Wen Gu" <guwen@linux.alibaba.com>,
 "Jon Maloy" <jmaloy@redhat.com>,
 "Tung Quang Nguyen" <tung.quang.nguyen@est.tech>,
 "Steffen Klassert" <steffen.klassert@secunet.com>,
 "Herbert Xu" <herbert@gondor.apana.org.au>,
 "Casey Schaufler" <casey@schaufler-ca.com>,
 "Paul Moore" <paul@paul-moore.com>, "James Morris" <jmorris@namei.org>,
 "Serge E. Hallyn" <serge@hallyn.com>,
 "Vikas Gupta" <vikas.gupta@broadcom.com>,
 "Bhargava Marreddy" <bhargava.marreddy@broadcom.com>,
 "Rajashekar Hudumula" <rajashekar.hudumula@broadcom.com>,
 =?UTF-8?Q?Markus_Bl=C3=B6chl?= <markus@blochl.de>,
 "Heiner Kallweit" <hkallweit1@gmail.com>,
 "Florian Fainelli" <florian.fainelli@broadcom.com>,
 "Krzysztof Kozlowski" <krzk@kernel.org>,
 "Qingfang Deng" <qingfang.deng@linux.dev>,
 "Julian Braha" <julianbraha@gmail.com>,
 "Ethan Nelson-Moore" <enelsonmoore@gmail.com>,
 "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
 "Eric Biggers" <ebiggers@kernel.org>, "Ard Biesheuvel" <ardb@kernel.org>,
 "Neal Cardwell" <ncardwell@google.com>,
 "Kuniyuki Iwashima" <kuniyu@google.com>,
 "Willem de Bruijn" <willemb@google.com>, "Alyssa Ross" <hi@alyssa.is>,
 "Joel Granados" <joel.granados@kernel.org>,
 "Oleg Nesterov" <oleg@redhat.com>, linux-rdma@vger.kernel.org,
 linux-kernel@vger.kernel.org,
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
 "open list:TIPC NETWORK LAYER" <tipc-discussion@lists.sourceforge.net>,
 linux-security-module@vger.kernel.org
Message-Id: <cda5d4e9-49a5-4d6f-93d4-fb50d74ed5ce@app.fastmail.com>
In-Reply-To: <aeb37452e976f5d44540ac3a0999d07b@tipi-net.de>
References: <20260910144914.8025-1-fmancera@suse.de>
 <20260910144914.8025-2-fmancera@suse.de>
 <aeb37452e976f5d44540ac3a0999d07b@tipi-net.de>
Subject: Re: [PATCH 01/13 net-next] net: ipv4: introduce CONFIG_IPV4 to decouple the
 IPv4 stack
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, Sep 10, 2026, at 17:11, Nicolai Buchwitz wrote:
>> diff --git a/net/packet/Kconfig b/net/packet/Kconfig
>> index 2997382d597c..00fda9e08cb0 100644
>> --- a/net/packet/Kconfig
>> +++ b/net/packet/Kconfig
>> @@ -5,6 +5,7 @@
>> 
>>  config PACKET
>>  	tristate "Packet socket"
>> +	depends on IPV4
>
>    depends on IPV4 || !INET
>
> Otherwise this would break existing configs with INET=n. The same 
> applies to other affected options that currently permit INET=n.

Since that's a lot of symbols that all need the same dependency,
maybe we could have an intermediate symbol for it:

config IPV4_IF_INET # or any better name you can think of
      def_bool IPV4 || !INET

Similarly, everything that currently has 'depends on INET && IPV4'
could be simplified to just 'depends on IPV4', and the leftover
'depends on INET && IPV6' from the days of modular IPV6 can now
become 'depends on IPV4'. We only needed to list both in the past
to deal with the IPV6=m case.

       Arnd
