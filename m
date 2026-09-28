Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A4E73BD241;
	Mon, 28 Sep 2026 19:31:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790623902; cv=none; b=grSLNekaTI3pQf5EubOSBvEjSQxbARLVqtkCp4QiqzpGRCIZKdAQCJfSrfUeUtBEJznvx4CmgrKxeCcSqdLs+4NJV8iZidHjiCdW07tL53E69w0zZx7fLCTL7QWCCM8uXGObUrcPtCPu7n7NcEBAOOudMpLDQWUMrdeluI+aRs0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790623902; c=relaxed/simple;
	bh=FuYHtQTbqw26mjq8W1siyuDuD3/KdBw0EwXgkJHrNyU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rCqa8HCp1VbCvMhaOWTo7MhL6+tj0zGy+2qwOHyGvI/gUsRgv3/k6pek9dZWx8wiURzofrGyeJJe7mgsPQGLxN+hO1Sz+7nrTGBEXEqGPREEQQk/ELjiFd2uEQ/RHo/5gA8FvjjpjfgJDA3XAGDEeXkInJlv2jkkp/w0VQJNbZo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=Zda0Ed1i; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=ZbOwEnvb; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=xY+i9hhx; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=ZhTGjgT3; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="Zda0Ed1i";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="ZbOwEnvb";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="xY+i9hhx";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="ZhTGjgT3"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id D357F21BA3;
	Mon, 28 Sep 2026 19:31:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1790623893; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4iT4hq2wtcM3fNuf88VBw8/khKp+sIm83YEs3yR8ZVc=;
	b=Zda0Ed1iGuaYmCHWvmkAonSaBPKN7s/Tz9/IISymOiRIU4oEWoMZ9UHZksfjB3X5e4qJXU
	Yzus2YG3F8wPxf2eS1neaDfH2juEX5SPVvcd7e96lpYDWtm36K22GYPVFvrdI+RaEVcOE4
	FtMEcYYOPM2wLT9oaSSP+wnmmZaisfw=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1790623893;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4iT4hq2wtcM3fNuf88VBw8/khKp+sIm83YEs3yR8ZVc=;
	b=ZbOwEnvbCIMIBWUn48Mny5VYJ6ABeYwKPbATdlGO/l/lQGy+gforxz1TWmx0j932qmojKm
	JDsTenFlAshxUnDg==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.de header.s=susede2_rsa header.b=xY+i9hhx;
	dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=ZhTGjgT3
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1790623888; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4iT4hq2wtcM3fNuf88VBw8/khKp+sIm83YEs3yR8ZVc=;
	b=xY+i9hhxyQ5dhKL9qZZO6ZTXNKYWvOhgvhWc/1Tj86xTiOjT4EZkLWejMfB1MtOKUsiOWr
	EfB7sBpl/Czzx5HXVbQWM+69ZSNHb/2yWN1occlX2hDr0PQyczFawfQMh40z1z1I07O9gU
	2kX6E5gegxSWOwYxNXL9MCqlsd2t0ic=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1790623888;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4iT4hq2wtcM3fNuf88VBw8/khKp+sIm83YEs3yR8ZVc=;
	b=ZhTGjgT30i70ptEOSMCyMtK/x7KzOg4VqhAmKL9PqNeh6C6KeV6kNwMyJW0EOQPYLvQSeR
	/UOEkFBcYGNHnSBw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 36FE6133F1;
	Mon, 28 Sep 2026 19:31:23 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 4RBiFn3AumpWOAAAD6G6ig:T2
	(envelope-from <fmancera@suse.de>); Mon, 28 Sep 2026 19:31:23 +0000
From: Fernando Fernandez Mancera <fmancera@suse.de>
To: netdev@vger.kernel.org
Cc: horms@kernel.org,
	kuba@kernel.org,
	pabeni@redhat.com,
	edumazet@kernel.org,
	davem@davemloft.net,
	Fernando Fernandez Mancera <fmancera@suse.de>,
	Chuck Lever <cel@kernel.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Leon Romanovsky <leon@kernel.org>,
	Zhu Yanjun <zyjzyj2000@gmail.com>,
	Andrew Lunn <andrew+netdev@lunn.ch>,
	Eric Dumazet <edumazet@google.com>,
	Tony Nguyen <anthony.l.nguyen@intel.com>,
	Przemek Kitszel <przemyslaw.kitszel@intel.com>,
	Elad Nachman <enachman@marvell.com>,
	Saeed Mahameed <saeedm@nvidia.com>,
	Tariq Toukan <tariqt@nvidia.com>,
	Mark Bloch <mbloch@nvidia.com>,
	Ido Schimmel <idosch@nvidia.com>,
	Petr Machata <petrm@nvidia.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Edward Cree <ecree.xilinx@gmail.com>,
	Maxime Chevallier <maxime.chevallier@bootlin.com>,
	Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Alexandre Torgue <alexandre.torgue@foss.st.com>,
	Arend van Spriel <arend.vanspriel@broadcom.com>,
	Miri Korenblit <miriam.rachel.korenblit@intel.com>,
	Keith Busch <kbusch@kernel.org>,
	Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@lst.de>,
	Sagi Grimberg <sagi@grimberg.me>,
	Chaitanya Kulkarni <kch@nvidia.com>,
	Varun Prakash <varun@chelsio.com>,
	"James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
	"Martin K. Petersen" <mkp@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>,
	David Howells <dhowells@redhat.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Marek Lindner <marek.lindner@mailbox.org>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <antonio@mandelbit.com>,
	Sven Eckelmann <sven@narfation.org>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	Matthieu Baerts <matttbe@kernel.org>,
	Mat Martineau <martineau@kernel.org>,
	Geliang Tang <geliang@kernel.org>,
	Julian Anastasov <ja@ssi.bg>,
	Allison Henderson <achender@kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Xin Long <lucien.xin@gmail.com>,
	Jon Maloy <jmaloy@redhat.com>,
	Tung Quang Nguyen <tung.quang.nguyen@est.tech>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Paul Moore <paul@paul-moore.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Krzysztof Kozlowski <krzk@kernel.org>,
	Qingfang Deng <qingfang.deng@linux.dev>,
	Julian Braha <julianbraha@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ethan Nelson-Moore <enelsonmoore@gmail.com>,
	Eric Biggers <ebiggers@kernel.org>,
	Ard Biesheuvel <ardb@kernel.org>,
	Kuniyuki Iwashima <kuniyu@google.com>,
	Alyssa Ross <hi@alyssa.is>,
	linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org,
	linux-net-drivers@amd.com,
	linux-stm32@st-md-mailman.stormreply.com,
	linux-arm-kernel@lists.infradead.org,
	linux-wireless@vger.kernel.org,
	brcm80211@lists.linux.dev,
	brcm80211-dev-list.pdl@broadcom.com,
	linux-nvme@lists.infradead.org,
	linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-afs@lists.infradead.org,
	linux-nfs@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org,
	bridge@lists.linux.dev,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	mptcp@lists.linux.dev,
	lvs-devel@vger.kernel.org,
	rds-devel@oss.oracle.com,
	linux-sctp@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net,
	linux-security-module@vger.kernel.org
Subject: [PATCH 01/16 net-next v2] ipv4: introduce CONFIG_IPV4 to decouple the IPv4 stack
Date: Mon, 28 Sep 2026 21:29:57 +0200
Message-ID: <20260928193046.6698-2-fmancera@suse.de>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20260928193046.6698-1-fmancera@suse.de>
References: <20260928193046.6698-1-fmancera@suse.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Spamd-Bar: /
X-Rspamd-Queue-Id: D357F21BA3
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spam-Score: 0.49
X-Spam-Level: 
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spamd-Result: default: False [0.49 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	FORGED_RECIPIENTS(2.00)[m:horms@kernel.org,m:kuba@kernel.org,m:edumazet@kernel.org,m:davem@davemloft.net,m:cel@kernel.org,m:jgg@ziepe.ca,m:leon@kernel.org,m:zyjzyj2000@gmail.com,m:edumazet@google.com,m:anthony.l.nguyen@intel.com,m:przemyslaw.kitszel@intel.com,m:ecree.xilinx@gmail.com,m:maxime.chevallier@bootlin.com,m:mcoquelin.stm32@gmail.com,m:alexandre.torgue@foss.st.com,m:arend.vanspriel@broadcom.com,m:miriam.rachel.korenblit@intel.com,m:kbusch@kernel.org,m:axboe@kernel.dk,m:sagi@grimberg.me,m:varun@chelsio.com,m:James.Bottomley@HansenPartnership.com,m:mkp@kernel.org,m:viro@zeniv.linux.org.uk,m:brauner@kernel.org,m:marc.dionne@auristor.com,m:trondmy@kernel.org,m:anna@kernel.org,m:jlayton@kernel.org,m:neil@brown.name,m:razor@blackwall.org,m:matttbe@kernel.org,m:martineau@kernel.org,m:geliang@kernel.org,m:achender@kernel.org,m:marcelo.leitner@gmail.com,m:lucien.xin@gmail.com,m:tung.quang.nguyen@est.tech,m:herbert@gondor.apana.org.au,m:serge@hallyn.com,m:krzk@kernel.org,m:qingfang.d
 eng@linux.dev,m:julianbraha@gmail.com,m:gregkh@linuxfoundation.org,m:enelsonmoore@gmail.com,m:ebiggers@kernel.org,m:ardb@kernel.org,m:kuniyu@google.com,m:hi@alyssa.is,m:linux-net-drivers@amd.com,m:brcm80211-dev-list.pdl@broadcom.com,s:mptcp@lists.linux.dev,s:tipc-discussion@lists.sourceforge.net,s:coreteam@netfilter.org,s:rds-devel@oss.oracle.com];
	SUSPICIOUS_RECIPS(1.50)[];
	MID_CONTAINS_FROM(1.00)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_MISSING_CHARSET(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	TO_DN_SOME(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	FREEMAIL_CC(0.00)[kernel.org,redhat.com,davemloft.net,suse.de,ziepe.ca,gmail.com,lunn.ch,google.com,intel.com,marvell.com,nvidia.com,resnulli.us,bootlin.com,foss.st.com,broadcom.com,kernel.dk,lst.de,grimberg.me,chelsio.com,HansenPartnership.com,zeniv.linux.org.uk,suse.cz,auristor.com,brown.name,oracle.com,talpey.com,mailbox.org,simonwunderlich.de,mandelbit.com,narfation.org,blackwall.org,netfilter.org,strlen.de,nwl.cc,ssi.bg,mojatatu.com,est.tech,secunet.com,gondor.apana.org.au,schaufler-ca.com,paul-moore.com,namei.org,hallyn.com,linux.dev,linuxfoundation.org,alyssa.is,vger.kernel.org,lists.osuosl.org,amd.com,st-md-mailman.stormreply.com,lists.infradead.org,lists.linux.dev,lists.open-mesh.org,oss.oracle.com,lists.sourceforge.net];
	RCVD_TLS_ALL(0.00)[];
	DKIM_TRACE(0.00)[suse.de:+];
	RCVD_COUNT_TWO(0.00)[2];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	TO_MATCH_ENVRCPT_SOME(0.00)[];
	TAGGED_RCPT(0.00)[netdev];
	RCPT_COUNT_GT_50(0.00)[106];
	R_RATELIMIT(0.00)[to_ip_from(RLg6d78oyz378k9c6yc3m86uey)];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:dkim,suse.de:email,suse.de:mid,imap1.dmz-prg2.suse.org:helo,imap1.dmz-prg2.suse.org:rdns]

Historically, the IPv4 protocol has been linked to the core INET
subsystem. Because shared infrastructure like the TCP/UDP engine,
routing or INET hashtables live inside net/ipv4/, it has been impossible
to compile a kernel with only IPv6 support.

This patch introduces the CONFIG_IPV4 Kconfig symbol, which is set to
'def_bool y' for now. This does not allow to completely disable the
IPv4 stack yet but it lays the necessary build-system work for that
goal.

In addition, multiple subsystems Kconfig symbols across networking
features like tunnels, drivers and filesystems have been adjusted to
depend on IPv4. Keep on mind that follow-up work is required to convert
the Kconfig symbol to bool and remove the dependency on IPv4 where it
makes sense.

Acked-by: Chuck Lever <cel@kernel.org>
Signed-off-by: Fernando Fernandez Mancera <fmancera@suse.de>
---
 drivers/infiniband/Kconfig                    |  2 +-
 drivers/infiniband/sw/rxe/Kconfig             |  2 +-
 drivers/net/Kconfig                           | 23 ++++++++++---------
 drivers/net/ethernet/chelsio/Kconfig          |  2 +-
 drivers/net/ethernet/intel/Kconfig            |  2 ++
 drivers/net/ethernet/marvell/prestera/Kconfig |  1 +
 .../net/ethernet/mellanox/mlx5/core/Kconfig   |  3 ++-
 drivers/net/ethernet/mellanox/mlxsw/Kconfig   |  1 +
 drivers/net/ethernet/qlogic/Kconfig           |  2 ++
 drivers/net/ethernet/rocker/Kconfig           |  1 +
 drivers/net/ethernet/sfc/Kconfig              |  1 +
 drivers/net/ethernet/stmicro/stmmac/Kconfig   |  1 +
 drivers/net/ethernet/via/Kconfig              |  1 +
 drivers/net/ppp/Kconfig                       |  1 +
 .../broadcom/brcm80211/brcmfmac/Kconfig       |  1 +
 drivers/net/wireless/intel/iwlwifi/Kconfig    |  1 +
 drivers/nvme/host/Kconfig                     |  2 +-
 drivers/nvme/target/Kconfig                   |  2 +-
 drivers/scsi/cxgbi/cxgb3i/Kconfig             |  2 +-
 drivers/scsi/cxgbi/cxgb4i/Kconfig             |  2 +-
 drivers/target/iscsi/Kconfig                  |  2 +-
 drivers/target/iscsi/cxgbit/Kconfig           |  2 +-
 fs/Kconfig                                    |  1 +
 fs/afs/Kconfig                                |  2 +-
 fs/nfs/Kconfig                                |  2 +-
 fs/nfsd/Kconfig                               |  2 +-
 net/Kconfig                                   | 12 ++++++----
 net/batman-adv/Kconfig                        |  6 ++---
 net/bridge/Kconfig                            |  2 +-
 net/bridge/netfilter/Kconfig                  |  3 ++-
 net/ipv4/Kconfig                              | 21 ++++++++++++++---
 net/ipv4/Makefile                             | 21 ++++++++---------
 net/ipv4/netfilter/Kconfig                    |  2 +-
 net/ipv6/Kconfig                              | 17 ++++++++++----
 net/ipv6/netfilter/Kconfig                    |  2 +-
 net/l2tp/Kconfig                              |  2 +-
 net/mptcp/Kconfig                             |  2 +-
 net/netfilter/Kconfig                         |  2 +-
 net/netfilter/ipset/Kconfig                   |  2 +-
 net/netfilter/ipvs/Kconfig                    |  2 +-
 net/rds/Kconfig                               |  1 +
 net/rxrpc/Kconfig                             |  2 +-
 net/sched/Kconfig                             |  2 +-
 net/sctp/Kconfig                              |  2 +-
 net/sunrpc/Kconfig                            |  2 +-
 net/tipc/Kconfig                              |  1 +
 net/xfrm/Kconfig                              | 10 ++++++--
 security/smack/Kconfig                        |  1 +
 48 files changed, 117 insertions(+), 64 deletions(-)

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index 086195758a8a..e9302002b6ea 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -3,7 +3,7 @@ menuconfig INFINIBAND
 	tristate "InfiniBand support"
 	depends on HAS_IOMEM && HAS_DMA
 	depends on NET
-	depends on INET
+	depends on INET && IPV4
 	depends on !ALPHA
 	select DMA_SHARED_BUFFER
 	select IRQ_POLL
diff --git a/drivers/infiniband/sw/rxe/Kconfig b/drivers/infiniband/sw/rxe/Kconfig
index 1ed5b63f8afc..e4272f863944 100644
--- a/drivers/infiniband/sw/rxe/Kconfig
+++ b/drivers/infiniband/sw/rxe/Kconfig
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 config RDMA_RXE
 	tristate "Software RDMA over Ethernet (RoCE) driver"
-	depends on INET && PCI && INFINIBAND && 64BIT
+	depends on INET && IPV4 && PCI && INFINIBAND && 64BIT
 	depends on INFINIBAND_VIRT_DMA
 	select NET_UDP_TUNNEL
 	select CRC32
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ff79c466712d..5f60c3ff182b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -40,7 +40,7 @@ if NET_CORE
 
 config BONDING
 	tristate "Bonding driver support"
-	depends on INET
+	depends on INET && IPV4
 	depends on TLS || TLS_DEVICE=n
 	help
 	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
@@ -73,7 +73,7 @@ config DUMMY
 
 config WIREGUARD
 	tristate "WireGuard secure network tunnel"
-	depends on NET && INET
+	depends on NET && INET && IPV4
 	select NET_UDP_TUNNEL
 	select DST_CACHE
 	select CRYPTO_LIB_CURVE25519
@@ -102,7 +102,7 @@ config WIREGUARD_DEBUG
 
 config OVPN
 	tristate "OpenVPN data channel offload"
-	depends on NET && INET
+	depends on NET && INET && IPV4
 	select DST_CACHE
 	select NET_UDP_TUNNEL
 	select CRYPTO
@@ -198,7 +198,7 @@ config IPVLAN_L3S
 
 config IPVLAN
 	tristate "IP-VLAN support"
-	depends on INET
+	depends on INET && IPV4
 	help
 	  This allows one to create virtual devices off of a main interface
 	  and packets will be delivered based on the dest L3 (IPv6/IPv4 addr)
@@ -229,7 +229,7 @@ config IPVTAP
 
 config VXLAN
 	tristate "Virtual eXtensible Local Area Network (VXLAN)"
-	depends on INET
+	depends on INET && IPV4
 	select NET_UDP_TUNNEL
 	select GRO_CELLS
 	help
@@ -244,7 +244,7 @@ config VXLAN
 
 config GENEVE
 	tristate "Generic Network Virtualization Encapsulation"
-	depends on INET
+	depends on INET && IPV4
 	select NET_UDP_TUNNEL
 	select GRO_CELLS
 	help
@@ -259,7 +259,7 @@ config GENEVE
 
 config BAREUDP
 	tristate "Bare UDP Encapsulation"
-	depends on INET
+	depends on INET && IPV4
 	select NET_UDP_TUNNEL
 	select GRO_CELLS
 	help
@@ -271,7 +271,7 @@ config BAREUDP
 
 config GTP
 	tristate "GPRS Tunneling Protocol datapath (GTP-U)"
-	depends on INET
+	depends on INET && IPV4
 	select NET_UDP_TUNNEL
 	help
 	  This allows one to create gtp virtual interfaces that provide
@@ -288,7 +288,7 @@ config GTP
 
 config PFCP
 	tristate "Packet Forwarding Control Protocol (PFCP)"
-	depends on INET
+	depends on INET && IPV4
 	select NET_UDP_TUNNEL
 	help
 	  This allows one to create PFCP virtual interfaces that allows to
@@ -301,7 +301,7 @@ config PFCP
 
 config AMT
 	tristate "Automatic Multicast Tunneling (AMT)"
-	depends on INET && IP_MULTICAST
+	depends on INET && IP_MULTICAST && IPV4
 	select NET_UDP_TUNNEL
 	help
 	  This allows one to create AMT(Automatic Multicast Tunneling)
@@ -471,6 +471,7 @@ config NETKIT
 
 config NET_VRF
 	tristate "Virtual Routing and Forwarding (Lite)"
+	depends on IPV4
 	depends on IP_MULTIPLE_TABLES
 	depends on NET_L3_MASTER_DEV
 	depends on IPV6_MULTIPLE_TABLES || IPV6=n
@@ -604,7 +605,7 @@ source "drivers/net/hyperv/Kconfig"
 config NETDEVSIM
 	tristate "Simulated networking device"
 	depends on DEBUG_FS
-	depends on INET
+	depends on INET && IPV4
 	depends on PSAMPLE || PSAMPLE=n
 	depends on PTP_1588_CLOCK_MOCK || PTP_1588_CLOCK_MOCK=n
 	select NET_DEVLINK
diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index 96d7779cd2f0..c738820688e0 100644
--- a/drivers/net/ethernet/chelsio/Kconfig
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -48,7 +48,7 @@ config CHELSIO_T1_1G
 
 config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
-	depends on PCI && INET
+	depends on PCI && INET && IPV4
 	select FW_LOADER
 	select MDIO
 	help
diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 780f113986ea..ce1c68e9cdf6 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -195,6 +195,7 @@ config IXGBE_IPSEC
 	bool "IPSec XFRM cryptography-offload acceleration"
 	depends on IXGBE
 	depends on XFRM_OFFLOAD
+	depends on IPV4 || !INET
 	default y
 	select XFRM_ALGO
 	help
@@ -221,6 +222,7 @@ config IXGBEVF_IPSEC
 	bool "IPSec XFRM cryptography-offload acceleration"
 	depends on IXGBEVF
 	depends on XFRM_OFFLOAD
+	depends on IPV4 || !INET
 	default y
 	select XFRM_ALGO
 	help
diff --git a/drivers/net/ethernet/marvell/prestera/Kconfig b/drivers/net/ethernet/marvell/prestera/Kconfig
index f2f7663c3d10..257afbb3c434 100644
--- a/drivers/net/ethernet/marvell/prestera/Kconfig
+++ b/drivers/net/ethernet/marvell/prestera/Kconfig
@@ -7,6 +7,7 @@ config PRESTERA
 	tristate "Marvell Prestera Switch ASICs support"
 	depends on NET_SWITCHDEV && VLAN_8021Q
 	depends on BRIDGE || BRIDGE=n
+	depends on IPV4 || !INET
 	select NET_DEVLINK
 	select PHYLINK
 	help
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 925ee25d05b4..99d998aa7e9b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -12,6 +12,7 @@ config MLX5_CORE
 	depends on PTP_1588_CLOCK_OPTIONAL
 	depends on PCI_HYPERV_INTERFACE || !PCI_HYPERV_INTERFACE
 	depends on HWMON || !HWMON
+	depends on IPV4 || !INET
 	help
 	  Core driver for low level functionality of the ConnectX-4 and
 	  Connect-IB cards by Mellanox Technologies.
@@ -28,7 +29,7 @@ config MLX5_FPGA
 
 config MLX5_CORE_EN
 	bool "Mellanox 5th generation network adapters (ConnectX series) Ethernet support"
-	depends on NETDEVICES && ETHERNET && INET && PCI && MLX5_CORE
+	depends on NETDEVICES && ETHERNET && INET && PCI && MLX5_CORE && IPV4
 	select PAGE_POOL
 	select PAGE_POOL_STATS
 	select DIMLIB
diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index 2229a2694aa5..fb3028600724 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -53,6 +53,7 @@ config MLXSW_I2C
 
 config MLXSW_SPECTRUM
 	tristate "Mellanox Technologies Spectrum family support"
+	depends on IPV4 || !INET
 	depends on MLXSW_CORE && MLXSW_PCI && NET_SWITCHDEV && VLAN_8021Q
 	depends on PSAMPLE || PSAMPLE=n
 	depends on BRIDGE || BRIDGE=n
diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index 1203353238e5..aed78311ecaf 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -29,6 +29,7 @@ config QLA3XXX
 config QLCNIC
 	tristate "QLOGIC QLCNIC 1/10Gb Converged Ethernet NIC Support"
 	depends on PCI
+	depends on IPV4 || !INET
 	select FW_LOADER
 	help
 	  This driver supports QLogic QLE8240 and QLE8242 Converged Ethernet
@@ -68,6 +69,7 @@ config QLCNIC_HWMON
 
 config NETXEN_NIC
 	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
+	depends on IPV4 || !INET
 	depends on PCI
 	select FW_LOADER
 	help
diff --git a/drivers/net/ethernet/rocker/Kconfig b/drivers/net/ethernet/rocker/Kconfig
index 2318811ff75a..2f994bd6f9bd 100644
--- a/drivers/net/ethernet/rocker/Kconfig
+++ b/drivers/net/ethernet/rocker/Kconfig
@@ -19,6 +19,7 @@ if NET_VENDOR_ROCKER
 config ROCKER
 	tristate "Rocker switch driver (EXPERIMENTAL)"
 	depends on PCI && NET_SWITCHDEV && BRIDGE
+	depends on IPV4 || !INET
 	select CRC32
 	help
 	  This driver supports Rocker switch device.
diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index e2898ec2e6e9..2bf5c2a185d2 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -18,6 +18,7 @@ if NET_VENDOR_SOLARFLARE
 
 config SFC
 	tristate "Solarflare SFC9100/EF100-family support"
+	depends on IPV4 || !INET
 	depends on PCI
 	depends on PTP_1588_CLOCK_OPTIONAL
 	select MDIO
diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index ab3c4cf96423..0b487786dad4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -1,6 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 config STMMAC_ETH
 	tristate "STMicroelectronics Multi-Gigabit Ethernet driver"
+	depends on IPV4 || !INET
 	depends on HAS_IOMEM && HAS_DMA
 	depends on PTP_1588_CLOCK_OPTIONAL
 	depends on ETHTOOL_NETLINK
diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kconfig
index 00773f5e4d7e..dbb24d35dfbd 100644
--- a/drivers/net/ethernet/via/Kconfig
+++ b/drivers/net/ethernet/via/Kconfig
@@ -45,6 +45,7 @@ config VIA_RHINE_MMIO
 
 config VIA_VELOCITY
 	tristate "VIA Velocity support"
+	depends on IPV4 || !INET
 	depends on (PCI || (OF_ADDRESS && OF_IRQ))
 	depends on HAS_DMA
 	select CRC32
diff --git a/drivers/net/ppp/Kconfig b/drivers/net/ppp/Kconfig
index 4047f13b83dc..c5200fae5e4a 100644
--- a/drivers/net/ppp/Kconfig
+++ b/drivers/net/ppp/Kconfig
@@ -160,6 +160,7 @@ config PPPOE_HASH_BITS
 
 config PPTP
 	tristate "PPP over IPv4 (PPTP)"
+	depends on IPV4 || !INET
 	depends on NET_IPGRE_DEMUX
 	select PPPOX
 	help
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Kconfig b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Kconfig
index 32794c1eca23..01a5b3310e1e 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Kconfig
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/Kconfig
@@ -1,6 +1,7 @@
 config BRCMFMAC
 	tristate "Broadcom FullMAC WLAN driver"
 	depends on CFG80211
+	depends on IPV4 || !INET
 	select BRCMUTIL
 	help
 	  This module adds support for wireless adapters based on Broadcom
diff --git a/drivers/net/wireless/intel/iwlwifi/Kconfig b/drivers/net/wireless/intel/iwlwifi/Kconfig
index 153a8368b412..3719fa0727c2 100644
--- a/drivers/net/wireless/intel/iwlwifi/Kconfig
+++ b/drivers/net/wireless/intel/iwlwifi/Kconfig
@@ -2,6 +2,7 @@
 config IWLWIFI
 	tristate "Intel Wireless WiFi Next Gen AGN - Wireless-N/Advanced-N/Ultimate-N (iwlwifi) "
 	depends on PCI && HAS_IOMEM && CFG80211
+	depends on IPV4 || !INET
 	depends on IWLMEI || !IWLMEI
 	select FW_LOADER
 	help
diff --git a/drivers/nvme/host/Kconfig b/drivers/nvme/host/Kconfig
index 31974c7dd20c..6e119cf475de 100644
--- a/drivers/nvme/host/Kconfig
+++ b/drivers/nvme/host/Kconfig
@@ -82,7 +82,7 @@ config NVME_FC
 
 config NVME_TCP
 	tristate "NVM Express over Fabrics TCP host driver"
-	depends on INET
+	depends on INET && IPV4
 	depends on BLOCK
 	select CRC32
 	select NET_CRC32C
diff --git a/drivers/nvme/target/Kconfig b/drivers/nvme/target/Kconfig
index 69bde270115e..f731a043f6a9 100644
--- a/drivers/nvme/target/Kconfig
+++ b/drivers/nvme/target/Kconfig
@@ -86,7 +86,7 @@ config NVME_TARGET_FCLOOP
 
 config NVME_TARGET_TCP
 	tristate "NVMe over Fabrics TCP target support"
-	depends on INET
+	depends on INET && IPV4
 	depends on NVME_TARGET
 	help
 	  This enables the NVMe TCP target support, which allows exporting NVMe
diff --git a/drivers/scsi/cxgbi/cxgb3i/Kconfig b/drivers/scsi/cxgbi/cxgb3i/Kconfig
index 143e881ec77e..abb4a462cb37 100644
--- a/drivers/scsi/cxgbi/cxgb3i/Kconfig
+++ b/drivers/scsi/cxgbi/cxgb3i/Kconfig
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 config SCSI_CXGB3_ISCSI
 	tristate "Chelsio T3 iSCSI support"
-	depends on PCI && INET
+	depends on PCI && INET && IPV4
 	select NETDEVICES
 	select ETHERNET
 	select NET_VENDOR_CHELSIO
diff --git a/drivers/scsi/cxgbi/cxgb4i/Kconfig b/drivers/scsi/cxgbi/cxgb4i/Kconfig
index dd1c8ff36b00..04b3e7b053dc 100644
--- a/drivers/scsi/cxgbi/cxgb4i/Kconfig
+++ b/drivers/scsi/cxgbi/cxgb4i/Kconfig
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 config SCSI_CXGB4_ISCSI
 	tristate "Chelsio T4 iSCSI support"
-	depends on PCI && INET
+	depends on PCI && INET && IPV4
 	depends on PTP_1588_CLOCK_OPTIONAL
 	depends on THERMAL || !THERMAL
 	depends on ETHERNET
diff --git a/drivers/target/iscsi/Kconfig b/drivers/target/iscsi/Kconfig
index 70d76f3dd693..362edff80c15 100644
--- a/drivers/target/iscsi/Kconfig
+++ b/drivers/target/iscsi/Kconfig
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 config ISCSI_TARGET
 	tristate "SCSI Target Mode Stack"
-	depends on INET
+	depends on INET && IPV4
 	select CRC32
 	select CRYPTO
 	select CRYPTO_HASH
diff --git a/drivers/target/iscsi/cxgbit/Kconfig b/drivers/target/iscsi/cxgbit/Kconfig
index bdeefa75f29e..7a2e585d76d7 100644
--- a/drivers/target/iscsi/cxgbit/Kconfig
+++ b/drivers/target/iscsi/cxgbit/Kconfig
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 config ISCSI_TARGET_CXGB4
 	tristate "Chelsio iSCSI target offload driver"
-	depends on ISCSI_TARGET && CHELSIO_T4 && INET
+	depends on ISCSI_TARGET && CHELSIO_T4 && INET && IPV4
 	select CHELSIO_LIB
 	help
 	To compile this driver as module, choose M here: the module
diff --git a/fs/Kconfig b/fs/Kconfig
index e05917adcd60..2f492fa3a3fb 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -358,6 +358,7 @@ config GRACE_PERIOD
 
 config LOCKD
 	tristate
+	depends on IPV4 || !INET
 	depends on FILE_LOCKING
 	select CRC32
 	select GRACE_PERIOD
diff --git a/fs/afs/Kconfig b/fs/afs/Kconfig
index 682bd8ec2c10..e7ed46426f81 100644
--- a/fs/afs/Kconfig
+++ b/fs/afs/Kconfig
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 config AFS_FS
 	tristate "Andrew File System support (AFS)"
-	depends on INET
+	depends on INET && IPV4
 	select AF_RXRPC
 	select DNS_RESOLVER
 	select NETFS_SUPPORT
diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 6bb30543eff0..52efd3664d21 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 config NFS_FS
 	tristate "NFS client support"
-	depends on INET && FILE_LOCKING && MULTIUSER
+	depends on INET && FILE_LOCKING && MULTIUSER && IPV4
 	select CRC32
 	select LOCKD
 	select SUNRPC
diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index ffb76761d6a8..153a9918214d 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 config NFSD
 	tristate "NFS server support"
-	depends on INET
+	depends on INET && IPV4
 	depends on FILE_LOCKING
 	depends on FSNOTIFY
 	select CRC32
diff --git a/net/Kconfig b/net/Kconfig
index 76ab44aa439a..ca86f20540dd 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -135,9 +135,12 @@ config INET
 if INET
 source "net/ipv4/Kconfig"
 source "net/ipv6/Kconfig"
-source "net/netlabel/Kconfig"
 source "net/mptcp/Kconfig"
 
+if IPV4
+source "net/netlabel/Kconfig"
+endif # if IPV4
+
 endif # if INET
 
 config NETWORK_SECMARK
@@ -232,6 +235,7 @@ config BRIDGE_NETFILTER
 	depends on BRIDGE
 	depends on NETFILTER && INET
 	depends on NETFILTER_ADVANCED
+	depends on IPV4
 	select NETFILTER_FAMILY_BRIDGE
 	select SKB_EXTENSIONS
 	help
@@ -384,7 +388,7 @@ menu "Network testing"
 
 config NET_PKTGEN
 	tristate "Packet Generator (USE WITH CAUTION)"
-	depends on INET && PROC_FS
+	depends on INET && IPV4 && PROC_FS
 	help
 	  This module will inject preconfigured packets, at a configurable
 	  rate, out of a given interface.  It is used for network interface
@@ -451,7 +455,7 @@ config LWTUNNEL
 
 config LWTUNNEL_BPF
 	bool "Execute BPF program as route nexthop action"
-	depends on LWTUNNEL && INET
+	depends on LWTUNNEL && INET && IPV4
 	default y if LWTUNNEL=y
 	help
 	  Allows to run BPF programs as a nexthop action following a route
@@ -473,7 +477,7 @@ config NET_IEEE8021Q_HELPERS
 
 config NET_SELFTESTS
 	def_tristate PHYLIB
-	depends on PHYLIB && INET
+	depends on PHYLIB && INET && IPV4
 
 config NET_SOCK_MSG
 	bool
diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index 58c408b7a7d9..5c66122c137c 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -33,7 +33,7 @@ config BATMAN_ADV_BATMAN_V
 
 config BATMAN_ADV_BLA
 	bool "Bridge Loop Avoidance"
-	depends on BATMAN_ADV && INET
+	depends on BATMAN_ADV && INET && IPV4
 	select CRC16
 	select NET_CRC32C
 	default y
@@ -46,7 +46,7 @@ config BATMAN_ADV_BLA
 
 config BATMAN_ADV_DAT
 	bool "Distributed ARP Table"
-	depends on BATMAN_ADV && INET
+	depends on BATMAN_ADV && INET && IPV4
 	default y
 	help
 	  This option enables DAT (Distributed ARP Table), a DHT based
@@ -56,7 +56,7 @@ config BATMAN_ADV_DAT
 
 config BATMAN_ADV_MCAST
 	bool "Multicast optimisation"
-	depends on BATMAN_ADV && INET && !(BRIDGE=m && BATMAN_ADV=y)
+	depends on BATMAN_ADV && INET && !(BRIDGE=m && BATMAN_ADV=y) && IPV4
 	default y
 	help
 	  This option enables the multicast optimisation which aims to
diff --git a/net/bridge/Kconfig b/net/bridge/Kconfig
index 318715c8fc9b..c7737d3ebac8 100644
--- a/net/bridge/Kconfig
+++ b/net/bridge/Kconfig
@@ -36,7 +36,7 @@ config BRIDGE
 config BRIDGE_IGMP_SNOOPING
 	bool "IGMP/MLD snooping"
 	depends on BRIDGE
-	depends on INET
+	depends on INET && IPV4
 	default y
 	help
 	  If you say Y here, then the Ethernet bridge will be able selectively
diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
index 4fd5a6ea26b4..31e388ce503f 100644
--- a/net/bridge/netfilter/Kconfig
+++ b/net/bridge/netfilter/Kconfig
@@ -28,6 +28,7 @@ endif # NF_TABLES_BRIDGE
 config NF_CONNTRACK_BRIDGE
 	tristate "IPv4/IPV6 bridge connection tracking support"
 	depends on NF_CONNTRACK
+	depends on IPV4 || !INET
 	default n
 	help
 	  Connection tracking keeps a record of what packets have passed
@@ -188,7 +189,7 @@ config BRIDGE_EBT_VLAN
 #
 config BRIDGE_EBT_ARPREPLY
 	tristate "ebt: arp reply target support"
-	depends on BRIDGE_NF_EBTABLES && INET
+	depends on BRIDGE_NF_EBTABLES && INET && IPV4
 	help
 	  This option adds the arp reply target, which allows
 	  automatically sending arp replies to arp requests.
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 301b47660305..51bf05d9770c 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -2,6 +2,9 @@
 #
 # IP configuration
 #
+config IPV4
+	def_bool y
+
 config IP_MULTICAST
 	bool "IP: multicasting"
 	help
@@ -62,7 +65,7 @@ config IP_FIB_TRIE_STATS
 
 config IP_MULTIPLE_TABLES
 	bool "IP: policy routing"
-	depends on IP_ADVANCED_ROUTER
+	depends on IPV4 && IP_ADVANCED_ROUTER
 	select FIB_RULES
 	help
 	  Normally, a router decides what to do with a received packet based
@@ -105,6 +108,7 @@ config IP_ROUTE_CLASSID
 
 config IP_PNP
 	bool "IP: kernel level autoconfiguration"
+	depends on IPV4
 	help
 	  This enables automatic configuration of IP addresses of devices and
 	  of the routing table during kernel boot, based on either information
@@ -161,6 +165,7 @@ config IP_PNP_RARP
 
 config NET_IPIP
 	tristate "IP: tunneling"
+	depends on IPV4
 	select INET_TUNNEL
 	select NET_IP_TUNNEL
 	help
@@ -185,12 +190,14 @@ config NET_IPGRE_DEMUX
 
 config NET_IP_TUNNEL
 	tristate
+	depends on IPV4
 	select DST_CACHE
 	select GRO_CELLS
 	default n
 
 config NET_IPGRE
 	tristate "IP: GRE tunnels over IP"
+	depends on IPV4
 	depends on NET_IPGRE_DEMUX
 	select NET_IP_TUNNEL
 	help
@@ -219,7 +226,7 @@ config IP_MROUTE_COMMON
 
 config IP_MROUTE
 	bool "IP: multicast routing"
-	depends on IP_MULTICAST
+	depends on IP_MULTICAST && IPV4
 	select IP_MROUTE_COMMON
 	help
 	  This is used if you want your machine to act as a router for IP
@@ -267,6 +274,7 @@ config IP_PIMSM_V2
 
 config SYN_COOKIES
 	bool "IP: TCP syncookie support"
+	depends on IPV4
 	help
 	  Normal TCP/IP networking is open to an attack known as "SYN
 	  flooding". This denial-of-service attack prevents legitimate remote
@@ -303,6 +311,7 @@ config SYN_COOKIES
 
 config NET_IPVTI
 	tristate "Virtual (secure) IP: tunneling"
+	depends on IPV4
 	select INET_TUNNEL
 	select NET_IP_TUNNEL
 	select XFRM
@@ -315,11 +324,13 @@ config NET_IPVTI
 
 config NET_UDP_TUNNEL
 	tristate
+	depends on IPV4
 	select NET_IP_TUNNEL
 	default n
 
 config NET_FOU
 	tristate "IP: Foo (IP protocols) over UDP"
+	depends on IPV4
 	select NET_UDP_TUNNEL
 	help
 	  Foo over UDP allows any IP protocol to be directly encapsulated
@@ -338,6 +349,7 @@ config NET_FOU_IP_TUNNELS
 
 config INET_AH
 	tristate "IP: AH transformation"
+	depends on IPV4
 	select XFRM_AH
 	help
 	  Support for IPsec AH (Authentication Header).
@@ -353,6 +365,7 @@ config INET_AH
 
 config INET_ESP
 	tristate "IP: ESP transformation"
+	depends on IPV4
 	select XFRM_ESP
 	help
 	  Support for IPsec ESP (Encapsulating Security Payload).
@@ -393,6 +406,7 @@ config INET_ESPINTCP
 
 config INET_IPCOMP
 	tristate "IP: IPComp transformation"
+	depends on IPV4
 	select INET_XFRM_TUNNEL
 	select XFRM_IPCOMP
 	help
@@ -747,7 +761,7 @@ config TCP_AO
 	select CRYPTO_LIB_SHA1
 	select CRYPTO_LIB_SHA256
 	select CRYPTO_LIB_UTILS
-	depends on 64BIT # seq-number extension needs WRITE_ONCE(u64)
+	depends on IPV4 && 64BIT # seq-number extension needs WRITE_ONCE(u64)
 	help
 	  TCP-AO specifies the use of stronger Message Authentication Codes (MACs),
 	  protects against replays for long-lived TCP connections, and
@@ -758,6 +772,7 @@ config TCP_AO
 
 config TCP_MD5SIG
 	bool "TCP: MD5 Signature Option support (RFC2385)"
+	depends on IPV4
 	select CRYPTO_LIB_MD5
 	select CRYPTO_LIB_UTILS
 	help
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 06e21c26b76f..8b148be79fa4 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -3,18 +3,17 @@
 # Makefile for the Linux TCP/IP (INET) layer.
 #
 
-obj-y     := route.o inetpeer.o protocol.o \
-	     ip_input.o ip_fragment.o ip_forward.o ip_options.o \
-	     ip_output.o ip_sockglue.o inet_hashtables.o \
-	     inet_timewait_sock.o inet_connection_sock.o \
-	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
+obj-y     := inetpeer.o protocol.o inet_hashtables.o inet_timewait_sock.o \
+	     inet_connection_sock.o tcp.o tcp_input.o tcp_output.o tcp_timer.o \
 	     tcp_minisocks.o tcp_cong.o tcp_metrics.o tcp_fastopen.o \
-	     tcp_recovery.o tcp_ulp.o \
-	     tcp_offload.o tcp_plb.o datagram.o raw.o udp.o \
-	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
-	     fib_frontend.o fib_semantics.o fib_trie.o fib_notifier.o \
-	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o \
-	     metrics.o netlink.o nexthop.o udp_tunnel_stub.o
+	     tcp_recovery.o tcp_ulp.o tcp_offload.o tcp_plb.o raw.o udp.o \
+	     udp_offload.o af_inet.o inet_fragment.o ping.o ip_tunnel_core.o \
+	     gre_offload.o metrics.o netlink.o nexthop.o udp_tunnel_stub.o
+
+obj-$(CONFIG_IPV4) += route.o ip_input.o ip_fragment.o ip_forward.o ip_options.o \
+		      ip_sockglue.o tcp_ipv4.o datagram.o icmp.o arp.o devinet.o \
+		      igmp.o fib_notifier.o ip_output.o fib_frontend.o \
+		      fib_semantics.o fib_trie.o
 
 obj-$(CONFIG_NET_IP_TUNNEL) += ip_tunnel.o
 obj-$(CONFIG_SYSCTL) += sysctl_net_ipv4.o
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 7dc9772fe2d8..ab4fa6a6d453 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -4,7 +4,7 @@
 #
 
 menu "IP: Netfilter Configuration"
-	depends on INET && NETFILTER
+	depends on INET && NETFILTER && IPV4
 
 config NF_DEFRAG_IPV4
 	tristate
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index c3806c6ac96f..f83efc1505cc 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -47,6 +47,7 @@ config IPV6_OPTIMISTIC_DAD
 config INET6_AH
 	tristate "IPv6: AH transformation"
 	select XFRM_AH
+	depends on IPV4
 	help
 	  Support for IPsec AH (Authentication Header).
 
@@ -61,6 +62,7 @@ config INET6_AH
 
 config INET6_ESP
 	tristate "IPv6: ESP transformation"
+	depends on IPV4
 	select XFRM_ESP
 	help
 	  Support for IPsec ESP (Encapsulating Security Payload).
@@ -101,6 +103,7 @@ config INET6_ESPINTCP
 
 config INET6_IPCOMP
 	tristate "IPv6: IPComp transformation"
+	depends on IPV4
 	select INET6_XFRM_TUNNEL
 	select XFRM_IPCOMP
 	help
@@ -111,6 +114,7 @@ config INET6_IPCOMP
 
 config IPV6_MIP6
 	tristate "IPv6: Mobility"
+	depends on IPV4
 	select XFRM
 	help
 	  Support for IPv6 Mobility described in RFC 3775.
@@ -119,6 +123,7 @@ config IPV6_MIP6
 
 config IPV6_ILA
 	tristate "IPv6: Identifier Locator Addressing (ILA)"
+	depends on IPV4
 	depends on NETFILTER
 	select DST_CACHE
 	select LWTUNNEL
@@ -149,6 +154,7 @@ config INET6_TUNNEL
 
 config IPV6_VTI
 	tristate "Virtual (secure) IPv6: tunneling"
+	depends on IPV4
 	select IPV6_TUNNEL
 	select NET_IP_TUNNEL
 	select XFRM
@@ -161,6 +167,7 @@ config IPV6_VTI
 
 config IPV6_SIT
 	tristate "IPv6: IPv6-in-IPv4 tunnel (SIT driver)"
+	depends on IPV4
 	select INET_TUNNEL
 	select NET_IP_TUNNEL
 	select IPV6_NDISC_NODETYPE
@@ -198,6 +205,7 @@ config IPV6_NDISC_NODETYPE
 
 config IPV6_TUNNEL
 	tristate "IPv6: IP-in-IPv6 tunnel (RFC2473)"
+	depends on IPV4
 	select INET6_TUNNEL
 	select DST_CACHE
 	select GRO_CELLS
@@ -209,6 +217,7 @@ config IPV6_TUNNEL
 
 config IPV6_GRE
 	tristate "IPv6: GRE tunnel"
+	depends on IPV4
 	select IPV6_TUNNEL
 	select NET_IP_TUNNEL
 	depends on NET_IPGRE_DEMUX
@@ -256,7 +265,7 @@ config IPV6_SUBTREES
 
 config IPV6_MROUTE
 	bool "IPv6: multicast routing"
-	depends on IPV6
+	depends on IPV4 && IPV6
 	select IP_MROUTE_COMMON
 	help
 	  Support for IPv6 multicast forwarding.
@@ -285,7 +294,7 @@ config IPV6_PIMSM_V2
 
 config IPV6_SEG6_LWTUNNEL
 	bool "IPv6: Segment Routing Header encapsulation support"
-	depends on IPV6
+	depends on IPV4 && IPV6
 	select LWTUNNEL
 	select DST_CACHE
 	select IPV6_MULTIPLE_TABLES
@@ -316,7 +325,7 @@ config IPV6_SEG6_BPF
 
 config IPV6_RPL_LWTUNNEL
 	bool "IPv6: RPL Source Routing Header support"
-	depends on IPV6
+	depends on IPV4 && IPV6
 	select LWTUNNEL
 	select DST_CACHE
 	help
@@ -327,7 +336,7 @@ config IPV6_RPL_LWTUNNEL
 
 config IPV6_IOAM6_LWTUNNEL
 	bool "IPv6: IOAM Pre-allocated Trace insertion support"
-	depends on IPV6
+	depends on IPV4 && IPV6
 	select LWTUNNEL
 	select DST_CACHE
 	help
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 81daf82ddc2d..f99a2176bf3d 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -4,7 +4,7 @@
 #
 
 menu "IPv6: Netfilter Configuration"
-	depends on INET && IPV6 && NETFILTER
+	depends on INET && IPV6 && NETFILTER && IPV4
 
 # old sockopt interface and eval loop
 config IP6_NF_IPTABLES_LEGACY
diff --git a/net/l2tp/Kconfig b/net/l2tp/Kconfig
index 0de178d5baba..e92cf6d94135 100644
--- a/net/l2tp/Kconfig
+++ b/net/l2tp/Kconfig
@@ -5,7 +5,7 @@
 
 menuconfig L2TP
 	tristate "Layer Two Tunneling Protocol (L2TP)"
-	depends on INET
+	depends on INET && IPV4
 	select NET_UDP_TUNNEL
 	help
 	  Layer Two Tunneling Protocol
diff --git a/net/mptcp/Kconfig b/net/mptcp/Kconfig
index be71fc9b4638..c5b660fdda4c 100644
--- a/net/mptcp/Kconfig
+++ b/net/mptcp/Kconfig
@@ -1,7 +1,7 @@
 
 config MPTCP
 	bool "MPTCP: Multipath TCP"
-	depends on INET
+	depends on INET && IPV4
 	select SKB_EXTENSIONS
 	select CRYPTO_LIB_SHA256
 	select CRYPTO_LIB_UTILS
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 09874c26fd13..857af95fbb48 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -1,6 +1,6 @@
 # SPDX-License-Identifier: GPL-2.0-only
 menu "Core Netfilter Configuration"
-	depends on INET && NETFILTER
+	depends on INET && IPV4 && NETFILTER
 
 config NETFILTER_INGRESS
 	bool "Netfilter ingress support"
diff --git a/net/netfilter/ipset/Kconfig b/net/netfilter/ipset/Kconfig
index 6c4d54758106..e6537c842a45 100644
--- a/net/netfilter/ipset/Kconfig
+++ b/net/netfilter/ipset/Kconfig
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 menuconfig IP_SET
 	tristate "IP set support"
-	depends on INET && NETFILTER
+	depends on INET && IPV4 && NETFILTER
 	select NETFILTER_NETLINK
 	help
 	  This option adds IP set support to the kernel.
diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 7724cb44e6de..fb09218d84d0 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -4,7 +4,7 @@
 #
 menuconfig IP_VS
 	tristate "IP virtual server support"
-	depends on INET && NETFILTER
+	depends on INET && NETFILTER && IPV4
 	depends on (NF_CONNTRACK || NF_CONNTRACK=n)
 	help
 	  IP Virtual Server support will let you build a high-performance
diff --git a/net/rds/Kconfig b/net/rds/Kconfig
index f007730aa2bb..af5632b37dd7 100644
--- a/net/rds/Kconfig
+++ b/net/rds/Kconfig
@@ -17,6 +17,7 @@ config RDS_RDMA
 config RDS_TCP
 	tristate "RDS over TCP"
 	depends on RDS
+	depends on IPV4
 	depends on IPV6 || !IPV6
 	help
 	  Allow RDS to use TCP as a transport.
diff --git a/net/rxrpc/Kconfig b/net/rxrpc/Kconfig
index 2cebb666dc07..2029d2d1065f 100644
--- a/net/rxrpc/Kconfig
+++ b/net/rxrpc/Kconfig
@@ -5,7 +5,7 @@
 
 config AF_RXRPC
 	tristate "RxRPC session sockets"
-	depends on INET
+	depends on INET && IPV4
 	select CRYPTO
 	select CRYPTO_LIB_DES if RXKAD
 	select KEYS
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 6ddff028b81a..bb782822c3fb 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -807,7 +807,7 @@ config NET_ACT_SKBEDIT
 
 config NET_ACT_CSUM
 	tristate "Checksum Updating"
-	depends on NET_CLS_ACT && INET
+	depends on NET_CLS_ACT && INET && IPV4
 	select NET_CRC32C
 	help
 	  Say Y here to update some common checksum after some direct
diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
index fc989a3791b3..eb3e2bf1ec3a 100644
--- a/net/sctp/Kconfig
+++ b/net/sctp/Kconfig
@@ -5,7 +5,7 @@
 
 menuconfig IP_SCTP
 	tristate "The SCTP Protocol"
-	depends on INET
+	depends on INET && IPV4
 	select CRYPTO_LIB_SHA1
 	select CRYPTO_LIB_SHA256
 	select CRYPTO_LIB_UTILS
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index e7808e5714dc..58e6f6db3100 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 config SUNRPC
 	tristate
-	depends on MULTIUSER
+	depends on MULTIUSER && IPV4
 
 config SUNRPC_GSS
 	tristate
diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index 18f62135e47b..2db479597c79 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -30,6 +30,7 @@ config TIPC_MEDIA_IB
 config TIPC_MEDIA_UDP
 	bool "IP/UDP media type support"
 	depends on TIPC
+	depends on IPV4
 	select NET_UDP_TUNNEL
 	default y
 	help
diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 4a62817a88f8..203188b05be4 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -4,7 +4,7 @@
 #
 config XFRM
 	bool
-	depends on INET
+	depends on INET && IPV4
 	select GRO_CELLS
 	select SKB_EXTENSIONS
 
@@ -13,6 +13,7 @@ config XFRM_OFFLOAD
 
 config XFRM_ALGO
 	tristate
+	depends on IPV4
 	select XFRM
 	select CRYPTO
 	select CRYPTO_AEAD
@@ -23,6 +24,7 @@ if INET
 config XFRM_USER
 	tristate "Transformation user configuration interface"
 	select XFRM_ALGO
+	depends on IPV4
 	help
 	  Support for Transformation(XFRM) user configuration interface
 	  like IPsec used by native Linux tools.
@@ -42,7 +44,7 @@ config XFRM_USER_COMPAT
 
 config XFRM_INTERFACE
 	tristate "Transformation virtual interface"
-	depends on XFRM && IPV6
+	depends on XFRM && IPV4 && IPV6
 	help
 	  This provides a virtual interface to route IPsec traffic.
 
@@ -83,6 +85,7 @@ config XFRM_STATISTICS
 # RFC 8221 lists as MUST be implemented.
 config XFRM_AH
 	tristate
+	depends on IPV4
 	select XFRM_ALGO
 	select CRYPTO
 	select CRYPTO_HMAC
@@ -92,6 +95,7 @@ config XFRM_AH
 # algorithms that RFC 8221 lists as MUST be implemented.
 config XFRM_ESP
 	tristate
+	depends on IPV4
 	select XFRM_ALGO
 	select CRYPTO
 	select CRYPTO_AES
@@ -105,12 +109,14 @@ config XFRM_ESP
 
 config XFRM_IPCOMP
 	tristate
+	depends on IPV4
 	select XFRM_ALGO
 	select CRYPTO
 	select CRYPTO_DEFLATE
 
 config NET_KEY
 	tristate "PF_KEY sockets (deprecated)"
+	depends on IPV4
 	select XFRM_ALGO
 	help
 	  PF_KEYv2 socket family, compatible to KAME ones.
diff --git a/security/smack/Kconfig b/security/smack/Kconfig
index 5a8dfad469c3..b4e6d0168bd1 100644
--- a/security/smack/Kconfig
+++ b/security/smack/Kconfig
@@ -3,6 +3,7 @@ config SECURITY_SMACK
 	bool "Simplified Mandatory Access Control Kernel Support"
 	depends on NET
 	depends on INET
+	depends on IPV4
 	depends on SECURITY
 	select NETLABEL
 	select SECURITY_NETWORK
-- 
2.55.0

