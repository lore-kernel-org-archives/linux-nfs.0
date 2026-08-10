Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F9BB3DD50D;
	Mon, 10 Aug 2026 13:24:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786368298; cv=none; b=C6gi4qylRsONma7J7f9JsEKvFqCVKdGVRPYqWdpR+ecCZiavkiJqQ0fgJGReqob1W+CpJd9JYfqdnvLW6OhHWGDywGBIsmnMXf2z4nT7jXcJc3my5GPNv+WJMExAzwz76e7oaHu/RtySzCHjmnz+o62EBBVH7CLP8urBttNFGVY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786368298; c=relaxed/simple;
	bh=maQOpdiE0Nzwl9nHvXTPD7Hmop2fglx39GVbR/iCWLc=;
	h=MIME-Version:Content-Type:Subject:From:To:Cc:In-Reply-To:
	 References:Date:Message-Id; b=FXpoB7L/9ya+H21NNE2U4xi8bRwqRVtOxV9vKXfFr1fuziCO7TFpcQVVE28a17PjWaUHY2mKEsmhrBoJRnsTsd09X+kR5d01wMWSsReyNB+h0+FDtvj9qSjk3X6dvbtb3fsQbookUzioVykh41JMCtswHHPZ4lwjyWlcxybkMus=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QHU9+DmU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QHU9+DmU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A65A11F000E9;
	Mon, 10 Aug 2026 13:24:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786368297;
	bh=LqbXuIW1AzbFRLlq+BlUwIYUreMyPkDhS0NmZzNzwDs=;
	h=Subject:From:To:Cc:In-Reply-To:References:Date;
	b=QHU9+DmUad00AqAVMjudvnPWCwaquhLGto8OXMhUsDoF0L2J1FS/N7uW7ZpszY7Wj
	 svXfOgfonUAlX1R9cDhLEWl1MhvlPG1IoLYDIL6/QskY1wwKDXM6Zb61KAkAozVv5Q
	 fxKRahgEQFAXZmA87gDXoJssKUE9mvATq0EMm7RZtniRgYrPkzXvy8C4hp+plDyczo
	 3cqtBSMmKZo96+AYKJ4wpuFljIJNA4HQN6H+WemMK0+ciUxIMNX+yksGgen3pPLjQI
	 kQQFZ/fZ/PZ+d4A0RPWHVErYAXPnddIKGVWrk9K8LR1CEBvIBbLPy2smFisKgRDnDl
	 mZuHErsvEMGoA==
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v3 0/2] vfs, afs, bash: Fix miscomparison of foreign
 user IDs in the VFS
From: Christian Brauner <brauner@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <christian@brauner.io>, 
 Marc Dionne <marc.dionne@auristor.com>, 
 Jeffrey Altman <jaltman@auristor.com>, Steve French <sfrench@samba.org>, 
 linux-afs@lists.infradead.org, openafs-devel@openafs.org, 
 linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <20260728141344.1811120-1-dhowells@redhat.com>
References: <20260728141344.1811120-1-dhowells@redhat.com>
Date: Mon, 10 Aug 2026 15:24:52 +0200
Message-Id: <20260810-jazzfest-unglaubhaft-miene-4d1cf4cf42d3@brauner>
X-Mailer: b4 0.17-dev-362b8
X-Developer-Signature: v=1; a=openpgp-sha256; l=3040; i=brauner@kernel.org;
 h=from:subject:message-id; bh=maQOpdiE0Nzwl9nHvXTPD7Hmop2fglx39GVbR/iCWLc=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWRVXlQ7qvirz0TGy/+jfkrD3qrvbHfKHnVtnxah3OMv8
 OlIdqVtRykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwESWbGdkmD7z7cU7Rf83ynz8
 aunf97QkmDXU6aNwW4rntXOSW0p5fzP8FWm+FW2+PGfxtlPvJQzFXh6M3SJ+4pdxecTHSon8s5a
 BDAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

On 2026-07-28 15:13 +0100, David Howells wrote:
> Hi Al, Christian,
> 
> Here's a pair of fixes that deal with some places the VFS mishandles
> foreign user ID checks.  By "foreign" I mean that the user IDs from the
> filesystem do not belong in the same number space as the system's user IDs.
> Network filesystems are prime examples of this, but it may also impact
> things like USB drives or cdroms.
> 
> Take AFS as example: Whilst each file does have a numeric user ID, the file
> may be accessed from a world-accessible public-facing server from some
> other organisation with its own idea of what that user ID refers to.  IDs
> from AFS may also collide with the system's own set of IDs and may also be
> unrepresentable as a 32-bit UID (in the case of AuriStor servers).
> 
> Further, kAFS uses a key containing an authentication token to specify the
> subject doing an RPC operation to the server - and, as such, this needs to
> be used instead of current_fsuid() in determining whether the current user
> has ownership rights over a file.
> 
> Additionally, filesystems (CIFS being a notable example) may also have user
> identifiers that aren't simple integers.
> 
> Now the problem in the VFS is that there are a number of places where it
> assumes it can directly compare i_uid (possibly id-mapped) to either than
> on another inode or a UID drawn from elsewhere (e.g. current_uid()) - but
> this doesn't work right.
> 
> This causes the write-to-sticky check to work incorrectly for AFS (though
> this is currently masked by a workaround in bash that has now been removed
> as of bash-5.3) whereby open(O_CREAT) of such a file will fail when it
> shouldn't.
> 
> Two patches are provided:
> 
>  (1) Add a pair of inode operations, one to compare the ownership of a pair
>      of inodes and the other to see if the current process has ownership
>      rights over an inode with an IOP flag to control access to them.
> 
>      Usage of this is then extended out into the VFS, replacing comparisons
>      between i_uid and i_uid and between i_uid and current_fsuid().  The
>      default, it the inode ops are unimplemented, is to do those direct i_uid
>      comparisons.
> 
>  (2) Fixes the bash workaround issue with regard to AFS, overriding the
>      checks as to whether two inodes have the same owner and the check as
>      to whether the current user owns an inode to work within the AFS
>      model.
> 
> kAFS uses the result of a status-fetch with a suitable key to determine
> file ownership (if the ADMINISTER bit is set) and just compares the 64-bit
> owner IDs to determine if two inodes have the same ownership.
> 
> Note that chown may also need modifying in some way - but that can't
> necessarily supply the information required (for instance, an AuriStor YFS ID
> is 64 bits, but chown can only handle a 32-bit integer; CIFS might use a
> GUID).

Seems that some other changes are required for this. I'll take a look
once a new version is out.

