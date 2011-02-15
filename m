Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64794 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab1BOPLf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 10:11:35 -0500
Received: by eye27 with SMTP id 27so126283eye.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 Feb 2011 07:11:34 -0800 (PST)
In-Reply-To: <20110215150628.GA24358@infradead.org>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
	<1297711116-3139-9-git-send-email-andros@netapp.com>
	<20110215092531.GB29871@infradead.org>
	<AANLkTik+dVSmWgO6LRANo2xTt6iMqQ7ehvgqk-igQFhM@mail.gmail.com>
	<20110215145828.GA18038@infradead.org>
	<4D5A94CD.4030508@panasas.com>
	<20110215150628.GA24358@infradead.org>
Date: Tue, 15 Feb 2011 10:11:28 -0500
Message-ID: <AANLkTimUK4gNpHdvYkTs2H6c9w757BqkEXFr54vD8_Y-@mail.gmail.com>
Subject: Re: [PATCH 08/16] pnfs: wave 3: lseg refcounting
From: Fred Isaman <iisaman@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Benny Halevy <bhalevy@panasas.com>, andros@netapp.com,
        trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 15, 2011 at 10:06 AM, Christoph Hellwig <hch@infradead.org> wrote:
> Btw, what's the point for deferring the free_lseg calls?  It looks like it's
> to avoid calling something that might block under i_lock, but looking around
> the pnfs-submit branch it seems that root cause could be fixed trivially.
>
> In common code *free_lseg* and *put_layout_hdr* do nothing but list
> manipulations and kfrees.  And in filelayout_free_lseg we have just kfrees
> and a call to pnfs_put_deviceid which may sleep due to calling
> synchronize_rcu.  But synchronize_rcu is horribly inefficient to start with,
> and you'd better be off using call_rcu to free the device id, which will
> lead to much saner code and better performance.
>

The fundamental reason was that filelayout_free_lseg can call
nfs_put_client (through nfs4_fl_free_deviceid_callback), which in some
codepaths grabs a mutex.

Fred
