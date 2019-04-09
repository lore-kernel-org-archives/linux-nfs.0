Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3854C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 20:34:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1683F20830
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 20:34:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726635AbfDIUe2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 16:34:28 -0400
Received: from fieldses.org ([173.255.197.46]:38272 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726333AbfDIUe2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Apr 2019 16:34:28 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id CF7B71CEE; Tue,  9 Apr 2019 16:34:27 -0400 (EDT)
Date:   Tue, 9 Apr 2019 16:34:27 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Kenneth D'souza <kdsouza@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH]  nfs4_getfacl: Add new option -c/--omit-header to not
 display comment header.
Message-ID: <20190409203427.GC29099@fieldses.org>
References: <20190326135740.16558-1-kdsouza@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326135740.16558-1-kdsouza@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks, applying with some fixes:

On Tue, Mar 26, 2019 at 07:27:40PM +0530, Kenneth D'souza wrote:
> With this patch the filename will not be printed.
> 
>     $ nfs4_getfacl /test/
>     # file: /test/
>     A::OWNER@:rwaDxtTcCy
>     A::GROUP@:rwaDxtcy
>     A::EVERYONE@:rwaDxtcy
> 
>     $ nfs4_getfacl -c /test/
> 
>     A::OWNER@:rwaDxtTcCy
>     A::GROUP@:rwaDxtcy
>     A::EVERYONE@:rwaDxtcy

I don't see any reason for that blank line, I've removed it.

> @@ -115,7 +119,10 @@ static void print_acl_from_path(const char *fpath)
>  	struct nfs4_acl *acl;
>  	acl = nfs4_acl_for_path(fpath);
>  	if (acl != NULL) {
> +		if(ignore_comment == 0)
>  		printf("\n# file: %s\n", fpath);

This needs to be indented.

> +		else
> +			printf("\n");

I've removed the "else" clause.

And fixed a couple minor whitespace issues.

--b.

>  		nfs4_print_acl(stdout, acl);
>  		nfs4_free_acl(acl);
>  	}
> @@ -125,7 +132,7 @@ static void usage(int label)
>  {
>  	if (label)
>  		fprintf(stderr, "%s %s -- get NFSv4 file or directory access control lists.\n", execname, VERSION);
> -	fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n", execname);
> +	fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n  -c, --omit-header\tDo not display the comment header (Do not print filename)\n", execname);
>  }
>  
>  static void more_help()
> -- 
> 2.20.1
