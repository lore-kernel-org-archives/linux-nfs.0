Received: from sonic309-27.consmr.mail.ne1.yahoo.com (sonic309-27.consmr.mail.ne1.yahoo.com [66.163.184.153])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 12DD74AD7F5
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 18:06:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.163.184.153
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789150010; cv=none; b=Db+LZ3J3EYDEegxV/lvdq49igrrFlmnldbJISClF3eHJ9bB9+FLaIFp0zSNUPzF1NhrnrYUYyI1tl2epAmEESsy9paMLmmRFFNmX3sruPaPeMWS+uZGjZeSWTvlPhkywKd7dSWVynOzbdCE5TXWJ5YFggavq/6ibVUCSH3avy+M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789150010; c=relaxed/simple;
	bh=Z57Iku1thXyXrd/tJuHixAzTq3I2TFBtAiDxp2vv5n8=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=tS8IBF9TITwwkcwA8atEH6PBEgFNcifGf1YTJNvx2Nlu1OQ9PBrqjAUBMK+Oz/RsfsTr9J6dRKMMn6qCglDTyvh18wWqXU/Odg+jrpcyQdyZz/1gR3RJ00kXmf2WJHkMQCETOS7iUKjuzgiRl1JWPCJxWeuGqvCebUhbb5q48c4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=schaufler-ca.com; spf=none smtp.mailfrom=schaufler-ca.com; dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b=SJo1s8Q1; arc=none smtp.client-ip=66.163.184.153
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=schaufler-ca.com
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=schaufler-ca.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b="SJo1s8Q1"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1789150007; bh=N0ksFx+o56aUgsrzSCG07cwcgBEXSZlDOBLwLo9KB9k=; h=Date:Subject:To:Cc:References:From:In-Reply-To:From:Subject:Reply-To; b=SJo1s8Q1vVsugOTkF+1RDn5zyrCnUvWiMWl9DkJEFblXQQLOq7seoI4F9WXlRHxzPD8qos1Udfs/rQ6ASgk36BiU4zy84T6harikTSCh6CC2YYJUZu+/SlTdJ9vsElPI9kKM1SrN4LS90QeeWZ+vt8mASEzPgpQycijwcQpcC6gX0vPin5XRkVdE1hzEAh5O3MAHzWAFxpBd8t3ezWHhAv3zOlohttmoecJLca4rlpXdzjliKmKVixAymsLBmXQ/juLmU+LK1NqrAe8F5pUWukwK+eMwdtPB4ciqo/Xsa1nfLR3T5rKyRMAg4TnN4VkU1DwsS/VCTNcwsnltOgnUaw==
X-SONIC-DKIM-SIGN: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1789150007; bh=1TPfxe4louX9IgOiGnOUB0biGI6qpOcs4Cw+TyDsGvo=; h=X-Sonic-MF:Date:Subject:To:From:From:Subject; b=Uy6Qgi7vDKUh1qcDSoW9NMgaUXThkB1+Vd5KX6qBW60HBe8mvaP3uNTYJFfq7cBwuWBbq00PiJqcctSl8SiXw9Q1OLccToXvVUlDOtt9DoJq2o7BHY/82B3Vha+WG68IqNM9QcQDRWgGXuUqtAXrulYubK5f9ojOs1uW7YhcpM/W7Y12KilsD0Hmeiwu1zYYL2TsMqhLiZaWfdcyAsUUuvxXoqFwt4VB44i4jtz9J6ghnAzL7dtaMSisKxweDtIUtyGAFzAuAvstqBW8T2fX9oUtrQHwjnmQro1AyLDmu3MNnSfcXI/ba4JGI7Owg2GbDzjkLGJUrmvL+gK94pmcNg==
X-YMail-OSG: Z9UMG9YVM1lctHC24HnZvwkpAFOQdH7gglIMIGoN9uePiY6tmM1qasTJ0aPnTzX
 tzt29oMHmILoCJ0h7IC3u49YVUVYpMiAR3DOapJZF7js1zavVTijW7mz6eDy0Aknu2cJAIMBsqct
 C3ya42KOnkk9oeom.b.QTEgcQUSRb.xUyEOV838qqsLQzKYF7X4scufuZH2ZMtPbL4WXhFrvUpaa
 b2h7qJsroiEU4KnSo_4R743CTWkEixpeInkhNH0gSxv83Oy2Qp2WDEFOmBoIryMYglQrGdPXsoBd
 pWMZwxUFVMji3.9WaIrRLWEwU0aCVr.y7dg7LlQywAhwgodXzjq7xYZrwHNyfNkFOZOORAsIxvzh
 T2.QUhV.JpcG1Fb6DrNXHkSYUzD9f0kby6nX1oVX_X3RSxKW_gdPGix0Yg2F.SZCIlWjZiWlfSct
 EHuva2iR3235_wLAiNbAoBnNIA0auBPdbrWlPKgBy8dD1rjj1N.QzBmZteeApzGC5cTnvC6GdB_Y
 pj2GFD41VlRPuSGzC1TI4dE8UtcO9WCWDGJJ.N9ljlE7ridZHp5sXcvrlb2a1bJn8b8g.gM_k0Y.
 rhnpwwCd5hEjjm.jA8eaExquIyZEltU8Mn8S09036R4ZIVIUqtSgx2_UM_72JpAgdr93yUloY4Ni
 ZkPaUGtv8xsIZjdsKhzb9Di_L2bWvEmHR1tEWk0sRpWSJgpkcV4TInr7E.FKZCDYRWAgpQas1uQJ
 1TOZ6fnSFy0FwYnc34A27vgJO53IRnC3i1fXQzozdz_ciT8l.ZAKAjYby7iyEEUlPZ7AuInZrPza
 IEdzUZNoQry0p.FCLskNePKfkzaolmO7kf1Xy1P9r1wU3jjfCqpzfxKG3gMpYwfVAsVNnOv6gDzl
 McJQL.IE2U_X9ZGVZjg4rkSvsjGUx_bL4lOIDeQWj5nb8EO_hS3ZFeOXVa76rEtJBTamfTTW_7Zc
 elKXzO0c0jsF_iGOvV2sX9TtagZFju13DPJgDpCFgKnK8RfROr.IP761grH7JdkzCRfBscbKj8k7
 Ahwv8KwS_qMFpGCZsVnKIueTdlB7CJitfx_aC17KoiI.w5vP5MeCFnyYnZ36ZuvoA4KiKo_Ncwrm
 CZCI96cIwehGcjN454ZgHYgmbxlMsQdtxl0ALCXIEd231qZxI5r3jKKzqWBRQBT6wyOE.JLSQXU3
 bZlUojN5mC7Gx19NhnLlG.lg751JnoD40Ciw_ysQAywCq2134cpLDvJiqE5XaWXg_KeWNaSx07Rp
 Z.Hp4cWssIRHg5vMk_aZs5Z7gP2r111AT0tPqB.Zl36I7EcMncMSuoK6TpjUpeCFPNA2Uzn6lWpv
 Ayq9XnDzPBBYPg3Z5Yq8pSj2VM5qO2prq6fi4wRQysNvd_1lqrs3VtFc9ydPyX8RD8VYVSxv1uJ1
 FB2N7hJH1gYewxLqD1TrMgTjhWKaalb0ZCqhrFy0PdSKktKHFroGOPZfZWAV4mekQimDDZkSUtnC
 yw.h8nHeNuzHO8V0HTM_P4nsUeGGf6aLnKrOA9cgDr2U7b1pfnZjwOEC9f3OwqLxHVtN7DxbxRBt
 XbRaMJ0t0JXpnmzFjCEwxOIe4YxMA79ojl0uBwAtD0Fy0woxF6BF3RJ1ZPPU0_PUXxNYTPAv797g
 hCvs4V7D7ilhn2pHF7zgioCgAymlDwbbb1kS25sFEgT.ab0mYvR_DTYvZdm8xvptaKga9_3Q_4la
 Nfg7LDwLu90rXbR_jFSVDg8_CRrWzNGZoExyv2KC5Ioxx4w5Z.vFZMm71aSdZqcz97awS9O27LEy
 zOpyEkEiGjFrw1cgZZtyu3Ew0HqIQ0h4xkl52jQ4XgT.30ChKEVFYvIV7iuJxGT28kntbVLk7n5h
 Qgdut7ArndRx8PCSev3URpMnf8AM0zR8NhPyD_xl.PBWGf9W2RDA6RRWpdjmgFHBTId2lKL_nSJl
 LkxGwDO7rDn_SxbCFne8eoKNae0qOWs798diQQVJL0Ddb8aFSC4LFGAwrr_d22T4W8yy.Ndfb49y
 z2dOYbOpJhAl12Ftt1XOzJGQFgwPv5Q_tiwpkT27_1AfToPZ2tfNNwEU5LXsoecZNMjPL637Fs88
 Pm9FtfEyd0XJbD1XOE.f.OBlHHpbiaJgp4mXcZx0q4HZOY4DX10_8VcqfbSEaXrmk1KmYyVyvbHM
 3QxDwZXAF5FNMwXncGbQWYGe_Azdm2WnLc5rY4RP0yu0DZzoy5yQFXvQ.VZQ0.Ig5LzjCVNNskre
 .fT9yhcSlPWI3IHZaEsNbS3ASejCKAAQtyEkTugxQ5eM1GTORRydzR8ohwGmxc5gursUvWq1obkV
 s1L1HzWgkFSZ7
X-Sonic-MF: <casey@schaufler-ca.com>
X-Sonic-ID: b76ab4a0-2ab9-47b3-8cf5-8bdd5faf0803
Received: from sonic.gate.mail.ne1.yahoo.com by sonic309.consmr.mail.ne1.yahoo.com with HTTP; Fri, 11 Sep 2026 18:06:47 +0000
Received: by hermes--production-gq1-678d9dd684-kwnw4 (Yahoo Inc. Hermes SMTP Server) with ESMTPA ID 399694003e99ff36e3a7b206375e9b12;
          Fri, 11 Sep 2026 17:46:02 +0000 (UTC)
Message-ID: <ee89e26c-3dad-450b-8861-badf19afa141@schaufler-ca.com>
Date: Fri, 11 Sep 2026 10:46:00 -0700
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 01/13 net-next] net: ipv4: introduce CONFIG_IPV4 to
 decouple the IPv4 stack
To: Fernando Fernandez Mancera <fmancera@suse.de>, netdev@vger.kernel.org
Cc: horms@kernel.org, kuba@kernel.org, pabeni@redhat.com,
 edumazet@google.com, davem@davemloft.net, Jason Gunthorpe <jgg@ziepe.ca>,
 Leon Romanovsky <leon@kernel.org>, Andrew Lunn <andrew+netdev@lunn.ch>,
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
 "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
 "Martin K. Petersen" <mkp@kernel.org>, Nilesh Javali <njavali@marvell.com>,
 Manish Rangankar <mrangankar@marvell.com>, Varun Prakash
 <varun@chelsio.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
 David Howells <dhowells@redhat.com>, Marc Dionne <marc.dionne@auristor.com>,
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 Marek Lindner <marek.lindner@mailbox.org>,
 Simon Wunderlich <sw@simonwunderlich.de>,
 Antonio Quartulli <antonio@mandelbit.com>,
 Sven Eckelmann <sven@narfation.org>,
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
 Dust Li <dust.li@linux.alibaba.com>, Sidraya Jayagond
 <sidraya@linux.ibm.com>, Mahanta Jambigi <mjambigi@linux.ibm.com>,
 Tony Lu <tonylu@linux.alibaba.com>, Wen Gu <guwen@linux.alibaba.com>,
 Jon Maloy <jmaloy@redhat.com>, Tung Quang Nguyen
 <tung.quang.nguyen@est.tech>, Steffen Klassert
 <steffen.klassert@secunet.com>, Herbert Xu <herbert@gondor.apana.org.au>,
 Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>,
 "Serge E. Hallyn" <serge@hallyn.com>, Vikas Gupta
 <vikas.gupta@broadcom.com>,
 Bhargava Marreddy <bhargava.marreddy@broadcom.com>,
 Rajashekar Hudumula <rajashekar.hudumula@broadcom.com>,
 Nicolai Buchwitz <nb@tipi-net.de>, =?UTF-8?Q?Markus_Bl=C3=B6chl?=
 <markus@blochl.de>, Arnd Bergmann <arnd@arndb.de>,
 Heiner Kallweit <hkallweit1@gmail.com>,
 Florian Fainelli <florian.fainelli@broadcom.com>,
 Krzysztof Kozlowski <krzk@kernel.org>,
 Qingfang Deng <qingfang.deng@linux.dev>, Julian Braha
 <julianbraha@gmail.com>, Ethan Nelson-Moore <enelsonmoore@gmail.com>,
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
 linux-security-module@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>
References: <20260910144914.8025-1-fmancera@suse.de>
 <20260910144914.8025-2-fmancera@suse.de>
Content-Language: en-US
From: Casey Schaufler <casey@schaufler-ca.com>
In-Reply-To: <20260910144914.8025-2-fmancera@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Mailer: WebService/1.1.26525 mail.backend.jedi.jws.acl:role.jedi.acl.token.atz.jws.hermes.yahoo

On 9/10/2026 7:48 AM, Fernando Fernandez Mancera wrote:
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
> ---
>  

...


>  security/smack/Kconfig                        |  1 +
>  54 files changed, 126 insertions(+), 66 deletions(-)
>
...

> diff --git a/security/smack/Kconfig b/security/smack/Kconfig
> index 5a8dfad469c3..b4e6d0168bd1 100644
> --- a/security/smack/Kconfig
> +++ b/security/smack/Kconfig
> @@ -3,6 +3,7 @@ config SECURITY_SMACK
>  	bool "Simplified Mandatory Access Control Kernel Support"
>  	depends on NET
>  	depends on INET
> +	depends on IPV4
>  	depends on SECURITY
>  	select NETLABEL
>  	select SECURITY_NETWORK

Why would this make sense? You're introducing the capability to use
IP6 by itself, which is admirable, but you're disallowing that configuration
with the Smack LSM. It appears that you've done a mechanical lookup in the
Kconfig files and applied the minimal change to make the kernel compile,
which probably works for most cases. It does not work for Smack. Unless
there's a strong argument that Smack with IPv6 and without IPv4 is and always
will be a pointless configuration you have my NAK.

