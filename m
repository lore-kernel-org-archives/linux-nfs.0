Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:44597 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753545Ab0JUT7z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 15:59:55 -0400
Date: Thu, 21 Oct 2010 21:59:58 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS bug with utime/file create
Message-ID: <20101021195958.GD11416@ics.muni.cz>
References: <20101007160659.GP12489@ics.muni.cz>
 <20101021195633.GG10192@fieldses.org>
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <20101021195633.GG10192@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 21, 2010 at 03:56:33PM -0400, J. Bruce Fields wrote:
> There have been a number of fixes to the client state recovery code
> since then, so it may be worth just retrying with a newer kernel on the
> client.

yeah, the problem was caused by endless loop in nfs4_do_open_expired. Already
fixed in mainline.

-- 
Luká¹ Hejtmánek
