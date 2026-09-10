Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF4F2346AD5;
	Thu, 10 Sep 2026 16:31:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789057919; cv=none; b=RT9vRVj7KOlvAjqKYMSt3/7pHN47D3hwUPewQnlGVloIm655Aa3g+ybWrYhcM+i8KzpjKNeYS/ZCPVo0JxE027p6UGfw5l9PxI+QTZpLS+nXAD7F7Mmny8mJf0fRrPRfqGIwL2oSo7334XwuJjFO0CayPgcwOf/4M+v/3Z/8kDw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789057919; c=relaxed/simple;
	bh=a47H8ascUBW8jMxwLKmfEWxJLnstKS97n+pzQV1m0XY=;
	h=Message-ID:Date:MIME-Version:Subject:From:To:Cc:References:
	 In-Reply-To:Content-Type; b=gx+lxrlZzwDExNlx2BL+wPeUnw4DMlwtJ4/z7OsT09IwEOElGASadNtwY0eUhopC/vWXJF1BXNsVkuWbmosjqgRJLp6IMpEm0hoIv4X9rjcPYqwE9UMoIzX4o4t5YiovHHiCMdb1oqYN6u+ymrkihExRp3yy9+r3Beglx11eZvQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=yQtRt462; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=LH324BSn; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=cYCiQcKe; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=ImEU0/HI; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="yQtRt462";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="LH324BSn";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="cYCiQcKe";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="ImEU0/HI"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 8191721DAF;
	Thu, 10 Sep 2026 16:31:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1789057901; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=K0lYofAWqHa7ePB/bJxKmxDOeogYPK+nv0lM1u2sygM=;
	b=yQtRt4622LZ6Zi4UvIWOPIjsnQFttLWbic0UbOJ/MktL5wrTGXBqQN6VGuGrXRhIlo/NeW
	mEztr0zz7AktV8m4uA1s3ZQ6UgnpG9dWJT2grEZj2W+OiQ8bJuPUunvGSejQ+jE1ZPWpKC
	TMxQGHoX9d9j13TmLvZ4K61GrFCE9hA=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1789057901;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=K0lYofAWqHa7ePB/bJxKmxDOeogYPK+nv0lM1u2sygM=;
	b=LH324BSnk58hu9qiwIXwVhycJLjRA5a8tBmcWkTq5EUKnPJNyXh5hxQGh9zkZjY59lz4yV
	8q006bBLfAs0WTDA==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.de header.s=susede2_rsa header.b=cYCiQcKe;
	dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b="ImEU0/HI"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1789057897; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=K0lYofAWqHa7ePB/bJxKmxDOeogYPK+nv0lM1u2sygM=;
	b=cYCiQcKeL+lNT5vXzUYXm2veHe3zr0mktCu+3rPmCBwrw2kTXo37AwFOyr1bYeWe0bmHdV
	1arZOiwul7owGD/gNEqP/XnSrf1owgb50cB3DU9jESucNN4UKtQMk8/5hHaj02PDghTAWf
	4mE3IjDeiQiY5bqZ7XKwd7ngXgaQAtU=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1789057897;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=K0lYofAWqHa7ePB/bJxKmxDOeogYPK+nv0lM1u2sygM=;
	b=ImEU0/HIDJ8BCgajwwBBxGIMxsn8h8Ik16/8D9zy28+7s2aEcSnL+JFiPuiMCS5WBdZZOG
	Rc066ADpK5HMSXCA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id E4ED913180;
	Thu, 10 Sep 2026 16:31:30 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 3ywWNWLbomodUwAAD6G6ig
	(envelope-from <fmancera@suse.de>); Thu, 10 Sep 2026 16:31:30 +0000
Message-ID: <6cd59005-16b9-402f-896e-a031c1e0b20d@suse.de>
Date: Thu, 10 Sep 2026 18:30:59 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 01/13 net-next] net: ipv4: introduce CONFIG_IPV4 to
 decouple the IPv4 stack
From: Fernando Fernandez Mancera <fmancera@suse.de>
To: netdev@vger.kernel.org
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
 Casey Schaufler <casey@schaufler-ca.com>, Paul Moore <paul@paul-moore.com>,
 James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>,
 Vikas Gupta <vikas.gupta@broadcom.com>,
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
 linux-security-module@vger.kernel.org
References: <20260910144914.8025-1-fmancera@suse.de>
 <20260910144914.8025-2-fmancera@suse.de>
 <bee1e0e0-6114-462b-975c-62ca2e448e8e@suse.de>
Content-Language: en-US
In-Reply-To: <bee1e0e0-6114-462b-975c-62ca2e448e8e@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Spam-Level: 
X-Rspamd-Action: no action
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Queue-Id: 8191721DAF
X-Spamd-Result: default: False [-1.01 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	FORGED_RECIPIENTS(2.00)[m:horms@kernel.org,m:kuba@kernel.org,m:edumazet@google.com,m:davem@davemloft.net,m:leon@kernel.org,m:andrew+netdev@lunn.ch,m:anthony.l.nguyen@intel.com,m:przemyslaw.kitszel@intel.com,m:enachman@marvell.com,m:saeedm@nvidia.com,m:tariqt@nvidia.com,m:mbloch@nvidia.com,m:idosch@nvidia.com,m:petrm@nvidia.com,m:ecree.xilinx@gmail.com,m:maxime.chevallier@bootlin.com,m:mcoquelin.stm32@gmail.com,m:alexandre.torgue@foss.st.com,m:arend.vanspriel@broadcom.com,m:miriam.rachel.korenblit@intel.com,m:kbusch@kernel.org,m:axboe@kernel.dk,m:hch@lst.de,m:sagi@grimberg.me,m:kch@nvidia.com,m:skashyap@marvell.com,m:jhasan@marvell.com,m:GR-QLogic-Storage-Upstream@marvell.com,m:James.Bottomley@HansenPartnership.com,m:mkp@kernel.org,m:njavali@marvell.com,m:mrangankar@marvell.com,m:varun@chelsio.com,m:brauner@kernel.org,m:marc.dionne@auristor.com,m:trondmy@kernel.org,m:anna@kernel.org,m:cel@kernel.org,m:jlayton@kernel.org,m:neil@brown.name,m:Dai.Ngo@oracle.com,m:marek.lindner@mailbox.o
 rg,m:antonio@mandelbit.com,m:sven@narfation.org,m:razor@blackwall.org,m:pablo@netfilter.org,m:phil@nwl.cc,m:matttbe@kernel.org,m:martineau@kernel.org,m:geliang@kernel.org,m:i.maximets@ovn.org,m:achender@kernel.org,m:jhs@mojatatu.com,m:marcelo.leitner@gmail.com,m:lucien.xin@gmail.com,m:alibuda@linux.alibaba.com,m:dust.li@linux.alibaba.com,m:sidraya@linux.ibm.com,m:mjambigi@linux.ibm.com,m:tonylu@linux.alibaba.com,m:guwen@linux.alibaba.com,m:tung.quang.nguyen@est.tech,m:herbert@gondor.apana.org.au,m:paul@paul-moore.com,m:jmorris@namei.org,m:serge@hallyn.com,m:vikas.gupta@broadcom.com,m:bhargava.marreddy@broadcom.com,m:rajashekar.hudumula@broadcom.com,m:markus@blochl.de,m:arnd@arndb.de,m:hkallweit1@gmail.com,m:florian.fainelli@broadcom.com,m:krzk@kernel.org,m:qingfang.deng@linux.dev,m:julianbraha@gmail.com,m:enelsonmoore@gmail.com,m:gregkh@linuxfoundation.org,m:ebiggers@kernel.org,m:ardb@kernel.org,s:oleg@redhat.com,s:linux-stm32@st-md-mailman.stormreply.com,s:linux-fsdevel@vger.kernel
 .org,s:linux-kernel@vger.kernel.org,s:linux-nfs@vger.kernel.org,s:linux-rdma@vger.kernel.org,s:linux-s390@vger.kernel.org,s:linux-scsi@vger.kernel.org,s:linux-sctp@vger.kernel.org,s:linux-security-module@vger.kernel.org,s:linux-wireless@vger.kernel.org,s:lvs-devel@vger.kernel.org,s:netfilter-devel@vger.kernel.org,s:target-devel@vger.kernel.org];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	FROM_HAS_DN(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	MIME_TRACE(0.00)[0:+];
	FREEMAIL_CC(0.00)[kernel.org,redhat.com,google.com,davemloft.net,ziepe.ca,lunn.ch,intel.com,marvell.com,nvidia.com,gmail.com,bootlin.com,foss.st.com,broadcom.com,kernel.dk,lst.de,grimberg.me,HansenPartnership.com,chelsio.com,zeniv.linux.org.uk,suse.cz,auristor.com,brown.name,oracle.com,talpey.com,mailbox.org,simonwunderlich.de,mandelbit.com,narfation.org,blackwall.org,netfilter.org,strlen.de,nwl.cc,sipsolutions.net,ssi.bg,ovn.org,mojatatu.com,resnulli.us,linux.alibaba.com,linux.ibm.com,est.tech,secunet.com,gondor.apana.org.au,schaufler-ca.com,paul-moore.com,namei.org,hallyn.com,tipi-net.de,blochl.de,arndb.de,linux.dev,linuxfoundation.org,alyssa.is,vger.kernel.org,lists.osuosl.org,corigine.com,amd.com,st-md-mailman.stormreply.com,lists.infradead.org,lists.linux.dev,lists.open-mesh.org,openvswitch.org,oss.oracle.com,lists.sourceforge.net];
	ARC_NA(0.00)[];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RCVD_TLS_ALL(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RLdey6otz8cz7qhffota9ydd97)];
	TO_DN_SOME(0.00)[];
	TO_MATCH_ENVRCPT_SOME(0.00)[];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	RCVD_COUNT_TWO(0.00)[2];
	FROM_EQ_ENVFROM(0.00)[];
	DKIM_TRACE(0.00)[suse.de:+];
	RCPT_COUNT_GT_50(0.00)[133];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	MID_RHS_MATCH_FROM(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	TAGGED_RCPT(0.00)[netdev];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.de:dkim,suse.de:email,suse.de:mid]
X-Spam-Flag: NO
X-Spam-Score: -1.01

On 9/10/26 6:22 PM, Fernando Fernandez Mancera wrote:
> On 9/10/26 4:48 PM, Fernando Fernandez Mancera wrote:
>> Historically, the IPv4 protocol has been linked to the core INET
>> subsystem. Because shared infrastructure like the TCP/UDP engine,
>> routing or INET hashtables live inside net/ipv4/, it has been impossible
>> to compile a kernel with only IPv6 support.
>>
>> This patch introduces the CONFIG_IPV4 Kconfig symbol, which is set to
>> 'def_bool y' for now. This does not allow to completely disable the
>> IPv4 stack yet but it lays the necessary build-system work for that
>> goal.
>>
>> In addition, multiple subsystems Kconfig symbols across networking
>> features like tunnels, drivers and filesystems have been adjusted to
>> depend on IPv4. Keep on mind that follow-up work is required to convert
>> the Kconfig symbol to bool and remove the dependency on IPv4 where it
>> makes sense.
>>
>> Signed-off-by: Fernando Fernandez Mancera <fmancera@suse.de>
> FWIW, I just checked and the following symbols that are currently marked 
> as "depends on IPV4" can already be compiled without IPV4:
> 
> IPV6_MIP6, IPV6_ILA and IPV6_MROUTE
> 

MIP6 depends on XFRM so it actually depends on IPV4 for now.

> They will be adjusted on the next revision of the series. A re-check for 
> all the symbols will be performed.
> 
> Thanks,
> Fernando.

