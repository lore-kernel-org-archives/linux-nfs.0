From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/3] integrity: path_check update
Date: Fri, 22 May 2009 09:58:46 +1000 (EST)
Message-ID: <alpine.LRH.2.00.0905220958330.6348@tundra.namei.org>
References: <8971a1efcc5153f1c9b167997e5ca0c3c40a69d5.1242753145.git.zohar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org, "J. Bruce Fields" <bfields@fieldses.org>,
	Eric Paris <eparis@redhat.com>,
	Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>,
	David Safford <safford-aZOuKsOsJu3MbYB6QlFGEg@public.gmane.org>,
	linux-nfs@vger.kernel.org, Mimi Zohar <zohar@us.ibm.com>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:41616 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbZEVABY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2009 20:01:24 -0400
In-Reply-To: <8971a1efcc5153f1c9b167997e5ca0c3c40a69d5.1242753145.git.zohar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 19 May 2009, Mimi Zohar wrote:

> - Add support in ima_path_check() for integrity checking without
> incrementing the counts. (Required for nfsd.)
> - rename and export opencount_get to ima_counts_get
> - replace ima_shm_check calls with ima_counts_get
> - export ima_path_check
> 
> Signed-off-by: Mimi Zohar <zohar@us.ibm.com>

Applied to 
git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/security-testing-2.6#next

-- 
James Morris
<jmorris@namei.org>
