Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7129E3A2574
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 17:42:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787938933; cv=none; b=Rz/0a080Iwy+f+8IgH1h0JqW9QgGkrUKSUJOEtgFuYMNZ2rGsxNlGDlGpgR8pAi2qz+SrF2nxEKq+MQiWbWOj/gkLwopNUaXixcLhxqHSOCSc8eEa4Yvr04qViNSwzFAmwQBSR890XyzkKvKe/6MZu3z5jviZnJlAPTm9QY1Bjs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787938933; c=relaxed/simple;
	bh=sJx2kpIALsfu1KyzpV0mRV0liu3XSs2ymhIKRwuW0V0=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=VZlQtntoqS2fcZy0INTCD0Y5nmCMl8CABjd6A6hltszLFAwY0d8L/k1RvRPoBKaU42Y8ZuQGlJKVaRafz8pJr5VJSr/jeTgAVlqmR3LaQO/+LfIWKnt1vlTasPukSf7MoW4kdwQZBz18ncBKsxjH0jH8HdGVqOEYjAJSyniWYZI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ML+/NQ3v; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ML+/NQ3v"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 46FFF1F000E9;
	Fri, 28 Aug 2026 17:42:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787938929;
	bh=b+jds6pm+KBL9M/beJRYI2usviXHKt39tVfQ9M2uWNQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=ML+/NQ3vIYvuhvbF0+RZGFUqYVkB+0ZqRcC68aMYlBmcxvq122b6gZpowc9riTiMS
	 EKPWvXmwPnh8MByqo0LxuXhLVhwDKkQxC6zGHtx6rxGftWM7GlbwEvZwobO+ztdyY8
	 FTiLVWuZhPRX8fDa0B6dFdSZA5cWAfNuDrN9I1pswhTa4RfG9eoLaUTixRe1aBNEYo
	 9kK9FQfzq7BhxbrZc/5e4PrRhsw1mYZEJ8K1ScL+yTzK3+IUHWt5Wo83OKSoCQNReF
	 qJjFKETRrr2PxTVI8aIPIh8GplEik5KGv3hKpVytVXoSCNAlxU5PUxTT1JiO9cLMHV
	 Xw/Dgwb54xTxQ==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 8117FF4006A;
	Fri, 28 Aug 2026 13:42:08 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Fri, 28 Aug 2026 13:42:08 -0400
X-ME-Sender: <xms:cMiRagseOpQrxKj7P9R_ACM88kTonqR1uFwDPx_DYb3R7z-scH4fFQ>
    <xme:cMiRaoSAb2tglBCFtXjcbNa9Rjs50eetsJ_DGJ0X6UzW4dJVy7vFGhMF2k76yokQB
    aEZn6RaV8E74nEgQH_-damiIgEfNVStjvypqQJbU71-_9JJzKR1WRKp>
X-ME-Proxy-Cause: dmFkZTEPHJW1PL68l/lGN7PcjRQAPAMOCd9yALY5NfsFVJTGwo/bi6BC46+4N4jR+d8VVp
    Z624GAjMwR2NleijmZbzehhTDOGf9qQOf+autnF5cP/76CEVuLvqZJwRTgcEJA5fbHevL+
    znPID4C+BgpQohZuAyT/f5LT3UFyb4J+cfZ6/lS2ujLftYGNRDCHnA2g89dFu3yZOWPxdZ
    Ff5n8W+B81FzesKBut7VlBqmeLbHovqCajv9HfIlTnt5ziL12/yrbTY9/OEBl8IMF3HpdJ
    Vu7TN1R4S4AfRTlnNq1r3hBYhMWHGdasJb7RTYwWqeV+vVh7Z+EHeRZCnB9v7qw0A6qytT
    grNXB7Do80NAejIhljBRUjoL8HgI/GOk17xgWqTwaKLMSkz8gJ6ZDHvMEBVK5fyt2Ukobk
    9mTo75CcpThfuuwSNI8yn2KhgTfVh+EHdAgmlLfYp5Lfal4Dct5bQwtRsjpAIU76KHjzlz
    6HDyMCWADbIDA5bNLI554qaHEgPTe8HRyZK3Na6qyI87vmr1/Kz3E0F+zvgnkBYLK2eHDc
    Fsz9WlOxqPoqX0DZE4fFVTcx0FQd1hsBqzdrL8WyUaRW/Cppkj5YWt9hDnV9hPFY11c1IT
    5RvkBrK/YFfoV/5KiUXxc1ncCf5bW4lJUN5iPilFehLH/YvgjkxuFFMgTt4g
X-ME-Proxy: <xmx:cMiRaqbq2jaZvV9j3wYcbahZ2UytlAVw7WB3gXeCIYrdmsbClV1Png>
    <xmx:cMiRamt8_DI7VfI3lAQQYygkE5NHP5yr-gK-o2fi7fTWAvgWSXY53A>
    <xmx:cMiRasPqYnCRDxA7UiZYwMxnNfZenkgERWEo5lts6ZPW92glpPirxQ>
    <xmx:cMiRat5F_c3h-1NhF7ljnUSZAwix90WCF00xMLbmNvJPfRKXIWdT6g>
    <xmx:cMiRaiSqTDz1eRP2WijgXL88tvniVK9uIYfvk5jUuY1HSMcJRpRYMzHN>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 4D0B1B6006E; Fri, 28 Aug 2026 13:42:08 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A7K4uVO3Lm2V
Date: Fri, 28 Aug 2026 13:41:48 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org, "Jonathan Curley" <jcurley@purestorage.com>,
 "Mike Snitzer" <snitzer@kernel.org>, "Jeff Layton" <jlayton@kernel.org>
Message-Id: <fdf3cf24-a0b2-4350-961b-028847c47bc9@app.fastmail.com>
In-Reply-To: 
 <da98de51fe276a11faef6b42d469ed73dd4ff53f.1787327939.git.bcodding@hammerspace.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
 <da98de51fe276a11faef6b42d469ed73dd4ff53f.1787327939.git.bcodding@hammerspace.com>
Subject: Re: [PATCH v2 14/23] NFSv4/flexfiles: Honor ndc_immediate on
 CB_NOTIFY_DEVICEID CHANGE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Aug 21, 2026, at 12:29 PM, Benjamin Coddington wrote:
> When a CHANGE notification carries ndc_immediate, RFC 8881 Section
> 20.12 says the change is enforced immediately and the client might not
> be able to complete pending I/O.  In addition to un-pinning the stripe's
> device node, mark the old node unavailable.
>
> Marking does not recall the references already handed out.  A write
> whose DS connection is already up keeps using the old node until that
> I/O errors: nfs4_ff_layout_prepare_ds() returns early on a live
> ds_clp, and the unavailable flag is only consulted when a connection
> is being established.  What the mark does change is that a read skips
> the node while another mirror is usable, and that an IOMODE_RW segment
> still pinning it stops counting as fully available -- so I/O the
> server rejects falls back to the MDS rather than being retried against
> a mapping the server has already withdrawn.
>
> The walk can also exchange out a node that already carries the new
> mapping: a re-resolve that completed between the unhash and the walk
> reaching the stripe, raced by this walk or by the walk of a later
> CHANGE for the same deviceid.  Ripping such a node out is harmless (it
> is still hashed, so the next I/O re-pins it from the cache), but it
> must not be marked unavailable.  Stale vintages are distinguishable by
> hashed-ness: every superseded node was unhashed before its walk began
> and is never re-inserted, while a fresh node is inserted before it is
> installed.  Only mark nodes that are no longer hashed.
>
> That test is hlist_unhashed_lockless(): the hook runs under the layout
> inode's i_lock and rcu_read_lock(), but not under nfs4_deviceid_lock,
> which is what serializes the writers of node.pprev -- and __hlist_del()
> stores a neighbour's pprev with WRITE_ONCE(), so removing any other
> entry in the same bucket can write the field this test reads.
>
> Without ndc_immediate, pending I/O drains on the old mapping and only
> new I/O re-resolves, as before.
>
> Assisted-by: Claude:claude-fable-5
> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 46ca58e8e96b..ebb19a919f9d 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -2541,6 +2541,14 @@ static void ff_layout_reresolve_deviceid(struct 
> pnfs_layout_hdr *lo,
>  				kfree(put);
>  				continue;
>  			}
> +			/* Only mark stale vintages: a node still hashed was

I don't think I've seen "vintage" used when talking about anything other than
wine before.

> +			 * fetched after the unhash and carries the new
> +			 * mapping.  Lockless -- nfs4_deviceid_lock, which
> +			 * serialises pprev, is not held here.
> +			 */

Nit: this comment is pretty wordy. Do we really need to define what "lockless"
means here?

Anna

> +			if (immediate &&
> +			    hlist_unhashed_lockless(&old->id_node.node))
> +				nfs4_mark_deviceid_unavailable(&old->id_node);
>  			put->dev = &old->id_node;
>  			list_add(&put->node, head);
>  		}
> -- 
> 2.53.0
