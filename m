Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 709FA54F86
	for <linux-nfs@vger.kernel.org>; Mon,  8 Jan 2024 19:10:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="baYpd0pY"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1704741037;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=5WpaiAXgIJcHSCV8HxyPjHGj793oUaJH1KJASvJo+js=;
	b=baYpd0pYjYaJB8C2UhFTinauTz6y5HjqputL55ZPkx+G9tW8GMUjxQCcGynsbuuGWa6FBW
	kYLGcIBxK8Peq4SDZAuocjDRYXKUIxCOYlmBFJory5hAhqXXuX82Ln12jzKa6tauSu/yzf
	QtFilhT1Q/NEfPY/cJH/x3YiuDnLmUc=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-588-thEPganHN7WonZIIW2kbLQ-1; Mon, 08 Jan 2024 14:10:29 -0500
X-MC-Unique: thEPganHN7WonZIIW2kbLQ-1
Received: from smtp.corp.redhat.com (int-mx10.intmail.prod.int.rdu2.redhat.com [10.11.54.10])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id AB0E3185A783;
	Mon,  8 Jan 2024 19:10:28 +0000 (UTC)
Received: from [100.85.132.103] (ovpn-0-5.rdu2.redhat.com [10.22.0.5])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 17A5E492BE6;
	Mon,  8 Jan 2024 19:10:27 +0000 (UTC)
From: Benjamin Coddington <bcodding@redhat.com>
To: Dan Shelton <dan.f.shelton@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
 ms-nfs41-client-devel@lists.sourceforge.net
Subject: Re: What are nfs persistent sessions, and how to enable them in the
 server?
Date: Mon, 08 Jan 2024 14:10:26 -0500
Message-ID: <317A2531-BA7D-45C7-8C18-DBC9E533BF91@redhat.com>
In-Reply-To: <CAAvCNcCqXr_U+WG2NK3uVvQMS7bYc4=n4emKs1ZLAtKy1XYEWQ@mail.gmail.com>
References: <CAAvCNcAAE0x4wJ0mVJ0b-7keSv3g=cFQf5o0yEd6-pMq35AzGg@mail.gmail.com>
 <466B1C7F-A994-4108-8154-4BA392B99647@redhat.com>
 <CAAvCNcCqXr_U+WG2NK3uVvQMS7bYc4=n4emKs1ZLAtKy1XYEWQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 3.4.1 on 10.11.54.10

On 8 Jan 2024, at 13:55, Dan Shelton wrote:

> On Mon, 8 Jan 2024 at 16:56, Benjamin Coddington <bcodding@redhat.com> wrote:
>>
>> On 7 Jan 2024, at 10:24, Dan Shelton wrote:
>>
>>> Hello!
>>>
>>> The ms-nfs41-client brings up a message about "persistent session" -
>>> what is that?
>>
>> Hi Dan,
>>
>> See: https://www.rfc-editor.org/rfc/rfc8881.html#section-2.10.6.5
>>
>
> Do the Linux or Solaris nfsd implement this? How can I turn this on or off?

The linux server does not, and I'm not sure about the Solaris server (but I
don't think that it does..)

Ben

