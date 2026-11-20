Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=80.69.43.37
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795180674;
	b=c4YtkcZAUOu/E1ElAKmAoPl7TG/OR5OHZn3fFn0XEQa2PCjz8q6F906m5hn9EI1h66vG
	 v31qR0t4DbIMQ+Js2zW865vj2wiaDfG/yY6X7Mr0koSwP1cZvqsi3P37xvge1bqw/C7+F
	 Zi4t1980W3UTz1FHUys3t8BsOol0g6q2BSDEf9GgxdMxVt78VCU++hP5heosCvj4OSQty
	 6wwaWvV7BVrRpAzUcSOOnmxocbkfB5CPNV9OXcVRUjSn5B+5L9cNmfmRWFbzBkOWk4j3d
	 JRgQ9oWKI2K5ICbG2RIYAqm/VFkG/wkgIa8xOwK2gOCVkux8kJVAUMXXyWQx+xFEQjw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795180674;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Date:From:To:Cc:
	 Subject:Message-ID:MIME-Version:Content-Type:Content-Disposition;
	bh=5JWf5OXupYVqIkiH9DSB2am/4xavv4dxRVzrPrLSdSI=;
	b=wHc0ikyzUoFkYz7oKmweulMarCFSXe+T/q2vmBCrOfa2a0+tDDD3o9em3jLgngPhVb50
	 uaxxOtG6W3lpyFP/ADNiOGQxv2RpKG9h3viBqOSRvVGZgJ9qOfvT9TW22EbwtuYxQHTcu
	 8Ni4SlJNCo0lMeB4LtF9VQjxhyiNGHYSEmbdNhZkuY9htHGlwbBySV9zucDZB3TNlzYN7
	 H3jmty9ZV89/NnftiegJC2IUJswyJqNibLC7rMli2YMY5mi7+xZ3Yw0dx2NYIAB259zI9
	 4dP0didSv14mzh+zw2OuSob9PBiOPi1u+MfpiS8t/nHOt0EuWmk6eyN5JmvZqpWr/ng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=vozeler.com;
	spf=pass smtp.mailfrom=vozeler.com;
	dkim=pass header.d=vozeler.com header.i=@vozeler.com header.a=rsa-sha256 header.s=max-2024-2 header.b=KqzQW1pg;
	arc=none smtp.remote-ip=80.69.43.37
Received: from imap.hinterhof.net (imap.hinterhof.net [80.69.43.37])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3581160A2618;
	Fri, 20 Nov 2026 13:17:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3581160A2618
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=vozeler.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=vozeler.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=vozeler.com header.i=@vozeler.com header.a=rsa-sha256 header.s=max-2024-2 header.b=KqzQW1pg
Received: from dp.vpn.hinterhof.net (dynamic-176-002-211-151.176.2.pool.telefonica.de [176.2.211.151])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange x25519 server-signature RSA-PSS (4096 bits) server-digest SHA256
	 client-signature RSA-PSS (4096 bits) client-digest SHA256)
	(Client CN "x201t.vpn.hinterhof.net", Issuer "Max Vozeler" (not verified))
	by imap.hinterhof.net (Postfix) with ESMTPS id 79B9F905A5B;
	Fri, 20 Nov 2026 13:17:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=vozeler.com;
	s=max-2024-2; t=1795180663;
	bh=0PEgacUkNlIZomwm9ydbicVjYtPuVcdoui4iSWh3UOI=;
	h=Date:From:To:Cc:Subject:From;
	b=KqzQW1pgjX75vCWF4sRK1jvCfEwUPZMYeQhd3lBWshcPFbdacYsvQCLuDZXzwSO9e
	 7Zgx/s6doXeDdGmQy1UsSRkWYrBCwWpZHfW/aHLk3wYiXSsEjN1koGWMPKNJKaK+S2
	 LZEHQa+FSC7vLD8rBilCquIkP5onVcjALDHk92+6Di/WW4lcCoodSFEyrDJw7XHbG5
	 PyrHJutQCZuxx33KNpnyKP9XBbuOOddGDCBALWHybXSInoaallhwOU21UFT3gC8rPl
	 k4oljtJC+AgGfIgKKxTXQk6d+LCN5sV+9rXZ5MZK9qx3CGaLj+6PMoEYDLabM1I24P
	 bTCt7+zsD6a2w==
Received: by dp.vpn.hinterhof.net (Postfix, from userid 1000)
	id CC87526018A; Fri, 20 Nov 2026 14:17:43 +0100 (CET)
Date: Fri, 20 Nov 2026 14:17:43 +0100
From: Max Vozeler <max@vozeler.com>
To: linux-nfs@vger.kernel.org
Cc: stable@vger.kernel.org, regressions@lists.linux.dev
Subject: [Regression linux-6.1.y]: NFSv4 server: sec=krb5p mount fails with
 EIO in 6.1.192
Message-ID: <awBIdxOJ4XSXuc7S@dp.vpn.hinterhof.net>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

#regzbot introduced: v6.1.190..v6.1.192

Hi,

after upgrading an NFS server (Debian bookworm) to 6.1.192
(Debian linux-image-6.1.0-55-amd64), NFSv4 clients fail to mount exports
using sec=krb5p with EIO.

Downgrading the server back to 6.1.190 (linux-image-6.1.0-54-amd64)
makes things work again.

Good: 6.1.190 (Debian linux-image-6.1.0-54-amd64)
Bad:  6.1.192 (Debian linux-image-6.1.0-55-amd64, linux-image-6.1.0-56-amd64)

sec=krb5i works on the exact same server, export, and Kerberos keytab;
only sec=krb5p fails.

# mount -vvv -t nfs4 -o sec=krb5p,vers=4.0 10.x.y.z:/<export> /mnt
mount.nfs4: timeout set for Fri Nov 20 08:10:07 2026
mount.nfs4: trying text-based options 'sec=krb5p,nfsvers=4.0,addr=10.x.y.z,clientaddr=10.x.y.a'
mount.nfs4: mount(2): Input/output error
mount.nfs4: mount system call failed

Server dmesg with rpcdebug enabled:

[42095.312947] svc: server 0000000039bc31cb, pool 0, transport 00000000cfa39484, inuse=2
[42095.312971] svc: server 0000000072d08ff5, pool 0, transport 00000000cfa39484, inuse=3
[42095.312975] svc: svc_authenticate (0)
[42095.324501] svc: server 0000000072d08ff5, pool 0, transport 00000000c60f4fcd, inuse=2
[42095.334305] svc: server 0000000072d08ff5, pool 0, transport 00000000c60f4fcd, inuse=2
[42095.334324] svc: svc_authenticate (6)
[42095.334331] svc: server 0000000039bc31cb, pool 0, transport 00000000c60f4fcd, inuse=3
[42095.334388] RPC:       xs_local_send_request(1756) = 0
[42095.338142] RPC:       krb5_encrypt returns 0
[42095.338144] RPC:       krb5_encrypt returns 0
[42095.338148] RPC:       krb5_encrypt returns 0
[42095.338148] RPC:       krb5_encrypt returns 0
[42095.338151] RPC:       krb5_encrypt returns 0
[42095.338151] RPC:       krb5_encrypt returns 0
[42095.338154] RPC:       krb5_encrypt returns 0
[42095.338154] RPC:       krb5_encrypt returns 0
[42095.338156] RPC:       krb5_encrypt returns 0
[42095.338156] RPC:       krb5_encrypt returns 0
[42095.338158] RPC:       krb5_encrypt returns 0
[42095.338158] RPC:       krb5_encrypt returns 0
[42095.338160] RPC:       gss_import_sec_context_kerberos: returning 0
[42095.338163] RPC:       gss_get_mic_v2
[42095.338546] svc: server 0000000072d08ff5, pool 0, transport 00000000cfa39484, inuse=2
[42095.338554] svc: svc_authenticate (6)
[42095.338555] RPC:       gss_verify_mic_v2
[42095.338557] RPC:       gss_get_mic_v2
[42095.338557] svc: server 0000000039bc31cb, pool 0, transport 00000000cfa39484, inuse=3
[42095.338559] RPC:       gss_verify_mic_v2
[42095.338573] nfsd4_exchange_id rqstp=0000000072d08ff5 exid=0000000096ec91a4 clname.len=27 clname.data=0000000035150242 ip_addr=10.x.y.50 flags 101, spa_how 1
[42095.338592] nfsd4_exchange_id seqid 0 flags 20001
[42095.338594] RPC:       gss_get_mic_v2
[42095.338777] svc: server 0000000072d08ff5, pool 0, transport 00000000cfa39484, inuse=2
[42095.338783] svc: svc_authenticate (6)
[42095.338784] RPC:       gss_verify_mic_v2
[42095.338786] RPC:       gss_get_mic_v2
[42095.338786] svc: server 0000000039bc31cb, pool 0, transport 00000000cfa39484, inuse=3
[42095.338787] RPC:       gss_verify_mic_v2
[42095.338790] nfsd4_exchange_id rqstp=0000000072d08ff5 exid=0000000096ec91a4 clname.len=27 clname.data=0000000035150242 ip_addr=10.x.y.50 flags 101, spa_how 1
[42095.338799] nfsd4_exchange_id seqid 0 flags 20001
[42095.338834] RPC:       gss_get_mic_v2
[42095.338953] svc: server 0000000072d08ff5, pool 0, transport 00000000cfa39484, inuse=2
[42095.338958] svc: svc_authenticate (6)
[42095.338958] RPC:       gss_verify_mic_v2
[42095.338960] RPC:       gss_get_mic_v2
[42095.338960] svc: server 0000000039bc31cb, pool 0, transport 00000000cfa39484, inuse=3
[42095.338962] RPC:       gss_verify_mic_v2
[42095.338982] check_slot_seqid enter. seqid 1 slot_seqid 0
[42095.338998] RPC:       set up xprt to 10.x.y.50 (port 0) via tcp
[42095.339057] RPC:       gss_get_mic_v2
[42095.339264] svc: server 0000000072d08ff5, pool 0, transport 00000000cfa39484, inuse=4
[42095.339267] svc: svc_authenticate (6)
[42095.339268] RPC:       gss_verify_mic_v2
[42095.339270] RPC:       gss_get_mic_v2
[42095.339271] RPC:       gss_verify_mic_v2
[42095.339271] svc: server 0000000039bc31cb, pool 0, transport 00000000cfa39484, inuse=5
[42095.339274] __find_in_sessionid_hashtbl: 1795172831:1033077859:4:0
[42095.339284] nfsd4_sequence: slotid 0
[42095.339285] check_slot_seqid enter. seqid 1 slot_seqid 0
[42095.339287] alloc_cld_upcall: allocated xid 9
[42095.340556] --> nfsd4_store_cache_entry slot 000000008b186fa8
[42095.340560] RPC:       gss_get_mic_v2
[42095.343136] svc: server 0000000072d08ff5, pool 0, transport 00000000f9548822, inuse=2
[42095.344680] svc: server 0000000072d08ff5, pool 0, transport 00000000f9548822, inuse=2
[42095.344687] svc: svc_authenticate (6)
[42095.344690] svc: server 0000000039bc31cb, pool 0, transport 00000000f9548822, inuse=3
[42095.344757] RPC:       xs_local_send_request(1756) = 0
[42095.347090] RPC:       krb5_encrypt returns 0
[42095.347092] RPC:       krb5_encrypt returns 0
[42095.347096] RPC:       krb5_encrypt returns 0
[42095.347096] RPC:       krb5_encrypt returns 0
[42095.347099] RPC:       krb5_encrypt returns 0
[42095.347099] RPC:       krb5_encrypt returns 0
[42095.347101] RPC:       krb5_encrypt returns 0
[42095.347101] RPC:       krb5_encrypt returns 0
[42095.347103] RPC:       krb5_encrypt returns 0
[42095.347104] RPC:       krb5_encrypt returns 0
[42095.347105] RPC:       krb5_encrypt returns 0
[42095.347105] RPC:       krb5_encrypt returns 0
[42095.347107] RPC:       gss_import_sec_context_kerberos: returning 0
[42095.347109] RPC:       gss_get_mic_v2
[42095.347456] svc: server 0000000072d08ff5, pool 0, transport 00000000cfa39484, inuse=4
[42095.347468] svc: svc_authenticate (6)
[42095.347469] RPC:       gss_verify_mic_v2
[42095.347471] RPC:       gss_get_mic_v2
[42095.347471] svc: server 0000000039bc31cb, pool 0, transport 00000000cfa39484, inuse=5
[42095.347473] RPC:       gss_unwrap_kerberos_v2
[42095.347646] RPC:       bc_destroy xprt 00000000488733b3
[42095.348467] svc: server 0000000072d08ff5, pool 0, transport 000000005d77f59c, inuse=2
[42095.348472] svc: svc_authenticate (6)
[42095.348474] RPC:       gss_verify_mic_v2
[42095.348481] RPC:       gss_get_mic_v2
[42095.348483] RPC:       gss_unwrap_kerberos_v2
[42095.348507] svc: server 0000000072d08ff5, pool 0, transport 000000005d77f59c, inuse=2
[42095.348713] svc: server 0000000072d08ff5, pool 0, transport 000000005d77f59c, inuse=2
[42095.348752] svc: server 0000000072d08ff5, pool 0, transport 000000005d77f59c, inuse=2
[42095.348758] svc: svc_authenticate (6)
[42095.348759] RPC:       gss_verify_mic_v2
[42095.348761] RPC:       gss_get_mic_v2
[42095.348763] RPC:       gss_unwrap_kerberos_v2
[42095.348762] svc: server 0000000039bc31cb, pool 0, transport 000000005d77f59c, inuse=3
[42095.365858] svc: server 0000000072d08ff5, pool 0, transport 000000005d77f59c, inuse=2
[42095.365867] svc: svc_authenticate (6)
[42095.365870] RPC:       gss_verify_mic_v2
[42095.365869] svc: server 0000000039bc31cb, pool 0, transport 000000005d77f59c, inuse=3
[42095.365877] RPC:       gss_get_mic_v2
[42095.365877] svc: svc_authenticate (6)
[42095.365880] RPC:       gss_delete_sec_context deleting 000000004f9c6594
[42095.365881] RPC:       gss_verify_mic_v2
[42095.365892] RPC:       gss_get_mic_v2
[42095.365894] RPC:       gss_verify_mic_v2
[42095.365900] nfsd4_destroy_session: 1795172831:1033077859:4:0
[42095.365901] __find_in_sessionid_hashtbl: 1795172831:1033077859:4:0
[42095.365903] svc: server 0000000072d08ff5, pool 0, transport 000000005d77f59c, inuse=3
[42095.365928] RPC:       gss_get_mic_v2
[42095.366086] svc: server 0000000072d08ff5, pool 0, transport 000000005d77f59c, inuse=2
[42095.366091] svc: svc_authenticate (6)
[42095.366092] RPC:       gss_verify_mic_v2
[42095.366094] RPC:       gss_get_mic_v2
[42095.366094] svc: server 0000000039bc31cb, pool 0, transport 000000005d77f59c, inuse=3
[42095.366095] RPC:       gss_verify_mic_v2
[42095.366101] alloc_cld_upcall: allocated xid 10
[42095.367452] RPC:       gss_get_mic_v2
[42095.367647] svc: server 0000000072d08ff5, pool 0, transport 000000005d77f59c, inuse=2
[42095.367653] svc: svc_authenticate (6)
[42095.367655] RPC:       gss_verify_mic_v2
[42095.367655] svc: server 0000000039bc31cb, pool 0, transport 000000005d77f59c, inuse=3
[42095.367658] RPC:       gss_get_mic_v2
[42095.367660] RPC:       gss_delete_sec_context deleting 0000000023931779

Let me know if there is any useful information I can provide.

Best regards,
Max
