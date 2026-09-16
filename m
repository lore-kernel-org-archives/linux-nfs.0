Received: from dog.birch.relay.mailchannels.net (dog.birch.relay.mailchannels.net [23.83.209.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3A41233920
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 00:08:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=23.83.209.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789603713; cv=none; b=X3qIgx08PBJmWvHxdgJLHu5BMR+d6GxF3WNrZC5YOw4O1L6K9pAeGmIWYu4Oym7+NQV5C9MYGFhccOMNXI2YJBEYf+qy46BOXizOGQJrpq7lqbtyOOzSDyWg5BChkPGagCaokrstD41tE09nP/ruwXiN9OxkO3VcXb4SX1K+fs4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789603713; c=relaxed/simple;
	bh=tQHdLCByZDb6pLsxMuNeTO34KgFXBPvyGvZXGD2qg7U=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=slmBbzOq4v5PPmX/0Up6lL2Y7wrq9BDsJBk/DLtI5ARwgrF+luZu1yLE6ZLzFFcQIm0YJE+U/vxyHohwnghD5kgcAIbgEnRxwjmLTboDVlIZX0x5NOkAw/AtZwkR6yctXTpNoF2pXRMXwPR6wPzCHVUT+w1w2ATylNcDpMH5PV8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nrubsig.org; spf=fail smtp.mailfrom=nrubsig.org; dkim=pass (2048-bit key) header.d=nrubsig.org header.i=@nrubsig.org header.b=h0G46N0o; arc=none smtp.client-ip=23.83.209.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nrubsig.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nrubsig.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nrubsig.org header.i=@nrubsig.org header.b="h0G46N0o"
X-Sender-Id: dreamhost|x-authsender|gisburn@nrubsig.org
Received: from relay.mailchannels.net (localhost [127.0.0.1])
	by relay.mailchannels.net (Postfix) with ESMTP id 485297A0E01
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 23:58:30 +0000 (UTC)
Received: from pdx1-sub0-mail-a220.dreamhost.com (100-100-221-165.trex-nlb.outbound.svc.cluster.local [100.100.221.165])
	(Authenticated sender: dreamhost)
	by relay.mailchannels.net (Postfix) with ESMTPA id 17BEA7A0DA4
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 23:58:30 +0000 (UTC)
X-Sender-Id: dreamhost|x-authsender|gisburn@nrubsig.org
X-MC-Relay: Neutral
X-MailChannels-SenderId: dreamhost|x-authsender|gisburn@nrubsig.org
X-MailChannels-Auth-Id: dreamhost
X-Print-Tasty: 3793705456130679_1789603110143_4140100931
X-MC-Loop-Signature: 1789603110143:2177085394
X-MC-Ingress-Time: 1789603110142
Received: from pdx1-sub0-mail-a220.dreamhost.com (pop.dreamhost.com
 [64.90.62.162])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384)
	by 100.100.221.165 (trex/8.0.2);
	Wed, 16 Sep 2026 23:58:30 +0000
Received: from mail-wm2-f13.google.com (mail-wm2-f13.google.com [74.125.225.141])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	(Authenticated sender: gisburn@nrubsig.org)
	by pdx1-sub0-mail-a220.dreamhost.com (Postfix) with ESMTPSA id 4hlbSP6lTBzLn
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:58:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nrubsig.org;
	s=dreamhost; t=1789603109;
	bh=oRIdcGhow3/thgcogrF3DXyJoDX8q8VkyfouDkDnLMQ=;
	h=From:Date:Subject:To:Content-Type;
	b=h0G46N0oTRUm8ljlFU6COu+6/f8e2c2FEKxiUmFtblbMOVbl9Vq2Bl9dazQv+EAzS
	 shQHK2MOQq17UNpIYJh83zkB3GnAxzBuEPXAJo0/tyYc36jtUXkyParSumJvVXp+8i
	 rORVOXYnzNXslqrimPOqR6nFvoUO0pCpWSyhEQ7KHUvsHk2G1/XHCEzLzCxAM7p7CY
	 Q43EAi2DZwcE0YF85y5dO1mY8uTm4HSfLFigbE6QLSzd5JAGCeOc4mtHvr0Bp3MEvX
	 TsJGcpihV3EWq3BKJ+u0nH5xy6VfXf394f3DH6b2gu5RJfGs8Pys3nfr7CtSE71a2K
	 ADzqKJgMMQiNQ==
Received: by mail-wm2-f13.google.com with SMTP id 5b1f17b1804b1-49e620fa473so1420475e9.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:58:29 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AKwUvBwdEIbrciKXG1/qGlPPkAyYseoG1c2cQKe0YhNqYz3eZ5YKk62E1Nxz2i0Pg/fLV0+U+re9RFsA9fs=@vger.kernel.org
X-Gm-Message-State: AFuF++l0Df8EjGc+yKoIV9wosmTyxU2KVpxLsn+JWxEMKyrGz97iJ8Vj
	dTOroFrwsSaTUOFly6wLiJKc6SUGG3DV4jjR5QKrmYFFj/M7KvIruTcFmSNudBJZQbAUaZdiGNm
	Pd8D13DKdLkOb+ThVpsgc/8dcZ7sFWG8=
X-Received: by 2002:a05:600c:4e8c:b0:49e:7cc2:e6c2 with SMTP id
 5b1f17b1804b1-49eb73309edmr54253725e9.27.1789603108901; Wed, 16 Sep 2026
 16:58:28 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Roland Mainz <roland.mainz@nrubsig.org>
Date: Thu, 17 Sep 2026 01:57:51 +0200
X-Gmail-Original-Message-ID: <CAKAoaQnTria60yM=zYQAe+dZti0ZvCfja0V+Y0F=Qu1h+hXGAA@mail.gmail.com>
X-Gm-Features: AcwNN1WA3LL6dSF2rQ2_iFPsuLY9X_c4UBMZXckgjFFug0MWuyIl8ib9nOLg4qE
Message-ID: <CAKAoaQnTria60yM=zYQAe+dZti0ZvCfja0V+Y0F=Qu1h+hXGAA@mail.gmail.com>
Subject: Need NFSv4.1 "WANT_DELEGATION" op ...
To: ms-nfs41-client-devel@lists.sourceforge.net, 
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

Hi!

----

We're experimenting with a delegation-driven client-side
consitency+caching model for the ms-nfs41-client Windows NFSV4.2
client a while now.

The original idea was to have two modes:
- Mode 1: Get delegations (read delegations for accessing data
read-only, write delegations for accessing data [a]) at OPEN time, and
return the delegation when the file handle gets closed ([b]). The
client only does buffering+caching if it has a delegation.
- Model 2:  Do not request a delegation at file open/creation, instead
translate Win32 oplocks into WANT_DELEGATION+DELEGRETURN. The client
only does buffering+caching if it has a delegation. Server-side
revocation of the delegation triggers an oplock break, releasing the
oplock from the Win32 side just returns the delegation. This is
basically how Win32 oplocks work on the SMB level.

But in real life there are problems:
- "Mode 1" only worked for small testcases. Real Windows applications
typically change filehandle attributes or change ACLs after creating a
file, which results in server-side delegation recall triggered by a
NFS SETATTR, and after that we do not have a delegation. And there is
no WANT_DELEGATION op support in Linux+FreeBSD nfsd to get a
delegation back. Which typically means write delegations not being
enabled and therefore no client-side buffering/caching.
- "Mode 2" does not work because Linux+FreeBSD nfsd does not implement
WANT_DELEGATION to implement this "on-demand delegation" model.

Or short: For "mode 1" or "mode 2" to work we need the NFSV4.1
operation "WANT_DELEGATION" to work, at least in syncronous mode (e.g.
no CB_PUSH_DELEG support needed for now [c]).

@Chuck Lever What do you think ?

[a] Win32 also supports opening a file for attributes only, which
means no delegation gets requested
[b] Note that WIndows supports close-delayed files, which means that
calling |CloseHandle()| will flush outstanding dirty data, but keeps
the file "active" in the driver for re-use for some time (except on
delete/rename/etc.). For the NFS driver this means that locks are
returned, but the delegation+buffering stays untouched.
[c] Technically requesting WANT_DELEGATION async via CB_PUSH_DELEG
would be a welcome optimisation, because it could help dealing with
files with high contention between machines.

----

Bye,
Roland
-- 
  __ .  . __
 (o.\ \/ /.o) roland.mainz@nrubsig.org
  \__\/\/__/  MPEG specialist, C&&JAVA&&Sun&&Unix programmer
  /O /==\ O\  TEL +49 641 3992797
 (;O/ \/ \O;)
