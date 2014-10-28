Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50695 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727AbaJ1T3q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 15:29:46 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s9SJTk6H014166
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2014 15:29:46 -0400
Received: from smallhat.boston.devel.redhat.com (smallhat.boston.devel.redhat.com [10.19.60.65])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s9SJTjwh007618
	for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2014 15:29:45 -0400
Message-ID: <544FEEA9.9050009@RedHat.com>
Date: Tue, 28 Oct 2014 15:29:45 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsidmap.map: Add more global variables to the map.
References: <1414521607-8426-1-git-send-email-steved@redhat.com>
In-Reply-To: <1414521607-8426-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/28/2014 02:40 PM, Steve Dickson wrote:
> With the introduction of a symbol version map
> (commit 045d2e46d) all global variables need to
> be in the map for the plugins to load correctly
> 
> Fixes https://bugzilla.redhat.com/show_bug.cgi?id=1156484
> 
> Reported-by: Jeff Layton <jlayton@poochiereds.net>
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  nfsidmap.map | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/nfsidmap.map b/nfsidmap.map
> index 540835c..1e7cf7e 100644
> --- a/nfsidmap.map
> +++ b/nfsidmap.map
> @@ -16,6 +16,10 @@ global:
>  	nfs4_gss_princ_to_ids_ex;
>  	nfs4_gss_princ_to_grouplist_ex;
>  	nfs4_set_debug;
> +	idmap_verbosity;
> +	idmap_log_func;
> +	get_default_domain;
> +	get_local_realms;
>  local:
>  	*;
>  };
> 
