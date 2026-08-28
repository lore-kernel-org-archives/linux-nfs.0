Received: from mail-ot1-f45.google.com (mail-ot1-f45.google.com [209.85.210.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2CD4D3ABD8F
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 20:50:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787950245; cv=none; b=b6FBA7oNKhMS353Gn1FSeuLYq4qclzcweEAyvRAv3geyE+ASLbLYv0VYnrGKh6EY/IiBX8UWN5MwyGgd8zTD9j5JUOTjzOFcwsPvxyVoqvnoajf9BpQkdKM1o6AoMoILJ+Q0f/fxNgK9Lzo6Q60Pj6Eu7Fy7rLDehT0PVElEij0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787950245; c=relaxed/simple;
	bh=I5g9sp7HAckDk+Au3D1bH78cHfeEk+Dzb5TRhrvFKeY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=XA9+wral8r3aYjjIy6zGxhMYBPZ50nRzpcrkBLak4O61DoxzNy+JcaLbilPuayYx57xKle+/nTY4MHQBiy0JorkjaKOaOIz3mLwf78icPCJ2dyuqdwS9u3FVnRDYq2W0MCuIxX+WT4uKP0DKsU//N5eBBz7SZMETEvgKlAX/MKE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=B+UtcEnl; arc=none smtp.client-ip=209.85.210.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="B+UtcEnl"
Received: by mail-ot1-f45.google.com with SMTP id 46e09a7af769-7f4cc6797b7so780407a34.0
        for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 13:50:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787950243; x=1788555043; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=x1b9Ked5NePNg7lEm5kzQUXx3dckoLD51FWIAGMmL88=;
        b=B+UtcEnlAJ9xP9Ssn8RXBBYd1KkTpUvF8cEeZJHjqvYd4vbL5ES257uApwuwyl4fIs
         +4nB/oIl7dN7PYtiQTbGS8isIsFxjbrxlHb4thAbJsIXkAxXVSGsqj5AtX4tyISw2Tca
         POmgXy3R/s8y5P0tBgBFlY5oY0megJAQDhc6yJYoOgcgSmW7CGhUwBmtLibFJ6ceTVbH
         w3AApwuMNLmc2TXPVzWbgmS3qKYR2k3PNtHEGh8DekDSn2xquMmlBjX9QY7lymN17152
         7YWiQevWsPEKbxIjtRcLH1PKQVWYS2ALIh6PpA0cIo0c/K/mdbgufZTxLgnquoLz+gbN
         89rg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787950243; x=1788555043;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=x1b9Ked5NePNg7lEm5kzQUXx3dckoLD51FWIAGMmL88=;
        b=aWBsK8XhJoQOV7k8a/A6pCEVlYTOhfH48KgljGBWVP6dRXBPaX3A3/IeJaSHVkBKZh
         OQANsZOM7yerynkF992/sZepYu60q95v5to4xRK/TstPWLjGx4udUbq0n5tRURzsxSrJ
         oa4inP1uyDY9vmt3cxMjDN2pcUw5/zWUW1pS/jKPVr3NCEX4a6wiUy4+oXWSZ49dUzn6
         hGLD0yGrvFvdU7o5vFCXLG4z3zcKG/TN6OMLag0vwC/tRxnijTOS6dFXW4o3dDsJ25jI
         vTUOKVTk0E1kbkSSWJMiuxreKQq9l2/jj45Dq7wuAw07ooLWostoVEMoJOVpO5KGScrA
         T9gQ==
X-Forwarded-Encrypted: i=1; AHgh+RrcrnGoVToRYaWrD8sms3liHrbg5neJC1cNSM1cpp4C/TtWr4O2f5cxCYB9ZIPPqi3TLuu2BcL3O0I=@vger.kernel.org
X-Gm-Message-State: AFuF++lhaOxjuuUCRcczuUrqSadgB/XH6mpUuULEE+6F+pEvdf67WWqp
	mA7d2XGCoNd3foT51OZSVuA317mIFA4hOQBATvwxRfpF5Q3HUmHa+0wmz/NQ7JXf9lM=
X-Gm-Gg: AR+sD10vMmMdzQuKnnOznU3R+cNEZGfzWbFSRhWUt4AaCCNy3ohqAvnVlpgjbEPUQFO
	OKcfn7vkJiJNUOmTe8F7yA1eR4ElpmlqR/8W7wPcd34KKdEokWwxEtZi2OJdGyeFKuvMMzN0twy
	tFgoDYpzl/d/9BvsX4G4CXfOUPIgMFKOULrQclTyorgIulQ7j3zh7IyN3cXFCzWJcIe5btR9oTQ
	r6bm0yzRg0OpfkFPP5zRXZcA1OHpAVMAn8DpXFRkmF1vrvVSKQGWlj7sS3c8ENCRrOLIAFZAJDD
	0r4DZcoytj8CnRcadsQOupjo/jvpkVHGH2tFxcGlm7rt2vwfiVCvXAb0ThPmD9dnxDVQRBOXqEb
	vWJIMk9Zme/y/jTN0IRE0MCu7b2/nw2A39+evLwqkNWRSv2LFU2+I3QORTQH7cuhBlg5P/esOik
	hLLhW0OA3y/ID660gi52peanvdb+yXCt7VMQb6AxdEg2i216zItcyZ5OmGpSAkP3OyYIhYbnTe/
	fhOW6UX
X-Received: by 2002:a05:6820:52d5:b0:6b1:3534:a5b8 with SMTP id 006d021491bc7-6b1c66161d9mr7806360eaf.15.1787950242852;
        Fri, 28 Aug 2026 13:50:42 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-468a2ef0452sm2530996fac.4.2026.08.28.13.50.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 28 Aug 2026 13:50:42 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Anna Schumaker <anna@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
 Jonathan Curley <jcurley@purestorage.com>, Mike Snitzer <snitzer@kernel.org>,
 Jeff Layton <jlayton@kernel.org>
Subject: Re: [PATCH v2 14/23] NFSv4/flexfiles: Honor ndc_immediate on
 CB_NOTIFY_DEVICEID CHANGE
Date: Fri, 28 Aug 2026 16:50:40 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <53B11861-643C-4B3F-9634-617736EC7E38@hammerspace.com>
In-Reply-To: <fdf3cf24-a0b2-4350-961b-028847c47bc9@app.fastmail.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
 <da98de51fe276a11faef6b42d469ed73dd4ff53f.1787327939.git.bcodding@hammerspace.com>
 <fdf3cf24-a0b2-4350-961b-028847c47bc9@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 28 Aug 2026, at 13:41, Anna Schumaker wrote:

> On Fri, Aug 21, 2026, at 12:29 PM, Benjamin Coddington wrote:
>> When a CHANGE notification carries ndc_immediate, RFC 8881 Section
>> 20.12 says the change is enforced immediately and the client might not
>> be able to complete pending I/O.  In addition to un-pinning the stripe's
>> device node, mark the old node unavailable.
>>
>> Marking does not recall the references already handed out.  A write
>> whose DS connection is already up keeps using the old node until that
>> I/O errors: nfs4_ff_layout_prepare_ds() returns early on a live
>> ds_clp, and the unavailable flag is only consulted when a connection
>> is being established.  What the mark does change is that a read skips
>> the node while another mirror is usable, and that an IOMODE_RW segment
>> still pinning it stops counting as fully available -- so I/O the
>> server rejects falls back to the MDS rather than being retried against
>> a mapping the server has already withdrawn.
>>
>> The walk can also exchange out a node that already carries the new
>> mapping: a re-resolve that completed between the unhash and the walk
>> reaching the stripe, raced by this walk or by the walk of a later
>> CHANGE for the same deviceid.  Ripping such a node out is harmless (it
>> is still hashed, so the next I/O re-pins it from the cache), but it
>> must not be marked unavailable.  Stale vintages are distinguishable by
>> hashed-ness: every superseded node was unhashed before its walk began
>> and is never re-inserted, while a fresh node is inserted before it is
>> installed.  Only mark nodes that are no longer hashed.
>>
>> That test is hlist_unhashed_lockless(): the hook runs under the layout
>> inode's i_lock and rcu_read_lock(), but not under nfs4_deviceid_lock,
>> which is what serializes the writers of node.pprev -- and __hlist_del()
>> stores a neighbour's pprev with WRITE_ONCE(), so removing any other
>> entry in the same bucket can write the field this test reads.
>>
>> Without ndc_immediate, pending I/O drains on the old mapping and only
>> new I/O re-resolves, as before.
>>
>> Assisted-by: Claude:claude-fable-5
>> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
>> ---
>>  fs/nfs/flexfilelayout/flexfilelayout.c | 8 ++++++++
>>  1 file changed, 8 insertions(+)
>>
>> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c
>> b/fs/nfs/flexfilelayout/flexfilelayout.c
>> index 46ca58e8e96b..ebb19a919f9d 100644
>> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
>> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
>> @@ -2541,6 +2541,14 @@ static void ff_layout_reresolve_deviceid(struct
>> pnfs_layout_hdr *lo,
>>  				kfree(put);
>>  				continue;
>>  			}
>> +			/* Only mark stale vintages: a node still hashed was
>
> I don't think I've seen "vintage" used when talking about anything other than
> wine before.

Not even cheese?

>
>> +			 * fetched after the unhash and carries the new
>> +			 * mapping.  Lockless -- nfs4_deviceid_lock, which
>> +			 * serialises pprev, is not held here.
>> +			 */
>
> Nit: this comment is pretty wordy. Do we really need to define what "lockless"
> means here?

I'll trim it up!

Ben
