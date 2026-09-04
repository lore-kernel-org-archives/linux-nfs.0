Received: from linux.microsoft.com (linux.microsoft.com [13.77.154.182])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id A41A736F434;
	Fri,  4 Sep 2026 15:13:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.77.154.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788534787; cv=none; b=UpCT6/J/e1xbIZa9Iwk3FTXoKE9zSXj4lkN+qHW9oQfFLe3oZ7iwBoDO4GjjNvnD7ujg091KmlBol+xPNuSeXnGrRdjCxiOX6jsVcSjA4cdCKJaS6HEOam4VcFyry2vTu7zmxq03oWy3+Dltz58FjL04ggKRt0Ja9uredGVPfQ4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788534787; c=relaxed/simple;
	bh=RXrBZhE/ukpzVTZYI9deZoWytyqusRSvDISlhwKvQ/w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LB6eo13Yr3nSrvbj9XFfo28a0HM1ta3I20akhcSF8Xi1SwlDV2iIRScvSKAMGgfGQHUYNANzPXtP0P2RW4DLbeUfRzyj/K9n1EOFW0+trZI4eePteLgo5H60C3CBP4l2aZS9qOsVyAE6ssk5PJHHXwL/1AztIQsFTEQ9e8jTMlk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com; spf=pass smtp.mailfrom=linux.microsoft.com; dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b=rZydSQVj; arc=none smtp.client-ip=13.77.154.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b="rZydSQVj"
Received: from localhost.localdomain (unknown [4.194.122.162])
	by linux.microsoft.com (Postfix) with ESMTPSA id 6274A20B7167;
	Fri,  4 Sep 2026 08:12:19 -0700 (PDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 linux.microsoft.com 6274A20B7167
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.microsoft.com;
	s=default; t=1788534748;
	bh=n7au8vxqsflc8mQdS/nOVCGhh6qmoyLCUlVGbYJqjJA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=rZydSQVjmEqpCD+wZ9AR7DUKuMBbLgxUjcolSDRu4biE+pKh43hbiwXIlkdHGKl5u
	 sLI0fUXqVuThhOM5UUx/K7onnFFXp6A878mAgosbv/GRTbZqnYXEzRbXIVzCWgatVF
	 7vySEi/7uaaU94BiNhE/Wrxod+NshnL/oTCPI0Qc=
From: "Cen Zhang (Microsoft Security FORGE Labs)" <cenzhang@linux.microsoft.com>
To: gregkh@linuxfoundation.org
Cc: AutonomousCodeSecurity@microsoft.com,
	Dai.Ngo@oracle.com,
	bfields@fieldses.org,
	cel@kernel.org,
	jlayton@kernel.org,
	kys@microsoft.com,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	stable@vger.kernel.org,
	tgopinath@linux.microsoft.com,
	tom@talpey.com,
	xmei5@asu.edu
Subject: Re: [PATCH] nfsd: hold cl_lock in client_has_state()
Date: Fri,  4 Sep 2026 11:12:13 -0400
Message-ID: <20260904151213.44891-1-cenzhang@linux.microsoft.com>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <2026082828-palpable-dingo-241b@gregkh>
References: <2026082828-palpable-dingo-241b@gregkh>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Fri, Aug 28, 2026 at 07:29:11AM +0200, Greg KH wrote:
> Please use your microsoft.com email address, and not a random gmail.com
> address.  It's kind of odd that Microsoft would have to rely on Google
> to send kernel patches :)

Thanks for pointing this out. I now have cenzhang@linux.microsoft.com
set up and will use it for future kernel submissions.

Chuck, since the patch is already in nfsd-testing, please let me know if
I should send a v2 from this address to update the author email.

Thanks,
Cen
