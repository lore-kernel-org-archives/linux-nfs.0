Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=131.169.56.155
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793866951;
	b=GtIK+VwrDth5PZberp0WjKhhyw2gCYtlWw6ZcMQnSYzSjDeEzwL0Y/YvkIx6XaVUmQPg
	 37riSKSIlnBoR5emYuFgUKX7PLjTyOJLrfxYFEhr02MbJ4Zb1ObMAYdLU3SMW36h7wtAG
	 6DskAaWe9qnCzX7pq60ZueD5PPpc3Uhchx7IRHi8/wcvM8AEaasAg6tlK5iapkpNh6IEw
	 +HAhNSIQ9O8l3n3KdDQgyPwlIKF+4jus9a9t+GGXUjKCPNr5DcfPMbSwRMW+rVZcdfI6B
	 dB3CSZk08TySkw/8GOVnNvhybSi5girekLe15yGAvnF9TEh0niHDurITrDXXOCN3tWQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793866951;
	h=DMARC-Filter:Received:DKIM-Filter:DKIM-Signature:Received:Received:
	 Received:Received:Date:From:To:Cc:Message-ID:In-Reply-To:References:
	 Subject:MIME-Version:Content-Type:X-Mailer:
	 X-Zimbra-Message-Verification:Thread-Topic:Thread-Index;
	bh=pPBNsWJaGKLJHgpHoEtDW2d/S6xc52mE7dETJuWlm9Q=;
	b=mXWr6xdn8M7kiczn4/RSO1KyCRjtfkgzUd5QXRSmS+dlgktIBB3OyeDmVoWMs0fPcuAF
	 yV6+6SGnC81tFhBMTebM4ZRvAIGasnZ8F2JB1lSkQpVfW8bZUXtW9Alk3koXCfo1uzG1b
	 LBwwwxnpS9KwrnIz+16NFmlIKiriwrSwXqNDaoPGC+n83T7NnqRk6VKjZgtMtT9fQzYwR
	 PE6Vna/ez39UsUFe05cf2Oal1j8GWG020PKLEirOdYzi6guMp/eV07u4wtkFL+63gSZGP
	 Op85Xj0RDMbR9W/5gdSthLwu1VppbmOcfo66/3OsCf3Ht71WyRkJinP88i126pIZV2g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=desy.de;
	spf=pass smtp.mailfrom=desy.de;
	dkim=pass header.d=desy.de header.i=@desy.de header.a=rsa-sha256 header.s=default header.b="efy2r/bU";
	arc=none smtp.remote-ip=131.169.56.155
Received: from smtp-o-2.desy.de (smtp-o-2.desy.de [131.169.56.155])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3FF3606A32F
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 08:22:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C3FF3606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=desy.de header.i=@desy.de header.a=rsa-sha256 header.s=default header.b=efy2r/bU
Received: from smtp-buf-2.desy.de (smtp-buf-2.desy.de [IPv6:2001:638:700:1038::1:a5])
	by smtp-o-2.desy.de (Postfix) with ESMTP id 1AF7C13F651
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 09:22:22 +0100 (CET)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-2.desy.de 1AF7C13F651
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1793866942; bh=pPBNsWJaGKLJHgpHoEtDW2d/S6xc52mE7dETJuWlm9Q=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=efy2r/bUNMnfvHO8umKKyfoD0GYSmMfd6FefRagFTknkLBDmUd380fcV6m6zo/fg5
	 CFviDJ9D6uxyNFli0ShNXEg5CG+KeU8vbq/6ZY4b3sqF6h7yiy5V1iB2M3FphtZ2dX
	 g39+gpcckfkkFKi4Vzod5TteDfFa6mFFyrAE129w=
Received: from smtp-m-1.desy.de (smtp-m-1.desy.de [IPv6:2001:638:700:1038::1:81])
	by smtp-buf-2.desy.de (Postfix) with ESMTP id 0A001120043;
	Thu,  5 Nov 2026 09:22:22 +0100 (CET)
Received: from c1722.mx.srv.dfn.de (c1722.mx.srv.dfn.de [194.95.239.47])
	by smtp-m-1.desy.de (Postfix) with ESMTP id EE27540045;
	Thu,  5 Nov 2026 09:22:21 +0100 (CET)
Received: from smtp-intra-3.desy.de (smtp-intra-3.desy.de [IPv6:2001:638:700:1038::1:45])
	by c1722.mx.srv.dfn.de (Postfix) with ESMTP id BF0AE10003E;
	Thu, 05 Nov 2026 09:22:20 +0100 (CET)
Received: from z-mbx-3.desy.de (z-mbx-3.desy.de [131.169.55.141])
	by smtp-intra-3.desy.de (Postfix) with ESMTP id 8013D1A0048;
	Thu,  5 Nov 2026 09:22:20 +0100 (CET)
Date: Thu, 5 Nov 2026 09:22:20 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Roberto Bergantinos Corpas <rbergant@redhat.com>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>, 
	Anna Schumaker <anna.schumaker@hammerspace.com>, 
	linux-nfs <linux-nfs@vger.kernel.org>, 
	Mike Snitzer <snitzer@kernel.org>, 
	Benjamin Coddington <ben.coddington@hammerspace.com>, 
	Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
Message-ID: <2054463495.18023214.1793866940338.JavaMail.zimbra@desy.de>
In-Reply-To: <20261104112505.2495943-1-rbergant@redhat.com>
References: <20261104112505.2495943-1-rbergant@redhat.com>
Subject: Re: [PATCH] NFSv4/flexfiles: couple back with NFSv3
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; 
	boundary="----=_Part_18023215_1165998336.1793866940463"
X-Mailer: Zimbra 10.1.21_GA_4899 (ZimbraWebClient - FF159 (Linux)/10.1.21_GA_4899)
X-Zimbra-Message-Verification: hash=SHA256;guid=MTViYjUxY2FkNzgwMWIwMDI3MWM1MzcwNzMyMDNjY2IyODcxMDAzNDY5MzVhNGQzYWUyMDVlZjU4OTQ5ZTgxNA==
Thread-Topic: NFSv4/flexfiles: couple back with NFSv3
Thread-Index: JgWAXagkEBlsHxI2WFKeJ9Ilb0LvQQ==

------=_Part_18023215_1165998336.1793866940463
Date: Thu, 5 Nov 2026 09:22:20 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Roberto Bergantinos Corpas <rbergant@redhat.com>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>, 
	Anna Schumaker <anna.schumaker@hammerspace.com>, 
	linux-nfs <linux-nfs@vger.kernel.org>, 
	Mike Snitzer <snitzer@kernel.org>, 
	Benjamin Coddington <ben.coddington@hammerspace.com>, 
	Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
Message-ID: <2054463495.18023214.1793866940338.JavaMail.zimbra@desy.de>
In-Reply-To: <20261104112505.2495943-1-rbergant@redhat.com>
References: <20261104112505.2495943-1-rbergant@redhat.com>
Subject: Re: [PATCH] NFSv4/flexfiles: couple back with NFSv3
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Mailer: Zimbra 10.1.21_GA_4899 (ZimbraWebClient - FF159 (Linux)/10.1.21_GA_4899)
X-Zimbra-Message-Verification: hash=SHA256;guid=MTViYjUxY2FkNzgwMWIwMDI3MWM1MzcwNzMyMDNjY2IyODcxMDAzNDY5MzVhNGQzYWUyMDVlZjU4OTQ5ZTgxNA==
Thread-Topic: NFSv4/flexfiles: couple back with NFSv3
Thread-Index: JgWAXagkEBlsHxI2WFKeJ9Ilb0LvQQ==



----- Original Message -----
> From: "Roberto Bergantinos Corpas" <rbergant@redhat.com>
> To: "Trond Myklebust" <trond.myklebust@hammerspace.com>, "Anna Schumaker" <anna.schumaker@hammerspace.com>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>, "Mike Snitzer" <snitzer@kernel.org>, "Benjamin Coddington"
> <ben.coddington@hammerspace.com>, "Antonio Alvarez Feijoo" <antonio.feijoo@suse.com>, "Tigran Mkrtchyan"
> <tigran.mkrtchyan@desy.de>
> Sent: Wednesday, 4 November, 2026 12:25:05
> Subject: [PATCH] NFSv4/flexfiles: couple back with NFSv3

> Commit 7a375cafc14e ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS on
> fatal DS connect errors") uncovered an unexpected issue, EPROTONOSUPPORT
> from a missing nfsv3 module during pNFS flexfiles I/O operation turned a
> harmless WARN + fallback to MDS into a forever retry op.
> 
> Flexfiles is decoupled from NFSv3 after commit a68c6fbb638a ("nfs41:
> drop dependency between flexfiles layout driver and NFSv3 modules"),
> so we trusted on legacy symbol_request(nfs3_set_ds_client) ->
> request_module at runtime to load NFSv3 module in case it's not loaded.
> 
> However this approach has some problematic scenarios, an unprivileged
> container may be denied by SELinux policy to load nfsv3 module, leading
> to writeback hang, other scenario is boot hang on NFSv4 root mounted
> hosts, where we get deadlocked trying to fetch from the filesystem the
> usermode helpers necessary for request_module to proceed.
> 
> So, couple back NFSv3 with flexfiles to make sure both are loaded on i.e.
> mount time, and remove the scaffolding associated with symbol_request()
> mechanism now that we have a hard dependency on the code with
> nfs3_set_ds_client.
> 
> Fixes: 7a375cafc14e ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS on fatal DS
> connect errors")
> Based-on-patch-by: Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
> Suggested-by: Benjamin Coddington <ben.coddington@hammerspace.com>
> Assisted-by: Claude Opus 4.6 <noreply@anthropic.com>
> Signed-off-by: Roberto Bergantinos Corpas <rbergant@redhat.com>
> ---
> fs/nfs/Kconfig     |  2 +-
> fs/nfs/nfs4super.c |  3 ---
> fs/nfs/pnfs.h      |  5 -----
> fs/nfs/pnfs_nfs.c  | 34 ++--------------------------------
> 4 files changed, 3 insertions(+), 41 deletions(-)
> 
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index fd430718d02b..b693f573c2ba 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -143,7 +143,7 @@ config PNFS_SCSI_LAYOUT
> 
> config PNFS_FLEXFILE_LAYOUT
> 	tristate
> -	depends on NFS_V4
> +	depends on NFS_V4 && NFS_V3

or maybe

  select NFS_V3

To enforce nfs3 to be built, if flexfiles layout type is selected.

Tigran.


> 	default NFS_V4
> 
> config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
> diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
> index 9c5895b551a1..f142e29a816c 100644
> --- a/fs/nfs/nfs4super.c
> +++ b/fs/nfs/nfs4super.c
> @@ -297,9 +297,6 @@ static int __init init_nfs_v4(void)
> 
> static void __exit exit_nfs_v4(void)
> {
> -	/* Not called in the _init(), conditionally loaded */
> -	nfs4_pnfs_v3_ds_connect_unload();
> -
> 	unregister_nfs_version(&nfs_v4);
> #ifdef CONFIG_NFS_V4_2
> 	nfs4_xattr_cache_exit();
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 2774d4adf4c3..e5a8547e050e 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -504,7 +504,6 @@ void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds);
> struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(const struct net *net,
> 				      struct list_head *dsaddrs,
> 				      u32 version, gfp_t gfp_flags);
> -void nfs4_pnfs_v3_ds_connect_unload(void);
> int nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
> 			  struct nfs4_deviceid_node *devid, unsigned int timeo,
> 			  unsigned int retrans, unsigned int nconnect,
> @@ -972,10 +971,6 @@ static inline struct nfs4_threshold
> *pnfs_mdsthreshold_alloc(void)
> 	return NULL;
> }
> 
> -static inline void nfs4_pnfs_v3_ds_connect_unload(void)
> -{
> -}
> -
> static inline bool nfs4_layout_refresh_old_stateid(nfs4_stateid *dst,
> 		struct pnfs_layout_range *dst_range,
> 		struct inode *inode)
> diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
> index 7adb6f941cf2..7775ee6d087c 100644
> --- a/fs/nfs/pnfs_nfs.c
> +++ b/fs/nfs/pnfs_nfs.c
> @@ -838,33 +838,6 @@ static void nfs4_clear_ds_conn_bit(struct nfs4_pnfs_ds *ds)
> 	clear_and_wake_up_bit(NFS4DS_CONNECTING, &ds->ds_state);
> }
> 
> -static struct nfs_client *(*get_v3_ds_connect)(
> -			struct nfs_server *mds_srv,
> -			const struct sockaddr_storage *ds_addr,
> -			int ds_addrlen,
> -			int ds_proto,
> -			unsigned int ds_timeo,
> -			unsigned int ds_retrans,
> -			unsigned int ds_nconnect);
> -
> -static bool load_v3_ds_connect(void)
> -{
> -	if (!get_v3_ds_connect) {
> -		get_v3_ds_connect = symbol_request(nfs3_set_ds_client);
> -		WARN_ON_ONCE(!get_v3_ds_connect);
> -	}
> -
> -	return(get_v3_ds_connect != NULL);
> -}
> -
> -void nfs4_pnfs_v3_ds_connect_unload(void)
> -{
> -	if (get_v3_ds_connect) {
> -		symbol_put(nfs3_set_ds_client);
> -		get_v3_ds_connect = NULL;
> -	}
> -}
> -
> static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
> 				 struct nfs4_pnfs_ds *ds,
> 				 unsigned int timeo,
> @@ -881,9 +854,6 @@ static int _nfs4_pnfs_v3_ds_connect(struct nfs_server
> *mds_srv,
> 
> 	dprintk("--> %s DS %s\n", __func__, ds->ds_remotestr);
> 
> -	if (!load_v3_ds_connect())
> -		return -EPROTONOSUPPORT;
> -
> 	list_for_each_entry(da, &ds->ds_addrs, da_node) {
> 		dprintk("%s: DS %s: trying address %s\n",
> 			__func__, ds->ds_remotestr, da->da_remotestr);
> @@ -920,8 +890,8 @@ static int _nfs4_pnfs_v3_ds_connect(struct nfs_server
> *mds_srv,
> 		    xprtsec_policy != RPC_XPRTSEC_NONE)
> 			ds_proto = XPRT_TRANSPORT_TCP_TLS;
> 
> -		clp = get_v3_ds_connect(mds_srv, &da->da_addr, da->da_addrlen,
> -					ds_proto, timeo, retrans, nconnect);
> +		clp = nfs3_set_ds_client(mds_srv, &da->da_addr, da->da_addrlen,
> +					 ds_proto, timeo, retrans, nconnect);
> 		if (IS_ERR(clp))
> 			continue;
> 		clp->cl_rpcclient->cl_softerr = 0;
> --
> 2.55.0

------=_Part_18023215_1165998336.1793866940463
Content-Type: application/pkcs7-signature; name=smime.p7s; smime-type=signed-data
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCAMIIF
2zCCBEOgAwIBAgIQF4XHXEetKIAlPr4cevwe6zANBgkqhkiG9w0BAQsFADBUMQswCQYDVQQGEwJO
TDEZMBcGA1UECgwQR0VBTlQgVmVyZW5pZ2luZzEqMCgGA1UEAwwhR0VBTlQgVENTIEF1dGhlbnRp
Y2F0aW9uIFJTQSBDQSA1MB4XDTI2MDgxOTEwMjQyMloXDTI3MDkxODEwMjQyMVowgakxEzARBgoJ
kiaJk/IsZAEZFgNvcmcxFjAUBgoJkiaJk/IsZAEZFgZ0ZXJlbmExEzARBgoJkiaJk/IsZAEZFgN0
Y3MxCzAJBgNVBAYTAkRFMS4wLAYDVQQKDCVEZXV0c2NoZXMgRWxla3Ryb25lbi1TeW5jaHJvdHJv
biBERVNZMSgwJgYDVQQDDB9UaWdyYW4gTWtydGNoeWFuIHRpZ3JhbkBkZXN5LmRlMIIBojANBgkq
hkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA1eVMTvYES3GLqhn0zqaiJ3+XELMB9tHgwI+HtD3+n3V8
tmPEw6Rkoo+3WKEg/Mo1vgJrGaYROtXEaS5fGx+AAMa9vVJyfPMjumhcIjXUXl2CU5HbCAu08grX
czcniDMT5QRR/W7n17XA3aK+okPpX51RTk4sg5r3JXglII8htTr3qNLNvH1a9xF3ha79h+24H2ST
+sYiCgG4xBSmkwZiS/to00/aQ95WQ3vDbfNrPWwItWBecf7EqVuopNHLhODCfnVxdbovoGn6ro/+
dDup9DtKC6EyYT3GiNEr/1eogutQXgS5H8xNc8qnJy5XhuVi8heqQZ94gohqoR44a5QELk3znB92
PLDpW2Gl1N1+SXdXe7QnpOivsYQHIFIGsTzAsMlKP6Cdl7dfRVsymfp8ZAZCyA3fBg9K0Ir/C9rd
PHPAL4rUphHBlL6Em+GF0LO39HrJhpAFzT9n0dYVR31gQ49VsgttPdYniQ9dnIL0X5/FEOkq9zvp
ogJ9ByBlPW5/AgMBAAGjggFRMIIBTTAfBgNVHSMEGDAWgBSDrT4rvBOJjYgJHL8g3F+4MVXq8TBX
BggrBgEFBQcBAQRLMEkwRwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuZ2VhbnQtcHJ2LmhhcmljYS5n
ci9HRUFOVC1UQ1MtQ2xpZW50LUF1dGgtUjUuY2VyMDUGA1UdIAQuMCwwDAYKKoZIhvdMBQICBTAN
BgsqhkiG90wFAgMDAzANBgsqhkiG90wFAgMBAjAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUH
AwQwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2NybC5nZWFudC1wcnYuaGFyaWNhLmdyL0dFQU5U
LVRDUy1DbGllbnQtQXV0aC1SNS5jcmwwHQYDVR0OBBYEFCFcUBIsi3uUE1kq670tMz37WCGaMA4G
A1UdDwEB/wQEAwIFoDANBgkqhkiG9w0BAQsFAAOCAYEAYnxTcPN9abeQXN8K8LPynNHsq08LUVDd
ROKGdsmCdVJLdDLI4VF2qxw/hyPALNb2XrjnYz6F7zpsOjGWh13IpDCN1ydcy14kurOq0XWeXPuJ
Cwh2+Q35xZX0CiMxDXVV8HbW5DLSkmMti5lAshu47KgJmQc2OqRY2Fx1A4d/eAsNfP0tmF6Z6wpW
AtTd2F0Tlv9yovu5uRWlSBrQOgzTKA4L9yELBtFwxZfRJXf7TdzJqcEmOxZqcRkA8vGMCTcaRzaQ
4az1+q6raJV8DvkKjtxrxg+CyjlY2ARFev1ofuPUXlJ2RGA1hhFuSWPIg/FFRiAUYkEkyrFSEmsx
ZhGuRFuikFrg9+lpqNv2Qnx8VHi0ZWZXRCbua2qv8bpYLv17jVSfUPT65Iha/0zVZiE9YeeE4r62
WH6cQdKylQM4vw0iVSgdbxA59um3VKi10sVGJnA076uEvCJw05tVpBb7Ac6CpIgPFJ2A/QzhFm5V
u+aRa6gZyRqPl0tGh5YNmmVkAAAxggLkMIIC4AIBATBoMFQxCzAJBgNVBAYTAk5MMRkwFwYDVQQK
DBBHRUFOVCBWZXJlbmlnaW5nMSowKAYDVQQDDCFHRUFOVCBUQ1MgQXV0aGVudGljYXRpb24gUlNB
IENBIDUCEBeFx1xHrSiAJT6+HHr8HuswDQYJYIZIAWUDBAIBBQCggc4wGAYJKoZIhvcNAQkDMQsG
CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjYxMTA1MDgyMjIwWjAtBgkqhkiG9w0BCTQxIDAe
MA0GCWCGSAFlAwQCAQUAoQ0GCSqGSIb3DQEBCwUAMC8GCSqGSIb3DQEJBDEiBCAekUux+OMohcw1
/Gtb0YlDwW97W4Zpdk3tW6eAkF5vNTA0BgkqhkiG9w0BCQ8xJzAlMAoGCCqGSIb3DQMHMA4GCCqG
SIb3DQMCAgIAgDAHBgUrDgMCBzANBgkqhkiG9w0BAQsFAASCAYC4R369Zx5TlSlgZCcCnkZxHNtt
TMBEX0z0tLiIUFXzvGMm3+xniF8nVWahUyv1WoFbOzz2d+E3iKkrPIfCe7JvF2LNKuGzCOrDtkFU
Ds+fNoKDtGCo+DUZShnr5oG8WpQxTplAYYjPzAR/qmNwpoG4Lkw3ug4fbF/n4zs56rsYhkhM6LsW
hirUTkZfnzzij+qyPTiwjA/89XT6BSKq52vMe9G4bpP7yBSD9BGXJGZyb8mf+5txF/WTE7LgHr87
juhVw6NE3l9XFzzE6srkWoqEZHmyj1i6BaYM6FIs5i0ZtAYrppux04NhpV7KM4TwyR/AzFfPihBL
EMq/EqoNsUO75MHjt8C6XM6TNz2ButpLcwRcV4VWvusZi24tPN+Ei+ID/4wBkwh05vJFCBJVMWLg
vkXSF2ZDqSTdDylDCbEbs81mcRY5vIY5wKVWimrZaFGu234Y522QrWP9evC8UD9XI2uA71fmqBbt
WboG/1ljOKPpQAR/uhEcvS0A2bZAnBQAAAAAAAA=
------=_Part_18023215_1165998336.1793866940463--
