Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794258158;
	b=Pk9a7yQxyLa8eHD7EHJH3F5A9fR0K1BhOm7h6M03WiuvucgQWbA8LV4slD8MrLneoK8a
	 GARWKGCEmxvDsM73wWQ+E96rSpOLCcdBds7kq6VwP7EeKK/T9wvd6PYPjoCUpn5wwBDBn
	 v+u3eZsYT7UHaKkj9E+vKyUFx9Wq/ulk7zzFlP4GxXLKAGHqjz20gpKc2JbS0ibchD7ci
	 Y9aO8GI3uyiK4yi5USt8hJr65MHGi1YBL9aNmsUT4LKmegIZ1lU1vcrM2kfWXnUGmHvku
	 89+Wz9ENywD1q90UbEeCwli9apbA4aYb5itmeht9VRrZkKul9l7nMwg2I5JjRCBo/Xg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794258158;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=MnGK8snWRLUf2DP6MV0CVJ7z2tIT3TBH19TgRltKZ5Y=;
	b=OjzLcomlo22eQz5oCpKjzJgwVVpWDZ/JiHgEV6rje6oO08rUnNjDrf0HRPL0nmLBdeVC
	 1IxmxNX605y0ZbmyjrPZYThxd6x9WkDDcjXrjhT2DATf3pO9in5GjE24aZ+CCbJxs7lnN
	 4B/4MT1szRCFX/GHdNuqwhk0B8h3xHlPQTeCWPDx59kemvbRfAD3DABAwl2utdPAptTzd
	 tw/fTEAWLrIqNaOkJMD+vttopnbJLIx+60vQsu05xlhzxbMLpUKNKEwh+XAzCYHysBaHZ
	 oIPB8b5TTx87YDLHZS1YQR3evRV4drqzT3O+AByIprg6+tAbW8ksgh6J8zr1FD4gHrg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=f9UdmFW9;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=K1dQHWut;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CC9D4606A31C
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 21:02:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CC9D4606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=f9UdmFW9;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=K1dQHWut
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794258156;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=MnGK8snWRLUf2DP6MV0CVJ7z2tIT3TBH19TgRltKZ5Y=;
	b=f9UdmFW9rh0q9v8OTuEY7f6qgsxdP/I1d58gU3MgcoljGn6Xaoo6EICrbLuemIBqxLQaJr
	8FUoZb9EUSYwtm/4ilNr9ue9lexgWcym9fAKe+fUKUPKMlYWNur4YEymsEaEU6FQ9cU0s6
	iY3Nd34IX8C3UqVR/9wces0yeApSbWg=
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com
 [209.85.160.198]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-486-Gjey6FCYP9O1W9LynJes7A-1; Mon, 09 Nov 2026 16:02:35 -0500
X-MC-Unique: Gjey6FCYP9O1W9LynJes7A-1
X-Mimecast-MFC-AGG-ID: Gjey6FCYP9O1W9LynJes7A_1794258155
Received: by mail-qt1-f198.google.com with SMTP id d75a77b69052e-5364605e74bso36770191cf.3
        for <linux-nfs@vger.kernel.org>; Mon, 09 Nov 2026 13:02:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1794258155; x=1794862955; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=MnGK8snWRLUf2DP6MV0CVJ7z2tIT3TBH19TgRltKZ5Y=;
        b=K1dQHWutvpX+n0gEyLAM0mOFY588e2ObaCd8YMY5muW91u2BAF7dFDW8ae94emxkmi
         VmZToKNDR+HEsZIFl+tAcIRXHiraJPSoWL3fJYt2cVkSaTkquBnSTOwxTrkQ73269AWF
         CbgGq+Yq39kNKYvSwS+zuvYZEMFKpLWwCpTrXv8dwKLhn/xmDeooeH4DjlZtRD+4RFPX
         i8bFXUZuH03/IZNI8CZ2oZBIQeGhT/oAiNWuY8ncFbOQXiTFQInZPUB760y1rKWuuPJk
         U4srwQZxZovMZHB64ebtEQMx70XHPPJHOGhTnZS7ok78TmZ0IQG1p+zn7HBhp3CZI13R
         J5Fg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794258155; x=1794862955;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=MnGK8snWRLUf2DP6MV0CVJ7z2tIT3TBH19TgRltKZ5Y=;
        b=Y/VK9cnf8u4vehDPzwxZXEV+EESTpGJSAOeFIhUNWhxI7DbOHLLNT3RVPp5GJyFLK0
         XPb/DAcgrfKEPT/dYfFgo6FrTzYN72fZ13rqTJheSpKe/j1Go1BL6StRaNVl8YnnltvX
         di4rzFlTjZW2BIHi9O78Lgz3FnK44gFP4MLXx0Fgtz0jRDJZ2/kVEVdq91Qc1823R7Kr
         KSOEEy0b/IyDd1KgR/PMAqAYujhSWc+L4bbyBNrRX/3jFxAUxDxvS4hNM2wM5PHexPeQ
         iKTsRhb7e0uoM1MjbODz27quVfkyaaJMlYDi5LpmsHbdhrIgn7M8WJJ5GiJqN2EyxUJe
         mAKw==
X-Gm-Message-State: APuU4Z80MlHNeH9hPZQgAJIj9g6HqB95c6y0yH6uqJBfMQcXCuEYh6Vn
	fv9aYx5buDZONPsq4ujojmD4kle9GOnYkCsiI2gGUCdnGjFKGmDmOf1P0vOarRfwK+F1E3GFPOB
	JEUoRdfOO+wtSo0qtKdyWU2FRleCuu+g8YicuZV9kdQI2klU44UT6Xlm3pfOXT8TXkmGt0Q==
X-Gm-Gg: AYBFou0hW1um+3H+6oVkgBGWpw+Cp2xdop77bhD7n5HDiTsuDbfTil9FskBX/aWLwQs
	p5sZAFlG7g+tZjoks9qZ7Vr0C0y2nR2t1qTMMPV08+sdOc6DuykGM1VBtn1GIOMNGEFUtRbXaTF
	cPd1XxdONUed6dzxO5LxtYv9ISEgF/1WSZPJitEA2XTCbf46MyL69iSNuNchuDU3zR1oqlsybzx
	fdp6gbwNqPtplziUTbeWHCaLg8glhHes2MrIoI1t1b/uqQALotbByWbfDADljPjVa1a1VFGgmnk
	Fr6N/Aq7+8beEYMn8O84V/f8dTWA7/45qmdRZoLOxGeVe0A0RMczcwuXdbqZNuD9+gnF6/M/1s5
	17KpnQ/2QqCJTp/5fWAl7NJ/kqO9hxj4di18tNYdI6kptOjg=
X-Received: by 2002:a05:622a:301:b0:539:c527:259 with SMTP id d75a77b69052e-5552a174972mr8194281cf.76.1794258154728;
        Mon, 09 Nov 2026 13:02:34 -0800 (PST)
X-Received: by 2002:a05:622a:301:b0:539:c527:259 with SMTP id d75a77b69052e-5552a174972mr8193461cf.76.1794258153914;
        Mon, 09 Nov 2026 13:02:33 -0800 (PST)
Received: from [172.31.1.12] ([70.105.245.156])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-555093d9c3fsm6815801cf.3.2026.11.09.13.02.31
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 09 Nov 2026 13:02:31 -0800 (PST)
Message-ID: <d101fd8f-9909-4cb6-81a1-2b8be8faa080@redhat.com>
Date: Mon, 9 Nov 2026 16:02:31 -0500
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
Subject: Re: [libtirpc PATCH] __binddynport: honor ip_local_port_range
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20261021224136.2273107-1-smayhew@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20261021224136.2273107-1-smayhew@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 10/21/26 6:41 PM, Scott Mayhew wrote:
> __binddynport() currently binds to ports in the dynamic port range
> defined by RFC 6335, which is ports 49152-65535.
> 
> If rpcbind is built with remotecalls enabled, it binds 2 dynamic ports
> for the remotecall sockets.  The selinux-policy allows rpcbind_t to bind
> ports with ephemeral_port_t, which is ports 32768-60999.  It does not
> allow rpcbind_t to bind ports with unreserved_port_t, which is ports in
> the ranges 61000-65535 and 1024-32767.  Currently, the random port
> selected by __binddynport might land in the former range, which triggers
> both an AVC error in selinux and an error from rpcbind in the syslog.
> 
> Read /proc/sys/net/ipv4/ip_local_port_range and constrain the range of
> ports used by __binddynport() to the intersection of the compiled-in
> defaults and the range defined by ip_local_port_range.
> 
> The default values for ip_local_port_range is "32768 60999", so the
> resulting dynamic range used by __binddynport() would be lowport=49152,
> highport=60999, nports=11848.
> 
> Link: https://bugzilla.redhat.com/show_bug.cgi?id=1758147
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... (tag: libtircp-1-3-8-rc3)

steved.> ---
>   src/binddynport.c | 90 ++++++++++++++++++++++++++++++++++++++++++-----
>   1 file changed, 81 insertions(+), 9 deletions(-)
> 
> diff --git a/src/binddynport.c b/src/binddynport.c
> index c2e9a20..52bac17 100644
> --- a/src/binddynport.c
> +++ b/src/binddynport.c
> @@ -57,6 +57,75 @@ enum {
>   	NPORTS		= ENDPORT - LOWPORT + 1,
>   };
>   
> +int lowport = LOWPORT;
> +int endport = ENDPORT;
> +int nports = NPORTS;
> +
> +/*
> + * Parse the first and last local port numbers from
> + *	/proc/sys/net/ipv4/ip_local_port_range.
> + *
> + * @first - the first (low) port in the range
> + * @last - the last (high) port in the range
> + *
> + * Returns 0 on success, and both @first and @last are updated.
> + * Returns -1 on failure, and neither @first nor @last are updated.
> + */
> +static int parse_ip_local_port_range(int *first, int *last)
> +{
> +	int res, new_first, new_last;
> +	FILE *fp;
> +
> +	fp = fopen("/proc/sys/net/ipv4/ip_local_port_range", "r");
> +	if (fp == NULL) {
> +		(void) syslog(LOG_ERR,
> +			"Unable to open open /proc/sys/net/ipv4/ip_local_port_range.");
> +		return -1;
> +	}
> +
> +	res = fscanf(fp, "%d %d", &new_first, &new_last);
> +	if (res != 2) {
> +		(void) syslog(LOG_ERR,
> +			"An error occurred while parsing ip_local_port_range.");
> +		fclose(fp);
> +		return -1;
> +	}
> +
> +	*first = new_first;
> +	*last = new_last;
> +
> +	fclose(fp);
> +	return 0;
> +}
> +
> +/*
> + * Try to update our dynamic port range using information from the kernel.
> + *
> + * Returns 0 on success, and lowport, endport, and nports should be the
> + *	intersection of the compiled-in defaults and the values reported
> + *	by /proc/sys/net/ipv4/ip_local_port_range.
> + * Returns -1 on failure, and lowport, endport, and nports retain their
> + *	default values.
> + *
> + * This function is called by __binddynport() before using any of:
> + *	endport, lowport, nports
> + */
> +static int update_dynamic_port_range(void)
> +{
> +	int ret, low, end;
> +
> +	ret = parse_ip_local_port_range(&low, &end);
> +	if (ret < 0)
> +		return -1;
> +
> +	if (lowport < low)
> +		lowport = low;
> +	if (endport > end)
> +		endport = end;
> +	nports = endport - lowport + 1;
> +	return 0;
> +}
> +
>   /*
>    * This function decodes information about given port from provided array and
>    * return if port is reserved or not.
> @@ -67,8 +136,8 @@ enum {
>    * Returns 0 if port is not reserved, non-negative if port is reserved.
>    */
>   static int is_reserved(char *reserved_ports, int port) {
> -	port -= LOWPORT;
> -	if (port < 0 || port >= NPORTS)
> +	port -= lowport;
> +	if (port < 0 || port >= nports)
>   		return 0;
>   	return reserved_ports[port/(8*sizeof(char))] & 1<<(port%(8*sizeof(char)));
>   }
> @@ -82,8 +151,8 @@ static int is_reserved(char *reserved_ports, int port) {
>    *
>    */
>   static void set_reserved(char *reserved_ports, int port) {
> -	port -= LOWPORT;
> -	if (port < 0 || port >= NPORTS)
> +	port -= lowport;
> +	if (port < 0 || port >= nports)
>   		return;
>   	reserved_ports[port/(8*sizeof(char))] |= 1<<(port%(8*sizeof(char)));
>   }
> @@ -193,13 +262,16 @@ int __binddynport(int fd)
>   		goto out;
>   	}
>   
> +	if (update_dynamic_port_range() < 0)
> +		(void) syslog(LOG_ERR, "Using default port range.");
> +
>   	if (!seed) {
>   		struct timeval tv;
>   
>   		gettimeofday(&tv, NULL);
>   		seed = tv.tv_usec * getpid();
>   	}
> -	array_size = NPORTS / (8*sizeof(char)) + 1;
> +	array_size = nports / (8*sizeof(char)) + 1;
>   	reserved_ports = malloc(array_size);
>   	if (!reserved_ports) {
>   		goto out;
> @@ -208,8 +280,8 @@ int __binddynport(int fd)
>   	if (parse_reserved_ports(reserved_ports) < 0)
>   		goto out;
>   
> -	port = (rand_r(&seed) % NPORTS) + LOWPORT;
> -	for (i = 0; i < NPORTS; ++i) {
> +	port = (rand_r(&seed) % nports) + lowport;
> +	for (i = 0; i < nports; ++i) {
>   		*portp = htons(port);
>   		if (!is_reserved(reserved_ports, port++)) {
>   			res = bind(fd, sap, salen);
> @@ -220,8 +292,8 @@ int __binddynport(int fd)
>   			if (errno != EADDRINUSE)
>   				break;
>   		}
> -		if (port > ENDPORT)
> -			port = LOWPORT;
> +		if (port > endport)
> +			port = lowport;
>   	}
>   
>   out:

