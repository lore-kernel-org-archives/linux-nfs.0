Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A91838DC44
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 14:16:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792160184; cv=none; b=VI294XrCTLuxHUejaQMpzxQc1znD3vLB4FZ/x/+dajn6E1wAulq7mI6jKS75hw0PMMHkW0/bupdnE3QnKnV3r9so8b7X5lTfYjz3/hLVr5LSynaDFH0j3cAL4e/ORVwCfF183qHhr3a9s/izwl+YeFLZxT3H/EIMwfb9LuQHKXQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792160184; c=relaxed/simple;
	bh=shry/UdanoxHfF8BCk5uBEnZLfJqo9y0D8UoJxvuP44=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=WGkp+x9tuqEYZgRjd4OBsNThhXieBiBJggAv9s/TYf1m+HGQ2dum11UNGb0lGfUlQN/8ubnKXLHTtV9B0d09MYHqjZP1WaNs4nzXAoXhUz/vMs1G3UT2X8ls6E0hUMMy0m4Q4WFLxKgd4F2qx1glIuB5az+6YIvKTBaT8HVasTQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UOYQ6mg6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UOYQ6mg6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5D7231F000C6;
	Fri, 16 Oct 2026 14:16:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792160179;
	bh=pa8zKPwhs9U0+idYsjoyYRHGkPIjRu/VRuzOZ6JvcTQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=UOYQ6mg6y2Xk1nxx766NLF++Kk0HLjGP2871uDK2IC5ZMt+aZfi6s8EX+a+DVwfdh
	 8dr53ulLUqL98jldkm4yZ7071KeJL2uDZX3XcD4ybw/wWoat1stvQ1vkfAct78rmXu
	 17ZlHxGfjMXtuRrUf1uO44IQkfyWyuAE2Sbo1cQDGRXe+9fQOL5MIwI/Jr7toHpnVB
	 u29H5nSOb/rLGYK5mWRVOdZdEkT+UWkCaVuH7fK9RDn+6EF8QMOrQOnx0zkedBnzmT
	 9E7tzMD/JlU90tWBdcVtQQYY9fZ9IneyFO/gBQI5arWUkZ6525nC2ra3I5z5X7qWVz
	 k/lRbpzc9h1zQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 16 Oct 2026 10:15:37 -0400
Subject: [PATCH nfs-utils 1/7] mountd: accept -L for --no-netlink
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261016-netlink-noproc-v1-1-42791f4b6eb5@kernel.org>
References: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
In-Reply-To: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=894; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=shry/UdanoxHfF8BCk5uBEnZLfJqo9y0D8UoJxvuP44=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq0jGxPOWHbGmPwx3FahMt9Kj/JJB3EVeDW4QPY
 4tArGI3miWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatIxsQAKCRAADmhBGVaC
 FVpbD/0dKKIwVr82HOrBmUHTkkmWJ2aqFUiUtz1kwFaTeLbpSvhxDDNnT9hSJTKRgIfiQw9zKdW
 w70vrNiPuaN7sllkUVVaSfizkTEiPBfSScEqUd2a0HxaDJeaD48JrXWWXl2CGHmuXV9uJdulE4v
 uGCBlOlSTghDjx+yMdzS2U1j0B1Z1U7qj6O+XYsSoGsgqXEIWLKeSoFQmx5ltesZvUify0cKf+i
 zjRfkzS/FsffYnhMqA139NurMn0hH3vCVzGbobMHHGkxNytJe4vufAMweQEzm6UsYRLO1pL8FcB
 KFCDosK/5mb9QywahWOvhDMpWOAzFbJvR7U2EfEeqfHY/fK0LzkFGfVP9Cg1lDepIRmQ9P9MlWc
 s9asEO/O4gmMuZug4GqzpjS4IJJoQUBcDCQIcbkSuUACSk5BXSgHr4HXi3eBTmxdyN+H7dQZLop
 Ej7HG6JuZcnUa0gX0rxxpLBMStUVkBfFM+ncyQaoHfbV8itvJWlxb9mu/F3Y5uK0C8TlEhiMtkD
 l8LUgQjNjj5AxWtggiVveo7LpQaHGvq4DU0b1RHYE/sIFtHLisqKurI7jGx0l7wMznvp+1vK7UW
 IsUhoZgrCmbYgqdi/D38ftcS0wxvicsFIN0EkvZfM7q2r62YiJeCCrnOXoSYoKJNCUnywY7E6wN
 3aHjptzkP+odRNg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The -L short option was documented and handled but left out of
shortopts, so "rpc.mountd -L" prints the usage and exits 1.

Fixes: 60c383830537 ("mountd/exportd/exportfs: add --no-netlink option to disable netlink")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/mountd/mountd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 92d8c4690efc..da1124b5c411 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -81,7 +81,7 @@ static struct option longopts[] =
 	{ "apply-root-cred", 0, 0, 'c' },
 	{ NULL, 0, 0, 0 }
 };
-static char shortopts[] = "o:nFd:p:P:hH:N:V:vurs:t:gliT:c";
+static char shortopts[] = "o:nFd:p:P:hH:N:V:vurs:t:gliLT:c";
 
 #define NFSVERSBIT(vers)	(0x1 << (vers - 1))
 #define NFSVERSBIT_ALL		(NFSVERSBIT(2) | NFSVERSBIT(3) | NFSVERSBIT(4))

-- 
2.56.0

