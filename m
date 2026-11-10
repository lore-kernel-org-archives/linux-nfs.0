Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794343565;
	b=HNsC/vjJBuB5u/YK1G2yiqB2RKoFSadg3+fEXWHpxKyVV+t3ZMJlnzs3cuBbSaVwbkFi
	 /QUt6or7HXVdMYUwrMAUZmBIpy7q7xyR4+u3E/zreORvVooq+tQdV8OmGcMIOybHw7SkY
	 mEkd1VNBxmJw66WC+0IkwA4LsSs+nMyZyLW59wEelZz5VTKD7uC2KALCBSuPU0MC94vlx
	 jTmrQqrd2xg8AePF0QrE49nK3ufouENS3Usdy1iZn3hAHyJ1AHx+BOSLYfm5yXeYDL4pN
	 2xX2SrSe58Pdm+uuRkZH1tKAssOPEN6XT6ijayhuSckHrwKT9QgohBCqQfqFFmBNtqQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794343565;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 Mail-Followup-To:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To;
	bh=rMRPONQOYjAF9HKKBayLjA2YuezRW4mL6HNg3dL1nlo=;
	b=KVq5pWAZaN9ymIusfsctj4IF8fI8xdDg0PjE3VK/9sG5Wcm23Gc3dcn8FcRTXagiFayO
	 kVJuNT6Q1MSw9YO4wWwTIrzSjEfFIdlFSOkvE2DPzPl6Fv4Z7BpDWj/k0ykNyktmZFpIU
	 qQKJZBpnBknfsr687Y3S7sqB5QcURQhpFxC+Bj+VjIKK1bVqMsqDQ29LCEh3H19jbYTCJ
	 IgQK67NjD+MbALDbGYFn7/n7Mwtkm9k4/8B1h42pi5npeqDd25xsiLhUI5W3cichSML6g
	 W3ZPwzQ99nyaUR+991RrbE4tPHjiC9LRIcu47uRTMNLMR+hXmKpmFerdwgtf1sAyD7Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HzRYE13j;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 117BB60A2603;
	Tue, 10 Nov 2026 20:46:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HzRYE13j
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 47D441F008AB;
	Tue, 10 Nov 2026 20:45:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794343564;
	bh=rMRPONQOYjAF9HKKBayLjA2YuezRW4mL6HNg3dL1nlo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=HzRYE13jB8RdQv3aSy711gVTQF5aN3kmny3Bm+Tqd6DGpMnW/UdmBhwvuV3tDKwWA
	 qBQkdAe99fCfyY4HwhHW6vpWLb11tiX1rqZm0gqSH24JDOLS4Qw49hrn6RKPLTZ5tX
	 8yK911/kTi5YKMv0Zeg0t9hinxeSS095ez81rveTvDj3lhZIp5MNrpZ0TzLVXjAROD
	 H+8sIgKlcwqIAFUbaPlcIA/mKF9hJXlPwet/3tzJzqABID/FKMqpm7AOyUBYjWme3C
	 0bNu78jINjA9S3ckBH6UNePnv8GkZJATc2s+TTg1AYJLjtNo7jNr7qgY8y7Qdi6pm5
	 ugUx9cOxV5vJQ==
Date: Tue, 10 Nov 2026 21:45:52 +0100
From: Gao Xiang <xiang@kernel.org>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>,
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>,
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org,
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>,
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
	driver-core@lists.linux.dev, linux-mm@kvack.org,
	bpf@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@vger.kernel.org, apparmor@lists.ubuntu.com,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org,
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev,
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-usb@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
	linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org
Subject: Re: [PATCH RFC 40/41] erofs: refuse files on pseudo filesystems as
 backing files
Message-ID: <avOCgJPOwRdsIxgd@MacBookPro.fritz.box>
Mail-Followup-To: Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>,
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>,
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org,
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>,
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
	driver-core@lists.linux.dev, linux-mm@kvack.org,
	bpf@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@vger.kernel.org, apparmor@lists.ubuntu.com,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org,
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev,
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-usb@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
	linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-40-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-40-4c998976c6c7@kernel.org>

On Tue, Nov 10, 2026 at 10:14:56AM +0100, Christian Brauner wrote:
> File-backed mounts take any regular file as the image and the same goes
> for the extra devices of such a mount. erofs reads them with the
> credentials of the mounter so this doesn't hand out anything the mounter
> couldn't read anyway. But files on pseudo filesystems aren't images.
> Refuse them just like loop does.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Gao Xiang <xiang@kernel.org>

Thanks,
Gao Xiang
