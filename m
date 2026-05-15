Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 785563F5BE7
	for <linux-nfs@vger.kernel.org>; Fri, 15 May 2026 22:19:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778883584; cv=none; b=e9aYAd5OKfKJpkNqtqWqGQosnEbI9WFwTzpawC0MBAAci+XZ1kNgoUvREF2JuuhE9onZ/FcYRaG28ywemf9QM30FoVUNHmqi6rGaN1ySmT3DtOSK4LAKdAINdIMhjFvqh8t04wB3T9xm4JafvxWjqahUUvNhsS+5oxjgq0aA1vc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778883584; c=relaxed/simple;
	bh=W0dCpwZODJFKPu2SY6eKQzfEttHd/2HhQ48IKdHDqaI=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=fG3ZFMJ1zo205wzf5yW5X45n/EIz5JD6LvZ5Irld/807yHFXXGTDov2xS3M/sj9NaYN5aXzz+hGJDgIQ9xgo9kzMn43FUvzxmlK/f4rT82NKHIB6rKgCQ4rPIH5XjGi2X5Sn75gVcSHV8zBWO8M3XMt7OZzv9B5Eg/4TlUN1BYw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=qPLUzIqe; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="qPLUzIqe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 47CD6C2BD00
	for <linux-nfs@vger.kernel.org>; Fri, 15 May 2026 22:19:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1778883583;
	bh=W0dCpwZODJFKPu2SY6eKQzfEttHd/2HhQ48IKdHDqaI=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=qPLUzIqe+TD/Ajtl2DCP1cDvkOJuqKO9ysrycysQpsE+m+xWszTfV+rlfwO2rVKqE
	 9F9C5+WMgR58Dq4JWhybLmVz6E2Gq1ppksYTWnpZZFoGIO2vmeRi1n5dNTZU0lZZUM
	 LHgpphCcyo4hniv1oCFJL/7skvnp5MyvMD82drSl7iHg2CdK9SgPMcT1eji4QEntu+
	 bKqWwOLzI8aqSyUq6S+qUu1FZ0TsUcs+G7zeRfwLEDUj7EhUwoZcp6lrZ+yJD0TAga
	 Y0BGiekqxRPhNJJkDIYjraBHPn27CGWMSn4nt6BcPAwp/tcUOYNTNfVjYZTGnNn7yX
	 yQrUAd2V5+gzA==
Received: by mail-yx1-f41.google.com with SMTP id 956f58d0204a3-65c52bb5dd7so653848d50.2
        for <linux-nfs@vger.kernel.org>; Fri, 15 May 2026 15:19:43 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AFNElJ8ZGznizclcJv8v4w/QHh2rySuXfiTsSTkgONxzsVT13plLBpAjPJQUFtEJnbBaZlRwRuUl0j20SlA=@vger.kernel.org
X-Gm-Message-State: AOJu0YxP/iVj6bdWFrlWk5q3CfyAZ2r+3P9EYzKbMmgJGmMn5vTQv2Jd
	6QxbWlX7KBFiFfIinhrpyiVbq4IfmdoYVWehFlRB0Y6kZjCJMAc3ibV8afBHpTFlVx4hKYGOPft
	8QkjUB0lBNEsRTkaYCj8IfMxppr4qJWXloGX4wWIq8Q==
X-Received: by 2002:a05:690e:4381:b0:651:c264:dd61 with SMTP id
 956f58d0204a3-65e226f5107mr4855343d50.7.1778883582591; Fri, 15 May 2026
 15:19:42 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260512053625.2950900-1-hch@lst.de> <20260512053625.2950900-5-hch@lst.de>
In-Reply-To: <20260512053625.2950900-5-hch@lst.de>
From: Chris Li <chrisl@kernel.org>
Date: Fri, 15 May 2026 15:19:31 -0700
X-Gmail-Original-Message-ID: <CACePvbUgHmSuo_r9WDSD+oMnQeW0537OziTPMt-sRHx96ihg3Q@mail.gmail.com>
X-Gm-Features: AVHnY4JAgCglMa8_5PLakfMWnAw05abJthdzcE1NPle548GazZ3X3WKDUpcNb-c
Message-ID: <CACePvbUgHmSuo_r9WDSD+oMnQeW0537OziTPMt-sRHx96ihg3Q@mail.gmail.com>
Subject: Re: [PATCH 04/12] swap: restrict to regular files or block devices
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kairui Song <kasong@tencent.com>, 
	Christian Brauner <brauner@kernel.org>, "Darrick J . Wong" <djwong@kernel.org>, Jens Axboe <axboe@kernel.dk>, 
	David Sterba <dsterba@suse.com>, "Theodore Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, 
	Chao Yu <chao@kernel.org>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Steve French <sfrench@samba.org>, Paulo Alcantara <pc@manguebit.org>, Carlos Maiolino <cem@kernel.org>, 
	Damien Le Moal <dlemoal@kernel.org>, Naohiro Aota <naohiro.aota@wdc.com>, linux-xfs@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, 
	linux-block@vger.kernel.org, linux-btrfs@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, 
	linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, May 11, 2026 at 10:37=E2=80=AFPM Christoph Hellwig <hch@lst.de> wro=
te:
>
> Various swap code assumes it runs either on a block device or on a
> regular file.  Make this restriction explicit using checks right
> after opening the file.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Chris Li <chrisl@kernel.org>

Chris
