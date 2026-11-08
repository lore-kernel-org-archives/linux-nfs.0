Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794106229;
	b=lzR4Kavk0n1qOTJ9U31QzNzsKtvViYM6OGtPR1XhhGA9Weyewj7MKaJPIy/gNYBhGuEZ
	 iZj/xAe+swzRUs0wxp1yIQYmozZeO5LySP8yvhFpxzh6m45GDIq62c9uGhtWOF8IJnLJ0
	 s6aB32Kqpn7OoM8EPm0lCeYxiaFrl/iV5cSIwiH/L/0usrnUQR/39Kx4fbx2V661Uj51r
	 IM0oLX6xnTNlBRBh1tRl1OFgd4pRBtrS2ZwngmhvpzcRd7MltkCcY744vL7BA40jYiwHA
	 XHEQ+HWqpHw8uEiZC+Sx9WkDf5M9RxMNuo32lwp7BhC299sowdEXccgGRBUxayeF+Lg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794106229;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=+XgAKvL9Yz88WJI2U+RHkRWBYREJXUrZL2P4iN0ZY3c=;
	b=LVpQjzc5ThX+JSIxU1EKkLHJgH+GNb+l70In2YjwsXoomSsg8WwuIlcWtFQIlQXI3fq1
	 NkEaq72lkJv9XCsgbPIPpRUPE0u5ivwOToLfYbS8OtteWJhV4teKBlVLey35YfA1c7pft
	 kivG3pXXsIs4DjVOEDkhhLf3n8dA/U4KGMLrhrvygDp6Shat9U9hDuPWa+oAZpLNjFBuC
	 /lpJGYUFLKlrpm0BQqtKHUblHSsEDscMJjf81Kbu2/OOTJqIsk4VYSFswj3jmIvkWhqBK
	 /fsW9NBtAzNx23Kv+lUtinmzQ1x7nQn2TWwZ736hjPQnXwhLv+Z5ArE37TyJ5lKfxgw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=rV9OCWC5;
	arc=none smtp.remote-ip=209.85.128.46
Received: from mail-wm1-f46.google.com (mail-wm1-f46.google.com [209.85.128.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06E8F606A31C
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 02:50:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 06E8F606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=rV9OCWC5
Received: by mail-wm1-f46.google.com with SMTP id 5b1f17b1804b1-4a5720b0a57so3870135e9.0
        for <linux-nfs@vger.kernel.org>; Sat, 07 Nov 2026 18:50:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794106227; x=1794711027; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=+XgAKvL9Yz88WJI2U+RHkRWBYREJXUrZL2P4iN0ZY3c=;
        b=rV9OCWC54JHnc2+elgYOl3F1cX5u5r2YX4E36xLsQbCNz+QaH6o10fMNpaqruDMCjU
         7w1i3BzMQXB8vvFjokaJEQ+5iD0QCIYQGOm+wQWv04cnUESwY9YB1o6wqFrTQqetE4Gn
         7JEzOWyLwbZ852yIybo/pV7ZqesvThY8h2zZUxyqg2yDLpT6TYzBhleGvnzCA4btnOYk
         PTCGmzKgjmyhhcK/qJPYdhjx7gbUJjiNo92kXyH8esiEcEoTZ+Nob2yGg6yC0c58/Eeu
         KdX2qoR5gl/FnwNco4JDmIheY3c/oC1rF4lbZmbKmJ76yV/x7wbLlDq4XJOrTY1Ml278
         fZbA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794106227; x=1794711027;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=+XgAKvL9Yz88WJI2U+RHkRWBYREJXUrZL2P4iN0ZY3c=;
        b=VwWq7RjmLAsBFjmNbzSs9rjpgokWXhX74pwEtIaF0I0KXg24hrF56Ve2a/tXKm4+Ry
         GwKf7Hlg4bbfPq2+neHpG+3nSZU0pw1gNUYT2ZeSv8LH2lWKhKDQibf2oLK0DDVD/sIe
         CcVyTxgxuXDGyu5ZO1QiRiEN6T/niJKvYRZzvwMtntNH8SctgEIz5mvxrON8uR3jpBmw
         rVuRyUt9VG6TOk/LN8McZrYt8DgS5hfRU9FSMERlcIKZGacFF8JOidr13WFBYgV0g3Dp
         Ud6qWCnsvolO4LecpisvMV5vmdJhqjXtvyFxPgYSudJJqmglTdHiFYMUqNAEVJBvO9p/
         uAog==
X-Forwarded-Encrypted: i=1; AKwUvByYwYHi37ci8YLN34KMZmNcGEYfK/GQIMwaq6ktTwP26M7655u+LmG/FDw7KADnmmhN71uXa+2WCy4=@vger.kernel.org
X-Gm-Message-State: APuU4Z9swyYNRYVS/WJFxdSarAxQpjUBJ08b6BzUs7fdjY3Vzpru0niR
	bD2lri6KlBeH9Y5HK9cnrFhd4nETVXek3ZD65gDBGhRaHEyiyRUscBMv
X-Gm-Gg: AYBFou2FtWyicyvqqZr62GvW357Z9zsOXAPIlEl9KmCPS6ATXoIUjKrq8pXT3NF9qw3
	SiakFMykfoWBrjapuI+OgQDEvujvf8rinu2ejri7zWZwB6QzB2YJM4mX5Pv1CJqg+qafJv+45zW
	/u7kojJN1Q+Eyw8m2cXnfpjcnmLlayqTHPCcVYW9OajtOjN/ZojIJ8IoBz3XH6DgvbXhhsBR8ab
	VeBJI/6vAHJKQhP33LhRKPklF9n59zx0N8LJsP0/UCZvJvblvPm9Qxvq8I28h0HP7NS6e+DS0Ns
	G8cCZc1eSomL6IY3dNlWCxRUK3pjjvXMZZhqcq1p/Foqnn9KpRY+ia9BF4QBv5jH4WnIu5FbeBx
	l+LBuWuplO2ZHYZdYN+oZX5lbn3uBaXVKPXMbJlL2Xrr2f1pbpD0WxVNiIHRlzniUBHZ2XkYs3U
	IBv5TMHCqDgdzEb9820crC0Jk4XnZGSwNLPnI2wqeR/n0g03tx2uN6vJMGximfL3ZeFXBoZPgnQ
	Xd1v9XVToMWYO2J1mBozysyXl652RLkJ+9vE3K9I0J05W/VbCsliXOxHRizFyPCmoGd7p3pBwhu
	zl8irtwENZ4xBSNhE5cqFLXA4FeEBCeNOaoW6kPp0HkDLrNPqGnDEdUIV+pp/xzlVkthDjPJdJZ
	mBg1rfn5paNzDRYZm+6K4EZ9KAjjs7lU/2QqsCl+KgzxqLzksRT6CUjt3YWpW9tpcUQ==
X-Received: by 2002:a05:600c:190e:b0:49e:65f2:db64 with SMTP id 5b1f17b1804b1-4b960d9c5f8mr7744875e9.5.1794106227158;
        Sat, 07 Nov 2026 18:50:27 -0800 (PST)
Received: from maria-VMware-Virtual-Platform ([187.55.90.25])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4b90f10c681sm22969665e9.10.2026.11.07.18.50.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 07 Nov 2026 18:50:25 -0800 (PST)
From: Maria Sheikh <mariasheikh812@gmail.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	rostedt@goodmis.org,
	mhiramat@kernel.org,
	mathieu.desnoyers@efficios.com,
	trond.myklebust@primarydata.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-trace-kernel@vger.kernel.org
Cc: outreachy@lists.linux.dev,
	julianbraha@gmail.com,
	Maria Sheikh <mariasheikh812@gmail.com>
Subject: [PATCH] sunrpc: Remove unused rpc_socket_reset_connection tracepoint
Date: Sun,  8 Nov 2026 07:49:42 +0500
Message-ID: <20261108024943.8130-2-mariasheikh812@gmail.com>
X-Mailer: git-send-email 2.53.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Tracepoint definitions consume kernel memory even when they are not
used. The rpc_socket_reset_connection tracepoint has had no callers
since commit 4efdd92c9211 ("SUNRPC: Remove TCP client connection reset
hack") removed the code that used it, but its definition was left
behind.
Remove unused definition. This reduces the size of sunrpc.ko by 628
bytes.

Fixes: 4efdd92c9211 ("SUNRPC: Remove TCP client connection reset hack")
Signed-off-by: Maria Sheikh <mariasheikh812@gmail.com>
---
 include/trace/events/sunrpc.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index ff855197880d..a0d02d735a7c 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -950,7 +950,6 @@ DECLARE_EVENT_CLASS(xs_socket_event_done,
 DEFINE_RPC_SOCKET_EVENT(rpc_socket_state_change);
 DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_connect);
 DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_error);
-DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_reset_connection);
 DEFINE_RPC_SOCKET_EVENT(rpc_socket_close);
 DEFINE_RPC_SOCKET_EVENT(rpc_socket_shutdown);
 
-- 
2.53.0

