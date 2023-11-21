Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F17215AB
	for <linux-nfs@vger.kernel.org>; Tue, 21 Nov 2023 00:45:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b="TVS0p6ta"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A1739C433C8;
	Tue, 21 Nov 2023 00:45:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
	s=korg; t=1700527556;
	bh=WydedWHI5hgSzmjYaAgFcEvQrWisnvd0Tah1sl3VwoE=;
	h=Date:From:To:Subject:From;
	b=TVS0p6taouw0TgFtgakwtmwzksHgfih/TAtxxM8blDBaM2wpZcmJo0Nrbwa88ySj6
	 87Dx8/t877CEaNV/X8EYu6bEhLQyYzKpc6TEmm5m8AdU51EQ3VSX+w5PiDr921If6G
	 bZVbwaQOqRgXjdeLdqFTtHykJQFSbBdMR9WUykgk=
Date: Mon, 20 Nov 2023 19:45:55 -0500
From: Konstantin Ryabitsev <konstantin@linuxfoundation.org>
To: linux-nfs@vger.kernel.org
Subject: PSA: this list has moved to new vger infra (no action required)
Message-ID: <20231120-acrid-rattlesnake-of-chaos-dbd58c@nitro>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hello, all:

This list has been migrated to new vger infrastructure. No action is required
on your part and there should be no change in how you interact with this list.

This message acts as a verification test that the archives are properly
updating.

If something isn't working or looking right, please reach out to
helpdesk@kernel.org.

Best regards,
-K
