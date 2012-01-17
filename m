Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43345 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755455Ab2AQTkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 14:40:55 -0500
Date: Tue, 17 Jan 2012 14:40:54 -0500
To: Tigran Mkrtchyan <kofemann@googlemail.com>
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v6 2/9] nfsd41: handle current stateid in open and close
Message-ID: <20120117194054.GA16118@fieldses.org>
References: <1326644410-7482-1-git-send-email-tigran.mkrtchyan@desy.de>
 <1326644410-7482-3-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1326644410-7482-3-git-send-email-tigran.mkrtchyan@desy.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 15, 2012 at 05:20:03PM +0100, Tigran Mkrtchyan wrote:
> +static void
> +put_stateid(struct nfsd4_compound_state *cstate, stateid_t *stateid)
> +{
> +	if (cstate->minorversion)
> +		cstate->current_stateid = stateid;
> +}
...
> @@ -54,6 +54,7 @@ struct nfsd4_compound_state {
>  	size_t			iovlen;
>  	u32			minorversion;
>  	u32			status;
> +	const stateid_t	*current_stateid;
>  };

I'd be more comfortable with passing stateid's by value rather than by
reference.

Presumably you're only ever pointing into one of the argument or result
structures which are currently guaranteed to be around for as long as
the compound is processed.

But it'd seem safer not to have to worry about the lifetime of the
pointed-to data at all, and just copy the stateid--it's only 16 bytes.

--b.
