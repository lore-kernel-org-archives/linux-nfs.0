Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792783710;
	b=B/qCJ+LgxWzjnEyaxw5G0iJIS9Lva6kK5KJqtqlkYwZmwzL6A4yw/OrEQV/5/0Ac6FtH
	 Zqh6r7YEABAvzUjpSvqFSCdFgk7NFpzvJjE1ul3KslZGXM8kZ4SDfe4fE6aHcybkSw60Z
	 06NmLwTcVZ3iOebpOQ2mVM41R3hGtSZcScLg6/hfvVflLw6Brc84ix6fOl+DLfmHEp2yW
	 orKUr1xmXMHiWQEcnn4GauU1wBhB1b4FQffvwYFHFiQERaKbnN0dziB4GOtyGKxMR++P0
	 nrLLSU6BMFzy1FgIT+VK2kPfcjR4Mv9/pSrl1vF/FM5eHodH9gP3zT8y7kdjWnbxxZQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792783710;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=YucjGLPVfjFQRU45mLqNxfKpDbA20oUVWgMR9JAb1tE=;
	b=LHAg783mebT9rdccBpkDhcLR3XlAyuCrX7VyxYzEvzj0dY7ACGtTo4HKbJ+XXyIJl3nZ
	 KlLJPGP7Jus9kladBOHacDxYVXi2LTlJngi99Ebee7YbKY8DWXnMoI9VqJj105yUbpbk2
	 DF4tzaMx8+TZ1SrLPM5yTFtGqu6W7DqYvwEQBsCavAxLQd03kwg8g/h6dB/xqAsKyrT0T
	 pQ05KN2bt3VW2dk+FT8Hlci9eDvYUjFd5G+CQ18l/yasGBdHc9wm3UgMwgRhQRA2HlpHY
	 1jX88hmzQ+vDXxjY4UM6yci/lwMbl0NSCnBMSlVs46DEgna3whyvoW1PsXwUseAiOvQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="JonC/Jn9";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A1B3606A31A;
	Fri, 23 Oct 2026 19:28:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JonC/Jn9
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9F02D1F031E0;
	Fri, 23 Oct 2026 19:28:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792783710;
	bh=YucjGLPVfjFQRU45mLqNxfKpDbA20oUVWgMR9JAb1tE=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=JonC/Jn9T6OY49KXRs1GsZTOkh08GSA99/ao6MYQ1MA7foTSR0tx5bg4bBcxNg+8M
	 HuBl91H7aA3wamOBU16/KO7UMshN7wEW+hJdX8iGulywrSpHn4Oddy33f4VwmbRBE+
	 /0VgIYUDvab3kLgKNZcRV99kYRn5dgNv05jcjeTKH7umYJ7P8bIhCYjm5MMFYyAhrU
	 JFOB1VqWhgkSt4NoH9d7oCGYIhHVcmyIwttOXCVuL3fN7UMhKaX5Oueqjmwx5VUKIP
	 +EXfwYCnOH5aVYWvJ/SXb7Jq3Wvjo2YdufcVFy7Z8bopeihAi//YB7o1bko5fCX+4P
	 KdER1PHkUVtlw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id B42DFF40067;
	Fri, 23 Oct 2026 15:28:28 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 23 Oct 2026 15:28:28 -0400
X-ME-Sender: <xms:XLXbamPKaYrOct-oPCf8AdL6uUqpW8LZ1opzc5t0nxMUPIOGMmaJsQ>
    <xme:XLXbavzxskPNp8AoNDVeQCKeCKvV_N65gYgVSIbwlBw_GoGPuR4p2Jhap7VbGz9aQ
    s3zd7Vx5_JFlcFKI9fGfCMbWAn7Pgr7TxaO2MsyPOrxtlMVMzoQcI4>
X-ME-Proxy-Cause: dmFkZTG2L7w9+ScBpps3pcT0gwT0auqlzz1dl7rMhFhKSOXbas2lU+Y26mDIzeydpBNhn4
    JwRaDiu+jXZdhEQHtqEqxEAulDYDADlNfr46ksPsTKfZaJYnC30pv68fkfNcX2aH1I4Bjp
    pK7GorRcJPYVu5g7KXJXZvHOa9F9rQTBuqEmGaPo/7/lxPG6TwTeGgP6/OQC1xe6MVru3w
    FSrSOXcMkT0AbUAb0HxM2FJuE3YYtx7Q5+WgF9hoX0IDgUR0pJsHYaSkzn5/1mmnsq/WrB
    yGvHSzv9klKbKfXL4fKD9b8m1cgUp9/FC2Ud0wsPvF6FbJpf9PMXGjIhyIwNn6O2t4DQfm
    7WAvklUskMvjTvsoiaQimItyQpq4pw+uQYCsIGKDHGgQv0OTBwlhs4eRI7l7LXwxJMJxzq
    uHLU97pljr0/np0wxzeux4NtwEHjo0Ukj1/1v78iQfTSksbfJ4irljXzNLO6dePTXWbC7I
    7PnG7QVH5Yb9Ey3BggdiEoPyvMUoUrms2tKzafuvyADkwa5ugsfnIMezIH+hQAFrDk6IRV
    Ty/sO5BhRquQL3rIa5RaLAKlMYgApwCwIykUsRSJx2vXoOYTSaC22SLkRwEdSTjhEJMmG6
    pwB5PHwsVQih0034lMqN+Ai6EWY/wE+oJRAvLOSnnO585GhkIJnODMIkSv8A
X-ME-Proxy: <xmx:XLXbahfaBil3GIisT2k61LJkr5GORrfY_vMLFVWYeZcAKHorhXXg6A>
    <xmx:XLXbarkF8N8mO-13B8YvVMQNxBgXSPXY8Xg-zOSOB_DIWVegzSDsRA>
    <xmx:XLXbau82nvWdN0mHDqyyMsfSKZWOLxRy4pcPZ_RlrNl7gLXReI3ryw>
    <xmx:XLXbapEyQScfJc7xAAlMzKDHdL6aScjLrfym051jJNLr9pLg_esnVw>
    <xmx:XLXbaqJto1JIcjYjnFHJDRl6pOex_IipizShwDEzc5o5uKJDgg5AWL0v>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 95437782738; Fri, 23 Oct 2026 15:28:28 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: A6RPtEbxHI2V
Date: Fri, 23 Oct 2026 15:28:08 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Li Xiasong" <lixiasong1@huawei.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, linux-nfs@vger.kernel.org,
 linux-rdma@vger.kernel.org, stable@vger.kernel.org, yuehaibing@huawei.com,
 zhangchangzhong@huawei.com, weiyongjun1@huawei.com
Message-Id: <bd63c152-702b-4043-a4f2-092593c0dc1a@slotpi15m67>
In-Reply-To: <20261023125033.528835-2-lixiasong1@huawei.com>
References: <20261023125033.528835-1-lixiasong1@huawei.com>
 <20261023125033.528835-2-lixiasong1@huawei.com>
Subject: Re: [PATCH 1/3] rpcrdma: Serialize notification registration with device
 removal
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/23/26 8:50 AM, Li Xiasong wrote:
> Use a module-wide mutex to protect the client-data lookup, removal-state
> check, notification publication and reference acquisition against the
> transition to REMOVING.

I thought a mutex might be a little heavy-weight, but registration and
unregistration happen once per connection, and NVMe has used a mutex
for this purpose since 2016 without complaints.


> +	mutex_lock(&rpcrdma_device_mutex);
> +	rd = rpcrdma_get_client_data(device);

The kernel-doc comments for rpcrdma_rn_register() and
rpcrdma_rn_unregister() should now carry a "Context:" section
noting that both take rpcrdma_device_mutex and may sleep. The
unregister path is reached from rpcrdma_ep_destroy(), which can run
from the CM event handler, so callers need to be able to see that
requirement without reading the function body.

Otherwise this one looks good to me.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
