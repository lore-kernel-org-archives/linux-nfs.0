Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8CD2649D5AF
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 19:11:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791918672; cv=none; b=TZ8BoHX3LvClZ3fIhVXkQhM2bHOR1+rP4W3ZvbIHlEo3pOSa9ITXLFSqYTTJjibMUvJ8jK5SLMxdjaOCGSJrjNTCulCQWdQDRMvlcGHAsIO8B8yM8/IP/59hYfq/XeOuawN3JZNE2AOYhBeR/sJEqjWo8b2BP4DmupdGQJvO1KM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791918672; c=relaxed/simple;
	bh=yJqsREo6JqVEKYnEKhEPIfrt3EOWl9e9xyldudDfVh8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=qXdwZy8GHQlcZTP+qnmj/K+xJomn3YlQ3IwUchpuSUvExdFAJmIWajE+FeL89yG2QD9BzWoWetyMGqwvMtcGtaP8uSWgockYb+smTBS+SooyeB2g/pxdvHmcdmcghxVSepitEFoMgae57BZ8qny9W+mOD0cc+dk8I7YX3Ls3vO0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UySymPfv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UySymPfv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C5C461F000FF;
	Tue, 13 Oct 2026 19:11:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791918671;
	bh=yJqsREo6JqVEKYnEKhEPIfrt3EOWl9e9xyldudDfVh8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=UySymPfv0SBuRR8pCfD2TcX4ZJMB8UskQWv/rH0T3x2nHIQvtAYqQsffvQOgb2z6D
	 pdCFN3vXay1Q04xEXHS58LaAhGnFiHGTLV1XaZBLDuWBqOKQ8wjNjs+AXxPCtmma1c
	 STe9UVwP5+IZIYj6Yt5ofuArGizM1AVnHJnosG8wiDjQoQZ06zOw+7vQxxd2+vrYFP
	 QmtjRb85IT5Uf5SwEFZlDo1xC7yGtQcJyu4paIQEp7Dj17gwUpSRnr4F4gITQGi1bj
	 Egs5bb12pwV0oqQCWeQ5gYwCu1QzwUCMl5Hys+rv28ER4AShlEkKZ2PIn5RWfrEsn0
	 U8LQfSoJRFk1w==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 33571F4006E;
	Tue, 13 Oct 2026 15:11:10 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 13 Oct 2026 15:11:10 -0400
X-ME-Sender: <xms:ToLOahsJl453g9JZrxoHZ-vEKewbmUAbQQnaOBqHLOzub_KLcMwUNw>
    <xme:ToLOalT27xImXxKUM6yvXdGWYE_mFX7j-_suaM3nkoxsTpm-A39xsPF1nitAoFPvH
    SCwXsuwWPjcdSd8NA_FIzhpv2R-N6PhWZEmGXgIjblqoRPUuWD1hiw>
X-ME-Proxy-Cause: dmFkZTFPhrhFuE7N0klfMxMdGhWn05Jn+vXciRhuz1PzMjUd1ljc3ZAep0aQKITflPQSSg
    B7aopezQH63f7qiQa3/JFUrXN4820A9EdF5SVDsQ3Y0Jbj8QhHqODlZKRmx16qPzyp+IN5
    UIrJWNXevsVBfFAXHbWNuo/IiUbvr8vj4LOcUSPMXQz8CNwLUkWQkSCiX9lJuwJ7PIOOhk
    rDqo+v2WGesqxu+WIGEDxsdmuBHhN8e8RnpYKbMvbdFxXB3OiKXFCpxpjLK5MOzO15UqmI
    5TcXIiAKZiAMCf3ciu3Z3a6THKBxc7FPbnTNflUpE13ZFgPIpl9L0xEmNWtlWDak1C9ao4
    Hq5bx+fSmTuwB31awP+WBUG6HuF0TKTt5aPI0Wxi6MfOT0L3Y1dCsLbBgu0OhJ9OO6jksz
    PUu6c1vUMQIsPT/bjjpflT9D+wKc3bYmhF2X/6O5QYhFyuJXj+NLW2fq1k43jWCVvbJ+eK
    cthb3zW0H11a1tcELYjI3t1j1Hr0FcLW4O4iYrIkMbmbKHJr1MxkgAZcSLtZIgwHDYJBol
    Kq7/JgdF2nPSPxSern8GEVnGpqs7IjepcXuy44EtUXdXXCPN7wqUYNK5fTpRhnhcJ6z3jX
    QuzD7/ZqssDksEcn/y4cwvT0gys+c0yKlHhs/IyhqninKkeI4Li1SlwXLDOg
X-ME-Proxy: <xmx:ToLOapBg73VM_NjIcfLoeXne8QGVGJzP-SK-XX7NQ6pcRgdX7rRgVw>
    <xmx:ToLOarVRInQLM-ohdbshbOpdiqw4jtj43ZsNoCoJVD2KwlbBPO6oJw>
    <xmx:ToLOatrHLuMhCyZ33KYIeOEe3HIu7uiGRsw31P6LupOhg7Z-sWKq_w>
    <xmx:ToLOanRPS3-dXMhrLgfeSt8hTiD0ThjA7KlML8iuOg1JgbnyAVDAnQ>
    <xmx:ToLOan0HzEEhQ9891l2518hpQKIOvWM0Nd-dYS3nU-JqfvRfdeGEiUic>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 15BC3B6006E; Tue, 13 Oct 2026 15:11:10 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A4VGITYuyewk
Date: Tue, 13 Oct 2026 15:10:48 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Roberto Bergantinos Corpas" <rbergant@redhat.com>,
 "Frank Filz" <ffilzlnx@mindspring.com>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, NeilBrown <neil@brown.name>,
 prabhakar.pujeri@dell.com, linux-nfs@vger.kernel.org
Message-Id: <3026f4b1-83f5-425e-b5ec-8bfb9d642ec2@app.fastmail.com>
In-Reply-To: 
 <CACWnjLwvhFa5nRTk0w5h2mFhFOKbtrjhnB_9V8i097XxbXxOwQ@mail.gmail.com>
References: <20260917104905.669983-1-rbergant@redhat.com>
 <fdb976f6e9b78e2618de70bcf6595e9f484fc30f.camel@kernel.org>
 <015401dd4d17$f0df5e60$d29e1b20$@mindspring.com>
 <CACWnjLwvhFa5nRTk0w5h2mFhFOKbtrjhnB_9V8i097XxbXxOwQ@mail.gmail.com>
Subject: Re: [PATCH v2] NFS: return DENIED in decode_lock_denied if we cannot decode
 owner
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Tue, Oct 13, 2026, at 1:16 PM, Roberto Bergantinos Corpas wrote:
> Trond/Anna, do you have any objections for taking this into the next p=
ull ?

No objection from me. I have it applied to my linux-next branch and plan
to send it along.

Anna

>
> thanks!
>
>
> On Fri, Sep 25, 2026 at 8:02=E2=80=AFPM Frank Filz <ffilzlnx@mindsprin=
g.com> wrote:
>>
>> The thing is, it may not be a server bug. The protocol specifies a li=
mit of 1024 bytes for the owner opaque. The owner may come from somethin=
g other than another Linux client.
>>
>> In fact, as has been pointed out by someone else, Ganesha returns a 2=
1 byte "ganesha_unknown_owner" when the lock owner is not another NFS ow=
ner. Obviously we could (and probably will) shorten this, but the owner =
could just as well come from another client, or be some representation o=
f a local owner. Nothing in the protocol even gives a hint that the owne=
r should be limited to something as small as 20 bytes.
>>
>> Personally I have wondered of the conflicting lock owner is really us=
eful to anyone anyway. Obviously the Linux client does nothing with it (=
which really is reasonable since the POSIX fcntl call only allows for re=
turning a pid). I guess there might be some use in a tcpdump trace (but =
even there, one might argue it would be nice to see the IP address of th=
e client holding the conflicting lock along with its [probably 20 byte] =
lock owner).
>>
>> Frank
>>
>> -----Original Message-----
>> From: Jeff Layton [mailto:jlayton@kernel.org]
>> Sent: Thursday, September 17, 2026 5:24 AM
>> To: Roberto Bergantinos Corpas <rbergant@redhat.com>; trondmy@kernel.=
org; anna@kernel.org
>> Cc: neil@brown.name; prabhakar.pujeri@dell.com; linux-nfs@vger.kernel=
.org
>> Subject: Re: [PATCH v2] NFS: return DENIED in decode_lock_denied if w=
e cannot decode owner
>>
>> ...
>>
>> Typically, we don't work around server bugs in the client (and vice v=
ersa), but I think this is a reasonable thing to do in this case since w=
e don't use remote lockowner information anywhere in the kernel.
>>
>> Reviewed-by: Jeff Layton <jlayton@kernel.org>
>>
>>
