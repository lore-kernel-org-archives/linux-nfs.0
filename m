Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([199.115.105.18]:46434 "EHLO
	mx2.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbbHUJgs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2015 05:36:48 -0400
Date: Fri, 21 Aug 2015 12:36:31 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
To: Jeff Layton <jlayton@poochiereds.net>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>, <hch@lst.de>,
        <kinglongmee@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
        <linux-mm@kvack.org>
Subject: Re: [PATCH v3 03/20] list_lru: add list_lru_rotate
Message-ID: <20150821093631.GK2797@esperanza>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
 <1440069440-27454-4-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <1440069440-27454-4-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 20, 2015 at 07:17:03AM -0400, Jeff Layton wrote:
> Add a function that can move an entry to the MRU end of the list.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Vladimir Davydov <vdavydov@parallels.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
