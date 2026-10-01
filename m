Received: from mail.stoffel.org (mail.stoffel.org [172.104.24.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15DA526ED40;
	Thu,  1 Oct 2026 19:43:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=172.104.24.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790883823; cv=none; b=F7ZLjmSsn9LM0bJxfhP9oxphgN9hRmIXCzwIaH4hcGNWTqy+aOYvjCeBDdhNFViQgvbXXu8zvMB3t9NPIMhguO30hFFO5btInAZTS4LWjKfQYGXxi3/NMjd2oRjolaxt5JT13MfPrXX2XLnK8F6K0FpkiNCu74PDywU069hZnSk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790883823; c=relaxed/simple;
	bh=7VeFmgz04ojf70Sdk2Y3kowM7FF4KSlRSKNyayO1weE=;
	h=MIME-Version:Content-Type:Message-ID:Date:From:To:Cc:Subject:
	 In-Reply-To:References; b=JLT27M3/9x22qbNu6KVH+nwXRQQnmUR4MRox6oM6SbcOLAmEI9+36rgbXt+PLUAdC6Y764bQKl+OQX+B2vUjT3e7eGyIGvSzZOpcOpK5mbNCrhuYF5qs6Kg9SA0kG5Iktd7ymjmb5abtCOvcPlzJJJVBGwHV+w3q9UDdPT3zeg8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=stoffel.org; spf=pass smtp.mailfrom=stoffel.org; dkim=pass (2048-bit key) header.d=stoffel.org header.i=@stoffel.org header.b=KKk52Xd5; arc=none smtp.client-ip=172.104.24.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=stoffel.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=stoffel.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=stoffel.org header.i=@stoffel.org header.b="KKk52Xd5"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=stoffel.org;
 i=@stoffel.org; q=dns/txt; s=20250308; t=1790883815; h=mime-version :
 content-type : content-transfer-encoding : message-id : date : from :
 to : cc : subject : in-reply-to : references : from;
 bh=7VeFmgz04ojf70Sdk2Y3kowM7FF4KSlRSKNyayO1weE=;
 b=KKk52Xd5ka/R5uY2KDeloblMAVP47KaRK5wllwu3bzZac5bgGegDOw9Qx9n/E274sGdUA
 tniQkj8TZ3vmemYSaCwbrbsU2zAKS7CJuBH3sUGIQ0EY6ird+cKUu9YbylStlkKu0H81mFL
 rDjQjvdnM5YiVAWLLzxYUmo+QXz3O+m0R6j+kr9y+gIY4I0D5TaGCMuaAlc2QtyJw5bsuKQ
 AskI2BYSNkNM6k0Kl59Ctrg5/JxzJzw3MIJCwljo/Yms2V1WEoIF9Hxu1e58C+4lbX0CAPh
 NYDjZYaj9qXW23XIAK4vaTY+MyrpBiWkd3NGyOjkjUsyeVKToWdJvTj9ncfQ==
Received: from quad.stoffel.org (unknown [24.177.6.168])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by mail.stoffel.org (Postfix) with ESMTPSA id B09B71EB24;
	Thu,  1 Oct 2026 15:43:35 -0400 (EDT)
Received: by quad.stoffel.org (Postfix, from userid 1000)
	id 53676A332A; Thu,  1 Oct 2026 15:43:35 -0400 (EDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <27326.47079.315579.582391@quad.stoffel.home>
Date: Thu, 1 Oct 2026 15:43:35 -0400
From: "John Stoffel" <john@stoffel.org>
To: NeilBrown <neil@brown.name>
Cc: "John Stoffel" <john@stoffel.org>,
    "Trond Myklebust" <trondmy@kernel.org>,
    "Anna Schumaker" <anna@kernel.org>,
    "Alexander Viro" <viro@zeniv.linux.org.uk>,
    "Christian Brauner" <brauner@kernel.org>,
    "Jeff Layton" <jlayton@kernel.org>,
    "Jan Kara" <jack@suse.cz>,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-kernel@vger.kernel.org
X-Clacks-Overhead: GNU Terry Pratchett
Subject: Re: [PATCH v2 3/9] nfs: remove d_drop()/d_alloc_parallel() from
 nfs_atomic_open()
In-Reply-To: <179080305245.37859.18267888595495397553@noble.neil.brown.name>
References: <20260929022547.1428036-1-neilb@ownmail.net>
	<20260929022547.1428036-4-neilb@ownmail.net>
	<27325.7525.26178.516077@quad.stoffel.home>
	<179080305245.37859.18267888595495397553@noble.neil.brown.name>
X-Mailer: VM 9.0.0snapshot under GNU Emacs 28.2 (x86_64-pc-linux-gnu)

>>>>> "NeilBrown" == NeilBrown  <neilb@ownmail.net> writes:

> On Thu, 01 Oct 2026, John Stoffel wrote:
>> >>>>> "NeilBrown" == NeilBrown  <neilb@ownmail.net> writes:
>> 
>> > From: NeilBrown <neil@brown.name>
>> > It is important that two non-create NFS "open"s of a negative dentry
>> > don't race.  They both have only a shared lock on i_rwsem and so could
>> > run concurrently, but they might both try to call d_splice_alias() at
>> > the same time which is confusing at best.
>> 
>> > nfs_atomic_open() currently avoids this by discarding the negative
>> > dentry and creating a new one using d_alloc_parallel().  Only one thread
>> > can successfully get the d_in_lookup() dentry, the other will wait for
>> > the first to finish, and can use the result of that first lookup.
>> 
>> This paragraph is confusing, and I'm not sure which thread can use the
>> result of the first lookup from this description.  

> Unfortunately it isn't clear to me what it is that isn't clear to you
> :-)

Sorry!  I wasn't clear, probably because I'm not great at the VFS
stuff and was just reacting more to my parsing of the language.  It's
probably not a big deal honestly.  

> When O_CREAT is not requested, calls to ->atomic_open are protected only
> by a shared lock on the parent so if the dcache contains a negative
> dentry for a given name then two ->atomic_open calls on that name can
> happen concurrently.  That can be a problem as they both might try to
> instantiate the dentry with an inode, and the second to do that will
> trigger a BUG.

> This is fixed by discarding (d_drop()) the dentry and using
> d_alloc_parallel() to allocate a new dentry.  d_alloc_parallel()
> effects a lock.  Only one thread will get an in_lookup dentry.  The
> other will block until the dentry has been instantiated, and will then
> be given the non-in_lookup dentry.

> The current code does all this in nfs_atomic_open().  The new code does
> the d_drop and the d_alloc_parallel() in VFS code were I can manage the
> locking rules more easily.

> I thought that is what I said above - though more briefly of course.  If
> you can point me more precisely to what is not clear in the original, I
> can try to improve it.

> Thanks,
> NeilBrown

