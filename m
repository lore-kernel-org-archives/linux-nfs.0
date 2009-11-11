From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: exportfs: Warning: /adir does not support NFS export.
Date: Wed, 11 Nov 2009 12:53:33 -0500
Message-ID: <20091111175333.GA3951@fieldses.org>
References: <4AF99861.7030103@aimvalley.nl> <20091110180747.GA15000@fieldses.org> <4AFA6431.9010405@aimvalley.nl> <20091111141318.GA335@fieldses.org> <4AFAC74A.5000503@aimvalley.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Norbert van Bolhuis <nvbolhuis-bYiImlzuGf1HoQZOM9yvow@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55924 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754959AbZKKRxQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Nov 2009 12:53:16 -0500
In-Reply-To: <4AFAC74A.5000503-bYiImlzuGf1HoQZOM9yvow@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 11, 2009 at 03:16:42PM +0100, Norbert van Bolhuis wrote:
>>
>> What source are you using for nfs-utils?
>>
>
> 779cf81044e92cb51ad590960e7b3671  nfs-utils-1.2.0.tar.bz2
>
> I got it from:
> http://sourceforge.net/projects/nfs/files/nfs-utils/nfs-utils-1.2.0.tar.bz2
>

Thanks.  From your description, yes, that sounds like a configuration
that should work.  But maybe there's some detail wrong--could you show
us the full output of the "mount" and "exportfs -v" commands?

--b.
