Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33456 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934982AbdBQUCz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 15:02:55 -0500
Date: Fri, 17 Feb 2017 15:02:53 -0500
To: "Mora, Jorge" <Jorge.Mora@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question about NFSv4.2 server-side copy implementation
Message-ID: <20170217200253.GI10894@fieldses.org>
References: <BLUPR06MB54767D9B4746E210D176C3AE1580@BLUPR06MB547.namprd06.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BLUPR06MB54767D9B4746E210D176C3AE1580@BLUPR06MB547.namprd06.prod.outlook.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 14, 2017 at 08:07:48PM +0000, Mora, Jorge wrote:
> I can understand failing with NFS4ERR_INVAL when the source offset is beyond the end of the file,
> but do you think failing with NFS4ERR_INVAL is too strict when the source offset plus the count is beyond the end of the file?
> What is the rationalization for failing on this specific instance?
> Why not return a short copy instead?
> Can the COPY return a count less than what it requested (a short copy)?
>  
> As of right now, the implementation on the Linux server adheres to the spec

That's weird, do you have network traces showing that, or is it possible
the EINVAL is happening on the client side?
