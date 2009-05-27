From: Mimi Zohar <zohar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] integrity: nfsd imbalance bug fix
Date: Wed, 27 May 2009 17:26:13 -0400
Message-ID: <1243459573.3408.9.camel@dyn9002018117.watson.ibm.com>
References: <1243431112-7388-1-git-send-email-zohar@linux.vnet.ibm.com>
	 <20090527140915.26efc70b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, hooanon05@yahoo.co.jp,
	"J. Bruce Fields" <bfields@fieldses.org>,
	James Morris <jmorris@namei.org>,
	David Safford <safford@watson.ibm.com>,
	linux-nfs@vger.kernel.org, Mimi Zohar <zohar@us.ibm.com>,
	Hugh Dickins <hugh.dickins@tiscali.co.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758752AbZE0V0Y@vger.kernel.org>
In-Reply-To: <20090527140915.26efc70b.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-05-27 at 14:09 -0700, Andrew Morton wrote:

> I have a note here that Hugh had some significant issues with the
> previous version of this patch.
> 
> Were these problems addressed?  If so, how?
> 
> Thanks.

With some reservation, he acked "[PATCH 2/3] integrity: move
ima_counts_get", but I'm not aware of his having any problems with this
patch. 

This patch was updated based on a comment from J.Bruce Fields.

Mimi Zohar
