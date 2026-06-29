Received: from flow-a7-smtp.messagingengine.com (flow-a7-smtp.messagingengine.com [103.168.172.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BFA139BFE1;
	Mon, 29 Jun 2026 06:59:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782716395; cv=none; b=ccfjqgs3j/bonGQNVrqlO19pb2u4KUMl1gMliD9BhvCZ19TAhAB1fJ/pnWKObqM1rQ4Jii6/KHhYej8MnX9X8o+ic5ddHErpWNh27+MOC7TmLFgi1QrKFs4MAT8Yixx3sSOW7tJfqNq7bYpCfDLNBSQvERlQ5n5nXO0wrlBccw8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782716395; c=relaxed/simple;
	bh=tYsHBzQ2vOQXcrOetqIt8QTpdhuvILhgntCm0fGFWQo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=knU9Qx08w9+Q9E6I9yhXvK+PWXsjfIdffeHoLG8HsrJEaNaSEGZC8b4p8q8vgAyuNF4ALLziAA8bE0C/vRByEx6f1UV05p6x7vUEo6pTC45ktzq2h8jby3osMBbDmgAw7aGVuSXLgBgQ86t9OVuVO/8uL61/nGNblQqR2fxyQyQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=Obsidian.Systems; spf=fail smtp.mailfrom=Obsidian.Systems; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=BHZdM1h7; arc=none smtp.client-ip=103.168.172.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=Obsidian.Systems
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=Obsidian.Systems
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="BHZdM1h7"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailflow.phl.internal (Postfix) with ESMTP id 6597A1380199;
	Mon, 29 Jun 2026 02:59:53 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Mon, 29 Jun 2026 02:59:53 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:subject:subject:to
	:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=
	1782716393; x=1782723593; bh=yKchnWIun08ZH/dza01bJYYLCZ3CGuAhcKX
	8fKBHQq8=; b=BHZdM1h7EBPAVqQBkpLLAi88Pyo+X2kqC/LnqsFSTk3glr2jqWg
	GqIkvvSznKPZoOrGWEmpsPD+Qbgg5lsnCbHKVk3q2FhKFRtzjZdGOo2JU8dyGG7y
	66JRkl6NBPsLCWuIvGesQYahTV/B+0qhYsm1v/seClIaXdV1+o8A0yp9yThUC1CB
	LBy31wo6FfVKma1jxxFqYgs+mUwp71WtsshK8nRB+VbqSkVpYbOhRReK9L+IfoZX
	TNkdJuxdIksn2I8zoYarC1OzwqSJ1FIt6DF7kG9baR7tBV2bB/TcZPqyUHbf33vq
	iEu/PGySY+4QnMgzKzsrWUEuQhmDuIs9h6A==
X-ME-Sender: <xms:5xdCagzsFueOF7noMHyCTf4kiChlI-8KLFnZC9PCmfZxogdqmoa4CA>
    <xme:5xdCam6I2pNTfoa1gUQDRC714pNU_7quuJ37nYBcVDyZDE2KYrazFpoRn363dX9ZO
    I7W5g7nyAzNub6VC9LtPSlAeYmemmNJu5O99F0f-NjXX3dlceQOcnw>
X-ME-Received: <xmr:5xdCah2ZIM5rY3dhehEJP-78RbE591i5ZZA2tfQwjYBiWGQrk5xCX8L7vZLz8isWFXvgwz5lfdKqYM8WlfSNOhA7hF6sHSZAd7ofmw>
X-ME-Proxy-Cause: dmFkZTG1MzZNIK/9LeMFIaDGsEfvFNo5AvCYGQDHW+g20Nu9ip4TV3nJ7p59RrHd/M78Hu
    Tp0tmf0jRIUShBiZMlJYf1knZYI21dsvCzMUUkvMby4qr5+GyT4SrKsaT7Au0nty91uRZo
    +0N0Od7YjXaw1Ge3foZofxXn5LVncJbLeoxaqP6M9RQsfpyke9fd6wdzqtzyygbsVzCNgU
    FkqSO5gWpGFZ7zkIBEZzol7+2F8f+lnnSm9E96SpcfsZYHrEYIyBWXWrKffH727ICfhi2e
    exm19riPEN6Sq4uUFYYA1BHaHccnvLVIZOT3aoVUoQcDZ6zCfm+1C1D29P9b6OkzVl1mKx
    YtGDyDyBMsqn9DlqQS8o3FOKpSed+ky+G+N4VqSlWkdCKSn7ol/cAUydRn1SbmgZFXVv5/
    xlRyu0nIKJ32bblV4W80J0qrB8mcIx06ZsaFginCPIop4dl+rhV7faHKHCDm3WzMk5YzBo
    RH1tZXKRWd4E0jMvz49bY80paH9WkV0dmV8eN8JoDFPg0RYii2W0p16wd4iMIXWgiQprfG
    fVBVqHQqQTMwJ0mDpewZC07EFG/WTVjZ+ePCpSdDlMGTSW29EFmL7zg1bTOmeJGF4Rlr6Z
    TbCY7jI7h9ay+yJPKsC3e0NctMPkxhPnstNr4surhjdc58oitBvM6OV6JoBA
X-ME-Proxy: <xmx:5xdCav0yswmb9mhUmQWj5jG9tuFFQYt73H1Lz3jW2Saujb7zHcvqyw>
    <xmx:5xdCagcqymsI4lnM6qRbvXTbr7ToZMTVfj96h_q5ut7osQczYFcB4w>
    <xmx:5xdCapIw3VAmdhYyGINTcxjJeqsP-6WE3TMeB6qaca7RwJckj2eYsg>
    <xmx:5xdCan-FKRbHRVqantc7u6i9lippIRP9-wb4cZgkoE1NWL8cXf0LSg>
    <xmx:6RdCal7ITYN3Qzl8b69T3cgnmcXrTimMkfzW3JrfsPjg8ll8zdVpofwL>
Feedback-ID: i91b946ab:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 29 Jun 2026 02:59:51 -0400 (EDT)
From: John Ericson <John.Ericson@Obsidian.Systems>
To: "Andy Lutomirski" <luto@kernel.org>,	"Al Viro" <viro@zeniv.linux.org.uk>,
	"Christian Brauner" <brauner@kernel.org>,	"Jan Kara" <jack@suse.cz>,
	"David Howells" <dhowells@redhat.com>,	"Chuck Lever" <cel@kernel.org>,
	"Jeff Layton" <jlayton@kernel.org>,
	"Shuah Khan" <skhan@linuxfoundation.org>,
	"David Laight" <david.laight.linux@gmail.com>,
	"H. Peter Anvin" <hpa@zytor.com>,	"Li Chen" <me@linux.beauty>,
	"Cong Wang" <cwang@multikernel.io>,	"Arnd Bergmann" <arnd@arndb.de>,
	"Thomas Gleixner" <tglx@kernel.org>,	"Ingo Molnar" <mingo@redhat.com>,
	"Borislav Petkov" <bp@alien8.de>,
	"Dave Hansen" <dave.hansen@linux.intel.com>,
	"Jonathan Corbet" <corbet@lwn.net>,	"Kees Cook" <kees@kernel.org>,
	"Sergei Zimmerman" <sergei@zimmerman.foo>,
	"Farid Zakaria" <farid.m.zakaria@gmail.com>,
	linux-arch <linux-arch@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-api <linux-api@vger.kernel.org>,	netfs <netfs@lists.linux.dev>,
	linux-nfs <linux-nfs@vger.kernel.org>
Cc: John Ericson <mail@JohnEricson.me>
Subject: [RFC PATCH 0/3] fs: support tasks with a null root or cwd
Date: Mon, 29 Jun 2026 02:58:19 -0400
Message-ID: <20260629065934.1425479-1-John.Ericson@Obsidian.Systems>
X-Mailer: git-send-email 2.51.2
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: John Ericson <mail@JohnEricson.me>

This patch series allows processes to avoid having a root directory
and/or a working directory. The actual implementation is in the second
patch. The first patch just prepares some documentation. (Are struct
fields documented like this? Would this be good regardless?) And the
third patch adds unit tests.

I have tested these patches by `kunit.py run`-ing my new test suite.

The motivation is discussed at length in the thread starting with [1].
This patch would be the first in a series trying to allow for
less-privileged and more cheaply less-privileged processes than we have
today, by nulling out their namespace fields (or similar) so they do not
belong to any namespaces. This specific change is a prelude (in spirit,
it might actually be orthogonal in practice) to nulling out the mount
namespace, so that the process does not "belong" to any mount namespace.

Nothing creates such a task yet; the new UAPIs that would take advantage
of this feature are left as future work. It may not be appropriate to
submit such a "dead-code" patch, but I wanted to demonstrate just how
easy this change is (along with at least a unit test to exercise it),
before getting into UAPI designs.

The marquee new UAPI around this would, I hope, be the new non-fork-exec
process spawning API Li Chen started in [2]. The idea would be that,
instead of doing process initialization in the child post-fork, it is
done from the parent, against (my terminology) an "embryonic" (not yet
runnable; withheld from the schedule) process. These null fields
(`struct path` to directories in this patch, pointers to namespaces in
the latter patches to be written) allow for lightweight and minimally
privileged initial embryonic processes, allowing for good performance
(don't preemptively allocate things the caller may not want) and abiding
by the "principle of least privilege" (initialization should always
grant, not take away, privileges and resources from the embryonic
process).

So far in the linked discussion, the alternative that best addresses my
motivation is using the new "nullfs" for the root directory and cwd.
Practically, that is almost as good -- reading and statting the
directory will work, but it will reliably be and remain empty regardless
of how privileged the caller is. The downside is simply that we would
like those operations also to fail, to more readily signal to developers
and users (human or agent, for that matter) that the working directory
and root directory should be avoided, and paths should instead always be
paired with a file descriptor and used with `*at` or other modern UAPIs.

[1]: https://lore.kernel.org/all/a49ce818-f38d-41b0-bbf7-80b8aad998b1@app.fastmail.com/

[2]: https://lore.kernel.org/all/20260528095235.2491226-1-me@linux.beauty/

John Ericson (3):
  fs: Add documentation to some `struct fs_struct` fields
  fs: support tasks with a null root or cwd
  fs: add KUnit tests for tasks with a null root or cwd

 fs/Kconfig                     |  11 +++
 fs/cachefiles/daemon.c         |   6 +-
 fs/d_path.c                    |   6 +-
 fs/fhandle.c                   |   3 +
 fs/fs_struct.c                 |   4 +
 fs/namei.c                     |  22 ++++-
 fs/proc/base.c                 |   8 +-
 fs/tests/null_root_cwd_kunit.c | 147 +++++++++++++++++++++++++++++++++
 include/linux/fs_struct.h      |  29 ++++++-
 9 files changed, 228 insertions(+), 8 deletions(-)
 create mode 100644 fs/tests/null_root_cwd_kunit.c

-- 
2.51.2

