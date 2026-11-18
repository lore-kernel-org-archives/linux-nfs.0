Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795004848;
	b=MW0iEEvv9l4HHFwWy5GhbV3lWuaRugO0/AcOwjBRdLCnAfYm+5ObWgU8pjTjkzWbIr+Y
	 vOxMiERbMF1RjZ+5b+yqTB3GWhjqftDYr+ntX98yoCibwTNicQvOR/VdmMCTsmM0gBuuV
	 4ZDrDKyQy78K5V/5YwCI85O/zMMtlSkIKO+zpTuu8j9fQMeXp/bG3wqeUzJITUcJVUhhR
	 u80MXqWDNQ3wga0hgTAraqaLdOVPa26w0o/OR7YEiBOnXcYtv2GxjtyeTtlMp34tf1iaQ
	 9ICDd5006Z1n4YCbEVSeoyjIsMZehe+3wMRmFSlXlM88iggL54jPQTjlz2iYnZHgdDw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795004848;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=SNFdEk0oGrfzkVbE7zgd9xrGSpnW5FMbgtjWxBI9Iq0=;
	b=oeIfAusg6LBEmnfjHKfZmMsVbF1FsyeL77pTsUJwkyvBAFoKyif14N6AD8nKFO2c02r5
	 KfD/lNhEbqlPre5V/Uj17puRRPRGdnrXyVhY+WP2JstnWZg9Sl9NF31K4K+lCbz0EgL3X
	 diGGB8gOthcpjlJWPYX5K+giOB6OkggHocUAD894bWWJkFW74Mwkdvre1D5iqCJ5+8oQT
	 3k0mNiG2Xd12ImT38x/XsCIBRXtlbcuI3srlTkUpyetoPrhTsfihhrF8lPEJrEvcYiz1I
	 45dLNkd/lLbhOOUiRX7Z1/z/ZiQhmx0Muv4JMlV9bQ1qtuPmG6b4RERS2dkyHjvLbjg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Kn3Ihn45;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=WrHKCgZi;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 58BC8606A320
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 12:27:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 58BC8606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Kn3Ihn45;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=WrHKCgZi
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795004846;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=SNFdEk0oGrfzkVbE7zgd9xrGSpnW5FMbgtjWxBI9Iq0=;
	b=Kn3Ihn45ja2al4aP6KOzOU0IUYZ4b1rKPSUVJWqF98N9RKnnx5ORAyNNDetapsjhaFxnBB
	Ddb1rjxB1cyXteE8Ipecn0VN6JvXZ6qtHqMLYfezdOUI5uI8H9HE4djnIIjCnLvHXbjlGG
	13q4LUiRVSIEID0uaaChoqZwO9pZP80=
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com
 [209.85.222.198]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-317-kjIvM33kMJyZyzF2CLoHWw-1; Wed, 18 Nov 2026 07:27:25 -0500
X-MC-Unique: kjIvM33kMJyZyzF2CLoHWw-1
X-Mimecast-MFC-AGG-ID: kjIvM33kMJyZyzF2CLoHWw_1795004845
Received: by mail-qk1-f198.google.com with SMTP id af79cd13be357-944138ed63fso71646585a.3
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 04:27:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1795004845; x=1795609645; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=SNFdEk0oGrfzkVbE7zgd9xrGSpnW5FMbgtjWxBI9Iq0=;
        b=WrHKCgZiQxCvYv3hqu0pjCbSFD/P97JinNdo0QmZxNX1vk+apSftp+L8PMohm0xMw9
         xYMiw1Z2+CfFtR79XXt9dLWnj0DQHGM8AG3QaAqzSPc/QGecE0KoPO3nCNOnk5FKwrMF
         kbNpUFr3lS/09hoX9aNhsLwSARf+FQqLIGPMVYDbAP9daBgPCy986mwTnaUpd2hZuZEF
         GKXIkGcDOpiqRVJ0uwQhq2rt3R7DYZOvGpOGadBt8SAS4tQni+AbRQYRskIxvHEU/c1k
         /JgLzfCE7yWdSgnbdLHZAje3xJeH9MuMcQvX49sYjq/XieqhW30zo/lAYNyuTeMcPPPd
         GG+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795004845; x=1795609645;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=SNFdEk0oGrfzkVbE7zgd9xrGSpnW5FMbgtjWxBI9Iq0=;
        b=hKYWIfxiw9qepxe04nfp0bxqUsjtqt/dpS4tYGpun0x6OQAYbZVD0ggLaf2quiJr6j
         frCPpmaPZeej+hOSfOtelhMV5yEf+VcWo15DVGZY+szNJJIfG7Ctvl5IL7rsae54Y+9s
         n0LJVcjCbofkV3U+5FsjO/CiNal/h5ubrTPACiepUSnWIQgayPAIHpWQESroMAGSTWoc
         cAYNK9FVwMPlC3uSEm8oOlRlOgSm16EI6yYaWzkDOZxosGN8YPriXgA+Xw8Uz+j7oxNb
         rLhubfwX7WcY/GV+KuK8Fy2bodzSd8+zUH7kCQR0IaYl6i1/TXHYBBzEECNn/4/a/KRR
         Ewzg==
X-Gm-Message-State: APuU4Z+AiRIRpvhW1Aj3nc8RZ4GPVKTRhszCA+cRpKShY3GJiiZKOsWm
	lBnfgwkHGciQCe39OeMKX4OdH20wUFBYdQiTQkisogMwByDImUCCwHYfwH3ik2yKnx5dVPVFAxU
	oR4JnJBWruTQ3q5QHG+IdJv/CB0tV4grL9IPG3fT/NhabFzB7Tm3ZLVptlXQ5wA==
X-Gm-Gg: AYBFou3x3/Bh1M/endR+iQNdJbIECaZj/YPMkWieo+xdn/1joGTLK3VafOjM4e2H/yM
	VsWbDPe/mF+dxVVUslBIi0imYXlDvqL00SwFFYTMraIxMsacO+AMz0BZ0c+gSqE2TBAEu15nIXP
	eDfuC85Erx+hOYwB1X3/eb07EB+t8ntJgxv78oIj/BBf3aTZmi6AKETdsk9lhjGJR2PJTMLZZFb
	QX99PK1rCsxPzdHlTI+NcstLYctGTFp+jLa7iHS5Aa4c+FuHpkZAVXV0CDBRXUpoz5JMUpCOqcP
	/eZYHb7L6M1vOo+qNOVZIg55X7SII7P/Yg84t4gw/ZP4SFuk0L5OjjDROUfdcgXQI+GfjyoL7Ac
	gCTeL24RA0Uj9ljqoRCKey+gVMl0Vdgtv3wZuevmJq5gFyBse
X-Received: by 2002:a05:620a:2b82:b0:93e:c12c:9b6d with SMTP id af79cd13be357-9499971536cmr427411885a.72.1795004844216;
        Wed, 18 Nov 2026 04:27:24 -0800 (PST)
X-Received: by 2002:a05:620a:2b82:b0:93e:c12c:9b6d with SMTP id af79cd13be357-9499971536cmr427405685a.72.1795004843378;
        Wed, 18 Nov 2026 04:27:23 -0800 (PST)
Received: from [172.31.1.12] ([70.105.240.105])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9499b75dd62sm168387685a.21.2026.11.18.04.27.20
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 18 Nov 2026 04:27:22 -0800 (PST)
Message-ID: <5189d543-86d3-4d7e-b9a0-64d71542c880@redhat.com>
Date: Wed, 18 Nov 2026 07:27:11 -0500
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] nfsdctl: bound the rpcbind calls to one 1s attempt
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
References: <2221871feaf9ae6ec4970238fe11805abd2496c6.1794862543.git.bcodding@hammerspace.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <2221871feaf9ae6ec4970238fe11805abd2496c6.1794862543.git.bcodding@hammerspace.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 11/16/26 3:58 PM, Benjamin Coddington wrote:
> libtirpc's rpcb_set() and rpcb_unset() create a client for every call
> and wait 60s for each reply. A local rpcbind that accepts the connection
> and never answers stalls nfsdctl for a minute per call: five UNSETs when
> the threads stop, and five UNSETs plus one SET per listener netid and
> program when they start. libtirpc's setter for that timeout is private.
> 
> Make the SET and UNSET calls on a client of nfsdctl's own, built with
> nfs_get_rpcclient(): AF_LOCAL on _PATH_RPCBINDSOCK first, then TCP to
> 127.0.0.1 port 111, as libtirpc's local_rpcb() orders them. Each pass
> uses one client, and each call is one attempt of 1s, matching
> 17ceb2fecc7c ("SUNRPC: bound the local rpcbind client timeout to 1s"):
> "The local rpcbind is on loopback or on an AF_LOCAL socket, and it
> answers in microseconds."
> 
> A call that gets no answer ends the pass with one warning, as
> ba8c47f04942 and df1ff8e4e275 do for the kernel's svc_register() and
> svc_unregister() sweep. A registration pass whose opening UNSET sweep
> gets no answer makes no SET. A reply of FALSE is logged and the pass
> continues, as before.
> 
> nfs_svc_unregister() is unchanged, and a build without TI-RPC keeps
> using it.
> 
> With the local rpcbind SIGSTOPped, on a kernel that leaves the nfsd
> registration to nfsdctl, "nfsdctl threads 0" returned after 3.4s, where
> it took 302.7s before. lockd's own registration in the kernel accounts
> for 2s of that. "nfsdctl autostart" now ends its registration pass after
> 1s. The THREADS_SET that follows still fails with EIO, because lockd
> cannot register.
> 
> Signed-off-by: Benjamin Coddington<bcodding@hammerspace.com>
Committed... (will be included in the upcoming release)

steved.> ---
>   utils/nfsdctl/rpcbind.c | 199 +++++++++++++++++++++++++++++++++++-----
>   1 file changed, 178 insertions(+), 21 deletions(-)
> 
> diff --git a/utils/nfsdctl/rpcbind.c b/utils/nfsdctl/rpcbind.c
> index 23034097b485..a705c54d8f40 100644
> --- a/utils/nfsdctl/rpcbind.c
> +++ b/utils/nfsdctl/rpcbind.c
> @@ -15,17 +15,23 @@
>   
>   #include <errno.h>
>   #include <netinet/in.h>
> +#include <stdio.h>
> +#include <stdlib.h>
>   #include <string.h>
>   #include <sys/socket.h>
> +#include <sys/un.h>
> +#include <unistd.h>
>   
>   #include <rpc/rpc.h>
>   
>   #ifdef HAVE_LIBTIRPC
>   #include <rpc/rpcb_clnt.h>
> +#include <rpc/rpcb_prot.h>
>   #include <netconfig.h>
>   #endif	/* HAVE_LIBTIRPC */
>   
>   #include "nfslib.h"
> +#include "nfsrpc.h"
>   #include "rpcmisc.h"
>   #include "sockaddr.h"
>   #include "xlog.h"
> @@ -43,7 +49,7 @@
>   
>   /*
>    * Programs to clear at shutdown. There is no reply to read at that point,
> - * so clear a superset. rpcb_unset() of an absent entry does nothing.
> + * so clear a superset. An UNSET of an absent entry does nothing.
>    */
>   static const struct {
>   	rpcprog_t	program;
> @@ -56,24 +62,135 @@ static const struct {
>   	{ NFS_ACL_PROGRAM,	3 },
>   };
>   
> +#ifdef HAVE_LIBTIRPC
> +
> +/*
> + * libtirpc's rpcb_set() and rpcb_unset() wait 60s for each call, and its
> + * setter for that timeout is not exported. The local rpcbind answers in
> + * microseconds, so make the calls on a client of our own with one attempt
> + * of 1s, as the kernel's own rpcbind client does.
> + */
> +static const struct timeval nfsd_rpcb_timeout = { 1, 0 };
> +
> +enum nfsd_rpcb_status {
> +	NFSD_RPCB_OK,
> +	NFSD_RPCB_DECLINED,
> +	NFSD_RPCB_NO_ANSWER,
> +};
> +
> +/* AF_LOCAL first, then loopback TCP, as libtirpc's local_rpcb() does. */
> +static CLIENT *nfsd_rpcb_client(void)
> +{
> +	const struct sockaddr_un sun = {
> +		.sun_family	= AF_LOCAL,
> +		.sun_path	= _PATH_RPCBINDSOCK,
> +	};
> +	const struct sockaddr_in sin = {
> +		.sin_family	= AF_INET,
> +		.sin_port	= htons(111),
> +		.sin_addr.s_addr = htonl(INADDR_LOOPBACK),
> +	};
> +	struct timeval timeout = nfsd_rpcb_timeout;
> +	CLIENT *clnt;
> +
> +	clnt = nfs_get_rpcclient((const struct sockaddr *)&sun, SUN_LEN(&sun),
> +				 0, RPCBPROG, RPCBVERS, &timeout);
> +	if (clnt) {
> +		xlog(D_GENERAL, "rpcbind: using %s", _PATH_RPCBINDSOCK);
> +		return clnt;
> +	}
> +
> +	timeout = nfsd_rpcb_timeout;
> +	clnt = nfs_get_rpcclient((const struct sockaddr *)&sin, sizeof(sin),
> +				 IPPROTO_TCP, RPCBPROG, RPCBVERS, &timeout);
> +	if (clnt)
> +		xlog(D_GENERAL, "rpcbind: using 127.0.0.1 port 111 over TCP");
> +	return clnt;
> +}
> +
> +/*
> + * A transport error means rpcbind accepted the connection and did not
> + * answer. Every later call on this pass would wait the same, so the caller
> + * stops.
> + */
> +static enum nfsd_rpcb_status nfsd_rpcb_call(CLIENT *clnt, rpcproc_t proc,
> +					    struct rpcb *parms)
> +{
> +	enum clnt_stat stat;
> +	bool_t rslt = FALSE;
> +
> +	stat = CLNT_CALL(clnt, proc, (xdrproc_t)xdr_rpcb, (char *)parms,
> +			 (xdrproc_t)xdr_bool, (char *)&rslt, nfsd_rpcb_timeout);
> +	switch (stat) {
> +	case RPC_SUCCESS:
> +		return rslt ? NFSD_RPCB_OK : NFSD_RPCB_DECLINED;
> +	case RPC_TIMEDOUT:
> +	case RPC_CANTRECV:
> +	case RPC_CANTSEND:
> +		xlog(L_WARNING,
> +		     "rpcbind did not answer %s of program %u version %u: %s. Skipping the remaining rpcbind calls.",
> +		     proc == RPCBPROC_SET ? "SET" : "UNSET",
> +		     parms->r_prog, parms->r_vers, clnt_sperrno(stat));
> +		return NFSD_RPCB_NO_ANSWER;
> +	default:
> +		xlog(D_GENERAL, "rpcbind call failed: %s", clnt_sperrno(stat));
> +		return NFSD_RPCB_DECLINED;
> +	}
> +}
> +
> +/*
> + * An empty netid and address unset every netid of [program, version], as
> + * rpcb_unset() with no netconfig does.
> + */
> +static enum nfsd_rpcb_status nfsd_rpcb_unset_sweep(CLIENT *clnt)
> +{
> +	char empty[] = "";
> +	char owner[16];
> +	struct rpcb parms = {
> +		.r_netid	= empty,
> +		.r_addr		= empty,
> +		.r_owner	= owner,
> +	};
> +	enum nfsd_rpcb_status status;
> +	unsigned int i;
> +
> +	snprintf(owner, sizeof(owner), "%d", (int)geteuid());
> +
> +	for (i = 0; i < ARRAY_SIZE(nfsd_rpcb_all); i++) {
> +		parms.r_prog = nfsd_rpcb_all[i].program;
> +		parms.r_vers = nfsd_rpcb_all[i].version;
> +
> +		status = nfsd_rpcb_call(clnt, RPCBPROC_UNSET, &parms);
> +		if (status == NFSD_RPCB_NO_ANSWER)
> +			return status;
> +		if (status == NFSD_RPCB_DECLINED)
> +			xlog(D_GENERAL,
> +			     "Failed to unregister program %u, version %u",
> +			     parms.r_prog, parms.r_vers);
> +	}
> +	return NFSD_RPCB_OK;
> +}
> +
>   /**
>    * nfsd_rpcb_unset_all - remove every nfsd entry from the local rpcbind
>    *
> - * rpcb_unset() matches [program, version, netid] and takes no address, so
> - * one call clears every netid. This mirrors the svc_unregister() sweep that
> - * svc_rpcb_setup() used to run, which an sv_no_rpcbind serv no longer does.
> + * This mirrors the svc_unregister() sweep that svc_rpcb_setup() used to
> + * run, which an sv_no_rpcbind serv no longer does.
>    */
>   void nfsd_rpcb_unset_all(void)
>   {
> -	unsigned int i;
> +	CLIENT *clnt;
>   
> -	for (i = 0; i < ARRAY_SIZE(nfsd_rpcb_all); i++)
> -		nfs_svc_unregister(nfsd_rpcb_all[i].program,
> -				   nfsd_rpcb_all[i].version);
> +	clnt = nfsd_rpcb_client();
> +	if (!clnt) {
> +		xlog(D_GENERAL, "cannot reach rpcbind: %s",
> +		     clnt_sperrno(rpc_createerr.cf_stat));
> +		return;
> +	}
> +	nfsd_rpcb_unset_sweep(clnt);
> +	CLNT_DESTROY(clnt);
>   }
>   
> -#ifdef HAVE_LIBTIRPC
> -
>   /*
>    * Map a transport name and address family to an rpcbind netid.
>    *
> @@ -125,32 +242,47 @@ static bool nfsd_rpcb_wildcard(const struct sockaddr_storage *ss,
>   	return false;
>   }
>   
> -static bool nfsd_rpcb_set_one(rpcprog_t program, rpcvers_t version,
> -			      const char *netid,
> -			      const struct sockaddr_storage *ss)
> +static enum nfsd_rpcb_status nfsd_rpcb_set_one(CLIENT *clnt,
> +					       rpcprog_t program,
> +					       rpcvers_t version,
> +					       const char *netid,
> +					       const struct sockaddr_storage *ss)
>   {
> +	enum nfsd_rpcb_status status;
>   	struct sockaddr_storage wild;
>   	struct netconfig *nconf;
> +	struct rpcb parms;
>   	struct netbuf nb;
> +	char owner[16];
>   	socklen_t len;
> -	bool ok;
>   
>   	if (!nfsd_rpcb_wildcard(ss, &wild, &len))
> -		return false;
> +		return NFSD_RPCB_DECLINED;
>   
>   	nconf = getnetconfigent(netid);
>   	if (!nconf) {
>   		xlog(L_WARNING, "no netconfig entry for %s", netid);
> -		return false;
> +		return NFSD_RPCB_DECLINED;
>   	}
>   
>   	nb.buf = &wild;
>   	nb.len = len;
>   	nb.maxlen = len;
>   
> -	ok = (rpcb_set(program, version, nconf, &nb) == TRUE);
> +	parms.r_addr = taddr2uaddr(nconf, &nb);
>   	freenetconfigent(nconf);
> -	return ok;
> +	if (!parms.r_addr)
> +		return NFSD_RPCB_DECLINED;
> +
> +	snprintf(owner, sizeof(owner), "%d", (int)geteuid());
> +	parms.r_prog = program;
> +	parms.r_vers = version;
> +	parms.r_netid = (char *)netid;
> +	parms.r_owner = owner;
> +
> +	status = nfsd_rpcb_call(clnt, RPCBPROC_SET, &parms);
> +	free(parms.r_addr);
> +	return status;
>   }
>   
>   /**
> @@ -167,14 +299,25 @@ static bool nfsd_rpcb_set_one(rpcprog_t program, rpcvers_t version,
>   void nfsd_rpcb_register(const struct server_socket *listeners, int nlisteners,
>   			const struct nfsd_rpcb_prog *progs, int nprogs)
>   {
> +	enum nfsd_rpcb_status status;
>   	unsigned int failed = 0;
> +	CLIENT *clnt;
>   	int i, j, k;
>   
> +	clnt = nfsd_rpcb_client();
> +	if (!clnt) {
> +		xlog(L_WARNING,
> +		     "cannot reach rpcbind: %s. Clients that look up the server in rpcbind cannot find it.",
> +		     clnt_sperrno(rpc_createerr.cf_stat));
> +		return;
> +	}
> +
>   	/*
>   	 * Clear first. rpcbind cannot express "drop one of two TCP ports",
>   	 * and the kernel no longer sweeps stale entries at serv creation.
>   	 */
> -	nfsd_rpcb_unset_all();
> +	if (nfsd_rpcb_unset_sweep(clnt) == NFSD_RPCB_NO_ANSWER)
> +		goto out;
>   
>   	for (i = 0; i < nlisteners; i++) {
>   		const struct server_socket *l = &listeners[i];
> @@ -215,9 +358,12 @@ void nfsd_rpcb_register(const struct server_socket *listeners, int nlisteners,
>   			    !strncmp(netid, "udp", 3))
>   				continue;
>   
> -			if (nfsd_rpcb_set_one(p->program, p->version, netid,
> -					      &l->ss))
> +			status = nfsd_rpcb_set_one(clnt, p->program,
> +						   p->version, netid, &l->ss);
> +			if (status == NFSD_RPCB_OK)
>   				continue;
> +			if (status == NFSD_RPCB_NO_ANSWER)
> +				goto out;
>   
>   			xlog(L_WARNING,
>   			     "cannot register program %u version %u on %s port %u",
> @@ -230,10 +376,21 @@ void nfsd_rpcb_register(const struct server_socket *listeners, int nlisteners,
>   	if (failed)
>   		xlog(L_WARNING,
>   		     "some rpcbind registrations failed. Clients that look up the server in rpcbind cannot find it.");
> +out:
> +	CLNT_DESTROY(clnt);
>   }
>   
>   #else	/* !HAVE_LIBTIRPC */
>   
> +void nfsd_rpcb_unset_all(void)
> +{
> +	unsigned int i;
> +
> +	for (i = 0; i < ARRAY_SIZE(nfsd_rpcb_all); i++)
> +		nfs_svc_unregister(nfsd_rpcb_all[i].program,
> +				   nfsd_rpcb_all[i].version);
> +}
> +
>   /*
>    * rpcb_set() and the netconfig database are TI-RPC only, so a build
>    * without it cannot own the registration. userspace_rpcbind_supported()
> -- 2.53.0
> 

