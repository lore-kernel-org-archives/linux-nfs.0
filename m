Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795022070;
	b=iANSVKuvefhr/OHOZfmwWc1K7x1KC0yVJbyB3hKmBwZHDFhwh717CLgrPt0iC8XtkFJg
	 KEjh2mvAnJ5Du6kYJQXWs9SZoA2DOrE+ceoFB5pfi+RHMdSZh2WDc90Og5s1euaG280+g
	 0ePrWq1oM0Nd6JAUppeGBK6jAKPZGUPftiqfJm9ZfTQXxUoKNmb3+eCynj+22YEwZ834a
	 AGJjtiX/O4UrlT/XFZngiHZx7h73s4IG7Mr3WrY465X/aNseHtVC8ff61HTiOLknqCbCt
	 44P6dgCBYYEwT8tGUKfB/QS8dUm/8Lpi+MH8XZbQm6vJlAcgu9cHmF+ccjC8RchFWYQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795022070;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=iuxQ2ylSQRCwgbS64Cu4sTUpzf9Rv38mt2//czf1GWg=;
	b=kjmY/hf5ozxKDDfmAveoJx+a8W7iqw3GJyznFKZb2ZsBYdqwc/XZJAF6plhHI8h9RnI4
	 4i70/1jwSzNuD4PNQ/44/ykmlY7NB1RcOP264eh+Ozy+o94MvS8NsFWTdk13DhenkZvWX
	 bWaefh4MPUKsfAt7sKJ0odWWHucpi0H3gwwAhbKmOXPUhmerkiugYSGgWSr1kWq5gFbbn
	 jzLGdSpNHSQIcMsBjbt1Srx00pWnznBQygoc0hfv2z1jTXpK35R8E1tUfKECjXP+AYMFc
	 +r58KdPPRx9YgSsuhM2hnTIA+eTCzpv3NmbvQlXA1FnKWNWYpbGiMawG1hQO8zEcvKA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ivrE64K9;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B7AFC606A32F;
	Wed, 18 Nov 2026 17:14:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ivrE64K9
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C0A181F000C7;
	Wed, 18 Nov 2026 17:14:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795022070;
	bh=iuxQ2ylSQRCwgbS64Cu4sTUpzf9Rv38mt2//czf1GWg=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=ivrE64K9k235nxChgM0l0sX5nQKg6oCGjCaDJ8LYOwWFeZawrGHqfDpoeCyEbeTg0
	 YCkEOPF7hps3z005XSeeuYDY2L9PFZ8xCnAQivZ65Jn1jf0NEnuWY5lYYUzha/mqiw
	 cQalEMGPPJbPgEVJxmrXd4OkfiNbg9BSOmonL0PeWVImon1ZabzkSmxwbpHxxQVMfw
	 uozWpIC1brrS+8/UY/UlpXIVGGOZTKaL/NYkPqG6xeZVFKN/0NRsuJVeSM5YhnNEmM
	 dFYjoM13W8WC4I+R/tbF43EEMxm5HnJzPfWpIaGt4/yOXki1RnK/vH/eWkGMI+RAQy
	 9UIr+CWEfV1uw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 02C49F4006D;
	Wed, 18 Nov 2026 12:14:29 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 18 Nov 2026 12:14:29 -0500
X-ME-Sender: <xms:9Nz9avLllcjjP2r1L1u4usU71qhGtsrlmuIl9tdqCXqqqfubn4KA_g>
    <xme:9Nz9at8nEceuwTXRPUo_LKMt-B9V3Nx4vmE7J1C5eqO25yGwdFEbtLEPWfI9Qn9wq
    iW5SWhX9NY1bKCtKpRi717HG0rnV9Hfl1jrUmOwewkC1d7jGjR1AirR>
X-ME-Proxy-Cause: dmFkZTF68uhA34dUZFXhC1OhT9K6/PB+XWVL9PjXE0rZcEgn2eGQ7IlouPiwo4Ly20+mLP
    /lurMllbg0WJrRpwvrpb1vE2rECGmLBzRBZ9KWzFfGeiPZ52nTSQ6tn+Zh2mdY9vmhOy1C
    qi/DMg3X4vHJ7VmQVlNHJ/ns/Xge49Iui9yShuVNn/r6kphQj26ndVDXwSEI+eVyMeMFdJ
    3MvV1pgbcf3/Hq/u6hab0FqIR8w60prJE8sQLSRDT1p73mXw/IECsYQ+F48C7GK54Qbaq2
    IGIoyjKlKVxNJQLA3U5xqNaTu9NqEcSD5pqn2ePx+6GeXKwzL1Ys6kxFywoni2oyfmbJWU
    E8HDlw81byIEQHf10k8KkiQQ4uYE59+WqrwGHJIxLsD88JVRS6TpVTc7xVXxIPGESvDzLW
    iNTGakW80MNLSqU+KZPfeEUMN8yxop7Jjjjgh/UquDdCWeqtKRANFQiB0MAHBqgwHGhlWJ
    ZmO0rXncZ/F5PVSdYu+vP225G02jg/2ViBpQ7BQA791tSopMMy9mXZYTrvSWq+b+uqqP5R
    fXxqovRQHkVLCsGCP+YYWR3NT56jQbyp1RYaF5OfCQyzvBUlTCF3T0Y5sRYGIxHDw5NN12
    ruY9v63wDM6kxJRYiYNvk3k6Gy9LcimQYksK8BWbEjzM/AGzvyYIZSLlsfKA
X-ME-Proxy: <xmx:9Nz9asqqIkvOYmEKjUPhfmu1DaGLctcH9M8szVikza9FK3lzF0Y2pw>
    <xmx:9Nz9al94RRYvfwA5oQ_NeqixjFhnaUKzt-GE7v422Qeqkqo5SLV2oA>
    <xmx:9Nz9atCI3zWU_AXx1IUa89pq85TIatDvWtmW06hQ0ESev8BrOVR3RQ>
    <xmx:9Nz9anHKD1OjQVsvBqVdcaen7Y77XNgNEAeKQ29o6vil0sI4X2eMZA>
    <xmx:9Nz9av0BlmDTZ5ReVMqRV5cDqJenueU2dmUrZMLM8UUkMqtzAR2WCc9Z>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C5EE4780076; Wed, 18 Nov 2026 12:14:28 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AgKvhXN-CN1w
Date: Wed, 18 Nov 2026 12:14:08 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Amir Goldstein" <amir73il@gmail.com>
Cc: koraynilay <koray.fra@gmail.com>, "David Sterba" <dsterba@suse.com>,
 "Namjae Jeon" <linkinjeon@kernel.org>,
 "Sungjong Seo" <sj1557.seo@samsung.com>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Konstantin Komarov" <almaz.alexandrovich@paragon-software.com>,
 "Paulo Alcantara" <pc@manguebit.org>, "Chris Mason" <mason@kernel.org>,
 "Yuezhang Mo" <yuezhang.mo@sony.com>, "Jan Kara" <jack@suse.cz>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Ronnie Sahlberg" <ronniesahlberg@gmail.com>,
 "Shyam Prasad N" <sprasad@microsoft.com>,
 "Bharath SM" <bharathsm@microsoft.com>,
 "Sergey Senozhatsky" <senozhatsky@chromium.org>,
 ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
 "Darrick J. Wong" <djwong@kernel.org>,
 "Sean Smith" <defendthedisabled@gmail.com>,
 "Andrey Albershteyn" <aalbersh@kernel.org>,
 "Pedro Falcato" <pfalcato@suse.de>,
 =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, linux-btrfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 exfat@lists.linux.dev, ntfs3@lists.linux.dev, linux-cifs@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Message-Id: <9c4a509c-b6af-4da1-8a64-9d5c26c74bff@app.fastmail.com>
In-Reply-To: 
 <CAOQ4uxjme9sJ5LGNDnP6rEKZLTJzX_ZdcMohgu2iLULK96GPOA@mail.gmail.com>
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261115180343.576773-8-koray.fra@gmail.com>
 <f297d9ea-ebd7-47f4-ab7b-de5c45980000@app.fastmail.com>
 <CAOQ4uxhpMARO_ZMJDeoa044BwufLVnS0o4Fv0abBF=tjaZmtWQ@mail.gmail.com>
 <cd49ce48-58d7-4341-b4fc-34e63daf3c52@app.fastmail.com>
 <CAOQ4uxjme9sJ5LGNDnP6rEKZLTJzX_ZdcMohgu2iLULK96GPOA@mail.gmail.com>
Subject: Re: [RFC PATCH v4 07/10] nfsd: add provenance time (ptime) via
 FATTR4_TIME_CREATE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Nov 18, 2026, at 11:36 AM, Amir Goldstein wrote:
> Can't an NFS client be connected to another NFS server
> implementation which does allow this?
>
> I can't wrap my head around the problem.

You already named the problem in a previous email: What happens
when the NFS server's kernel is upgraded from an NFSD that exposes
only btime to one that picks either ptime or btime?

Clients will see a file's btime before the server restart, and
afterwards, they will see a changed TIME_CREATE but the file's
NFSv4 change attribute will be unchanged.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
