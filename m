Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA3EA4A99C6;
	Fri, 11 Sep 2026 18:32:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789151546; cv=none; b=BoZ5DgVfsrgpEs7NWHry5Lmt+zHGxyHRS8+m9vbI2WyI8w8Kc2gzoCVybW8rXEZRHE5fOqFO3Kxc9y/A95P7Ldb6BGwx30tknO9rKbOVUlNjN8nDxlTFDVsroC1lpZ+XY7VOx2act8tOeS1d+PQP0xkRJbtAnw/t21Xss1nDJWg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789151546; c=relaxed/simple;
	bh=kGcna8qnasBYiXRYEi48BDAzZBHcd69XY9IMfaZN56k=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=isiojdouDgrKiUUYTpHRE5ISzqs6mHS7087fpUWNcDrecNK5EUCBnQoczuFyvn64cQBarbHdYHourzKMCqAorBO6/mWnihu80JY0wEwppQ/yjJznjAuTdJHMWIgPHlL+biVvte9SXMZPSPZUP7YVDks6HBmOZ/NduNt01B924sE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=Rod0sU8Q; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=SIrVXAQ4; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=t9gvN2nl; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=FnLFXx/K; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="Rod0sU8Q";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="SIrVXAQ4";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="t9gvN2nl";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="FnLFXx/K"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 164481FEF2;
	Fri, 11 Sep 2026 18:32:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1789151538; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=b3huHsOxzXu3WG732phakZA+zeD+7wCDwsZTRvWLdY4=;
	b=Rod0sU8Qdbl2a9I9t1TH8nevi4QRfn3TPfcK74bX64NGYlK6IHkuzAhBL08HIKt63niSI/
	6veFNIqyotajC6UCFkeNjNmJezrJxBptWKdfl94tSQs8eHOgD9mU8KcO4CkQo1s/NpMwfn
	kmsnciPVbpHoeV5HykyGSvDyJ/flO3w=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1789151538;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=b3huHsOxzXu3WG732phakZA+zeD+7wCDwsZTRvWLdY4=;
	b=SIrVXAQ4ceuoB0fGrHOOtVO1/WzKntIfVXPqXNQPSKYuVdsXv8YzVUOSr+XNFJ/yIPVMhN
	zTZpSfo+uSEO1wDA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1789151534; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=b3huHsOxzXu3WG732phakZA+zeD+7wCDwsZTRvWLdY4=;
	b=t9gvN2nlbxSG+QCJOr3Qwp0FANn+yCEqu4YHmsqlPzf0zjeumUAtcGLCZTbmav6JBEjAnm
	c41BWBSWq8AARidcMzA+ZhJfDP3iy28qnix3YpHWZbSEX+hx1j3W5/Dot4Ih4kiPxwIVpp
	7cHlpzVuqFt2y519+0+mCk4UCgw+K/g=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1789151534;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=b3huHsOxzXu3WG732phakZA+zeD+7wCDwsZTRvWLdY4=;
	b=FnLFXx/K4kGWIzrUI6pjTmx6O95RSJHfUkFLZdB3yB4XYnlrurdCfLL7hNThqzkOntilHf
	8PYNspUtNK/EHXCg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 6A640132D3;
	Fri, 11 Sep 2026 18:32:07 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id B8AjFydJpGrJdAAAD6G6ig
	(envelope-from <fmancera@suse.de>); Fri, 11 Sep 2026 18:32:07 +0000
Message-ID: <dfd9590c-e029-4432-9a13-c789f708cfee@suse.de>
Date: Fri, 11 Sep 2026 20:31:20 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 01/13 net-next] net: ipv4: introduce CONFIG_IPV4 to
 decouple the IPv4 stack
To: Casey Schaufler <casey@schaufler-ca.com>, netdev@vger.kernel.org
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
 linux-security-module@vger.kernel.org
References: <20260910144914.8025-1-fmancera@suse.de>
 <20260910144914.8025-2-fmancera@suse.de>
 <ee89e26c-3dad-450b-8861-badf19afa141@schaufler-ca.com>
Content-Language: en-US
From: Fernando Fernandez Mancera <fmancera@suse.de>
In-Reply-To: <ee89e26c-3dad-450b-8861-badf19afa141@schaufler-ca.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Spam-Level: 
X-Spam-Score: -0.80
X-Spam-Flag: NO
X-Spamd-Result: default: False [-0.80 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	FORGED_RECIPIENTS(2.00)[m:horms@kernel.org,m:kuba@kernel.org,m:edumazet@google.com,m:davem@davemloft.net,m:leon@kernel.org,m:andrew+netdev@lunn.ch,m:anthony.l.nguyen@intel.com,m:przemyslaw.kitszel@intel.com,m:enachman@marvell.com,m:saeedm@nvidia.com,m:tariqt@nvidia.com,m:mbloch@nvidia.com,m:idosch@nvidia.com,m:petrm@nvidia.com,m:ecree.xilinx@gmail.com,m:maxime.chevallier@bootlin.com,m:mcoquelin.stm32@gmail.com,m:alexandre.torgue@foss.st.com,m:arend.vanspriel@broadcom.com,m:miriam.rachel.korenblit@intel.com,m:kbusch@kernel.org,m:axboe@kernel.dk,m:hch@lst.de,m:sagi@grimberg.me,m:kch@nvidia.com,m:skashyap@marvell.com,m:jhasan@marvell.com,m:GR-QLogic-Storage-Upstream@marvell.com,m:James.Bottomley@HansenPartnership.com,m:mkp@kernel.org,m:njavali@marvell.com,m:mrangankar@marvell.com,m:varun@chelsio.com,m:brauner@kernel.org,m:marc.dionne@auristor.com,m:trondmy@kernel.org,m:anna@kernel.org,m:cel@kernel.org,m:jlayton@kernel.org,m:neil@brown.name,m:Dai.Ngo@oracle.com,m:marek.lindner@mailbox.o
 rg,m:antonio@mandelbit.com,m:sven@narfation.org,m:razor@blackwall.org,m:pablo@netfilter.org,m:phil@nwl.cc,m:matttbe@kernel.org,m:martineau@kernel.org,m:geliang@kernel.org,m:i.maximets@ovn.org,m:achender@kernel.org,m:jhs@mojatatu.com,m:marcelo.leitner@gmail.com,m:lucien.xin@gmail.com,m:alibuda@linux.alibaba.com,m:dust.li@linux.alibaba.com,m:sidraya@linux.ibm.com,m:mjambigi@linux.ibm.com,m:tonylu@linux.alibaba.com,m:guwen@linux.alibaba.com,m:tung.quang.nguyen@est.tech,m:herbert@gondor.apana.org.au,m:paul@paul-moore.com,m:jmorris@namei.org,m:serge@hallyn.com,m:vikas.gupta@broadcom.com,m:bhargava.marreddy@broadcom.com,m:rajashekar.hudumula@broadcom.com,m:markus@blochl.de,m:arnd@arndb.de,m:hkallweit1@gmail.com,m:florian.fainelli@broadcom.com,m:krzk@kernel.org,m:qingfang.deng@linux.dev,m:julianbraha@gmail.com,m:enelsonmoore@gmail.com,m:gregkh@linuxfoundation.org,m:ebiggers@kernel.org,m:ardb@kernel.org,s:oleg@redhat.com,s:linux-stm32@st-md-mailman.stormreply.com,s:linux-fsdevel@vger.kernel
 .org,s:linux-kernel@vger.kernel.org,s:linux-nfs@vger.kernel.org,s:linux-rdma@vger.kernel.org,s:linux-s390@vger.kernel.org,s:linux-scsi@vger.kernel.org,s:linux-sctp@vger.kernel.org,s:linux-security-module@vger.kernel.org,s:linux-wireless@vger.kernel.org,s:lvs-devel@vger.kernel.org,s:netfilter-devel@vger.kernel.org,s:target-devel@vger.kernel.org];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-0.999];
	MIME_GOOD(-0.10)[text/plain];
	TAGGED_RCPT(0.00)[netdev];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	ARC_NA(0.00)[];
	TO_DN_SOME(0.00)[];
	MIME_TRACE(0.00)[0:+];
	MID_RHS_MATCH_FROM(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[kernel.org,redhat.com,google.com,davemloft.net,ziepe.ca,lunn.ch,intel.com,marvell.com,nvidia.com,gmail.com,bootlin.com,foss.st.com,broadcom.com,kernel.dk,lst.de,grimberg.me,HansenPartnership.com,chelsio.com,zeniv.linux.org.uk,suse.cz,auristor.com,brown.name,oracle.com,talpey.com,mailbox.org,simonwunderlich.de,mandelbit.com,narfation.org,blackwall.org,netfilter.org,strlen.de,nwl.cc,sipsolutions.net,ssi.bg,ovn.org,mojatatu.com,resnulli.us,linux.alibaba.com,linux.ibm.com,est.tech,secunet.com,gondor.apana.org.au,paul-moore.com,namei.org,hallyn.com,tipi-net.de,blochl.de,arndb.de,linux.dev,linuxfoundation.org,alyssa.is,vger.kernel.org,lists.osuosl.org,corigine.com,amd.com,st-md-mailman.stormreply.com,lists.infradead.org,lists.linux.dev,lists.open-mesh.org,openvswitch.org,oss.oracle.com,lists.sourceforge.net];
	R_RATELIMIT(0.00)[to_ip_from(RLzghooyjbkt4nddgixz9uws5c)];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	TO_MATCH_ENVRCPT_SOME(0.00)[];
	RCPT_COUNT_GT_50(0.00)[133];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:email,suse.de:mid,imap1.dmz-prg2.suse.org:helo]

On 9/11/26 7:46 PM, Casey Schaufler wrote:
> On 9/10/2026 7:48 AM, Fernando Fernandez Mancera wrote:
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
>> ---
>>   
> 
> ...
> 
> 
>>   security/smack/Kconfig                        |  1 +
>>   54 files changed, 126 insertions(+), 66 deletions(-)
>>
> ...
> 
>> diff --git a/security/smack/Kconfig b/security/smack/Kconfig
>> index 5a8dfad469c3..b4e6d0168bd1 100644
>> --- a/security/smack/Kconfig
>> +++ b/security/smack/Kconfig
>> @@ -3,6 +3,7 @@ config SECURITY_SMACK
>>   	bool "Simplified Mandatory Access Control Kernel Support"
>>   	depends on NET
>>   	depends on INET
>> +	depends on IPV4
>>   	depends on SECURITY
>>   	select NETLABEL
>>   	select SECURITY_NETWORK
> 
> Why would this make sense? You're introducing the capability to use
> IP6 by itself, which is admirable, but you're disallowing that configuration
> with the Smack LSM. It appears that you've done a mechanical lookup in the
> Kconfig files and applied the minimal change to make the kernel compile,
> which probably works for most cases. It does not work for Smack. Unless
> there's a strong argument that Smack with IPv6 and without IPv4 is and always
> will be a pointless configuration you have my NAK.
> 
> 

Right, that was kind of the point. The idea was to be able to compile 
core networking without IPv4. There are still plenty of modules that 
depends on IPv4. It does not mean that they will remain like that 
forever as I mentioned my idea was a follow-up on the series to avoid 
having a too long series.

Anyway, I can make Smack to do not depend on IPv4 on this series if that 
could grant an ACK.

Thanks,
Fernando.

