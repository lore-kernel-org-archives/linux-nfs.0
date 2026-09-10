Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DE4B58F061;
	Thu, 10 Sep 2026 19:45:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789069506; cv=none; b=UQIy+EambDXFPJdRSDJy7q7/PwUkqZ4alc+AB/dCOOoRQqCUborDhX9vwGQO3eB8gWUVVQeHXtOxRF4lF6zFGnSqw+eeRapNPkbakNVgyz6UVEbC5sxKISH/iFlHFGoKT7wfUesWvgLo1at9Z9dAVKbxhqMuzY8EngoHQrNDHsk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789069506; c=relaxed/simple;
	bh=BROin2cVz4hRIBHaEMllo6eYnTKB/R1C/XpIlxqCDJQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=vEtYiiIEEH7w6LY24tsgEJHt1Xtfcwanv7zqOnXMQdUkZw25O5kaTWAoOSeHK8QEr7QxRowwmIIrXGTgDTHqQMcbOZTI71XlIhD/N315YXWCzu0dUE/pKrbqri1v4gEUr1M4w8DKBIK1/8Hb/tfjkZosduVpKRq/1/fvsrPRpMg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Un9EkA0F; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Un9EkA0F"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6B8C21F000FF;
	Thu, 10 Sep 2026 19:45:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789069504;
	bh=3iRs/EjoPnXZlmJC+DNw6FSMcHs3NCeQuUhPy36UbpU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Un9EkA0FwmwZfNR3lp0RmRPF4Mn+cNo2ZP/WnJs+Ps+HSWqOzVxbLZM1Y10SGsodX
	 7uwyyhknNydibl/3T2nXoMh+y7wb0wyYBN5eOS0XDMHIF1/emkcrQUsfS2CBiXdgMK
	 GaLUykL7gqKckB13vbUzYkZu9lr/Nr/FEAKYdnPHoRGDJAnMB4lB1qhKKIRu/7XR7r
	 FmcW6bc6FrkvhHWaTLbi0xa937uSi8CHBSjjwrhsKw4vApJG7v+iV0sfeKFNin12hF
	 XXQR59fkwjB6ARPOySDhdTaeXZb20BEsYVpZyAUjH2fvl/q5+/3Q5GjxlYk9Po9qau
	 gioHWcCKplYCQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A0590F40066;
	Thu, 10 Sep 2026 15:45:03 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 10 Sep 2026 15:45:03 -0400
X-ME-Sender: <xms:vwijalmySYNU8vmQjwk2ZUGdYRFzvKDAPoeAZbzdYCQqfr6UNi3RQQ>
    <xme:vwijarq5N5DF2ZgfP9ed3Vs4pdjjKCkMMkuIQcSH_Gm69yl3XS7bHsCYVcNRzPCYD
    xyBuihwvUldii1qQCN0xKWYiRc0i8xxgy_KRtbx4qlHRmBJtpxpydHt>
X-ME-Proxy-Cause: dmFkZTFsSQI6puzxGTFuElVXBVrDBPKpLl68RN/U+uHZUWvFxx/LcQxPM2Osx4tCE80LTc
    HAeM+eCNOYBHdMl9Ol5Rzt1gE9x2fUwud8WbFoYfnNvglvXCIco2MZQRQ1ZTGWe+HG/KlQ
    EcsWWOMFVL+BgAWQpE1mqa/FFMgPd0etSh1IoCXjDaHWqNzT5/CYb+hqwT9vFz+RiVU6N8
    2L2k0SZpvflfQZeNvSYyDWSQy7MkQIXiBs7KtMyVVgOeYZIlQ+/vUK5OND7iHYZW7MExAc
    1EtqM9pBx2UnFkTGz0p07WmYNzlxbUSRBgOXY90J5QwA8SvF9FU3+hwQo+nZsA3gsxqwBU
    AaZqolcFzn5i7f0vkRw39tm4Tyft8Tuirx9sskLczdnyKPaq9lEvL/DmLPDwUH4OgO+i+k
    pvgLKQx53o/WA0q8dw6qkegIN40nPD6WLxOgLCVbgWLy3pXeKcSLDNQZ9OTq6M4sN0qbWa
    fRVR5aFVg0lBxrhrcmVjTfPioEgwcK2uiKKVOtgd5FVzjqrhbjS9LmZYE6shMoOk1oRlJO
    NT490Te6GZdSX0Jh/LKAI+DjN3+Pao3OzPbjQPsl7oTOegY+L/7Lm4d+ZAjfvhdWtK+Glm
    +IZexPy6IwU/y1teXFSlXdnu63LXUPqlNpKkq4lYc2HXE9Lm3xP8Hej7mo0Q
X-ME-Proxy: <xmx:vwijasZVByI07pUtncwdXrSNj_JcJD2JDX-3rP-Jf7XlZ2255Penmw>
    <xmx:vwijaowA0jw_7d_BXVyrLL9xO2n1AOik0owjeqQgU8fC_YdCs71uyQ>
    <xmx:vwijagPDrhYkpMfbqbq5qk6mW25ZAAp0Wuy_ppI59zNMUa4qtHUOzg>
    <xmx:vwijau5wWBDjoYnIVOpnv-AnxWfL3EFVsSMLzxTlLymk9JKlHHUBzA>
    <xmx:vwijaufyKwBFOOhPRiPGpsV-NSwCSiNlOBqeL1y8jvwLlTPak60EKXiI>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 7D4767811F0; Thu, 10 Sep 2026 15:45:03 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AUcfVFBzQN6c
Date: Thu, 10 Sep 2026 15:44:41 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "Donald Hunter" <donald.hunter@gmail.com>, "Shuah Khan" <shuah@kernel.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, linux-kselftest@vger.kernel.org
Message-Id: <937d96b5-0163-40a0-af2e-76c0ce9c0834@slotpi15m67>
In-Reply-To: <20260910-nfsd-norpcb-v1-3-b4d5182d634c@kernel.org>
References: <20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org>
 <20260910-nfsd-norpcb-v1-3-b4d5182d634c@kernel.org>
Subject: Re: [PATCH 3/5] NFSD: honour the userspace-rpcbind flag in listener_set
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 10 Sep 2026, Jeff Layton wrote:

> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -2111,15 +2112,25 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
> +	userspace_rpcbind = nla_get_flag(info->attrs[NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND]);
> +
>  	mutex_lock(&nfsd_mutex);
>  
> -	err = nfsd_create_serv(net);
> +	nn = net_generic(net, nfsd_net_id);
> +
> +	if (nn->nfsd_serv && nn->nfsd_serv->sv_no_rpcbind != userspace_rpcbind) {
> +		NL_SET_ERR_MSG(info->extack,
> +			       "cannot change rpcbind ownership while a server exists");
> +		mutex_unlock(&nfsd_mutex);
> +		return -EBUSY;
> +	}
> +
> +	err = nfsd_create_serv(net, userspace_rpcbind);

This ownership check lives only in the netlink path, so it is
enforced in one direction. Consider: the serv is created here with
userspace-rpcbind, then an old rpc.nfsd writes a socket fd to
/proc/fs/nfsd/portlist. __write_ports_addfd() calls
nfsd_create_serv(net, false), which returns 0 at the existing
"if (nn->nfsd_serv) return 0;" without looking at the flag.
svc_addsock() then goes through svc_setup_socket() with pmap_register
set, and svc_register() returns 0 early because sv_no_rpcbind is set.
The write succeeds, and the new listener is neither registered by the
kernel nor reported to the userspace owner. The reverse order gets
-EBUSY from the check above.

Moving the mismatch test into nfsd_create_serv(), where every creator
already funnels, would make both paths agree. The extack message would
need a different home, but the errno is the important part.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
