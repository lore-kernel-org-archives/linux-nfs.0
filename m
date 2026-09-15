Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B94F4CE681;
	Tue, 15 Sep 2026 20:36:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789504566; cv=none; b=H+pundZ4dxznGklf2CQC1YUlzKs7POMWB6qJHRaXapviGWh5V3429QTaqnQ4Cxdjcbd9cdahZmF2qNuUiePTQhT4/mHtkVCdHcpzSG9vNKvLueOiMiJQVlCkrZ0pjF8534/8y65NOZcDzMTZZHf36uTpmven1mNmDmDH8V9YTNw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789504566; c=relaxed/simple;
	bh=tf8Z1+KhERDicsVGIFE9UboDmzgpr/mocD4AgW+5yg4=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=YmisczLaoP1aQTV0tBSYiSCdOivuF7P9caARD21y+zUciwdc13cqCeId/i4mf5eCsUPM/HP6T//1S5UJqEwG49wUHEzZXLGpTmNExOAjxen9x9dN9r0MtDOuryFz+gGlTR4P2Sq1I5gFu29pkXEfZ6BfoaROm/N3iDNMjj/lkLU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eAcYmq6a; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eAcYmq6a"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5D1691F000FF;
	Tue, 15 Sep 2026 20:36:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789504564;
	bh=Q935r2F/2lYMqlRjrM1mXXzZhLZ+RRbvLWlFr3BnxLk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=eAcYmq6aABNPSTZUTbFbQRd5Qw7JHC2w1tF2EOeyXWRuESCa4Px+5sbwe6Y6HCy9z
	 MZWcanaZAokEQC2SNgcJot6bwHVESMBwMAlYt4pX6sMYRYNYAF6Q2GMrhvZaz5Fe/3
	 HaKs4Thdx7ddIyh4n5W0z/WynJ4d8jiI1DF67Q4djZ0o/otmiQvJEq21M3CQQMSzRE
	 1OoqH0EVR64gAruqj1fjA6QKIphGq1jMjkltC8WfAo5HnADsn+KOQCpPAgEdu1LHsI
	 xI+oyDgvgdFMZhxQcuh4Mj2WRA8i0xGVLOjf6/cSfHIJHviDyUVdMmGp3+6Tl+F6oo
	 yW1uo+54zcp6A==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 7A42CF40068;
	Tue, 15 Sep 2026 16:36:03 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 15 Sep 2026 16:36:03 -0400
X-ME-Sender: <xms:M6ypanDK5utd1_Z-DMOVf9o80leBPBgUagAS6Fs_bH1egOXQ41ukVA>
    <xme:M6ypaoWl82UzL38ptGt0zrDa7YMZdlt-nSOwZrW1DBtYsNDuGctXl7DiJDlVlBKVr
    5cvnXs7HIz_DGkO0zmdXV24sxRyGDxvW_PRoscNERjofch-Kyee2Z5l>
X-ME-Proxy-Cause: dmFkZTFfJUXOV67mK6JY2U59MvgT15W/AasgXwwNzNcIcZ+83vWpIlGpvxvHkM0Z7Poaqg
    fKpTxdV7/qqJPXxXt/Sa0Em0E2exX1YhGCmpiagTm8SWgopTv0VuiTYRiMgu5i27YCe4mM
    riAY8lcqR3/cCNhCQzU2IeyNxqKqDwQWa+lSn9Ig/AaEdidTCCecavnUzAPUVuKi5VXQSk
    QwXD/AwSVZqrhdyVI+Zb/uY29HcIeGmzl1F82CipkH1ebrwoMrC8g67yV5jKy6bBGpyptB
    dhyNu3ZHVyOU4IYDECKZUN1xAwvokh4h1PmsFNSPryOzJLesPjv6lo/XTgeOdI3701rimn
    Ne+bH7JA58fz11d0AUhGOcaLP/c42VdeM5vXfFIt/+p+iNnGhBzYGu7J5NPpKkCf4J4xu4
    HGWGzvFfA2lcRC+/aUAv11N2ODkNZ1qRI99FyOghUWYH2TQOvW66LVkpDA37qx5WqZpZJk
    G0zTFpKrjDzKd776UdwLi3rfFHuxsG5WiYmfa+YWXbvRIhmNhbgI50fW8s+MDVio3KBYoN
    SsfVvzFpWiGBofdMXDFdvlhnV2874Xherl4/Di03JQX+1dBuC8qyEfbo6GQChKlsskRZZ6
    tvvs4aetce43UFm1x9XQnDKuOqLmQ2YxauTTKF9z+kBgtzMVzjHdJujAnRvg
X-ME-Proxy: <xmx:M6ypanmc2qcxR6YYxV2mBhU9_MZT1vlKgGHb8npaQw9n7DGgpQ4PBA>
    <xmx:M6ypasaS40DpZWGzWBuLJjQQ0TdyIbjSWuA8aTV94apxRV1D8tFO0Q>
    <xmx:M6ypas741V_9r1a3TRyNJomULkz5sfvbcuK1a3caspSIs9R3GTbMNg>
    <xmx:M6ypamDVijjQLKdoLcYZws0y5MO4qcToezx1W3f_RH1u0mI7ZpD8FQ>
    <xmx:M6ypaq8n6oxK8aRM6mEzr9EPXxX73S-_e0GjhiGhqoNsN5JcDs7hPWrr>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 59759780076; Tue, 15 Sep 2026 16:36:03 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AAPZyXKTxCYB
Date: Tue, 15 Sep 2026 16:35:37 -0400
From: "Chuck Lever" <cel@kernel.org>
To: linux-nfs@vger.kernel.org, "Sagi Grimberg" <sagi@grimberg.me>
Cc: keyrings@vger.kernel.org, kernel-tls-handshake@lists.linux.dev,
 netdev@vger.kernel.org, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Christoph Hellwig" <hch@lst.de>,
 "Hannes Reinecke" <hare@suse.de>, "David Howells" <dhowells@redhat.com>,
 "Jarkko Sakkinen" <jarkko@kernel.org>
Message-Id: <ec140adb-dc46-4bf0-ba29-930d47ba9a9f@app.fastmail.com>
In-Reply-To: <8ddb29a7-28e7-4c90-8d6c-5ab2976fa53a@app.fastmail.com>
References: <20260602154740.49861-1-cel@kernel.org>
 <8ddb29a7-28e7-4c90-8d6c-5ab2976fa53a@app.fastmail.com>
Subject: Re: [RFC] NFS: named client identities for mTLS mounts and a per-namespace
 .nfs keyring
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sun, Sep 13, 2026, at 12:05 PM, Chuck Lever wrote:
> On Tue, Jun 2, 2026, at 11:47 AM, Chuck Lever wrote:
>
>> Userspace front end
>> ===================
>>
>> With the keyring in place the front end is straightforward and follows
>> the nvme-cli / cifscreds pattern.
>>
>> A new nfs-utils tool -- working name nfstlskey, fitting the nfsidmap /
>> nfsconf family -- manages x.509 client identities:
>>
>>     nfstlskey add  <identity> --cert cert.pem --key key.pem
>>     nfstlskey list
>>     nfstlskey remove <identity>
>>
>> The add subcommand reads the PEM cert and key, converts each to DER,
>> and creates two "user" keys on the netns .nfs keyring ("user" because
>> tlshd consumes raw DER via keyctl_read_alloc()), with possessor-only
>> read. Description convention:
>>
>>     nfs:x509:<identity>:cert
>>     nfs:x509:<identity>:privkey
>>
>> The mount command names the identity:
>>
>>     mount -o xprtsec=mtls,tls_identity=<identity> server:/export /mnt
>>
>> mount.nfs runs in the caller's namespace, searches the .nfs keyring for
>> the two descriptions, and passes the existing cert_serial= and
>> privkey_serial= options to the kernel. tls_identity= is purely a
>> userspace convenience that resolves a name to the serials the kernel
>> already accepts; the raw serial options remain as a documented escape
>> hatch. Both get documented in nfs(5), with a new nfstlskey(8) page.
>>
>> tlshd changes are minimal: confirm the per-handshake link of the passed
>> keyring happens before the cert and privkey serials are read, and
>> retire the now-unnecessary .nfs entry in the keyrings= startup path.
>
> I've created an nfstlskey tool and pushed it to the nfs-mtls-identity
> branch of https://github.com/oracle/ktls-utils/ . It compiles, but I
> haven't otherwise tested it. There is a nfstlskey(8) man page.
>
> There is a change to tlshd so that the handshake children processes
> pick up the .nfs keyring instead of picking .nfs up at tlshd start-up
> time. This avoids the ordering problem of starting tlshd before the
> NFS client module is loaded.
>
> I'm hoping this new tool can be used with current kernels, though
> all of this is missing proper namespace support at the moment, so
> it should work in the init net-ns only. Kernel patches for namespace
> support are in the works.
>
> Please kick the tires. Is this the kind of administrative UX you
> expect?

Top five patches in

https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git/log/?h=nfs-mtls-identity

provide the kernel plumbing to copy key serial numbers provided by
NFS mount options to the tlshd upcall.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
