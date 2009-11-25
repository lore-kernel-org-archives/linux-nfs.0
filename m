From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 3/5] s390: remove unused nfsd #includes
Date: Wed, 25 Nov 2009 09:38:23 +0100
Message-ID: <20091125093823.7b079905@mschwide.boeblingen.de.ibm.com>
References: <4B0C1EB7.50508@panasas.com>
	<4B0C1F98.4000204@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-parisc <linux-parisc@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>,
	linux-s390 <linux-s390@vger.kernel.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <4B0C1F98.4000204@panasas.com>
Sender: linux-parisc-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Nov 2009 20:02:00 +0200
Boaz Harrosh <bharrosh@panasas.com> wrote:

> Some unused includes removed.
> 
> This patch is in an effort to cleanup nfsd headers and move
> private definitions to source directory.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  arch/s390/kernel/compat_linux.c |    6 ------
>  arch/s390/kernel/compat_linux.h |    4 ----
>  2 files changed, 0 insertions(+), 10 deletions(-)
 
The patch is fine. I'll add it to the feature branch of git390 for the
next merge window. 

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

