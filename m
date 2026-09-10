Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 407A258E2C6;
	Thu, 10 Sep 2026 18:55:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789066546; cv=none; b=qI04ZCD/mffz8cpWqepYGMFV8Mp+SckjY1mMcAa6rsDe9kbC0stcfx2zD+J7+I3u1JbuCYOfprkKBtOdQXCzDaRdWO8wC3s07a4U34v1gZM4aPdg96uWmghvXCkFNLpDqk3ix6QSKvlbeFommd9l3PlW59y1YVogEyWBeklnOxg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789066546; c=relaxed/simple;
	bh=jA1OIjMBwv91UuOt5Tn56hy+6IGDF/xyXBVDc+O0W7c=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=A+ac7OsFdCSk2ZgjggUEYNyk4qABfHooj+hlO9MbViUc0WCRtXI5eLFkxpk7W9dQ5JYKjN2SCapwFEuOSIMOYCeUAUznU6rWrRcXDK+Uv8sJjOm3BmsrZD6qMF1fS9r9KQgw8cQJYtc7xANVQGzoX0yYNcmROoSIKr0IrqWz3ac=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=F6i3O5AT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="F6i3O5AT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C4DDF1F008A1;
	Thu, 10 Sep 2026 18:55:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789066544;
	bh=CrpBp6UrC3ldEa5GcKmmPo3oz74G2RAnpQBvJ2o9k1k=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=F6i3O5AT5R2f9Yx+JsX4oi2MbBVZy6vhmuah8fyZ7HoRM4fcwu9ko/hMOipVkG55B
	 1Zmg31PLcmFyjN/6qwvx+Gi14CUmpNgqwIW3GIcgTV8r/HdYjj80cmHBvTlnPKg5uR
	 OFZIpZsE3LqRG10E9rSuJaexxU9wT5CasLzhcaoOUlc1HtwpM6VduzyZ+RCbNEeTCG
	 7mnywN+8+H6LvsHwXafWrsaQmZDzIueYYyazPefKJGcMkw5e44QHRXV4epY9oIt8b/
	 VxUYOa++vQ7n7D+qHzq2qnf380yDhptkzXHvt9CgqRKD1Qe5yMUYoD9jvQW061SukA
	 KzIemnQ3+sQfA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id C451EF40069;
	Thu, 10 Sep 2026 14:55:42 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 10 Sep 2026 14:55:42 -0400
X-ME-Sender: <xms:Lv2iajO020W1DUB7kxvyyEY7DfRl-e2BIJTX073yLiFUhMClSPWBiA>
    <xme:Lv2iaoxfBFeDEd_VmLtT0qd94HDtXRhhpDvUfHkJM_m66XDNqrBNS-B2koOqMN4lP
    Sa0Ug9f_2FH0Kq2r3-yqf79TNecZT6-Lakr_OXpOKrFWd9sWBuPoBo>
X-ME-Proxy-Cause: dmFkZTF4DbH3FZ3dPjetu62giaNH+KK3h7Vnr+fEg85PysIt/4nck/4imrawKEp8DsE6Pr
    r0whIQLHunubPaHCLLANlXfZ8RvcApjV2EH4HvJnIa7IIlTjW/aieFsEYioNdVnIC1pGZ7
    r7+Be7rv47aINSOQmPbhGzYvhtHf8def9lEg4PtjWAs9LAnZxAA8HHEDG0Nu5Q4D+ErnGo
    wbL3v3GuUBm9m4647OHl9jiHICZ+8M7+WaOVrci5hxhVfG9CY47ExztZrbckd1/ZxcD0FZ
    vwDE7nYg/E3N/QLZgdrUVACuceWMJkJ6Wb+Z2hJc7h8HgoI8f/4b+gnUnlKGDgCx/5CDPJ
    po6DIC9Q8yofj6Gyo3f7FKL5mt0EHv82L6g17/YO3gWxVRbIFJetz+YWg8fgbv7WuFfefm
    hnLsmWUjBQVBzx6B9SMuUsPATs4OJtGO1f+mnt0J/1peJ5Nq63D3J9EC8B1PaX5BKnWN5n
    NTUc5qHazXKrxzCndz85zJiyINbeiTNLTCeRjTR7RMcNSUFcXqheUFmGnh70f88dysYIhz
    x/wWpwuzN1bBTEbUGCyOiSyCxaCxeioaasg+88aeLfS3v1QhYfc5bHYGwrmHrU/cjZ20YX
    SgmgetWptaxFGpGrTy/DDcJdYBDIVEtFh7oH120w4eOuhoZaxlVn3LGzD7xQ
X-ME-Proxy: <xmx:Lv2iagKDhe4ENuyDEBPe0XuX5JV95iH3pOzVxXrfT1HwGt5hmy731g>
    <xmx:Lv2iavY0YWPFwc5heNSQaejsEbm3T9Hzm9qfGqn3H3Ql0pmX2TgP2A>
    <xmx:Lv2ias4lIQtLaB1oGx0UNzfhFXq0OCShC-yE9ybCKPEj_MhGksso3A>
    <xmx:Lv2iaoJl7Z6wMLyQsn5RJgRWdIhUrImOwvxM7EqgPgmRZWBE2AuVGw>
    <xmx:Lv2iaqawY0GSonv8zq4bA_iHkDoRcvBDh1ekvmmQAljAmwqWH4krgir7>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8F75E7811F0; Thu, 10 Sep 2026 14:55:42 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AHIlAaKAQArc
Date: Thu, 10 Sep 2026 14:55:20 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Fernando Fernandez Mancera" <fmancera@suse.de>, netdev@vger.kernel.org
Cc: "Simon Horman" <horms@kernel.org>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, edumazet@google.com,
 davem@davemloft.net, "Jason Gunthorpe" <jgg@ziepe.ca>,
 "Leon Romanovsky" <leon@kernel.org>,
 "Andrew Lunn" <andrew+netdev@lunn.ch>,
 "Tony Nguyen" <anthony.l.nguyen@intel.com>,
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
 "James Bottomley" <James.Bottomley@hansenpartnership.com>,
 "Martin K. Petersen" <mkp@kernel.org>,
 "Nilesh Javali" <njavali@marvell.com>,
 "Manish Rangankar" <mrangankar@marvell.com>,
 "Varun Prakash" <varun@chelsio.com>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jan Kara" <jack@suse.cz>,
 "David Howells" <dhowells@redhat.com>,
 "Marc Dionne" <marc.dionne@auristor.com>,
 "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
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
 "Nicolai Buchwitz" <nb@tipi-net.de>,
 =?UTF-8?Q?Markus_Bl=C3=B6chl?= <markus@blochl.de>,
 "Arnd Bergmann" <arnd@arndb.de>,
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
 linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
 oss-drivers@corigine.com, linux-net-drivers@amd.com,
 linux-stm32@st-md-mailman.stormreply.com,
 linux-arm-kernel@lists.infradead.org, linux-wireless@vger.kernel.org,
 brcm80211@lists.linux.dev, brcm80211-dev-list.pdl@broadcom.com,
 linux-nvme@lists.infradead.org,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 target-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
 b.a.t.m.a.n@lists.open-mesh.org, bridge@lists.linux.dev,
 netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
 mptcp@lists.linux.dev, lvs-devel@vger.kernel.org, dev@openvswitch.org,
 rds-devel@oss.oracle.com, linux-sctp@vger.kernel.org,
 linux-s390@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
 linux-security-module@vger.kernel.org
Message-Id: <ff6ff699-e942-455f-8816-49af24afb370@app.fastmail.com>
In-Reply-To: <20260910144914.8025-2-fmancera@suse.de>
References: <20260910144914.8025-1-fmancera@suse.de>
 <20260910144914.8025-2-fmancera@suse.de>
Subject: Re: [PATCH 01/13 net-next] net: ipv4: introduce CONFIG_IPV4 to decouple the
 IPv4 stack
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Sep 10, 2026, at 10:48 AM, Fernando Fernandez Mancera wrote:
> Historically, the IPv4 protocol has been linked to the core INET
> subsystem. Because shared infrastructure like the TCP/UDP engine,
> routing or INET hashtables live inside net/ipv4/, it has been impossible
> to compile a kernel with only IPv6 support.
>
> This patch introduces the CONFIG_IPV4 Kconfig symbol, which is set to
> 'def_bool y' for now. This does not allow to completely disable the
> IPv4 stack yet but it lays the necessary build-system work for that
> goal.
>
> In addition, multiple subsystems Kconfig symbols across networking
> features like tunnels, drivers and filesystems have been adjusted to
> depend on IPv4. Keep on mind that follow-up work is required to convert
> the Kconfig symbol to bool and remove the dependency on IPv4 where it
> makes sense.
>
> Signed-off-by: Fernando Fernandez Mancera <fmancera@suse.de>

> diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
> index e7808e5714dc..58e6f6db3100 100644
> --- a/net/sunrpc/Kconfig
> +++ b/net/sunrpc/Kconfig
> @@ -1,7 +1,7 @@
>  # SPDX-License-Identifier: GPL-2.0-only
>  config SUNRPC
>  	tristate
> -	depends on MULTIUSER
> +	depends on MULTIUSER && IPV4
> 
>  config SUNRPC_GSS
>  	tristate

Acked-by: Chuck Lever <cel@kernel.org>


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
