Return-Path: <SRS0=GU+o=44=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53E35C0044D
	for <linux-nfs@archiver.kernel.org>; Wed, 11 Mar 2020 19:19:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 445AB20691
	for <linux-nfs@archiver.kernel.org>; Wed, 11 Mar 2020 19:19:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731059AbgCKTTJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 11 Mar 2020 15:19:09 -0400
Received: from fieldses.org ([173.255.197.46]:48580 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730807AbgCKTTJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Mar 2020 15:19:09 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id C85DE1C19; Wed, 11 Mar 2020 15:19:08 -0400 (EDT)
Date:   Wed, 11 Mar 2020 15:19:08 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] doc: describe required python3 modules
Message-ID: <20200311191908.GA8918@fieldses.org>
References: <20200310162720.61835-1-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200310162720.61835-1-tigran.mkrtchyan@desy.de>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Applied, thanks!--b.

On Tue, Mar 10, 2020 at 05:27:20PM +0100, Tigran Mkrtchyan wrote:
> ---
>  README | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/README b/README
> index f9d7005..79cac62 100644
> --- a/README
> +++ b/README
> @@ -4,9 +4,9 @@ the 4.0 pynfs code was all moved into the nfs4.0 directory, but as time
>  passes we expect to merge the two code bases.
>  
>  Install dependent modules; on Fedora:
> -	yum install krb5-devel python-devel swig python-gssapi python-ply
> +	yum install krb5-devel python3-devel swig python3-gssapi python3-ply
>  on Debian:
> -	apt-get install libkrb5-dev python-dev swig python-pip
> +	apt-get install libkrb5-dev python3-dev swig python3-pip
>  	pip install ply gssapi
>  
>  You can prepare both for use with
> -- 
> 2.24.1
