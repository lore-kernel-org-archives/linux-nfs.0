Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DA2839E191
	for <linux-nfs@vger.kernel.org>; Wed, 17 Jun 2026 13:38:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781703508; cv=none; b=qP5ZNU8JibPGYnVloT5VSIHNeWBhXRRKEb3QvhJPtNl1X6mEmRwzTu0NANYh81q1nLaNCYrf0SONzQ5rL0r4KaBjjTH4Rc6219OefxQpmtazKfKLS0uAGewYMFHzPoq5272jrj0VFXmqrAfij1ZueiKsuf6ofX+n5nLZ7Ws7gnA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781703508; c=relaxed/simple;
	bh=7MPv5E+z+UaFdS262rpQHJcc6n6yM8XtnDfhyqBA2ac=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=FNtgGBb369rqO7xZBlPTD5zqkBkYWGzmi5oWlzkq75//J7ktKknAXjlETqWHQwugp4Edzuqxh3vHlKMpB2XFl2OscfGU7DuePtWcmQBTRBODTMhuNVsSQRfu6pf2bMFzKF/5ka3vfL2OY5dkPrMJXMFryXV2kSNKAuOk8R2hD/4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=d+Jt3Dn+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="d+Jt3Dn+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EC0741F000E9;
	Wed, 17 Jun 2026 13:38:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781703507;
	bh=PkLUDAefJCEDfLfM1Nbes++7zE9nYNU0bAMKUKrJzLg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=d+Jt3Dn+9Gg66wwgrgMPxW4sCILV+KjSl1M0WGDpKbT/JdMBdDeDUNWVUtKV+dzfG
	 P8Pnx5w25dGihF3KFrrnvApK2gipQ0sFw+MFWytZvZwxwkND4hLWYLMd9Yx3ulU2Ks
	 u8PpVJdBzf4HocEbJExUhaV/SjA+LIvIPV9q3tpUmwdYrcR3Ril15xcfwdsprIr1VY
	 6tSvzdI423VbiwdjJYQtve1CAdFHMH8I5nwRS8sfRRS8DQ7w5/n1o34BnbnVef7gMB
	 7W3YjwaeaJ0vv8qQ5wf22hLTU4CvGP/ZZlHCnnu/23FZdwIR2TiDka/+XiIYi4FyZc
	 BWzG837KXoPiw==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	Chuck Lever <cel@kernel.org>,
	Oscar Ou <oscarou@synology.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] lockd: fix swapped arguments in nlmsvc_match_ip()
Date: Wed, 17 Jun 2026 09:38:23 -0400
Message-ID: <178170349726.1539549.17398579325429557639.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260617075738.1151797-1-oscarou@synology.com>
References: <20260617075738.1151797-1-oscarou@synology.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Wed, 17 Jun 2026 15:57:38 +0800, Oscar Ou wrote:
> When releasing locks by server IP address via /proc/fs/nfsd/unlock_ip,
> nlmsvc_unlock_all_by_ip() calls nlm_traverse_files() with the server
> sockaddr as the opaque @data argument:
> 
> 	nlm_traverse_files(server_addr, nlmsvc_match_ip, NULL);
> 
> The match callback is later invoked from nlm_traverse_locks() as:
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] lockd: fix swapped arguments in nlmsvc_match_ip()
      commit: 80e05cc8a30aec76f4457a9c163b222e9ff5a671

--
Chuck Lever

