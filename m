Received: from mxout5.mail.janestreet.com (mxout5.mail.janestreet.com [64.215.233.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C0BDE299937
	for <linux-nfs@vger.kernel.org>; Wed,  8 Jul 2026 14:37:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=64.215.233.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783521479; cv=none; b=gpVDSkZG0SI+z/aT/sEYh+gx8M70Ob720WuHvkIGSmxRYK3a3Sa6MBJ5BAhtwpfsElWZ8QVg3a3wGTJFSfOYSMheu4hNpQhlOOn16eW4X3JzNUEMf2V6PqRTp7SCr0WvXZKcRZRf4rFmA1Zbs7ocnYzvxP+sgZB7Hc4B+Mea5Vw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783521479; c=relaxed/simple;
	bh=v12DQ8za5E1b5G5ZhdoWW/HMR9aNrh+7H0BFAiLzSLI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bM+ww3Ej/OAXl5kFVeeQj7CDhs8qU9YOC8838opHQkp509uBigCumKUKZMeBG23n7t6kbjvkyeKVC5S8g9PGvI1OiYN3LfARGpF3r0ldjv9+v2NHN7Nc7nqFyFbNjZzW+17iPBnyLzh5pFalgkAx6VldRCy7QzbgWiiQisIu9m8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=janestreet.com; spf=pass smtp.mailfrom=janestreet.com; dkim=pass (2048-bit key) header.d=janestreet.com header.i=@janestreet.com header.b=u81GnZ71; arc=none smtp.client-ip=64.215.233.18
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=janestreet.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=janestreet.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=janestreet.com header.i=@janestreet.com header.b="u81GnZ71"
From: tilan@janestreet.com
To: cel@kernel.org
Cc: anna@kernel.org,
 	linux-nfs@vger.kernel.org,
 	tilan@janestreet.com,
 	trondmy@kernel.org
Subject: RE nfs: opening a file with O_WRONLY|O_CREAT flags can result in permission denied error
Date: Wed,  8 Jul 2026 10:37:51 -0400
Message-ID: <20260708143751.4172658-1-tilan@janestreet.com>
X-Mailer: git-send-email 2.43.7
In-Reply-To: <dfe72971-5478-45dd-82c1-0aa2e1156aee@app.fastmail.com>
References: <dfe72971-5478-45dd-82c1-0aa2e1156aee@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=janestreet.com;
  s=waixah; t=1783521471;
  bh=4AsbDyBFANvust+buQxkV6KGvXiAg5S/6LAA4t3zKZU=;
  h=From:To:Cc:Subject:Date:In-Reply-To:References;
  b=u81GnZ71t8oNeMGkOGRNyJ+yBFg+QeVarMnnpxEBXD5AQ99T5fcpgPHiymZu9ww4R
  gcmveSzDFrldezkw4I84CW9FZ0ouahMjWQdW7gpmypavzPqp8s6rKzBFPCA6kIGSN7
  /BaM6nk49qkj8FPKnexrMPTPi1wKog0fr6om6J4KTN7KWcSQsB7ZtrwYAMJZC+5afx
  Qavz61B0N1Y4Y4OjbfFlnQhOFrWkqCx7O3O6+6PTaSL5P/lkVgdgZLACOD26QnrtqG
  2P3g375fPCx3c5TCsxSOlICQFHWSNbEuVFZyrJZ7+Fyry6fWW9AoF6JPQcD9lcH4vn
  opvQjgcsK49/A==

>>>> Hello,
>>>> 
>>>> We recently noticed there is a behavior change w.r.t opening a file 
>>>> with the O_WRONLY|O_CREAT flags over the NFSv3 protocol after
>>>> upgrading
>>>> the kernel from 6.1 LTS to 6.12 LTS. From the packets capturing, it
>>>> seems
>>>> like the kernel would now issue an additional CREATE rpc call to the
>>>> remote NFS server regardless if the target file pre-exists or not.
>>>> The CREATE rpc request could return an EACCES error if the client
>>>> only has 
>>>> the write permission to the pre-existing file but no write permission
>>>> on 
>>>> the directory containing the pre-existing file. This causes the
>>>> openat 
>>>> syscall to fail with permission denied error which is not expected.
>>>> 
>>>> After doing some code tracing, it seems like the new behavior was
>>>> introduced as part of 7c6c5249f061 ("NFS: add atomic_open for NFSv3
>>>> to
>>>> handle O_TRUNC correctly."). We would like to confirm if the current 
>>>> behavior that we are observing with the 6.12 kernel is expected given
>>>> that the new behavior breaks existing user's application code. We 
>>>> currently have a workaround by explicitly remove the O_CREAT flag
>>>> when 
>>>> opening a pre-existing file for write, but would still prefer not
>>>> have
>>>> to apply this workaround when upgrading to the newer kernel.
>>>
>>> What server are you using?
>>>
>> The permission error was reproduced against a vendor appliance, running
>> the same test against NFSD seems to yield a different result
>> (no permission errors) due to differences in behavior from the CREATE 
>> RPC implementation.
>>
>> NFSD behavior
>>
>>   - CREATE RPC (UNCHECKED mode) returns the filehandle of the 
>>     existing file along with the file's attributes
>>	  
>> Vendor appliance
>>
>>   - CREATE RPC (UNCHECKED mode) always attempts to create a new
>>     file and returns the new filehandle. This explains why we
>>     are seeing permission denied error from openat syscall.
>>	  
>> RFC 1813 states that 
>>
>>   "UNCHECKED means that the file should be created without checking
>>   for the existence of a duplicate file in the same directory. In this
>>   case, how.obj_attributes is a sattr3 describing the initial
>>   attributes for the file."
>>	 
>> It seems like the vendor's implementation matches more closely to what
>> the "standard" describes, but the behavior might not be what a normal
>> user would expect. I guess there is no win-win situation here.

> Compare RFC 7530's UNCHECKED4. It says explicitly that if the object
> already exists, a non-exclusive create does not recreate it. The
> existing object is used and the supplied attributes are applied. RFC
> 7530 and subsequent RFCs document what UNCHECKED was always meant to
> do, and NFSD's NFSv3 behavior is consistent with that.

> IMHO the correct interpretation, the one consistent with the rest of
> NFSv3, with NFSv4's clarifying text, and with POSIX, is NFSD's, not
> the vendor's. UNCHECKED governs error-vs-no-error on a duplicate,
> not recreate-vs-reuse.

> But to confirm this, look for an RFC 1813 erratum, or WG/implementor-list
> guidance, stating that UNCHECKED must replace or re-create a pre-existing
> file and return a fresh filehandle. It would also be sensible to check
> how Solaris NFSv3 behaves, as it is a reference implementation for
> RFC 1813.

I ran the same test against the Solaris 11.4, and the NFSv3's behavior
is consistent with the Linux nfsd. I guess this would be sufficient to
conclude that the vendor's implementation is deviated from the actual 
intent and the addition of NFSv3 atomic_open exposes this difference in
an very unfortunate way.


Thanks,
Tian
