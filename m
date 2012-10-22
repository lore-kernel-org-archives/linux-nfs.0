Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58603 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753911Ab2JVNv0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Oct 2012 09:51:26 -0400
Message-ID: <50854F5C.9040709@RedHat.com>
Date: Mon, 22 Oct 2012 09:51:24 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/8] Junctions should inherit parent's export options
References: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
In-Reply-To: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/10/12 11:10, Chuck Lever wrote:
> Following suggestions by Steve and Bruce, I've at long last
> implemented a mechanism by which junctions inherit the export
> options of their parent exports.
> 
> While I was there, I took the opportunity to clean up the junction
> resolution logic.
> 
> ---
> 
> Chuck Lever (8):
>       mountd: Simplify "no junction support" case
>       mountd: Dynamically allocate exportent that represents junctions
>       mountd: Add exportent_release()
>       mountd: Junctions inherit parent export's options
>       mountd: Add lookup_export_parent()
>       mountd: Set e_fslocdata field directly
>       mountd: Use static buffer when constructing junction export options
>       mountd: Warn when a broken junction is encountered
> 
> 
>  support/export/export.c    |   19 ++--
>  support/include/exportfs.h |    1 
>  utils/mountd/cache.c       |  217 ++++++++++++++++++++++++++++++--------------
>  3 files changed, 162 insertions(+), 75 deletions(-)
> 
Committed....

steved.
