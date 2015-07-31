Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38149 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486AbbGaTdH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Jul 2015 15:33:07 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20150731175414.8708.69775.stgit@seurat.1015granger.net>
References: <20150731175414.8708.69775.stgit@seurat.1015granger.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsidmap: Enumerate kernel cache of ID mapping results
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 31 Jul 2015 20:33:03 +0100
Message-ID: <6788.1438371183@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever <chuck.lever@oracle.com> wrote:

> +	if ((fp = fopen(PROCKEYS, "r")) == NULL) {
> +		xlog_err("fopen(%s) failed: %m", PROCKEYS);
> +		return 1;
> +	}
> +
> +	rc = 1;
> +	while(fgets(buf, BUFSIZ, fp) != NULL) {
> +		unsigned int id;
> +
> +		if (strstr(buf, "keyring") == NULL)
> +			continue;
> +		if (strstr(buf, keyring) == NULL)
> +			continue;
> +		if (sscanf(buf, "%x %*s", &id) != 1)
> +			continue;
> +
> +		list_keys(keyring, (key_serial_t)id);
> +		rc = 0;
> +		break;
> +	}
> +

Did you want find_key_by_type_and_desc() in libkeyutils?

David
