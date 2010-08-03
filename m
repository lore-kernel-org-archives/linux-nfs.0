Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41884 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756232Ab0HCTYC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 15:24:02 -0400
Date: Tue, 3 Aug 2010 15:22:41 -0400
To: Victor =?utf-8?Q?Matar=C3=A9?= <dreck@vmsd.ath.cx>
Cc: linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs
Message-ID: <20100803192241.GD31579@fieldses.org>
References: <201008030401.33552.dreck@vmsd.ath.cx>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <201008030401.33552.dreck@vmsd.ath.cx>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 03, 2010 at 04:01:32AM +0200, Victor Mataré wrote:
> Hello,
> 
> I still hope I'm mistaken in assuming I have to go back to NFSv3 if I want to 
> skip NFSv4 UID mapping altogether and just use the numeric UIDs the way 
> they're stored on-disk. However if that's actually true, I'd like to try and 
> make a case for implementing an option to turn off UID mapping completely (or 
> at least for unknown UIDs). If this is already work in progress, just ignore 
> this mail.
> 
> Thing is, the forced UID mapping seems to make tasks like backing up data a 
> little inconvenient. You might want to preserve UIDs that are only known to 
> the client.
> But when you copy an entire root filesystem, it becomes outright destructive, 
> because the rootfs will probably have several accounts that the server can't 
> be expected know. Just imagine a server that's used for maintenance (like 
> backing up and replacing hard drives) of random (foreign) systems. Idmapd will 
> map all unknown UIDs to a single value and thereby destroy that information.
> 
> I think I read somewhere

Pointer?

--b.

> that the Sun people already have a way of handling 
> this. Any chance Linux could do that, too?
> 
> Please excuse me if I'm barking up the wrong tree. If this has already been 
> discussed, I'd appreciate a pointer.
> 
> Thanks,
> Victor
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
