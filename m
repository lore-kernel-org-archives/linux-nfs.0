Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795126180;
	b=b5p82uLPZ0o7qN8gL+6E2KpArZ8FhZb8s6L3TXBDkfzUALkE02ur2qNxNuoQW5voDe5N
	 6+nRWgXUAdjSBnOkSqxi//B4IyhDhL0VVJ7oQuWxUxtLir9FqHcNu9aT9V/jxH8oRJaBq
	 ZqsYNigXNReLQCUtetYQ+D2dW3WG+ZDSAwGIxmZnEcGf3YBhmzhpEYPkj9WtINIP1UfwN
	 R/DynpurC4SXGOecc89Yn0m97GCTAcvgw67qF+Tz8mhYCMcX5KZ9zYS2HYP5DMU12Ps5h
	 IETsgLkPIgkl8Dfu5JoI8BN1ah1zPIfA0elVuoFg4Vxfq7ncc6uJXG7WM8I3S+cfhFg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795126180;
	h=Received:DKIM-Signature:Received:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To:User-Agent;
	bh=KqNyElDhP7uj6kmGvqPEGbEm6BRkttpUAEwQA2VfMIU=;
	b=4js4YHN5PYnwAXP3LJEtzwLLQoPl6KpTQ2Gq4cfaVNCiFry4AxN6IWsxcHqZPHod1IyG
	 tR6ljRb4UgLetpLJDUnPZ9BE2lVotVLl1EuNGVDpNEhTrXhQm0eNgdBVqmej6mSI8ZWdp
	 Qk/VcB+oItNl39+FXobqKo3cXi9us9QIUPneSII01h8Dgh0ZMwxABOVy2HeGF2kxKbBMg
	 4PBp6W0vlTLvwKQY0yyYMM+7enB3gyiDN4OQhYae2kG3QvhnaOCmjQUdhnVJeyEJEu/AE
	 HftVccu3/miXbUOH0OyjHx5n7mT9NymuEZ3DHdJMWOkhYKZgMxUqL7ZJpNpITiFgfQA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XEUyRzTZ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4DD2860A2617;
	Thu, 19 Nov 2026 22:09:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XEUyRzTZ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 849841F000C4;
	Thu, 19 Nov 2026 22:09:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795126179;
	bh=KqNyElDhP7uj6kmGvqPEGbEm6BRkttpUAEwQA2VfMIU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=XEUyRzTZRdJfGT6BXmpGGdCjTNoIMo/TD3KHFLKYS9Nnjz+spxWLymKmHg3OvnTYY
	 kAoKCkVflJqIWXyySIDAZUyvBlh8AjLUjBzaTXGt0Ohb9QmH2CN9mkSMIGP5qRyhog
	 soY4NpBN0GHAJ0RYdvZULi2feVRfrMHG2b9/x9Y5Dlp59bJyegB78onlovTW4SWMH9
	 3S7Zgf0j1snBq4wL3gP6p+/OKn66am+ZMRqBFQ0qJR8OcmF+4071xr5QXnM74J6AME
	 sIS0+CsvtPAkveuISH9C+j7T4EYeo3RlR9GiKgUkyOpeMVj7cWxuH5bKXej+L03bL5
	 +UQd/TFTrfa0g==
Received: by pali.im (Postfix)
	id 9A9A35C7; Thu, 19 Nov 2026 23:09:36 +0100 (CET)
Date: Thu, 19 Nov 2026 23:09:36 +0100
From: Pali =?utf-8?B?Um9ow6Fy?= <pali@kernel.org>
To: koraynilay <koray.fra@gmail.com>
Cc: Amir Goldstein <amir73il@gmail.com>, David Sterba <dsterba@suse.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Sungjong Seo <sj1557.seo@samsung.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>,
	Paulo Alcantara <pc@manguebit.org>, Chris Mason <mason@kernel.org>,
	Yuezhang Mo <yuezhang.mo@sony.com>, Jan Kara <jack@suse.cz>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Bharath SM <bharathsm@microsoft.com>,
	Sergey Senozhatsky <senozhatsky@chromium.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
	"Darrick J . Wong" <djwong@kernel.org>,
	Sean Smith <defendthedisabled@gmail.com>,
	Andrey Albershteyn <aalbersh@kernel.org>,
	Pedro Falcato <pfalcato@suse.de>, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	exfat@lists.linux.dev, ntfs3@lists.linux.dev,
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-api@vger.kernel.org
Subject: Re: [RFC PATCH v4 09/10] ksmbd: add provenance time (ptime) and map
 it to CreationTime
Message-ID: <20261119220936.mssmaixcorn2gzli@pali>
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261115180343.576773-10-koray.fra@gmail.com>
 <CAOQ4uxhjxp5sxYphWoB=8sgX3XHOv9zLVYf+8ZjYbS_gQDxO3w@mail.gmail.com>
 <DMZIQG4U1NTH.2IN0S2YIWEYTG@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <DMZIQG4U1NTH.2IN0S2YIWEYTG@gmail.com>
User-Agent: NeoMutt/20180716

On Thursday 19 November 2026 22:51:26 koraynilay wrote:
> On Thu Nov 19, 2026 at 6:34 PM CET, Amir Goldstein wrote:
> > On Sun, Nov 15, 2026 at 7:04 PM koraynilay <koray.fra@gmail.com> wrote:
> >>
> >> Implement provenance time (ptime) in ksmbd, as introduced in a
> >> previous commit ("vfs: add provenance time (ptime)").
> >>
> >> Map it to SMB's CreationTime, making it settable by SMB clients. When
> >> reporting CreationTime to clients, prioritize ptime over da.create_time
> >> memorized in the user.DOSATTRIB xattr.
> >
> > That doesn't sound like the right thing to do.
> >
> > If the server stored a CreationTime that client had set, you cannot
> > override this.
> 
> Ah, yes, but how would we handle older files which get a custom
> CreationTime both before (in the xattr) and after (in ptime) a kernel
> upgrade?

Just to note that this problem is already there. ksmbd can export for
example ntfs filesystem on removable disk. And this removable disk can
be connected to Windows machine which will always only touch
CreationTime and ignores xattr DOSATTRIB.

> > When the client sets CreationTime, the server can decide if it can and wants
> > (may be a policy decision) to store CreationTime in PTIME and not store
> > it in user.DOSATTRIB.
> 
> To fix the above problem we should probably keep storing it in both
> ptime and the xattr though.

IMHO for a long term solution it is better to not have duplicated
information in xattr. Because duplicated information are going to be
out-of-sync. Windows NTFS driver will not update xattr DOSATTRIB.

For me it looks like that this needs some policy / configuration
decision done by user. We do not know if the user will replug that disk
also to Windows NTFS driver (and then those xattr DOSATTRIB could cause
out-of-sync issues) or will only use it from Linux or Samba and then
xattr DOSATTRIB is probably fine.

> > Fun fact: the user.DOSATTRIB format also has a mask so storing the
> > creation time inside it is also optional.
> 
> With my current patch series applied, when CreationTime gets set by a
> client, ksmbd writes it to ptime and fixes/heals the xattr (= removing
> the CREATE_TIME flag created by older kernels, see the other fun fact
> below).
> 
> And another fun fact: until [1] ksmbd ignored the flags and just
> read/wrote the attribs every time :) so that can only be honored for
> files that have been written to/updated with newer kernels.
> (That's why there is the ((flags & CREATE_TIME) || da.create_time > 0)
> in my patch, and not just the flag check)
> 
> Thanks,
> koraynilay
> 
> [1]: https://lore.kernel.org/linux-cifs/20261115155308.415734-1-koray.fra@gmail.com/
> 
> > Thanks,
> > Amir.
> 
> 
