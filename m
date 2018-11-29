Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A55FC43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 19:47:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6DFDD21019
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 19:47:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DFDD21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=RedHat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725905AbeK3Gxh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 01:53:37 -0500
Received: from mx1.redhat.com ([209.132.183.28]:63040 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725871AbeK3Gxh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 01:53:37 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4987930BCCF2
        for <linux-nfs@vger.kernel.org>; Thu, 29 Nov 2018 19:47:05 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id F1A8219497;
        Thu, 29 Nov 2018 19:47:04 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: Allow setting of commented out values in
 nfs.conf
To:     Justin Mitchell <jumitche@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1540480050.8177.2.camel@redhat.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <92dc60df-e956-5c85-08be-32fa1ad4efad@RedHat.com>
Date:   Thu, 29 Nov 2018 14:47:04 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <1540480050.8177.2.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 29 Nov 2018 19:47:05 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 10/25/18 11:07 AM, Justin Mitchell wrote:
> When using nfsconf tool to set values, allow it to uncomment a setting
> it finds in the relevant section if it would otherwise have had to create
> a new one.
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
Committed... Sorry it too so long.... 

steved.

> ---
>  support/nfs/conffile.c | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index 3845b94..713f81b 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -1830,6 +1830,8 @@ conf_write(const char *filename, const char *section, const char *arg,
>  
>  			/* this is the section we care about */
>  			if (where != NULL && is_section(where->text, section, arg)) {
> +				struct outbuffer *section_start = where;
> +
>  				/* is there an existing assignment */
>  				while ((where = TAILQ_NEXT(where, link)) != NULL) {
>  					if (is_tag(where->text, tag)) {
> @@ -1838,6 +1840,26 @@ conf_write(const char *filename, const char *section, const char *arg,
>  					}
>  				}
>  
> +				/* no active assignment, but is there a commented one */
> +				if (!found) {
> +					where = section_start;
> +					while ((where = TAILQ_NEXT(where, link)) != NULL) {
> +						if (is_comment(where->text)) {
> +							char *cline = where->text;
> +							while (isspace(*cline)) cline++;
> +
> +							if (*cline != '#') continue;
> +							cline++;
> +
> +							if (is_tag(cline, tag)) {
> +								found = true;
> +								break;
> +							}
> +						}
> +					}
> +				}
> +
> +				/* replace the located tag with an updated one */
>  				if (found) {
>  					struct outbuffer *prev = TAILQ_PREV(where, tailhead, link);
>  					bool again = false;
> 
