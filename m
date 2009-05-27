From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH v2] integrity: nfsd imbalance bug fix
Date: Thu, 28 May 2009 09:49:10 +1000 (EST)
Message-ID: <alpine.LRH.2.00.0905280948500.28804@tundra.namei.org>
References: <1243431112-7388-1-git-send-email-zohar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	hooanon05@yahoo.co.jp, "J. Bruce Fields" <bfields@fieldses.org>,
	Hugh Dickins <hugh@veritas.com>,
	David Safford <safford@watson.ibm.com>,
	linux-nfs@vger.kernel.org, Mimi Zohar <zohar@us.ibm.com>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762811AbZE0Xto@vger.kernel.org>
In-Reply-To: <1243431112-7388-1-git-send-email-zohar@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 27 May 2009, Mimi Zohar wrote:

> 
> This patch adds:
> - integrity (permission) checking for nfsd exported files in nfsd_permission().
> - a call to increment counts for files opened by nfsd.
> 
> This patch has been updated to return the nfs error types.
> 
> Signed-off-by: Mimi Zohar <zohar@us.ibm.com>


Applied to
git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/security-testing-2.6#next

-- 
James Morris
<jmorris@namei.org>
