Received: from relay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2CB2E26A1AC;
	Wed,  8 Apr 2026 00:40:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=216.40.44.11
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775608853; cv=none; b=scv9kOwn5r7si42KZEYLHocQ3IOxLhubCNT9RWVwTjINEz6Gfm2k1OQsKeLzqAxUVMj3yxrMCeykkuK4UNwZB4U0OTYP/n1SQb1mYJo2zfUah2L+3+7maFzbwkvY6fEVGRmVvRrxGzyjknxm7G2yK8uPG4AVl5SaLVlH9PH3g2w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775608853; c=relaxed/simple;
	bh=Cegwari8vptxDKvjR+0BLUPedC0qGVpLh1ZQOMxlgvc=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=LruoB2JA32kpBlYEfbOprdQvPxpHvLdhow9663kiCI56t7nfr7ndoR6H/wISH2Aavh2W4e+Ofri5+2pjuEhS89VeOG5aubKkPAqm/6MNJFuFJZq6XjeZrMpDv0xZQ3cqDW3qJblDbKWL6j8sLnu+GOgjprZrqRCINsEO3q+9Zf8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=goodmis.org; spf=pass smtp.mailfrom=goodmis.org; arc=none smtp.client-ip=216.40.44.11
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=goodmis.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=goodmis.org
Received: from omf06.hostedemail.com (a10.router.float.18 [10.200.18.1])
	by unirelay06.hostedemail.com (Postfix) with ESMTP id C376B1B83A4;
	Wed,  8 Apr 2026 00:40:41 +0000 (UTC)
Received: from [HIDDEN] (Authenticated sender: rostedt@goodmis.org) by omf06.hostedemail.com (Postfix) with ESMTPA id D6ACD20012;
	Wed,  8 Apr 2026 00:40:36 +0000 (UTC)
Date: Tue, 7 Apr 2026 20:41:50 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner
 <brauner@kernel.org>, Jan Kara <jack@suse.cz>, Chuck Lever
 <chuck.lever@oracle.com>, Alexander Aring <alex.aring@gmail.com>, Masami
 Hiramatsu <mhiramat@kernel.org>, Mathieu Desnoyers
 <mathieu.desnoyers@efficios.com>, Jonathan Corbet <corbet@lwn.net>, Shuah
 Khan <skhan@linuxfoundation.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, Anna
 Schumaker <anna@kernel.org>, Amir Goldstein <amir73il@gmail.com>, Calum
 Mackay <calum.mackay@oracle.com>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-trace-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 14/24] nfsd: add tracepoint to dir_event handler
Message-ID: <20260407204150.6bc1cd73@gandalf.local.home>
In-Reply-To: <20260407-dir-deleg-v1-14-aaf68c478abd@kernel.org>
References: <20260407-dir-deleg-v1-0-aaf68c478abd@kernel.org>
	<20260407-dir-deleg-v1-14-aaf68c478abd@kernel.org>
X-Mailer: Claws Mail 3.20.0git84 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Rspamd-Server: rspamout07
X-Rspamd-Queue-Id: D6ACD20012
X-Stat-Signature: a58i7egn919wo5bfc1dijgryt4aruch5
X-Session-Marker: 726F737465647440676F6F646D69732E6F7267
X-Session-ID: U2FsdGVkX19wpl42ANRPgMmD+SVWM2QxvjbmYGpmFKs=
X-HE-Tag: 1775608836-706489
X-HE-Meta: U2FsdGVkX18ILWolfDCcJNYxXZsXn6fYE/yJQ0Hd5qi1oONwm0/67OtFIHaBlcfJprHD1QzYu1HPkBTF6L5jaUy2cun50LXyY7G1rVbBMMRgYdtW2LTvIh84r+ttFdtCPpKLr/FJGl7f45ETWiNnVGC90PW8QIA41Opt245d7/SUyNWV0EPWuS0WJU6Joqv9kQIYTZaEIeo8kpKbEEOL/faCQzqLp9vTto3WflI/UV16ylb0YNjjr0IhKl3mhrxqFieedMMtgX2Ki+UzQcIKPOi0Nprsj+C5xeNA2qhhWgRilHph8Sp1YO4y30MCBrihOGQH8nJdhdmf8RHadW0eta95IALDOfcIxsm/xyXPVgC1jE1lb5zjGM6YASEfCky9ZgSLHHns3Fsgi6Q1p7LKVQ==

On Tue, 07 Apr 2026 09:21:27 -0400
Jeff Layton <jlayton@kernel.org> wrote:

> Add some extra visibility around the fsnotify handlers.
> 
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/nfs4state.c |  2 ++
>  fs/nfsd/trace.h     | 20 ++++++++++++++++++++
>  2 files changed, 22 insertions(+)

Reviewed-by: Steven Rostedt (Google) <rostedt@goodmis.org>

-- Steve
